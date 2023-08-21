import UIKit

extension UITextView {
    func numberOfLine() -> Int {
        let size = CGSize(width: frame.width, height: .infinity)
        let estimatedSize = sizeThatFits(size)
        
        return Int(estimatedSize.height / (self.font!.lineHeight))
    }
    
    func contentHeight() -> CGFloat {
           guard let attributedText = self.attributedText else {
               return 0
           }
           
           let textContainer = NSTextContainer(size: CGSize(width: self.bounds.width, height: .greatestFiniteMagnitude))
           textContainer.lineFragmentPadding = 0
           
           let layoutManager = NSLayoutManager()
           layoutManager.addTextContainer(textContainer)
           
           let textStorage = NSTextStorage(attributedString: attributedText)
           textStorage.addLayoutManager(layoutManager)
           
           textContainer.lineBreakMode = self.textContainer.lineBreakMode
           textContainer.maximumNumberOfLines = self.textContainer.maximumNumberOfLines
           
           let usedRect = layoutManager.usedRect(for: textContainer)
           return ceil(usedRect.size.height)
       }
    
    // TextView 한줄 높이
    func singleLineTextHeight() -> CGFloat {
          guard let font = self.font else {
              return 0.0
          }
          
          let lineHeight = font.lineHeight
          return lineHeight
      }
}
