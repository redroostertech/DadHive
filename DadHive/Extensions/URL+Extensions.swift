import Foundation

extension NSURL {
    
    var baseDomain: String? {
        return host?.components(separatedBy: ".").suffix(2).joined(separator: ".")
    }
}
