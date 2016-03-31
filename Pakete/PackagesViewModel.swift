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
    private var disposeBag = DisposeBag()
    
    init() {
        self.fetchCouriers()
        // fetch local cache
        self.reloadPackagesLocalData()
        self.reloadCouriersLocalData()
        // update packages
        self.refreshPackages()
    }
    
    func fetchCouriers() {
        let endpoint = Pakete.Router.Couriers
        Alamofire.request(endpoint).responseSwiftyJSON { (request, response, json, error) -> Void in
            if let error = error {
                print(error)
            } else {
                // parse json
                var couriers = [Courier]()
                for courierJSON in json.arrayValue {
                    let courier = Courier(json: courierJSON)
                    couriers.append(courier)
                }
                self.saveCouriers(couriers)
                self.reloadCouriersLocalData()
            }
        }
    }
    
    func refreshPackages() {
        let pendingPackages = self.packages.value.filter({ $0.value.completed == false })
        pendingPackages.forEach { (package) -> () in
            // mark as updating
            package.value.updating = true

            self.trackPackage(package)
                .subscribeNext({ (package) -> Void in
                    // check for the package index first
                    if let index = self.packages.value.indexOf({ $0.value == package.value }) {
                        self.packages.value[index].value = package.value
                    }
                })
                .addDisposableTo(self.disposeBag)
        }
    }
    
    // TODO: - Refactor because redundant function
    func trackPackage(package: ObservablePackage) -> Observable<ObservablePackage> {
        return Observable.create({ (observer) -> Disposable in
            let endpoint = Pakete.Router.TrackPackage(package.value.courier.code, package.value.trackingNumber)
            let request = Alamofire.request(endpoint).responseSwiftyJSON { (request, response, json, error) -> Void in
                if let error = error {
                    observer.onError(error)
                } else {
                    let package = Package(name: package.value.name, courier: package.value.courier!, json: json)
                    self.savePackage(package)
                    observer.onNext(Variable(package))
                    observer.onCompleted()
                }
            }
            
            return AnonymousDisposable {
                request.cancel()
            }
        })
    }
    
    func addPackage(trackingNumber: String, courier: Courier, name: String) -> Observable<ObservablePackage> {
        return Observable.create({ (observer) -> Disposable in
            let endpoint = Pakete.Router.TrackPackage(courier.code, trackingNumber)
            let request = Alamofire.request(endpoint).responseSwiftyJSON { (request, response, json, error) -> Void in
                if let error = error {
                    print(error)
                    observer.onError(error)
                } else {
                    let package = Package(name: name, courier: courier, json: json)
                    self.savePackage(package)
                    
                    // insert at the top of the array
                    let observablePackage = Variable(package)
                    self.packages.value.insert(observablePackage, atIndex: 0)
                    // show newly added package
                    self.showPackage.onNext(package)
                    
                    observer.onNext(observablePackage)
                    observer.onCompleted()
                }
            }
            
            return AnonymousDisposable {
                request.cancel()
            }
        })
    }
    
    func archivePackageIndexPath(indexPath: NSIndexPath) {
        let package = self.packages.value[indexPath.row].value
        self.packages.value.removeAtIndex(indexPath.row)
        
        let realm = try! Realm()
        try! realm.write { () -> Void in
            package.archived = true
        }
    }
        
    func packageWithTrackingNumber(trackingNumber: String, courier: Courier) -> Package? {
        let realm = try! Realm()
        return realm.objects(Package).filter({ $0.trackingNumber == trackingNumber && $0.courier == courier }).first
    }
    
    func unarchivePackage(package: Package) {
        let realm = try! Realm()
        try! realm.write({ () -> Void in
            package.archived = false
        })
        // show package details
        self.showPackage.onNext(package)

        // insert at the top of the array
        let observablePackage = Variable(package)
        self.packages.value.insert(observablePackage, atIndex: 0)
    }
    
}

extension PackagesViewModel {
    private func reloadPackagesLocalData() {
        let realm = try! Realm()
        let activePackages = realm.objects(Package).filter("archived = %@", false).sorted("createdAt", ascending: false).toObservableArray()
        // completed packages
        let completedPackages = activePackages.filter({ $0.value.completed })
        // in transit packages
        let inTransitPackages = activePackages.filter({ $0.value.completed == false })
        // merge so completed packages will be at the bottom
        self.packages.value = [inTransitPackages, completedPackages].flatMap { $0 }
    }
    
    private func reloadCouriersLocalData() {
        let realm = try! Realm()
        self.couriers.value = realm.objects(Courier).sorted("name").toArray()
    }
    
    private func savePackage(package: Package) {
        let realm = try! Realm()
        try! realm.write { () -> Void in
            realm.add(package, update: true)
        }
    }
    
    private func saveCouriers(couriers: [Courier]) {
        // save and update
        let realm = try! Realm()
        try! realm.write { () -> Void in
            realm.add(couriers, update: true)
        }
    }
}