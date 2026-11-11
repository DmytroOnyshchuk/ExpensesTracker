import UIKit

extension UIImage {
    convenience init?(circleDiameter: CGFloat, color: UIColor) {
        let size = CGSize(width: circleDiameter, height: circleDiameter)

        let renderer = UIGraphicsImageRenderer(size: size)

        let image = renderer.image { ctx in
            color.setFill()
            ctx.cgContext.fillEllipse(in: CGRect(origin: .zero, size: size))
        }

        guard let cgImage = image.cgImage else {
            return nil
        }

        self.init(cgImage: cgImage)
    }

    func scaled(toMaxWidth width: CGFloat, maxHeight height: CGFloat) -> UIImage {
        let oldWidth = size.width
        let oldHeight = size.height

        guard oldHeight > height || oldWidth > width else { return self }

        let scaleFactor = (oldWidth > width) ? width / oldWidth : height / oldHeight
        let newHeight = oldHeight * scaleFactor
        let newWidth = oldWidth * scaleFactor
        let newSize = CGSize(width: newWidth, height: newHeight)

        UIGraphicsBeginImageContext(newSize)
        draw(in: .init(origin: .zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage ?? self
    }

    func withRoundedCorners(radius: CGFloat? = nil) -> UIImage? {
        let maxRadius = min(size.width, size.height) / 2
        let cornerRadius: CGFloat = if let radius, radius > 0, radius <= maxRadius {
            radius
        } else {
            maxRadius
        }
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        let rect = CGRect(origin: .zero, size: size)
        UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius).addClip()
        draw(in: rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }

    func scaledToSize(newSize: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        draw(in: CGRectMake(0, 0, newSize.width, newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }

    func makeLocalURL() -> URL? {
        let fileManager = FileManager.default
        let imageName = "\(Int.random(in: 0 ... 9999)).jpg"

        guard let cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first else { return nil }
        let url = cacheDirectory.appendingPathComponent(imageName)

        guard fileManager.fileExists(atPath: url.path) else {
            guard let data = pngData() else { return nil }
            fileManager.createFile(atPath: url.path, contents: data, attributes: nil)
            return url
        }

        return url
    }

    func resizeImage(targetSize: CGSize) -> UIImage {
        let size = size

        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height

        let newSize: CGSize = if widthRatio > heightRatio {
            CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }

        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage ?? UIImage()
    }

    // Getting optimal image size for avoid blurring
    func getOptimalSize() -> CGSize {
        var scale = 1
        let optimalWidth = 400 // 300 worthest quality
        let optimalHeight = 400 // 300 worthest quality

        while Int(size.width) / scale / 2 >= optimalWidth && Int(size.height) / scale / 2 >= optimalHeight {
            scale *= 2
        }
        return CGSize(width: size.width / CGFloat(scale),
                      height: size.height / CGFloat(scale))
    }

    func getOptimalSizeImage() -> UIImage {
        let newSize = getOptimalSize()
        return resizeImage(targetSize: newSize)
    }
}

extension UIImage {
    enum JPEGQuality: CGFloat {
        case lowest = 0
        case low = 0.25
        case medium = 0.5
        case high = 0.75
        case highest = 1
    }

    /// Returns the data for the specified image in JPEG format.
    /// If the image object’s underlying image data has been purged, calling this function forces that data to be reloaded into memory.
    /// - returns: A data object containing the JPEG data, or nil if there was a problem generating the data. This function may return nil if the image has no data or if the underlying CGImageRef contains data in an unsupported bitmap format.
    func jpeg(_ jpegQuality: JPEGQuality) -> Data? {
        jpegData(compressionQuality: jpegQuality.rawValue)
    }
}
