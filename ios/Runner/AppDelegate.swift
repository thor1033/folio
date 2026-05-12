import CoreGraphics
import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
    private var pdfDocument: CGPDFDocument?

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)

        guard let controller = window?.rootViewController as? FlutterViewController else {
            return super.application(application, didFinishLaunchingWithOptions: launchOptions)
        }

        let channel = FlutterMethodChannel(
            name: "com.thorsimonsen.folio/pdf",
            binaryMessenger: controller.binaryMessenger
        )

        channel.setMethodCallHandler { [weak self] call, result in
            switch call.method {
            case "openDocument":
                guard let args = call.arguments as? [String: Any],
                      let path = args["path"] as? String
                else {
                    result(FlutterError(code: "INVALID_ARGS", message: "Missing path", details: nil))
                    return
                }
                DispatchQueue.global(qos: .userInitiated).async {
                    self?.openDocument(path: path, result: result)
                }

            case "getPageCount":
                result(self?.pdfDocument?.numberOfPages ?? 0)

            case "renderPage":
                guard let args = call.arguments as? [String: Any],
                      let index = args["index"] as? Int,
                      let width = args["width"] as? Int
                else {
                    result(FlutterError(code: "INVALID_ARGS", message: "Missing index or width", details: nil))
                    return
                }
                DispatchQueue.global(qos: .userInitiated).async {
                    self?.renderPage(index: index, width: width, result: result)
                }

            case "closeDocument":
                self?.pdfDocument = nil
                result(nil)

            default:
                result(FlutterMethodNotImplemented)
            }
        }

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    private func openDocument(path: String, result: FlutterResult) {
        let url = URL(fileURLWithPath: path)
        guard let doc = CGPDFDocument(url as CFURL) else {
            DispatchQueue.main.async {
                result(FlutterError(code: "OPEN_ERROR", message: "Failed to open \(path)", details: nil))
            }
            return
        }
        pdfDocument = doc
        DispatchQueue.main.async { result(doc.numberOfPages) }
    }

    private func renderPage(index: Int, width: Int, result: FlutterResult) {
        guard let doc = pdfDocument,
              let page = doc.page(at: index + 1) // CGPDFDocument pages are 1-indexed
        else {
            DispatchQueue.main.async {
                result(FlutterError(code: "INVALID_PAGE", message: "Page \(index) not found", details: nil))
            }
            return
        }

        let mediaBox = page.getBoxRect(.mediaBox)
        let scale = CGFloat(width) / mediaBox.width
        let renderWidth = width
        let renderHeight = Int(ceil(mediaBox.height * scale))

        guard let ctx = CGContext(
            data: nil,
            width: renderWidth,
            height: renderHeight,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.noneSkipFirst.rawValue
        ) else {
            DispatchQueue.main.async {
                result(FlutterError(code: "CONTEXT_ERROR", message: "Failed to create CGContext", details: nil))
            }
            return
        }

        // White background
        ctx.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 1))
        ctx.fill(CGRect(x: 0, y: 0, width: renderWidth, height: renderHeight))

        // PDF origin is bottom-left; flip to top-left for screen coordinates
        ctx.translateBy(x: 0, y: CGFloat(renderHeight))
        ctx.scaleBy(x: scale, y: -scale)
        ctx.drawPDFPage(page)

        guard let cgImage = ctx.makeImage() else {
            DispatchQueue.main.async {
                result(FlutterError(code: "IMAGE_ERROR", message: "Failed to create CGImage", details: nil))
            }
            return
        }

        guard let pngData = UIImage(cgImage: cgImage).pngData() else {
            DispatchQueue.main.async {
                result(FlutterError(code: "ENCODE_ERROR", message: "Failed to encode PNG", details: nil))
            }
            return
        }

        DispatchQueue.main.async {
            result(FlutterStandardTypedData(bytes: pngData))
        }
    }
}
