//
//  File.swift
//  WFMS
//
//  Created by NectarInfotel2 on 27/02/20.
//  Copyright © 2020 NectarInfotel2. All rights reserved.
//

import Foundation
import UIKit
import MaterialComponents

extension Date {
    func toString(withFormat format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.init(identifier: "en")
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    
//    func getCurrentTimeStamp() -> String{
//        let formater = DateFormatter()
//        formater.dateFormat = Constants.DateTimeFormats.kStandardFormat
//        formater.locale =  Locale(identifier: "en")
//        return formater.string(from: self)
//    }
//
//    func getDOB() -> String{
//        let dateFormatter = DateFormatter()
//        dateFormatter.locale = Locale.init(identifier: "en")
//        dateFormatter.dateFormat = Constants.DateTimeFormats.kDOBFormat
//        return self.toString(withFormat: Constants.DateTimeFormats.kDOBFormat)
//    }
    
    // Date extensions
    func secondsFromBeginningOfTheDay() -> TimeInterval {
        let calendar = Calendar.current
        // omitting fractions of seconds for simplicity
        let dateComponents = calendar.dateComponents([.hour, .minute, .second], from: self)
        
        let dateSeconds = dateComponents.hour! * 3600 + dateComponents.minute! * 60 + dateComponents.second!
        
        return TimeInterval(dateSeconds)
    }
    
    // Interval between two times of the day in seconds
    func timeOfDayInterval(toDate date: Date) -> TimeInterval {
        let date1Seconds = self.secondsFromBeginningOfTheDay()
        let date2Seconds = date.secondsFromBeginningOfTheDay()
        return date2Seconds - date1Seconds
    }
    
    func dayOfWeek() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        dateFormatter.locale = Locale.init(identifier: "en")
        return dateFormatter.string(from: self)
    }
    
    func isEqualTo(_ date: Date) -> Bool {
        return self == date
    }
    
    func isGreaterThan(_ date: Date) -> Bool {
        return self > date
    }
    
    func isSmallerThan(_ date: Date) -> Bool {
        return self < date
    }
}


extension Double {
    
    func formattedString(uptoDecimal: Int? = 2) -> String{
        
        return String(format: "%.\(uptoDecimal!)f", self.roundTo(places: uptoDecimal!))
    }
    

    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
    
    func roundToDecimal(_ fractionDigits: Int) -> Double {
        let multiplier = pow(10, Double(fractionDigits))
        return Darwin.floor(self * multiplier) / multiplier
    }
    
    func toIndianCurrency() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        
        formatter.locale = Locale.init(identifier: "en")
        formatter.roundingMode = .down
        let formattedBal: String? = formatter.string(for: self)
        
        return (formattedBal?.description)!
    }
}


extension UIColor
{
    convenience init(hexString: String)
    {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}


extension UIImage {
    
    class func imageWithColor(color: UIColor?) -> UIImage! {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        let context = UIGraphicsGetCurrentContext()
        
        if let color = color{
            color.setFill()
        }else{
            UIColor.white.setFill()
        }
        
        context!.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    enum JPEGQuality: CGFloat {
        case lowest  = 0
        case low     = 0.25
        case medium  = 0.5
        case high    = 0.75
        case highest = 1
    }
    
