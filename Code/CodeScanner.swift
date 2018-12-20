
import UIKit
import AVFoundation

public class CodeScanner: UIView {
    
    public var supportedCodeTypes: [AVMetadataObject.ObjectType] = [ .qr, .code128 ]
    
    public var onScanResult: ((String) -> Void)?
    
    private var configuration: CodeScannerConfiguration!
    
    private var captureSession: AVCaptureSession!
    
    private var captureDevice: AVCaptureDevice!
    
    private var capturePreviewLayer: AVCaptureVideoPreviewLayer?
    
    private var isTorchOn = false {
        didSet {
            if isTorchOn {
                if setTorchMode(.on) {
                    torchButton.setImage(configuration.torchOffImage, for: .normal)
                }
            }
            else {
                if setTorchMode(.off) {
                    torchButton.setImage(configuration.torchOnImage, for: .normal)
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
        
        view.backgroundColor = configuration.laserColor
        view.isHidden = true
        
        addSubview(view)
        
        return view
        
    }()
    
    private lazy var viewFinder: ViewFinder = {
        
        let view = ViewFinder()
        
        view.maskColor = configuration.viewFinderMaskColor
        view.borderWidth = configuration.viewFinderBorderWidth
        view.borderColor = configuration.viewFinderBorderColor
        view.cornerSize = configuration.viewFinderCornerSize
        view.cornerWidth = configuration.viewFinderCornerWidth
        view.cornerColor = configuration.viewFinderCornerColor
        
        addSubview(view)
        
        return view
        
    }()
    
    private lazy var guideView: UILabel = {
        
        let view = UILabel()
        
        view.text = configuration.guideTitle
        view.font = configuration.guideTextFont
        view.textColor = configuration.guideTextColor
        
        view.sizeToFit()
        
        addSubview(view)
        
        return view
        
    }()
    
    private lazy var torchButton: UIButton = {
        
        let view = UIButton()
        
        view.setImage(configuration.torchOffImage, for: .normal)
        view.frame.size = CGSize(width: configuration.torchButtonWidth, height: configuration.torchButtonHeight)
        view.isHidden = true
        
        addSubview(view)
        
        view.addTarget(self, action: #selector(onTorchToggle), for: .touchUpInside)
        
        return view
        
    }()
    
    public convenience init(configuration: CodeScannerConfiguration) {
        
        self.init()
        self.configuration = configuration
        
        setup()
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
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
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        
        layer.insertSublayer(previewLayer, at: 0)
        
        capturePreviewLayer = previewLayer
        
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

        capturePreviewLayer?.frame = bounds
        
        laserView.frame.size = CGSize(width: boxWidth - 2 * configuration.viewFinderBorderWidth - 2 * configuration.laserGap, height: configuration.laserHeight)
        laserView.center.x = box.midX
        
        viewFinder.frame = bounds
        viewFinder.box = box
        viewFinder.setNeedsLayout()
        viewFinder.setNeedsDisplay()
        
        guideView.center.x = bounds.midX
        guideView.frame.origin.y = box.origin.y + boxHeight + configuration.guideMarginTop
        
        torchButton.center.x = bounds.midX
        torchButton.frame.origin.y = box.origin.y - configuration.torchButtonMarginBottom - configuration.torchButtonHeight
        
        stopLaser()

    }

    private func startLaser() {

        guard let box = viewFinder.box, !laserView.isHidden else {
            return
        }
        
        let top = box.origin.y + configuration.viewFinderBorderWidth + configuration.laserHeight / 2
        let bottom = box.origin.y + box.height - configuration.viewFinderBorderWidth - configuration.laserHeight / 2
        
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
