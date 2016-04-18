//
//  PackagesTests.swift
//  Pakete
//
//  Created by Royce Albert Dy on 18/04/2016.
//  Copyright © 2016 Pakete. All rights reserved.
//

import XCTest
import RealmSwift
import Mockingjay
import RxSwift
import NSObject_Rx
@testable import Pakete

class PackagesTests: XCTestCase {
    
    let packagesViewModel = PackagesViewModel()

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = self.name
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCouriersIsNotEmpty() {
        // stub endpoint
        let endpoint = Pakete.Router.Couriers
        self.stubResponseForEndpoint(endpoint, stubFileName: "Couriers")
        
        packagesViewModel.fetchCouriers()
            .subscribeNext { (couriers) in
                XCTAssertNotEqual(couriers.count, 0)
            }
        .addDisposableTo(rx_disposeBag)
    }
    
    func testTrackLBCPackage() {
        let courier = Courier()
        courier.code = "lbc"
        let package = Package(name: "LBC Package", trackingNumber: "123456789012", courier: courier)
        
        // stub endpoint
        let endpoint = Pakete.Router.TrackPackage(courier.code, package.trackingNumber)
        self.stubResponseForEndpoint(endpoint, stubFileName: "LBCPackage")
        
        self.packagesViewModel.trackPackage(ObservablePackage(package))
            .subscribeNext { (package) in
                XCTAssertNotNil(package.value)
                XCTAssertNotEqual(package.value.trackHistory.count, 0)
            }
        .addDisposableTo(rx_disposeBag)
    }

}

extension PackagesTests {
    func stubResponseForEndpoint(endpoint: Pakete.Router, stubFileName: String) {
        let stubbedResponse = self.stubbedResponseFor(stubFileName)
        
        var httpMethod: Mockingjay.HTTPMethod!
        switch endpoint.method {
        case .GET:
            httpMethod = .GET
        case .POST:
            httpMethod = .POST
        case .PUT:
            httpMethod = .PUT
        case .DELETE:
            httpMethod = .DELETE
        default: ()
        }
        self.stub(http(httpMethod, uri: endpoint.URLRequest.URLString), builder: jsonData(stubbedResponse))
    }
    
    private func stubbedResponseFor(filename: String) -> NSData! {
        @objc class TestClass: NSObject { }
        
        let bundle = NSBundle(forClass: TestClass.self)
        let path = bundle.pathForResource(filename, ofType: "json")
        return NSData(contentsOfFile: path!)
    }
}