    /// Returns the data for the specified image in JPEG format.
    /// If the image object’s underlying image data has been purged, calling this function forces that data to be reloaded into memory.
    /// - returns: A data object containing the JPEG data, or nil if there was a problem generating the data. This function may return nil if the image has no data or if the underlying CGImageRef contains data in an unsupported bitmap format.
    func jpeg(_ quality: JPEGQuality) -> Data? {
        return self.jpegData(compressionQuality: quality.rawValue)
    }
}

extension UIImageView {
    func downloaded(from url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit) {  // for swift 4.2 syntax just use ===> mode: UIView.ContentMode
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() {
                self.image = image
            }
            }.resume()
    }
    func downloaded(from link: String, contentMode mode: UIView.ContentMode = .scaleAspectFit) {  // for swift 4.2 syntax just use ===> mode: UIView.ContentMode
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}



extension UIFont {
    enum Lato: String {
        
//        case lato_Black = "Lato-Black"
//        case lato_BlackItalic = "Lato-BlackItalic"
        case lato_Bold = "Lato-Bold"
//        case lato_BoldItalic = "Lato-BoldItalic"
//        case lato_Hairline = "Lato-Hairline"
//        case lato_HairlineItalic = "Lato-HairlineItalic"
//        case lato_Heavy = "Lato-Heavy"
//        case lato_HeavyItalic = "Lato-HeavyItalic"
//        case lato_Italic = "Lato-Italic"
//        case lato_Light = "Lato-Light"
//        case lato_LightItalic = "Lato-LightItalic"
//        case lato_Medium = "Lato-Medium"
//        case lato_MediumItalic = "Lato-MediumItalic"
        case lato_Regular = "Lato-Regular"
//        case lato_Semibold = "Lato-Semibold"
//        case lato_SemiboldItalic = "Lato-SemiboldItalic"
//        case lato_Thin = "Lato-Thin"
//        case lato_ThinItalic = "Lato-ThinItalic"
        
        func of(size: CGFloat) -> UIFont {
            print(self.rawValue)
//            return UIFont(name: self.rawValue, size: size)!
            return UIFont.init(name:self.rawValue, size: size)!
        }
    }
    
    //    enum CalliGarfitiFont: String {
    //        case regular = "Calligraffiti"
    //
    //        func of(size: CGFloat) -> UIFont {
    //            return UIFont(name: self.rawValue, size: size)!
    //        }
    //
    //    }
}

extension CGRect {
    func getCGRectHeight() -> CGFloat{
        return self.size.height
    }
    
    func getCGRectWidth() -> CGFloat{
        return self.size.width
    }
}

//MARK: UIViewController Extension
extension UIViewController {

    func setLightMode(){

        if #available(iOS 13.0, *) {
            self.overrideUserInterfaceStyle = .light

        } else {
            // Fallback on earlier versions
        }
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func disablehideKeyboardWhenTappedAround(){
        guard let gestures = view.gestureRecognizers else{
            return
        }
        for gesture in gestures {
            view.removeGestureRecognizer(gesture)
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
        toucheArround()
    }
    
    func disableGesturePopup()
    {
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    open func toucheArround(){
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
    }
}

extension UIApplication {
    class func topViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        
        if let tab = base as? UITabBarController {
            let moreNavigationController = tab.moreNavigationController
            
            if let top = moreNavigationController.topViewController, top.view.window != nil {
                return topViewController(base: top)
            } else if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        
        return base
    }
    
    
    var takeScreenShot: UIImage?  {
        
        if let rootViewController = keyWindow?.rootViewController {
            let scale = UIScreen.main.scale
            let bounds = rootViewController.view.bounds
            UIGraphicsBeginImageContextWithOptions(bounds.size, false, scale);
            if let _ = UIGraphicsGetCurrentContext() {
                rootViewController.view.drawHierarchy(in: bounds, afterScreenUpdates: true)
                let screenshot = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                return screenshot
            }
        }
        return nil
    }
}

extension UIScrollView {
    func updateContentView() {
        contentSize.height = subviews.sorted(by: { $0.frame.maxY < $1.frame.maxY }).last?.frame.maxY ?? contentSize.height
    }
}

protocol MaterialView {
   func elevate(elevation: Double)
}

extension UIView: MaterialView {
   func elevate(elevation: Double) {
      self.layer.masksToBounds = false
      self.layer.shadowColor = UIColor.black.cgColor
      self.layer.shadowOffset = CGSize(width: 0, height: elevation)
      self.layer.shadowRadius = CGFloat(elevation)
      self.layer.shadowOpacity = 0.5
   }
}


extension UIView {
    

    
    @IBInspectable var shadow: Bool {
        get {
            return layer.shadowOpacity > 0.0
        }
        set {
            if newValue == true {
                self.addShadow()
            }
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return self.layer.cornerRadius
        }
        set {
            self.layer.cornerRadius = newValue
            
            // Don't touch the masksToBound property if a shadow is needed in addition to the cornerRadius
            if shadow == false {
                self.layer.masksToBounds = true
            }
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return self.layer.borderWidth
        }
        set {
            self.layer.borderWidth = newValue
        }
    }
    
    
    //    @IBInspectable var shadowRadius: CGFloat {
    //        get {
    //            return self.layer.shadowRadius
    //        }
    //        set {
    //            self.layer.shadowRadius = newValue
    //        }
    //    }
    
    
    @IBInspectable var borderColor: UIColor {
        get {
            return UIColor(cgColor: self.layer.borderColor!)
        }
        set {
            self.layer.borderColor = newValue.cgColor
        }
    }
    
    
    func addShadow(shadowColor: CGColor = UIColor.lightGray.cgColor,
                   shadowOffset: CGSize = CGSize(width: 1.0, height: 2.0),
                   shadowOpacity: Float = 0.4,
                   shadowRadius: CGFloat = 3.0) {
        layer.shadowColor = shadowColor
        layer.shadowOffset = shadowOffset
        layer.shadowOpacity = shadowOpacity
        layer.shadowRadius = shadowRadius
    }
    
    func addShadowEffect() {
        let shadowSize: CGFloat = 2
        let shadowPath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: 1.0, height: 1.0))
        self.layer.shadowPath = shadowPath.cgPath

        self.layer.shadowOffset = .zero
        self.layer.shadowRadius = 1
        self.layer.shadowOpacity = 1

        self.layer.borderColor = UIColor.white.cgColor
        self.layer.borderWidth = shadowSize
    }
    
