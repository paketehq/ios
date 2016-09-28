//
//  PackagesViewModel.swift
//  Pakete
//
//  Created by Royce Albert Dy on 13/03/2016.
//  Copyright © 2016 Pakete. All rights reserved.
//

import Foundation
import RealmSwift
import Alamofire
import RxSwift

typealias ObservablePackage = Variable<Package>

class PackagesViewModel {

    let packages: Variable<[ObservablePackage]> = Variable([])
    let couriers: Variable<[Courier]> = Variable([])
    var showPackage: PublishSubject<Package> = PublishSubject()
    fileprivate let disposeBag = DisposeBag()

    init() {
        self.fetchCouriers()
            .subscribe()
            .addDisposableTo(self.disposeBag)

        // fetch local cache
        self.reloadPackagesLocalData()
        self.reloadCouriersLocalData()
        // update packages
        self.refreshPackages()
    }

    func fetchCouriers() -> Observable<[Courier]> {
        return Observable.create({ (observer) -> Disposable in
            let endpoint = Pakete.Router.couriers
            let request = Alamofire.request(endpoint).responseSwiftyJSON { (request, response, json, error) -> Void in
                if let error = error {
                    print(error)
                    observer.onError(error)
                } else {
                    // parse json
                    var couriers = [Courier]()
                    for courierJSON in json.arrayValue {
                        let courier = Courier(json: courierJSON)
                        couriers.append(courier)
                    }
                    self.saveCouriers(couriers)
                    self.reloadCouriersLocalData()
                    observer.onNext(couriers)
                    observer.onCompleted()
                }
            }

            return Disposables.create {
                request.cancel()
            }
        })
    }

    func refreshPackages() {
        let pendingPackages = self.packages.value.filter({ $0.value.completed == false && $0.value.updating == false })
        pendingPackages.forEach { (package) -> () in
            // mark as updating
            let updatingPackage = package.value
            updatingPackage.updating = true
            package.value = updatingPackage
            // start tracking package
            self.trackPackage(package)
                .shareReplay(1)
                .subscribe(onNext: { (updatedPackage) in
                    // trigger to update package
                    package.value = updatedPackage.value
                }, onError: { (error) in
                    package.value.updating = false
                    if let behaviorSubject = package.asObservable() as? BehaviorSubject {
                        // just send the same value so it will trigger to refresh
                        behaviorSubject.onNext(package.value)
                    }
                })
                .addDisposableTo(self.disposeBag)
        }
    }

    func trackPackage(_ package: ObservablePackage) -> Observable<ObservablePackage> {
        return Observable.create({ (observer) -> Disposable in
            let endpoint = Pakete.Router.trackPackage(courier: package.value.courier, trackingNumber: package.value.trackingNumber)
            let request = Alamofire.request(endpoint).responseSwiftyJSON { (request, response, json, error) -> Void in
                if let error = error {
                    print(error)
                    observer.onError(error)
                } else {
                    let aPackage = Package(name: package.value.name, courier: package.value.courier, json: json)
                    self.savePackage(aPackage)

                    observer.onNext(ObservablePackage(aPackage))
                    observer.onCompleted()
                }
            }

            return Disposables.create {
                request.cancel()
            }
        })
    }

    func addPackage(_ package: ObservablePackage) {
        guard self.packages.value.index(where: { $0.value == package.value }) != nil else {
            // insert at the top of the array
            self.packages.value.insert(package, at: 0)
            return
        }
    }

    func archivePackage(_ package: ObservablePackage) {
        let updatedPackage = package.value
        do {
            let realm = try Realm()
            try realm.write {
                updatedPackage.archived = true
            }
            // trigger to update
            package.value = updatedPackage
            // remove from the packages
            if let index = self.packages.value.index(where: { $0.value == updatedPackage }) {
                self.packages.value.remove(at: index)
            }
        } catch {
            print("There was a problem archiving the package")
        }
    }

    func archivePackageIndexPath(_ indexPath: IndexPath) {
        let package = self.packages.value[indexPath.row]
        self.packages.value.remove(at: indexPath.row)
        self.archivePackage(package)
    }

    func packageWithTrackingNumber(_ trackingNumber: String, courier: Courier) -> Package? {
        do {
            let realm = try Realm()
            return realm.objects(Package.self).filter({ $0.trackingNumber == trackingNumber && $0.courier == courier }).first
        } catch {
            return nil
        }
    }

