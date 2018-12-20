
import UIKit
import AVFoundation

public class CodeScanner: UIView {
    
    
    public var guideTextFont = UIFont.systemFont(ofSize: 12)
    
    public var guideTextColor = UIColor(red: 255, green: 255, blue: 255, alpha: 0.7)
    
    public var guideMarginTop: CGFloat = 14
    
    public var laserGap: CGFloat = 10
    
    public var laserHeight: CGFloat = 1
    
    public var laserColor = UIColor(red: 1, green: 0.48, blue: 0.03, alpha: 0.625)
    
    public var torchOnImage = UIImage(named: "code_scanner_torch_on")
    
    public var torchOffImage = UIImage(named: "code_scanner_torch_off")
    
    public var torchButtonWidth: CGFloat = 44
    
    public var torchButtonHeight: CGFloat = 44
    
    public var torchButtonMarginBottom: CGFloat = 0
    
    public var guideTitle = "" {
        didSet {
            guideView.text = guideTitle
            guideView.sizeToFit()
        }
    }
    
    
    
    
    
    
    
    

    public var supportedCodeTypes: [AVMetadataObject.ObjectType] = [ .qr, .code128 ]
    
    public var onScanResult: ((String) -> Void)?
    
    private var captureSession: AVCaptureSession!
    
    private var captureDevice: AVCaptureDevice!
    
    private var capturePreviewLayer: AVCaptureVideoPreviewLayer!
    
    private var isTorchOn = false {
        didSet {
            if isTorchOn {
                if setTorchMode(.on) {
                    torchButton.setImage(torchOffImage, for: .normal)
                }
            }
            else {
                if setTorchMode(.off) {
                    torchButton.setImage(torchOnImage, for: .normal)
                }
            }
        }
    }
    
    private var isPreviewing = false {
        didSet {
            if isPreviewing {
                torchButton.isHidden = false
                laserView.isHidden = false
                startLaser()
            }
            else {
                torchButton.isHidden = true
                laserView.isHidden = true
                stopLaser()
            }
        }
    }
    
    private lazy var laserView: UIView = {
        
        let view = UIView()
        
        view.backgroundColor = laserColor
        view.isHidden = true
        
        addSubview(view)
        
        return view
        
    }()
    
    private lazy var viewFinder: ViewFinder = {
        
        let view = ViewFinder()
        
        addSubview(view)
        
        return view
        
    }()
    
    private lazy var guideView: UILabel = {
        
        let view = UILabel()
        
        view.font = guideTextFont
        view.textColor = guideTextColor
        
        addSubview(view)
        
        return view
        
    }()
    
    private lazy var torchButton: UIButton = {
        
        let view = UIButton()
        
        view.setImage(torchOffImage, for: .normal)
        view.frame.size = CGSize(width: torchButtonWidth, height: torchButtonHeight)
        view.isHidden = true
        
        addSubview(view)
        
        view.addTarget(self, action: #selector(onTorchToggle), for: .touchUpInside)
        
        return view
        
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
    
        backgroundColor = .clear

        updateView()
        
        guard let device = pickDevice() else {
            print("has no available device")
            return
        }
        
        captureDevice = device
        
        captureSession = AVCaptureSession()
        
        do {
            try addInput(device: device)
        }
        catch {
            print(error.localizedDescription)
            return
        }
        
        addOutput()
        addPreview()
        
        captureSession.startRunning()

        isPreviewing = true
        
    }
    
    private func pickDevice() -> AVCaptureDevice? {
        
        let devices: [AVCaptureDevice]

        if #available(iOS 10.0, *) {
            let session = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .unspecified)
            devices = session.devices
        }
        else {
            devices = AVCaptureDevice.devices(for: .video)
        }
        
        for device in devices {
            if device.position == .back {
                return device
            }
        }
        
        return nil
        
    }
    
    private func addInput(device: AVCaptureDevice) throws {
        
        let input = try AVCaptureDeviceInput(device: device)
        
        if captureSession.canAddInput(input) {
            captureSession.addInput(input)
        }
        
    }
    
    private func addOutput() {
        
        let output = AVCaptureMetadataOutput()
        
        if captureSession.canAddOutput(output) {
            captureSession.addOutput(output)
        }
        
        output.metadataObjectTypes = supportedCodeTypes
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        
    }
    
    private func addPreview() {
        
        capturePreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        capturePreviewLayer.videoGravity = .resizeAspectFill
        capturePreviewLayer.frame = bounds
        
        layer.addSublayer(capturePreviewLayer)
        
    }
    
    private func setTorchMode(_ torchMode: AVCaptureDevice.TorchMode) -> Bool {
        
        do {
            try captureDevice.lockForConfiguration()
            
            captureDevice.torchMode = torchMode
            if torchMode == .on {
                try captureDevice.setTorchModeOn(level: 1.0)
            }
            
            captureDevice.unlockForConfiguration()
            
            return true
        }
        catch {
            print(error.localizedDescription)
        }
        
        return false
        
    }
    
    private func updateView() {

        let viewWidth = bounds.width
        let viewHeight = bounds.height
        
        let scale: CGFloat = 0.8
        let boxWidth = viewWidth * scale
        let boxHeight = min(viewHeight * scale, boxWidth)
        
        let box = CGRect(x: (viewWidth - boxWidth) / 2, y: (viewHeight - boxHeight) / 2, width: boxWidth, height: boxHeight)

        laserView.frame.size = CGSize(width: boxWidth - 2 * viewFinder.borderWidth - 2 * laserGap, height: laserHeight)
        laserView.center.x = box.midX
        
        viewFinder.frame = bounds
        viewFinder.box = box
        viewFinder.setNeedsLayout()
        viewFinder.setNeedsDisplay()
        
        guideView.center.x = bounds.midX
        guideView.frame.origin.y = box.origin.y + boxHeight + guideMarginTop
        
        torchButton.center.x = bounds.midX
        torchButton.frame.origin.y = box.origin.y - torchButtonMarginBottom - torchButtonHeight
        
        stopLaser()

    }

    private func startLaser() {

        guard let box = viewFinder.box, !laserView.isHidden else {
            return
        }
        
        let top = box.origin.y + viewFinder.borderWidth + laserHeight / 2
        let bottom = box.origin.y + box.height - viewFinder.borderWidth - laserHeight / 2
        
        laserView.center.y = top
        
        UIView.animate(withDuration: 3, delay: 0, options: .curveLinear, animations: {
            self.laserView.center.y = bottom
        }, completion: { success in
            self.startLaser()
        })
        
    }
    
    private func stopLaser() {
        laserView.layer.removeAllAnimations()
    }
    
    @objc private func onTorchToggle() {
        isTorchOn = !isTorchOn
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        updateView()
    }
    
}

extension CodeScanner: AVCaptureMetadataOutputObjectsDelegate {
    
    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        if metadataObjects.count == 0 {
            return
        }
        
        let metadataObject = metadataObjects[0]
        guard supportedCodeTypes.contains(metadataObject.type) else {
            return
        }
        
        let result = metadataObject as! AVMetadataMachineReadableCodeObject
        if let text = result.stringValue {
            onScanResult?(text)
        }
        
    }
}