    func circleView() {
        self.clipsToBounds = true
        self.layer.cornerRadius = CGFloat(Int(self.frame.size.width) / 2)
    }
    

    
    
    func flipView(){
        self.transform = CGAffineTransform(scaleX: -1, y: 1)
    }
    
    
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.duration = 0.6
        animation.values = [-20.0, 20.0, -20.0, 20.0, -10.0, 10.0, -5.0, 5.0, 0.0]
        layer.add(animation, forKey: "shake")
    }
    
    func takeScreenshot() -> UIImage {
        
        // Begin context
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)
        
        // Draw view in that context
        drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        
        // And finally, get image
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if (image != nil)
        {
            return image!
        }
        return UIImage()
    }
    
    //MARK: PSP add dashed line
    
    func createDashedLine(from point1: CGPoint, to point2: CGPoint, color: UIColor, strokeLength: NSNumber, gapLength: NSNumber, width: CGFloat) {
        let shapeLayer = CAShapeLayer()
        
        shapeLayer.strokeColor = color.cgColor
        shapeLayer.lineWidth = width
        shapeLayer.lineDashPattern = [strokeLength, gapLength]
        
        let path = CGMutablePath()
        path.addLines(between: [point1, point2])
        shapeLayer.path = path
        layer.addSublayer(shapeLayer)
    }
    
    //MARK: PSP Round Corners
    func roundCorners(cornerRadius: Double) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [.allCorners], cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path = path.cgPath
        self.layer.mask = maskLayer
    }
        
}

extension UIScrollView{
    func takeScrollScreenShot() -> UIImage{
        UIGraphicsBeginImageContext(self.contentSize)
        
        let savedContentOffset = self.contentOffset
        let savedFrame = self.frame
        
        self.contentOffset = CGPoint.zero
        self.frame = CGRect(x: 0, y: 0, width: self.contentSize.width, height: self.contentSize.height)
        
        self.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        self.contentOffset = savedContentOffset
        self.frame = savedFrame
        
        UIGraphicsEndImageContext()
        
        if (image != nil)
        {
            return image!
        }
        return UIImage()
    }
}

