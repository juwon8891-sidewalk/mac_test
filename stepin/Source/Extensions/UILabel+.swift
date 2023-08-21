import UIKit

extension UILabel {
    func lineNumber(labelWidth: CGFloat) -> Int {
        let boundingRect = self.text!.boundingRect(with: .zero,
                                                   options: [.usesFontLeading],
                                                   attributes: [.font: self.font!],
                                                   context: nil)
        print(boundingRect)
                return Int(boundingRect.width / labelWidth + 1)
    }
    func lineNumber() -> Int {
        let boundingRect = self.text?.boundingRect(with: .zero,
                                                   options: [.usesFontLeading],
                                                   attributes: [.font: self.font],
                                                   context: nil)
        return Int((boundingRect?.width ?? 0) / self.frame.width)
    }
    
    func calculateMaxLines() -> Int {
        let maxSize = CGSize(width: frame.size.width, height: CGFloat(Float.infinity))
        let charSize = font.lineHeight
        let text = (self.text ?? "") as NSString
        let textSize = text.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        let linesRoundedUp = Int(ceil(textSize.height/charSize))
        return linesRoundedUp
    }
    // 줄바꿈 개수
    func calculateNumberOfLines() -> Int {
        // 라벨의 총 높이를 구합니다.
        let labelText = self.text ?? ""
        let attributes = [NSAttributedString.Key.font: self.font as Any]
        let labelSize = CGSize(width: self.frame.width, height: CGFloat.greatestFiniteMagnitude)
        let rect = labelText.boundingRect(with: labelSize, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
        
        // 라벨의 라인 높이를 구합니다.
        let lineHeight = self.font.lineHeight
        
        // 라인 수를 계산합니다.
        let numberOfLines = Int(rect.height / lineHeight)
        return numberOfLines
    }
    
    // UILabel 한줄 높이
    func singleLineTextHeight() -> CGFloat {
          guard let font = self.font else {
              return 0.0
          }
          
          let lineHeight = font.lineHeight
          return lineHeight
      }

}
