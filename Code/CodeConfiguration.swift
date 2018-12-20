import UIKit
import AVFoundation

// 配置
public class CameraViewConfiguration {
    
    // 引导文本颜色
    public var guideLabelTextColor = UIColor(red: 200 / 255, green: 200 / 255, blue: 200 / 255, alpha: 1)
    
    // 引导文本字体
    public var guideLabelTextFont = UIFont.systemFont(ofSize: 13)
    
    // 引导文本与录制按钮的距离
    public var guideLabelMarginBottom: CGFloat = 30
    
    // 引导文本几秒后淡出
    public var guideLabelFadeOutInterval: TimeInterval = 3
    
    // 引导文本
    public var guideLabelTitle = "轻触拍照，按住摄像"

    public init() { }

}