extension String {
    
    
    var htmlToAttributedString: NSAttributedString? {
        guard
            let data = self.data(using: .utf8)
            else { return nil }
        do {
            return try NSAttributedString(data: data, options: [
                NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html,
                NSAttributedString.DocumentReadingOptionKey.characterEncoding: String.Encoding.utf8.rawValue
                ], documentAttributes: nil)
        } catch let error as NSError {
            print(error.localizedDescription)
            return  nil
        }
    }

    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }

    //    func jsonStringToDictionary() -> [String: Any]? {
    //        guard let data = self.data(using: .utf8) else { return nil }
    //        let anyResult = try? JSONSerialization.jsonObject(with: data, options: [])
    //        return anyResult as? [String: Any]
    //    }
    //
    
    
    subscript (i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }
    
    //    func group(by groupSize:Int, separator:String) -> String
    //    {
    //        if self.count <= groupSize
    //        {
    //            return self
    //        }
    //
    //        let splitSize  = min(max(2,self.count-2) , groupSize)
    //        let splitIndex = index(startIndex, offsetBy:splitSize)
    //
    //        return substring(to:splitIndex)
    //            + separator
    //            + substring(from:splitIndex).group(by:groupSize, separator:separator)
    //    }
    
    func separate(every stride: Int = 4, with separator: Character = " ") -> String
    {
        return String(enumerated().map { $0 > 0 && $0 % stride == 0 ? [separator, $1] : [$1]}.joined())
    }
    
    func localised() -> String{
        return NSLocalizedString(self, comment: "")
    }
    
    func getDomain() -> String? {
        guard let url = URL(string: self) else { return nil }
        return url.host
    }

    
    
    //    func isEmail() -> Bool
    //    {
    //        do {
    //            let regex = try NSRegularExpression(pattern: "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]+$", options: NSRegularExpression.Options.caseInsensitive)
    //            return regex.firstMatch(in: self, options: [], range: NSMakeRange(0, self.count)) != nil
    //        } catch { return false }
    //    }
    
    func getImagefromBase64() -> UIImage{
        let imageData : Data = Data(base64Encoded: self, options: .ignoreUnknownCharacters)!
        let image = UIImage(data: imageData)
        return image!
    }
    
    func getCharacterAtIndex(index: Int) -> String
    {
        if self.count != 0 {
            let index = self.index(self.startIndex, offsetBy: index)
            return String(self[index]).uppercased()
        }else{
            return ""
        }
    }
    
    func formatSring() -> String{
        return self.replacingOccurrences(of: "|", with: "\n")
    }
    
    func convertToDictionary() -> [String: Any]? {
        if let data = self.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    func fromString(withFormat format: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: self)!
    }
    
//    func toInt() -> Int{
//        guard let value = Int(self) else {
//            Utility.printLog(key: "Problem casting to int", value: "")
//            return 0
//        }
//        return value
//    }
    
    func toDouble(uptoDecimal: Int? = 2) -> Double{
        
         if (self as NSString).doubleValue == 0
        {
            return 0.0
        }
        else
        {
            let strAmount = self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            
            let formatter = NumberFormatter()
            formatter.locale = Locale.current // USA: Locale(identifier: "en_US")
            formatter.numberStyle = .decimal
            
            if let number = formatter.number(from: strAmount) {
                
                guard let  doubleValue = Double(exactly: number) else{
                    return 0.0
                }
                
                let returnValue = doubleValue.roundToDecimal(uptoDecimal!)
                
                return returnValue
                
            }else{
                return 0.0
            }
         }
    }
    
    
//    func sha256() -> String{
//        if let stringData = self.data(using: String.Encoding.utf8) {
//            return hexStringFromData(input: digest(input: stringData as NSData))
//        }
//        return ""
//    }
    
