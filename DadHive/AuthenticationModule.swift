import Foundation

class AuthenticationModule {
    private var apiRepository: APIRepository!
    private var errorJsonResponse: DadHiveError {
        return DadHiveError.jsonResponseError
    }
    
    init() {
        self.apiRepository = APIRepository()
    }
    
    func loginUsing(credentials: [String: Any]?, completion: @escaping ([String: Any]?, Error?) -> Void) {
        guard let credentials = credentials else {
            return completion(nil, generateError(fromError: errorJsonResponse))
        }
        self.apiRepository.performRequest(path: "auth/login", method: .post, parameters: credentials) { (results, error) in
            guard error == nil else {
                return completion(nil, error!)
            }
            guard let resultsDict = results as? [String: Any], let results = resultsDict["data"] as? [String: Any] else {
                return completion(nil, self.generateError(fromError: self.errorJsonResponse))
            }
            completion(results, nil)
        }
    }
    
    func registerUsing(credentials: [String: Any]?, completion: @escaping (User?, Error?) -> Void) {
        guard let credentials = credentials else {
            return completion(nil, generateError(fromError: errorJsonResponse))
        }
        apiRepository.performRequest(path: "auth/login", method: .post, parameters: credentials) { (results, error) in
            guard error == nil else {
                return completion(nil, error!)
            }
            guard let resultsDict = results as? [String: Any], let results = resultsDict["data"] as? [String: Any], let user: User = User(JSON: results) else {
                return completion(nil, self.generateError(fromError: self.errorJsonResponse))
            }
            completion(user, nil)
        }
    }
}

extension AuthenticationModule {
    fileprivate func generateError(fromError error: DadHiveError) -> NSError {
        return NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : error.rawValue])
    }
}
