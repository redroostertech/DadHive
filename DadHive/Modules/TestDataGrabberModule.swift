//
//  TestDataGrabber.swift
//  codewithmike
//
//  Created by Michael Westbrooks on 11/16/18.
//  Copyright © 2018 RedRooster Technologies Inc. All rights reserved.
//

import Foundation

class TestDataGrabberModule {
    static let shared = TestDataGrabberModule()
    private init() { }
    
    //  MARK:- Methods for Local Data
    func getJSONResourceData(fileName: String) -> [String: Any]? {
        let url = Bundle.main.url(forResource: fileName,
                                  withExtension: "json")!
        do {
            let jsonData = try Data(contentsOf: url)
            let json = try JSONSerialization.jsonObject(with: jsonData) as! [String:Any]
            return json
        }
        catch {
            print(error)
            return nil
        }
    }
    
    //  MARK:- Methods for Remote Data
    func getJSONResourceData(path: String) -> [String:Any]? {
        var object = [String:Any]()
        getJSONResourceData(path: path) {
            data in
            if let data = data {
                object = data
            }
        }
        return object
    }
    
    private func getJSONResourceData(path: String, completion: @escaping(_ data: [String: Any]?) -> Void) {
        APIRepository.shared.performRequest(path: path) {
            (json, error) in
            if let error = error {
                print(error.localizedDescription)
                completion(nil)
            } else {
                guard let json = json as? [String:Any] else {
                    print(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : DadHiveError.jsonResponseError.rawValue]))
                    completion(nil)
                    return
                }
                completion(json)
            }
        }
    }
}
