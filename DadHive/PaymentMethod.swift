import Foundation
import ObjectMapper
import RRoostSDK

class PaymentMethod: Mappable, CustomStringConvertible {
    
    private var cusID: Any?
    private var last4: Any?
    private var expDate: Any?

    required init?(map: Map) { }

    func mapping(map: Map) {
        cusID <- map["cusID"]
        last4 <- map["last4"]
        expDate <- map["expDate"]
    }

    func getCusID() -> String {
        guard let cusID = self.cusID as? String else {
            return ""
        }
        return cusID
    }

    func getLast4() -> String {
        guard let last4 = self.last4 as? String else {
            return ""
        }
        return last4
    }

    func getExpDate() -> String {
        guard let expDate = self.expDate as? String else {
            return ""
        }
        return expDate
    }

    func getPaymentMethod() -> String {
        guard let lastfour = self.last4, let expiration = self.expDate else {
            return "No payment method has been set."
        }
        return "\(expiration) | \(lastfour)"
    }

}
