
import UIKit

// https://medium.com/@MedvedevTheDev/generating-basic-qr-codes-in-swift-63d7222aa011

public class QRCodeView: UIImageView {
    
    public var text = "" {
        didSet {
            
            let data = text.data(using: String.Encoding.utf8)
            
            guard let filter = CIFilter(name: "CIQRCodeGenerator") else {
                return
            }
            
            filter.setValue(data, forKey: "inputMessage")
            filter.setValue("H", forKey: "inputCorrectionLevel")
            
            guard let output = filter.outputImage else {
                return
            }
            
            qrcodeImage = output
            updateCode()
            
        }
    }
    
    private var qrcodeImage: CIImage?
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        updateCode()
    }
    
    private func updateCode() {
        
        let viewSize = frame.size

        guard let qrcodeImage = qrcodeImage, viewSize.width > 0, viewSize.height > 0 else {
            return
        }
        
        let imageSize = qrcodeImage.extent.size
        
        guard imageSize.width > 0, imageSize.height > 0 else {
            return
        }
        
        let scaleX = viewSize.width / imageSize.width
        let scaleY = viewSize.height / imageSize.height

        let transformed = qrcodeImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
        
        image = UIImage(ciImage: transformed)
        
    }

}
