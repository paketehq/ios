//
//  API.swift
//  Pakete
//
//  Created by Royce Albert Dy on 13/03/2016.
//  Copyright © 2016 Pakete. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

let defaultManager: Alamofire.Manager = {
    let serverTrustPolicies: [String: ServerTrustPolicy] = [
        "localhost:5000": .DisableEvaluation
    ]
    
    let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
    configuration.HTTPAdditionalHeaders = Alamofire.Manager.defaultHTTPHeaders
    
    return Alamofire.Manager(
        configuration: configuration,
        serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies)
    )
}()

struct Pakete {
    enum Router: URLRequestConvertible {
        static let baseURLString = "https://agile-forest-88999.herokuapp.com/v1"
//        static let baseURLString = "http://192.168.0.115:5000/v1"

        case TrackPackage(String, String)
        case Couriers

        var method: Alamofire.Method {
            return .GET
        }
        
        var path: String {
            switch self {
            case .TrackPackage:
                return "/track"
            case .Couriers:
                return "/couriers"
            }
        }
        
        // MARK: URLRequestConvertible
        var URLRequest: NSMutableURLRequest {
            let parameters: [String: AnyObject] = {
                switch self {
                case .TrackPackage(let courier, let trackingNumber):
                    return ["courier": courier, "tracking_number": trackingNumber]

                default:
                    return [:]
                }
            }()
            
            let URL = NSURL(string: Router.baseURLString)!
            let URLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(self.path))
            URLRequest.HTTPMethod = method.rawValue
            URLRequest.setValue("compress, gzip", forHTTPHeaderField: "Accept-Encoding")
            URLRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            URLRequest.setValue(Token().tokenString(), forHTTPHeaderField: "Authorization")
            let encoding = Alamofire.ParameterEncoding.URL
            
            return encoding.encode(URLRequest, parameters: parameters).0
        }
    }
}

extension Request {
    public func responseSwiftyJSON(completionHandler: (request: NSURLRequest, response: NSHTTPURLResponse?, json: SwiftyJSON.JSON, error: NSError?) -> Void) -> Self {
//        BigBrother.Manager.sharedInstance.incrementActivityCount()
        
        return response(queue: nil, responseSerializer: Request.JSONResponseSerializer(options: .AllowFragments), completionHandler: { (response) -> Void in
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
//                BigBrother.Manager.sharedInstance.decrementActivityCount()
                var responseJSON = JSON.null
                var responseError: NSError?
                
                switch response.result {
                case .Success(let value):
                    if let httpURLResponse = response.response {
                        responseJSON = SwiftyJSON.JSON(value)
                        // if not 200 then it's a problem
                        if httpURLResponse.statusCode != 200 {
                            responseError = NSError(domain: response.request!.URLString, code: httpURLResponse.statusCode, userInfo: [NSLocalizedFailureReasonErrorKey: responseJSON["message"].stringValue])
                        }
                    }
                case .Failure(let error):
                    responseError = error
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    completionHandler(request: response.request!, response: response.response, json: responseJSON, error: responseError)
                })
            })
        })
    }
}