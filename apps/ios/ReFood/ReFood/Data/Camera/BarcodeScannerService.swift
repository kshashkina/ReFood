import AVFoundation

public final class BarcodeScannerService: NSObject, BarcodeScanning {
    public let session = AVCaptureSession()
    public var onCodeScanned: ((String) -> Void)?
    private let sessionQueue = DispatchQueue(label: "barcode.scanner.session.queue")
    private var videoDeviceInput: AVCaptureDeviceInput?
    private var isRunning = false
    private var didEmitCode = false
    private let supportedTypes: [AVMetadataObject.ObjectType] = [
        .ean13,
        .ean8,
        .upce,
        .code128
    ]
    public override init() {
        super.init()
    }

    public func configure() {
        sessionQueue.async { [weak self] in
            guard let self else { return }

            self.session.beginConfiguration()
            self.session.sessionPreset = .high

            guard let device = AVCaptureDevice.default(
                .builtInWideAngleCamera,
                for: .video,
                position: .back
            ) else {
                self.session.commitConfiguration()
                return
            }

            do {
                let input = try AVCaptureDeviceInput(device: device)

                if self.session.canAddInput(input) {
                    self.session.addInput(input)
                    self.videoDeviceInput = input
                } else {
                    self.session.commitConfiguration()
                    return
                }
            } catch {
                self.session.commitConfiguration()
                return
            }
            let metadataOutput = AVCaptureMetadataOutput()

            if self.session.canAddOutput(metadataOutput) {
                self.session.addOutput(metadataOutput)
                metadataOutput.setMetadataObjectsDelegate(self, queue: .main)
                metadataOutput.metadataObjectTypes = self.supportedTypes
            }
            self.session.commitConfiguration()
        }
    }

    public func start() {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            guard !self.isRunning else { return }

            self.didEmitCode = false
            self.session.startRunning()
            self.isRunning = true
        }
    }

    public func stop() {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            guard self.isRunning else { return }

            self.session.stopRunning()
            self.isRunning = false
        }
    }

    public func reset() {
        sessionQueue.async { [weak self] in
            self?.didEmitCode = false
        }
    }

    public func setTorch(enabled: Bool) {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            guard
                let device = self.videoDeviceInput?.device,
                device.hasTorch
            else { return }

            do {
                try device.lockForConfiguration()
                device.torchMode = enabled ? .on : .off
                device.unlockForConfiguration()
            } catch { }
        }
    }
}

extension BarcodeScannerService: AVCaptureMetadataOutputObjectsDelegate {

    public func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {

        guard !didEmitCode else { return }

        guard let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let value = object.stringValue,
              !value.isEmpty
        else { return }

        didEmitCode = true
        onCodeScanned?(value)
    }
}
