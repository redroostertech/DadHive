 //
//  APIService.swift
//  PopViewers
//
//  Created by Michael Westbrooks II on 5/13/18.
//  Copyright © 2018 MVPGurus. All rights reserved.
//

import Foundation
import Alamofire

class APIRepository {
    
    static let shared = APIRepository()
    private init() { }

    func performRequest(path: String = "",
                        method: HTTPMethod = .get,
                        parameters: Parameters = [:],
                        apiKey api: String = "",
                        andAccessKey access: String = "",
                        headers: HTTPHeaders = [:],
                        completion: @escaping (Any?, Error?) -> Void)
    {
        let urlString = path
        let method = method
        let parameters = parameters
        let apiKey = api
        let accessKey = access
        
        var headers = [
            "Accept": "application/json",
            "wsc-api-key": apiKey,
            "wsc-access-key": accessKey
        ]
        
        for key in headers.keys {
            headers[key] = headers[key]
        }
        
        buildRequest(urlString: urlString,
                     method: method,
                     parameters: parameters,
                     headers: headers) { (results, error) in

                        completion(results, error)
        }
    }
    
    private func buildRequest(urlString: String,
                              method: HTTPMethod,
                              parameters: Parameters,
                              headers: HTTPHeaders,
                              completion: @escaping (Any?, Error?) -> Void)
    {
        Alamofire.request(urlString,
                          method: method,
                          parameters: parameters,
                          encoding: URLEncoding.httpBody,
                          headers: headers)
            .responseJSON { response in
                switch response.result {
                case .success:
                    if let json = response.result.value {
                        completion(json,
                                   nil)
                    } else {
                        completion(nil,
                                   NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : DadHiveError.jsonResponseError.rawValue]))
                    }
                case .failure(let error):
                    print(error)
                    completion(nil,
                               error)
                }
        }
    }
    
    func getToken(paramsForTokenRetrieval params: [String:Any], completion:
        @escaping (_ result: [String:String]?, _ error: Error?) -> Void) {

        guard let requestBodyData = try? JSONSerialization.data(withJSONObject: params,
                                                                options: []) else {
            completion(nil,
                       NSError(domain: "There was an error.",
                               code: 500,
                               userInfo:nil))
            return
        }

        let urlString: String = Api.Endpoint.authToken

        if let urlFromString = URL(string: urlString) {

            var urlRequest: URLRequest = URLRequest(url: urlFromString)
            urlRequest.httpMethod = "POST"
            urlRequest.addValue("application/json",
                                forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = requestBodyData
            let dataTask = URLSession.shared.dataTask(with: urlRequest,
                                                      completionHandler: { (data, response, error) in
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
                    let urlString: String = Api.Endpoint.retrieveKeys
                    if let urlFromString = URL(string: urlString) {
                        var urlRequest: URLRequest = URLRequest(url: urlFromString)
                        urlRequest.httpMethod = "GET"
                        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
                        urlRequest.addValue(token, forHTTPHeaderField: "x-access-token")
                        let dataTask = URLSession.shared.dataTask(with: urlRequest, completionHandler: {
                            (data, response, error) in
                            guard error == nil else {
                                completion(nil, NSError(domain: "There was an error. \(String(describing: error?.localizedDescription))", code: 500, userInfo:nil))
                                return
                            }
                            print("Retrieve Key fetch is running on = \(Thread.isMainThread ? "Main Thread" : "Background Thread")")
                            guard let responseData = data else {
                                completion(nil, NSError(domain:"There was no data", code: 500, userInfo:nil))
                                return
                            }
                            do {
                                guard let rawJSONArray = try JSONSerialization.jsonObject(with: responseData, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary else {
                                    completion(nil, NSError(domain:"Error with JSON", code: 500, userInfo:nil))
                                    return
                                }
                                guard let json = rawJSONArray["data"] as? NSDictionary else {
                                    completion(nil, NSError(domain:"Error with JSON", code: 500, userInfo:nil))
                                    return
                                }
                                completion(json as? [String : String], nil)
                            } catch {
                                completion(nil, NSError(domain:"Error converting Data", code: 500, userInfo:nil))
                            }
                        })
                        dataTask.resume()
                    } else {
                        completion(nil, NSError(domain:"Can't create URL", code: 500, userInfo:nil))
                    }
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
