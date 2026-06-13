import AVFoundation

public protocol BarcodeScanning: AnyObject {
    var session: AVCaptureSession { get }
    var onCodeScanned: ((String) -> Void)? { get set }
    func configure()
    func start()
    func stop()
    func reset()
    func setTorch(enabled: Bool)
}