    func updatePackageName(_ name: String, package: ObservablePackage) {
        let updatedPackage = package.value
        do {
            let realm = try Realm()
            try realm.write({ () -> Void in
                updatedPackage.name = name
            })
            // trigger to update
            package.value = updatedPackage
        } catch {
            print("There was a problem updating the package name")
        }
    }

    func unarchivePackage(_ package: Package) {
        do {
            let realm = try Realm()
            try realm.write({ () -> Void in
                package.archived = false
            })
            // show package details
            self.showPackage.onNext(package)

            // insert at the top of the array
            let observablePackage = ObservablePackage(package)
            self.packages.value.insert(observablePackage, at: 0)
        } catch {
            print("There was a problem unarchiving the package")
        }
    }

    // MARK: - Settings
    func packagesSortBy() -> PackagesSortByType {
        let userDefaults = UserDefaults.standard
        return PackagesSortByType(rawValue: userDefaults.integer(forKey: Constants.Defaults.SortByKey)) ?? .lastUpdated
    }

    func packagesGroupByDelivered() -> Bool {
        let userDefaults = UserDefaults.standard
        guard let groupByDelivered = userDefaults.object(forKey: Constants.Defaults.GroupByDeliveredKey) else {
            // set group by delivered to on
            userDefaults.set(true, forKey: Constants.Defaults.GroupByDeliveredKey)
            userDefaults.synchronize()
            return true
        }
        return (groupByDelivered as AnyObject).boolValue
    }

    func sortBy(_ sort: PackagesSortByType) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(sort.rawValue, forKey: Constants.Defaults.SortByKey)
        userDefaults.synchronize()
        // reload packages
        self.reloadPackagesLocalData()
    }

    func groupByDelivered(_ group: Bool) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(group, forKey: Constants.Defaults.GroupByDeliveredKey)
        userDefaults.synchronize()
        // reload packages
        self.reloadPackagesLocalData()
    }
}

extension PackagesViewModel {
    fileprivate func reloadPackagesLocalData() {
        do {
            let realm = try Realm()
            var activePackages = realm.objects(Package.self).filter("archived = %@", false).toArray()
            // sort packages
            switch self.packagesSortBy() {
            case .lastUpdated:
                // we need to pick the latest track history date
                activePackages = activePackages.sorted(by: { (package1, package2) in
                    if let package1LatestTrackHistory = package1.latestTrackHistory(),
                        let package2LatestTrackHistory = package2.latestTrackHistory() {
                        return package1LatestTrackHistory.date.timeIntervalSinceNow > package2LatestTrackHistory.date.timeIntervalSinceNow
                    }
                    return true
                })
            case .dateAdded:
                activePackages.sort(by: { $0.createdAt.compare($1.createdAt as Date) == .orderedDescending })
            case .name:
                activePackages.sort(by: { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending })
            }
            // check if group by delivered
            if self.packagesGroupByDelivered() {
                // completed packages
                let completedPackages = activePackages.filter({ $0.completed })
                // in transit packages
                let inTransitPackages = activePackages.filter({ $0.completed == false })
                // merge so completed packages will be at the bottom
                let combinedPackages = [inTransitPackages, completedPackages].flatMap { $0 }
                // set to packages
                self.packages.value = combinedPackages.map { ObservablePackage($0) }
            } else {
                self.packages.value = activePackages.map { ObservablePackage($0) }
            }
        } catch {
            print("problem reloading packages local data")
        }
    }

    fileprivate func reloadCouriersLocalData() {
        do {
            let realm = try Realm()
            self.couriers.value = realm.objects(Courier.self).sorted(byProperty: "name").toArray()
        } catch {
            print("problem reloading couriers local data")
        }
    }

    fileprivate func savePackage(_ package: Package) {
        do {
            let realm = try Realm()
            try realm.write { () -> Void in
                realm.add(package, update: true)
            }
        } catch {
            print("problem saving package")
        }
    }

    fileprivate func saveCouriers(_ couriers: [Courier]) {
        // save and update
        do {
            let realm = try Realm()
            try realm.write { () -> Void in
                realm.add(couriers, update: true)
            }
        } catch {
            print("problem saving couriers")
        }
    }
}
