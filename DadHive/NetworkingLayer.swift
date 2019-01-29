//
//  NetworkingLayer.swift
//  DadHive
//
//  Created by Michael Westbrooks II on 11/23/17.
//  Copyright © 2017 RedRooster Technologies Inc. All rights reserved.
//

import Foundation

class NetworkingLayer {
    var url : String!
    
    init(httpUrl: String) {
        self.url = httpUrl
    }
    
    func registration(paramsForTokenRetrieval params: [String:Any], completion:
        @escaping (_ result: [String:String]?, _ error: Error?) -> Void) {
        guard let requestBodyData = try? JSONSerialization.data(withJSONObject: params, options: []) else {
            completion(nil, NSError(domain: "There was an error.", code: 500, userInfo:nil))
            return
        }
        let urlString: String = self.url
        print(urlString)
        
        if let urlFromString = URL(string: urlString) {
            var urlRequest: URLRequest = URLRequest(url: urlFromString)
            urlRequest.httpMethod = "POST"
            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = requestBodyData
            let dataTask = URLSession.shared.dataTask(with: urlRequest, completionHandler: {
                (data, response, error) in
                guard error == nil else {
                    completion(nil, NSError(domain: "There was an error. \(String(describing: error?.localizedDescription))", code: 500, userInfo:nil))
                    return
                }
                print("Token fetch is running on = \(Thread.isMainThread ? "Main Thread" : "Background Thread")")
                guard let responseData = data else {
                    completion(nil, NSError(domain: "No Data", code: 500, userInfo:nil))
                    return
                }
                do {
                    guard let rawJSONArray = try JSONSerialization.jsonObject(with: responseData, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary else {
                        completion(nil, NSError(domain: "Error with JSON", code: 500, userInfo:nil))
                        return
                    }
                    guard let status = rawJSONArray["response"] as? Int, status == 200 else {
                        completion(nil, NSError(domain: "Error with connection", code: 500, userInfo:nil))
                        return
                    }
                    guard let json = rawJSONArray["data"] as? NSDictionary else {
                        completion(nil, NSError(domain: "Error with JSON", code: 500, userInfo:nil))
                        return
                    }
                    guard let token = json["auth_token"] as? String else {
                        completion(nil, NSError(domain: "Error getting token string", code: 500, userInfo:nil))
                        return
                    }
                    completion(json as! [String : String], nil)
                } catch {
                    completion(nil, NSError(domain:"Error converting Data", code: 500, userInfo:nil))
                }
            })
            dataTask.resume()
        } else {
            completion(nil, NSError(domain:"Can't create URL", code: 500, userInfo:nil))
        }
    }

    func query(paramsForTokenRetrieval params: [String:Any], completion:
        @escaping (_ result: NSDictionary?, _ error: Error?) -> Void) {
        guard let requestBodyData = try? JSONSerialization.data(withJSONObject: params, options: []) else {
            completion(nil, NSError(domain: "There was an error.", code: 500, userInfo:nil))
            return
        }
        let urlString: String = self.url
        print(urlString)
        
        if let urlFromString = URL(string: urlString) {
            var urlRequest: URLRequest = URLRequest(url: urlFromString)
            urlRequest.httpMethod = "POST"
            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = requestBodyData
            let dataTask = URLSession.shared.dataTask(with: urlRequest, completionHandler: {
                (data, response, error) in
                guard error == nil else {
                    completion(nil, NSError(domain: "There was an error. \(String(describing: error?.localizedDescription))", code: 500, userInfo:nil))
                    return
                }
                print("Token fetch is running on = \(Thread.isMainThread ? "Main Thread" : "Background Thread")")
                guard let responseData = data else {
                    completion(nil, NSError(domain: "No Data", code: 500, userInfo:nil))
                    return
                }
                do {
                    guard let rawJSONArray = try JSONSerialization.jsonObject(with: responseData, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary else {
                        completion(nil, NSError(domain: "Error with JSON", code: 500, userInfo:nil))
                        return
                    }
                    guard let status = rawJSONArray["response"] as? Int, status == 200 else {
                        completion(nil, NSError(domain: "Error with connection", code: 500, userInfo:nil))
                        return
                    }
                    guard let json = rawJSONArray["data"] as? NSDictionary else {
                        completion(nil, NSError(domain: "Error with JSON", code: 500, userInfo:nil))
                        return
                    }
                    
                    completion(json, nil)
                } catch {
                    completion(nil, NSError(domain:"Error converting Data", code: 500, userInfo:nil))
                }
            })
            dataTask.resume()
        } else {
            completion(nil, NSError(domain:"Can't create URL", code: 500, userInfo:nil))
        }
    }

}
