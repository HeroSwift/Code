
import UIKit

public class BarCodeView: CodeView {
    
    override func createFilter() -> CIFilter? {
        
        guard let filter = CIFilter(name: "CICode128BarcodeGenerator") else {
            return nil
        }
        
        return filter
        
    }
    
}
