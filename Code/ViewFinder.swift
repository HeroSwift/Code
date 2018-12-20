
import UIKit

public class ViewFinder: UIView {
    
    public var maskColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.61)
    
    public var cornerColor = UIColor(red: 1, green: 0.48, blue: 0.03, alpha: 1)
    
    public var cornerWidth: CGFloat = 2
    
    public var cornerSize: CGFloat = 16
    
    public var borderWidth = 1 / UIScreen.main.scale
    
    public var borderColor = UIColor(red: 255, green: 255, blue: 255, alpha: 0.6)
    
    public var box: CGRect!

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func draw(_ rect: CGRect) {
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        
        // 遮罩
        context.setFillColor(maskColor.cgColor)
        context.addRect(bounds)
        context.drawPath(using: .fill)
        context.clear(box)
        
        let left = box.origin.x
        let top = box.origin.y
        let right = left + box.width
        let bottom = top + box.height
        
        // 边框
        if borderWidth > 0 {
            let halfBorderWidth = borderWidth / 2
            context.setStrokeColor(borderColor.cgColor)
            context.setLineWidth(borderWidth)
            context.addRect(CGRect(x: left + halfBorderWidth, y: top + halfBorderWidth, width: box.width - borderWidth, height: box.height - borderWidth))
            context.drawPath(using: .stroke)
        }
        
        
        context.setFillColor(cornerColor.cgColor)
        
        // 左上
        context.addRect(CGRect(x: left, y: top, width: cornerSize, height: cornerWidth))
        context.addRect(CGRect(x: left, y: top + cornerWidth, width: cornerWidth, height: cornerSize - cornerWidth))
        
        // 右上
        context.addRect(CGRect(x: right - cornerSize, y: top, width: cornerSize, height: cornerWidth))
        context.addRect(CGRect(x: right - cornerWidth, y: top + cornerWidth, width: cornerWidth, height: cornerSize - cornerWidth))
        
        // 右下
        context.addRect(CGRect(x: right - cornerWidth, y: bottom - cornerSize, width: cornerWidth, height: cornerSize))
        context.addRect(CGRect(x: right - cornerSize, y: bottom - cornerWidth, width: cornerSize, height: cornerWidth))

        // 左下
        context.addRect(CGRect(x: left, y: bottom - cornerSize, width: cornerWidth, height: cornerSize))
        context.addRect(CGRect(x: left + cornerWidth, y: bottom - cornerWidth, width: cornerSize - cornerWidth, height: cornerWidth))
        
        context.drawPath(using: .fill)
        
    }
    
}
