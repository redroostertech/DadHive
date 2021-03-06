//
//  UIImage+Extensions.swift
//  boothnoire
//
//  Created by Michael Westbrooks on 10/5/18.
//  Copyright © 2018 RedRooster Technologies Inc. All rights reserved.
//

import Foundation
import UIKit

let imageCache = NSCache <AnyObject,AnyObject>()
//  MARK:- Extensions for UIImageView
extension UIImageView {
    func makeCircular() {
        self.applyCornerRadius()
    }
    
    func makeAspectFill() {
        self.contentMode = .scaleAspectFill
    }
    
    func makeAspectFit() {
        self.contentMode = .scaleAspectFit
    }
    
    func setImage(name: String) {
        self.image = UIImage.getImage(name: name)
    }
    
    func setImage(image: UIImage) {
        self.image = image
    }

    public func imageFromUrl(theUrl: String) {
        self.image = nil

        //check cache for image
        if let cachedImage = imageCache.object(forKey: theUrl as AnyObject) as? UIImage{
            self.image = cachedImage
            return
        }

        //otherwise download it
        let url = URL(string: theUrl)
        URLSession.shared.dataTask(with: url!, completionHandler: {(data, response, error) in

            //print error
            if (error != nil){
                print(error!)
                return
            }

            DispatchQueue.main.async(execute: {
                if let downloadedImage = UIImage(data: data!){
                    imageCache.setObject(downloadedImage, forKey: theUrl as AnyObject)
                    self.image = downloadedImage
                }
            })

        }).resume()
    }
    
}

//  MARK:- Extensions for UIImage
extension UIImage {
    @objc class func imageFromColor(_ color: UIColor) -> UIImage {
        let rect: CGRect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context: CGContext = UIGraphicsGetCurrentContext()!
        context.setFillColor(color.cgColor)
        context.fill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    class func getImage(name: String) -> UIImage {
        return UIImage(named: name)!
    }
    
    func resizedImage(newSize: CGSize) -> UIImage {
        guard self.size != newSize else { return self }
        
        let originRatio = self.size.width / self.size.height
        let newRatio = newSize.width / newSize.height
        var size: CGSize = .zero
        
        if originRatio < newRatio {
            size.height = newSize.height
            size.width = newSize.height * originRatio
        } else {
            size.width = newSize.width
            size.height = newSize.width / originRatio
        }
        
        let scale: CGFloat = UIScreen.main.scale
        size.width /= scale
        size.height /= scale
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        self.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    func makeCentrallyAlignedCompositeImage(_ superImposeImage: UIImage, scaleInParts: CGFloat) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, true, 0.0)
        self.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let scale = (floor(scaleInParts / 2))/scaleInParts
        let width = size.width
        let height = size.height
        let compositeImageRect = CGRect(x: width*scale, y: height*scale, width: width/scaleInParts, height: height/scaleInParts)
        superImposeImage.draw(in: compositeImageRect)
        return UIGraphicsGetImageFromCurrentImageContext()!
    }

    var isPortrait:  Bool    { return size.height > size.width }
    var isLandscape: Bool    { return size.width > size.height }
    var breadth:     CGFloat { return min(size.width, size.height) }
    var breadthSize: CGSize  { return CGSize(width: breadth, height: breadth) }
    var breadthRect: CGRect  { return CGRect(origin: .zero, size: breadthSize) }
    var circleMasked: UIImage? {
        UIGraphicsBeginImageContextWithOptions(breadthSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        guard let cgImage = cgImage?.cropping(to: CGRect(origin: CGPoint(x: isLandscape ? floor((size.width - size.height) / 2) : 0, y: isPortrait  ? floor((size.height - size.width) / 2) : 0), size: breadthSize)) else { return nil }
        UIBezierPath(ovalIn: breadthRect).addClip()
        UIImage(cgImage: cgImage, scale: 1, orientation: imageOrientation).draw(in: breadthRect)
        return UIGraphicsGetImageFromCurrentImageContext()
    }

    func squareImage() -> UIImage {
        let image = self
        let originalWidth  = image.size.width
        let originalHeight = image.size.height
        var x: CGFloat = 0.0
        var y: CGFloat = 0.0
        var edge: CGFloat = 0.0

        if (originalWidth > originalHeight) {
            // landscape
            edge = originalHeight
            x = (originalWidth - edge) / 2.0
            y = 0.0

        } else if (originalHeight > originalWidth) {
            // portrait
            edge = originalWidth
            x = 0.0
            y = (originalHeight - originalWidth) / 2.0
        } else {
            // square
            edge = originalWidth
        }

        let cropSquare = CGRect(x:x, y:y, width:edge, height:edge)

        let imageRef = image.cgImage!.cropping(to: cropSquare)

        return UIImage(cgImage: imageRef!, scale: UIScreen.main.scale, orientation: image.imageOrientation)
    }
}
