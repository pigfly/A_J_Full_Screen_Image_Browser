//
//  UIImage+Ex.swift
//  A_J_Full_Screen_Image_Browser
//
//  Created by Alex Jiang on 27/4/18.
//  Copyright © 2018 Junliang Jiang. All rights reserved.
//

import UIKit

public extension UIImage {
    public func aj_imageWithPlayIcon() -> UIImage {
        guard let bundlePath = Bundle(for: SingleMedia.self).path(forResource: "FullScreenImageBrowser", ofType: "bundle") else { return self }
        guard let playButtonImage = UIImage(named: "video-play-icon", in: Bundle(path: bundlePath), compatibleWith: nil) else { return self }

        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let width = min(size.width, size.height) * 0.2
        let x = size.width / 2.0 - width / 2.0
        let y = size.height / 2.0 - width / 2.0
        playButtonImage.draw(in: CGRect(x: x, y: y, width: width, height: width))

        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return self }
        UIGraphicsEndImageContext()

        return result
    }
}
