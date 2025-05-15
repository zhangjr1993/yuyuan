
import UIKit

extension UIImage {
    func adjustImageSaturation(saturation: CGFloat) -> UIImage? {
        guard saturation != 1.0 else { return self }
        
        let inputImage = CIImage(image: self)
        let saturationFilter = CIFilter(name: "CIColorControls")!
        saturationFilter.setDefaults()
        saturationFilter.setValue(inputImage, forKey: kCIInputImageKey)
        saturationFilter.setValue(saturation, forKey: "inputSaturation")
        
        let processedImage = saturationFilter.outputImage!
        let outputImage = UIImage(ciImage: processedImage)
        
        return outputImage
    }
}