//    func encryptRequestWithDefaultKeyIV() -> String? {
//        let data = self.description.data(using: .utf8)
//        let encryptedData : Data = Utility.CryptWithDefaultValues(data: data!, operation: kCCEncrypt)!
//        let base64Str = encryptedData.base64EncodedString()
//        return base64Str
//    }
//
//    func decryptResponseWithDefaultKeyIV() -> [String: Any]? {
//        let str1Data = Data(base64Encoded: self)
//        let decrypt = Utility.CryptWithDefaultValues(data: str1Data!, operation: kCCDecrypt)!
//        let plain = String(data: decrypt, encoding: .utf8)
//        let decryptedResponse = plain?.convertToDictionary()
//        return decryptedResponse
//    }
//
//    func decryptedStringWithDefaultKeyIV() -> String? {
//        let str1Data = Data(base64Encoded: self)
//        let decrypt = Utility.CryptWithDefaultValues(data: str1Data!, operation: kCCDecrypt)!
//        let plain = String(data: decrypt, encoding: .utf8)
//        return plain
//    }
//
//
//
//    private func digest(input : NSData) -> NSData {
//        let digestLength = Int(CC_SHA256_DIGEST_LENGTH)
//        var hash = [UInt8](repeating: 0, count: digestLength)
//        CC_SHA256(input.bytes, UInt32(input.length), &hash)
//        return NSData(bytes: hash, length: digestLength)
//    }
//
    private  func hexStringFromData(input: NSData) -> String {
        var bytes = [UInt8](repeating: 0, count: input.length)
        input.getBytes(&bytes, length: input.length)
        
        var hexString = ""
        for byte in bytes {
            hexString += String(format:"%02x", UInt8(byte))
        }
        
        return hexString
    }
    
    
//    func getDateStringForTxnHistoryFormat() -> String
//    {
//        let dateFormatter = DateFormatter()
//        dateFormatter.locale = Locale.init(identifier: "en")
//        dateFormatter.dateFormat = Constants.DateTimeFormats.kTxnDate
//        let currentDate = dateFormatter.date(from: self)
//
//        dateFormatter.dateFormat = "yyyy"
//        let year: String = dateFormatter.string(from: currentDate!)
//
//        dateFormatter.dateFormat = "MM"
//        let month: String = dateFormatter.string(from: currentDate!)
//
//        dateFormatter.dateFormat = "dd"
//        let day: String = dateFormatter.string(from: currentDate!)
//
//        dateFormatter.dateFormat = "HH:mm"
//        let hours: String = dateFormatter.string(from: currentDate!)
//
//        return "\(month)/\(day)/\(year) | \(hours) "
//    }
    
}

public extension UIDevice {
    
    static let modelName: String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        func mapToDevice(identifier: String) -> String { // swiftlint:disable:this cyclomatic_complexity
            #if os(iOS)
            switch identifier {
            case "iPod5,1":                                 return "iPod Touch 5"
            case "iPod7,1":                                 return "iPod Touch 6"
            case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
            case "iPhone4,1":                               return "iPhone 4s"
            case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
            case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
            case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
            case "iPhone7,2":                               return "iPhone 6"
            case "iPhone7,1":                               return "iPhone 6 Plus"
            case "iPhone8,1":                               return "iPhone 6s"
            case "iPhone8,2":                               return "iPhone 6s Plus"
            case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
            case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
            case "iPhone8,4":                               return "iPhone SE"
            case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
            case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
            case "iPhone10,3", "iPhone10,6":                return "iPhone X"
            case "iPhone11,2":                              return "iPhone XS"
            case "iPhone11,4", "iPhone11,6":                return "iPhone XS Max"
            case "iPhone11,8":                              return "iPhone XR"
            case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
            case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
            case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
            case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
            case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
            case "iPad6,11", "iPad6,12":                    return "iPad 5"
            case "iPad7,5", "iPad7,6":                      return "iPad 6"
            case "iPad11,4", "iPad11,5":                    return "iPad Air (3rd generation)"
            case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
            case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
            case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
            case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
            case "iPad11,1", "iPad11,2":                    return "iPad Mini 5"
            case "iPad6,3", "iPad6,4":                      return "iPad Pro (9.7-inch)"
            case "iPad6,7", "iPad6,8":                      return "iPad Pro (12.9-inch)"
            case "iPad7,1", "iPad7,2":                      return "iPad Pro (12.9-inch) (2nd generation)"
            case "iPad7,3", "iPad7,4":                      return "iPad Pro (10.5-inch)"
            case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4":return "iPad Pro (11-inch)"
            case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8":return "iPad Pro (12.9-inch) (3rd generation)"
            case "AppleTV5,3":                              return "Apple TV"
            case "AppleTV6,2":                              return "Apple TV 4K"
            case "AudioAccessory1,1":                       return "HomePod"
            case "i386", "x86_64":                          return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "iOS"))"
            default:                                        return identifier
            }
            #elseif os(tvOS)
            switch identifier {
            case "AppleTV5,3": return "Apple TV 4"
            case "AppleTV6,2": return "Apple TV 4K"
            case "i386", "x86_64": return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "tvOS"))"
            default: return identifier
            }
            #endif
        }
        
        return mapToDevice(identifier: identifier)
    }()
    
}

