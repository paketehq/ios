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

struct Pakete {
    enum Router: URLRequestConvertible {
        static let baseURLString = "https://pakete-api-staging.herokuapp.com/v1"

        case trackPackage(courier: Courier, trackingNumber: String)
        case couriers

        var method: HTTPMethod {
            return .get
        }

        var path: String {
            switch self {
            case .trackPackage:
                return "/track"
            case .couriers:
                return "/couriers"
            }
        }

        // MARK: URLRequestConvertible
        func asURLRequest() throws -> URLRequest {
            let result: (path: String, parameters: Parameters) = {
                switch self {
                case .trackPackage(let courier, let trackingNumber):
                    return ("/track", ["courier": courier.code, "tracking_number": trackingNumber])
                case .couriers:
                    return ("/couriers", [:])
                }
            }()

            let url = try Router.baseURLString.asURL()
            var urlRequest = URLRequest(url: url.appendingPathComponent(result.path))
            urlRequest.httpMethod = method.rawValue
            urlRequest.setValue("compress, gzip", forHTTPHeaderField: "Accept-Encoding")
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.setValue(Token().tokenString(), forHTTPHeaderField: "pakete-api-key")

            return try URLEncoding.default.encode(urlRequest, with: result.parameters)
        }
    }
}

extension DataRequest {
    public func responseSwiftyJSON(_ completionHandler: @escaping (_ request: URLRequest, _ response: HTTPURLResponse?, _ json: SwiftyJSON.JSON, _ error: NSError?) -> Void) -> Self {

        return response(queue: nil, responseSerializer: DataRequest.jsonResponseSerializer(options: .allowFragments), completionHandler: { (response) -> Void in
            DispatchQueue.global(qos: .default).async(execute: {
                var responseJSON = JSON.null
                var responseError: NSError?

                if let originalRequest = response.request {
                    switch response.result {
                    case .success(let value):
                        if let httpURLResponse = response.response {
                            responseJSON = SwiftyJSON.JSON(value)
                            // if not 200 then it's a problem
                            if httpURLResponse.statusCode != 200 {
                                responseError = NSError(domain: originalRequest.url?.absoluteString ?? "", code: httpURLResponse.statusCode, userInfo: [NSLocalizedFailureReasonErrorKey: responseJSON["message"].stringValue])
                            }
                        }
                    case .failure(let error):
                        responseError = error as NSError
                    }

                    DispatchQueue.main.async(execute: {
                        completionHandler(originalRequest, response.response, responseJSON, responseError)
                    })
                } else {
                    fatalError("original request is nil")
                }
            })
        })
    }
}
