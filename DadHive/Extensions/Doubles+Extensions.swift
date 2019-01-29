//
//  Doubles+Extensions.swift
//  test
//
//  Created by Michael Westbrooks on 10/13/18.
//  Copyright © 2018 RedRooster Technologies Inc. All rights reserved.
//

import Foundation

extension Double {
    func cleanValue(maxDecimal: Int = 2, minDecimal: Int? = nil, withCommas: Bool = true) -> String {
        
        let inputNumber = self
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        numberFormatter.maximumFractionDigits = maxDecimal
        if minDecimal != nil {
            numberFormatter.minimumFractionDigits = minDecimal!
            if minDecimal! > maxDecimal {
                numberFormatter.maximumFractionDigits = minDecimal!
            }
        }
        
        let formattedValue = numberFormatter.string(from: inputNumber as NSNumber)!
        let formattedValueNoCommas = formattedValue.replacingOccurrences(of: ",", with: "")
        
        switch withCommas {
        case true:
            return formattedValue
        case false:
            return formattedValueNoCommas
        }
    }
}