extension Data {
    struct HexEncodingOptions: OptionSet {
        let rawValue: Int
        static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
    }
    
    func hexEncodedString(options: HexEncodingOptions = []) -> String {
        let format = options.contains(.upperCase) ? "%02hhX" : "%02hhx"
        return map { String(format: format, $0) }.joined()
    }
    
}


private var kAssociationKeyMaxLength: Int = 0

extension UITextField {
    
    @IBInspectable var maxLength: Int {
        get {
            if let length = objc_getAssociatedObject(self, &kAssociationKeyMaxLength) as? Int {
                return length
            } else {
                return Int.max
            }
        }
        set {
            objc_setAssociatedObject(self, &kAssociationKeyMaxLength, newValue, .OBJC_ASSOCIATION_RETAIN)
            addTarget(self, action: #selector(checkMaxLength), for: .editingChanged)
        }
    }
    
    @objc func checkMaxLength(textField: UITextField) {
        guard let prospectiveText = self.text,
            prospectiveText.count > maxLength
            else {
                return
        }
        
        let selection = selectedTextRange
        
        let indexEndOfText = prospectiveText.index(prospectiveText.startIndex, offsetBy: maxLength)
        let substring = prospectiveText[..<indexEndOfText]
        text = String(substring)
        
        selectedTextRange = selection
    }
}

//MARK: Encodable
extension Encodable {
    var convertToDictionary: [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
    }
}

//MARK: Save Custpm object to UserDefaults
extension UserDefaults {
    
    func save<T:Encodable>(customObject object: T, inKey key: String) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(object) {
            self.set(encoded, forKey: key)
        }
    }
    
    func retrieve<T:Decodable>(object type:T.Type, fromKey key: String) -> T? {
        if let data = self.data(forKey: key) {
            let decoder = JSONDecoder()
            if let object = try? decoder.decode(type, from: data) {
                return object
            }else {
                print("Couldnt decode object")
                return nil
            }
        }else {
            print("Couldnt find key")
            return nil
        }
    }
    
}


extension DispatchQueue {
    
    static func background(delay: Double = 0.0, background: (()->Void)? = nil, completion: (() -> Void)? = nil) {
        DispatchQueue.global(qos: .background).async {
            background?()
            if let completion = completion {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
                    completion()
                })
            }
        }
    }
    
}

extension Double {
    func roundTo(places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
        
    }
}


extension UINavigationController {
    public func pushViewController(
        _ viewController: UIViewController,
        animated: Bool,
        completion: @escaping () -> Void)
    {
        pushViewController(viewController, animated: animated)
        
        guard animated, let coordinator = transitionCoordinator else {
            DispatchQueue.main.async { completion() }
            return
        }
        
        coordinator.animate(alongsideTransition: nil) { _ in completion() }
    }
    
    func popViewController(
        animated: Bool,
        completion: @escaping () -> Void)
    {
        popViewController(animated: animated)
        
        guard animated, let coordinator = transitionCoordinator else {
            DispatchQueue.main.async { completion() }
            return
        }
        
        coordinator.animate(alongsideTransition: nil) { _ in completion() }
    }
}
