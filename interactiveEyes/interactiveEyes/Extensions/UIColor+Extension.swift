//
//  UIColor+Extension.swift
//  interactiveEyes
//
//  Created by Aline Krajuska on 8/17/21.
//

import UIKit

enum paletteColor {
    case mint
    case purple
    case yellow
    case rose
    case pink
    case offwhite
    case textColor
}

extension UIColor {
    
   convenience init(red: Int, green: Int, blue: Int) {
       assert(red >= 0 && red <= 255, "Invalid red component")
       assert(green >= 0 && green <= 255, "Invalid green component")
       assert(blue >= 0 && blue <= 255, "Invalid blue component")

       self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
   }

   convenience init(rgb: Int) {
       self.init(
           red: (rgb >> 16) & 0xFF,
           green: (rgb >> 8) & 0xFF,
           blue: rgb & 0xFF
       )
   }
    
    convenience init(_ color: paletteColor) {
        switch color {
        case .mint:
            self.init(rgb: 0xABDEE6)
        case .purple:
            self.init(rgb: 0xCBAACB)
        case .yellow:
            self.init(rgb: 0xFFFFB5)
        case .rose:
            self.init(rgb: 0xFFCCB6)
        case .pink:
            self.init(rgb: 0xF3B0C3)
        case .offwhite:
            self.init(rgb: 0xECEAE4)
        case .textColor:
            self.init(rgb: 0x740E4C)
        }
    }
}
