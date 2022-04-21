//
//  Color.swift
//  Daily
//
//  Created by kasoly on 2022/3/27.
//

import SwiftUI
import Foundation



extension Color {
    /// hex 或者 Color.description 转 Color
    init(hex: String) {
        if hex.hasPrefix("kCGColorSpaceModelRGB") {
            var red:Double = 0
            var green:Double = 0
            var blue:Double = 0
            var alpha: Double = 1
            let args :[String] = hex.components(separatedBy: " ")
            if args.count == 6 {
                red = Double(args[1]) ?? 0
                green = Double(args[2]) ?? 0
                blue = Double(args[3]) ?? 0
                alpha = Double(args[4]) ?? 1
            }
            self.init(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
        }
        
        var string: String = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if string.hasPrefix("#") {
            _ = string.removeFirst()
        }
        if !string.count.isMultiple(of: 2), let last = string.last {
            string.append(last)
        }

        if string.count > 8 {
            string = String(string.prefix(8))
        }

        let scanner = Scanner(string: string)

        var color: UInt64 = 0
        scanner.scanHexInt64(&color)

        if string.count == 2 {
            let mask = 0xFF

            let g = Int(color) & mask

            let gray = Double(g) / 255.0

            self.init(.sRGB, red: gray, green: gray, blue: gray, opacity: 1)

        } else if string.count == 4 {
            let mask = 0x00FF

            let g = Int(color >> 8) & mask
            let a = Int(color) & mask

            let gray = Double(g) / 255.0
            let alpha = Double(a) / 255.0

            self.init(.sRGB, red: gray, green: gray, blue: gray, opacity: alpha)

        } else if string.count == 6 {
            let mask = 0x0000FF
            let r = Int(color >> 16) & mask
            let g = Int(color >> 8) & mask
            let b = Int(color) & mask

            let red = Double(r) / 255.0
            let green = Double(g) / 255.0
            let blue = Double(b) / 255.0

            self.init(.sRGB, red: red, green: green, blue: blue, opacity: 1)

        } else if string.count == 8 {
            let mask = 0x000000FF
            let r = Int(color >> 24) & mask
            let g = Int(color >> 16) & mask
            let b = Int(color >> 8) & mask
            let a = Int(color) & mask

            let red = Double(r) / 255.0
            let green = Double(g) / 255.0
            let blue = Double(b) / 255.0
            let alpha = Double(a) / 255.0
            self.init(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
        } else {
            self.init(.sRGB, red: 1, green: 1, blue: 1, opacity: 1)
        }
    }
    
    // Color 转 hex
    var hexString: String {
        if self.description.hasPrefix("#") {
            return self.description
        }
        if self.description.hasPrefix("kCGColorSpaceModelRGB") {
            var red:Double = 0
            var green:Double = 0
            var blue:Double = 0
            var alpha: Double = 1
            let args :[String] = description.components(separatedBy: " ")
            if args.count == 6 {
                red = Double(args[1]) ?? 0
                green = Double(args[2]) ?? 0
                blue = Double(args[3]) ?? 0
                alpha = Double(args[4]) ?? 1
            }
            if alpha == 1 {
                return String(format: "#%02X%02X%02X%02X", Int(red * 255), Int(green * 255), Int(blue * 255), Int(alpha * 255))
            } else {
                return String(format: "#%02X%02X%02X", Int(red * 255), Int(green * 255), Int(blue * 255))
            }
        }
        return  ""
    }

    
}
