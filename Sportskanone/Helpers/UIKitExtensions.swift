//
//  UIKitExtensions.swift
//  Sportskanone
//
//  Created by Fabian Pahl on 25/03/2017.
//  Copyright © 2017 21st digital GmbH. All rights reserved.
//

import UIKit

extension UIImage {

  // TODO: Refactor temporary helper
  static func image(forRank rank: Int) -> UIImage? {
    let scale = UIScreen.main.scale
    let myString: NSString = "\(rank)." as NSString
    let font = UIFont.boldSystemFont(ofSize: 26)

    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = .center

    let attributes = [NSFontAttributeName: font, NSParagraphStyleAttributeName: paragraphStyle]

    let size = CGSize(width: 60, height: 60)
    UIGraphicsBeginImageContextWithOptions(size, false, scale)

    let rect = CGRect(origin: CGPoint(x: size.width * 0.5 - 26, y: size.height * 0.5 - 16), size: size)
    myString.draw(in: rect, withAttributes: attributes)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return image
  }
  
}

extension UIViewController {
  
  func presentError(error: Error, title: String) {
    let alertController = UIAlertController(title: title, message: error.localizedDescription, preferredStyle: .alert)
    let cancelAction = UIAlertAction(title: "Alert.Button.Cancel.Title".localized, style: .cancel, handler: nil)
    alertController.addAction(cancelAction)
    
    self.present(alertController, animated: true, completion: nil)
  }
  
}

extension UIFont {
  
  static var skHeadline: UIFont {
    return UIFont.systemFont(ofSize: 32, weight: UIFontWeightHeavy)
  }
  
  static var skLabel: UIFont {
    return UIFont.systemFont(ofSize: 18, weight: UIFontWeightBold)
  }
  
  static var skText: UIFont {
    return UIFont.systemFont(ofSize: 17, weight: UIFontWeightLight)
  }
  
  static var skDetail: UIFont {
    return UIFont.systemFont(ofSize: 12, weight: UIFontWeightLight)
  }
  
  static var skTextButton: UIFont {
    return UIFont.systemFont(ofSize: 17, weight: UIFontWeightBold)
  }
  
}

extension UIColor {
  
  static var skGreen: UIColor {
    return UIColor(red: 76, green: 183, blue: 147)
  }
  
  static var skBrown: UIColor {
    return UIColor(red: 210, green: 151, blue: 113)
  }
  
  static var skBlack: UIColor {
    return UIColor(red: 62, green: 67, blue: 71)
  }
  
  static var skGray: UIColor {
    return UIColor(red: 148, green: 152, blue: 155)
  }
  
  convenience init(red: Int, green: Int, blue: Int) {
    assert(red >= 0 && red <= 255, "Invalid red component")
    assert(green >= 0 && green <= 255, "Invalid green component")
    assert(blue >= 0 && blue <= 255, "Invalid blue component")
    
    self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
  }
  
}

extension UILabel {
  
  @IBInspectable dynamic var fontColor: UIColor {
    get {
      return textColor
    }
    set {
      textColor = newValue
    }
  }
  
  dynamic var textFont: UIFont? {
    get {
      return font
    }
    set {
      font = newValue
    }
  }
}

extension UIButton {
  
  @IBInspectable dynamic var shadowColor: UIColor? {
    get {
      guard let shadowColor = layer.shadowColor else {
        return nil
      }
      return UIColor(cgColor: shadowColor)
      
    }
    set {
      layer.shadowColor = newValue?.cgColor
    }
  }
  
  @IBInspectable dynamic var shadowOffset: CGSize {
    get {
      return layer.shadowOffset
    }
    set {
      layer.shadowOffset = newValue
    }
  }
  
  @IBInspectable dynamic var shadowRadius: CGFloat {
    get {
      return layer.shadowRadius
    }
    set {
      layer.shadowRadius = newValue
    }
  }
  
  @IBInspectable dynamic var shadowOpacity: Float {
    get {
      return layer.shadowOpacity
    }
    set {
      layer.shadowOpacity = newValue
    }
  }
  
  @IBInspectable dynamic var borderWidth: CGFloat {
    get {
      return layer.borderWidth
    }
    set {
      layer.borderWidth = newValue
    }
  }
  
  @IBInspectable dynamic var borderColor: UIColor? {
    get {
      guard let borderColor = layer.borderColor else {
        return nil
      }
      return UIColor(cgColor: borderColor)
    }
    set {
      layer.borderColor = newValue?.cgColor
    }
  }
  
  var title: String? {
    get {
      return currentTitle
    }
    set {
      setTitle(newValue, for: .normal)
    }
  }
  
  dynamic var titleFont: UIFont? {
    get {
      guard let font = titleLabel?.font else {
        return nil
      }
      return font
    }
    set {
      titleLabel?.font = newValue
    }
  }
  
}
