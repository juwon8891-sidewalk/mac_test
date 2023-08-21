import Foundation
import UIKit

extension String {
    func replaceSpaceString(target: String, withString: String) -> String
    {
        return self.replacingOccurrences(of: target, with: withString, options: NSString.CompareOptions.literal, range: nil)
    }
    
    func localized(comment: String = "") -> String {
        return NSLocalizedString(self, comment: comment)
    }
    
    func localized(with argument: CVarArg = [], comment: String = "") -> String {
        return String(format: self.localized(comment: comment), argument)
    }
    
    func setAttributeString(textColor: UIColor, font: UIFont) -> AttributedString {
        let attirbuteTitle = NSMutableAttributedString(string: self, attributes: [
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor: textColor
        ])
        return AttributedString(attirbuteTitle)
    }
    
    func setAttributeString(textColor: UIColor, font: UIFont, kern: Float) -> NSAttributedString {
        let attirbuteTitle = NSMutableAttributedString(string: self, attributes: [
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor: textColor,
            NSAttributedString.Key.kern: kern
        ])
        return attirbuteTitle
    }
    
    func setAttributeString(range: NSRange, font: UIFont, textColor: UIColor) -> NSAttributedString {
        let attributeString = NSMutableAttributedString(string: self)
        attributeString.addAttribute(.foregroundColor, value: textColor, range: range)
        attributeString.addAttribute(.font, value: font, range: range)
        return attributeString
    }
    
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
    
    func isContainEnglish() -> Bool {
        let pattern = "[A-Za-z]+"
        guard let isContain = self.range(of: pattern, options: .regularExpression) else { return false}
        return true
    }
    
    func isContainNumber() -> Bool {
        let pattern = ".*[0-9]+.*"
        guard let isContain = self.range(of: pattern, options: .regularExpression) else { return false}
        return true
    }
    
    func isContainNumberAndAlphabet() -> Bool {
        let pattern = "^[0-9a-zA-Z]*$"
        guard let isContain = self.range(of: pattern, options: .regularExpression) else { return false}
        return true
    }
    
    func isLengthOver8() -> Bool {
        if self.count >= 8 {
            return true
        } else {
            return false
        }
    }
    
    func isLengthOver(lenght: Int) -> Bool {
        if self.count >= lenght {
            return true
        } else {
            return false
        }
    }
    
    func matchString (_string : String) -> String {
        let strArr = Array(_string)
        let pattern = "^[a-zA-Z0-9]{0,}$" // 정규식 : 한글, 영어, 숫자만 허용 (공백, 특수문자 제거)
        
        var resultString = ""
        if strArr.count > 0 {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                var index = 0
                while index < strArr.count {
                    let checkString = regex.matches(in: String(strArr[index]), options: [], range: NSRange(location: 0, length: 1))
                    if checkString.count == 0 {
                        index += 1
                    }
                    else {
                        resultString += String(strArr[index])
                        index += 1
                    }
                }
            }
            return resultString
        }
        else {
            return _string
        }
    }
    
    func stringToDate(toformat: String, fromFormat: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = toformat
        let date = formatter.date(from: self)
        
        guard let returnDateString = date?.toString(dateFormat: fromFormat) else {return ""}
        return returnDateString
    }
    
    func scoreToState(score: Float) -> String {
        switch score {
        case 90.0 ... 100.0:
            return "Perfect"
        case 70.0 ... 89.99:
            return "Great"
        case 40.0 ... 69.99:
            return "Good"
        default:
            return "Bad"
        }
    }
    
    func scoreToColor(score: Float) -> UIColor {
        switch score {
        case 90.0 ... 100.0:
            return .SystemYellow
        case 70.0 ... 89.99:
            return .SecondaryPinkHeavy
        case 40.0 ... 69.99:
            return .SecondaryGreenHeavy
        default:
            return UIColor(red: 154.0 / 255.0,
                           green: 106.0 / 255.0,
                           blue: 255.0 / 255.0,
                           alpha: 1.0) //제발 있는 컬러만 사용해주세요 제발제발제발제발제발제발제발제발제발제발제발제발제발제발제발제발제발제발제발제발제발
        }
    }
}
