import Foundation

class AuthenticationModule {
    private var apiRepository: APIRepository!
    init() {
        self.apiRepository = APIRepository()
    }
    
    func loginUsing(credentials: [String: Any]?,
                    completion: @escaping ([String: Any]?, Error?) -> Void)
    {
        if let credentials = credentials {
            self.apiRepository.performRequest(path: "auth/login",
                                              method: .post,
                                              parameters: credentials)
            {
                (results, error) in
                
                if let error = error {
                    completion(nil, error)
                } else {
                    guard
                        let resultsDict = results as? [String: Any],
                        let results = resultsDict["data"] as? [String: Any] else
                    {
                        return completion(nil, NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : DadHiveError.jsonResponseError.rawValue]))
                    }
                    completion(results, nil)
                }
            }
        } else {
            completion(nil, NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : DadHiveError.jsonResponseError.rawValue]))
        }
    }
    
    func registerUsing(credentials: [String: Any]?,
                       completion: @escaping (User?, Error?) -> Void)
    {
        if let credentials = credentials {
            self.apiRepository.performRequest(path: "auth/login",
                                              method: .post,
                                              parameters: credentials)
            {
                (results, error) in
                
                if let error = error {
                    completion(nil, error)
                } else {
                    guard
                        let resultsDict = results as? [String: Any],
                        let results = resultsDict["data"] as? [String: Any],
                        let user: User = User(JSON: results) else
                    {
                        return completion(nil, NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : DadHiveError.jsonResponseError.rawValue]))
                    }
                    completion(user, nil)
                }
            }
        } else {
            completion(nil, NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : DadHiveError.jsonResponseError.rawValue]))
        }
    }

}

