//
//  SingleImage.swift
//  A_J_Full_Screen_Image_Browser
//
//  Created by Alex Jiang on 26/2/18.
//  Copyright © 2018 Junliang Jiang. All rights reserved.
//

import UIKit

public final class SingleImage: ImageAsyncDownloadable {
    public var image: UIImage?
    public var imageURL: URL?

    public init(imageURL: URL?) {
        self.imageURL = imageURL
    }

    public func loadImageWithCompletionHandler(_ completion: @escaping (UIImage?, NSError?) -> ()) {
        if let image = image {
            completion(image, nil)
            return
        }
        loadImageWithURL(imageURL, completion: completion)
    }

    // override this method to use your favourite networking service
    public func loadImageWithURL(_ url: URL?, completion: @escaping (_ image: UIImage?, _ error: NSError?) -> ()) {
        let session = URLSession(configuration: URLSessionConfiguration.default)

        if let imageURL = url {
            session.dataTask(with: imageURL, completionHandler: { (response, data, error) in
                DispatchQueue.main.async(execute: { () -> Void in
                    if error != nil {
                        completion(nil, error as NSError?)
                    } else if let response = response, let image = UIImage(data: response) {
                        completion(image, nil)
                    } else {
                        completion(nil, NSError(domain: "FullScreenImageBrowserDomain", code: -1, userInfo: [ NSLocalizedDescriptionKey: "Couldn't load image"]))
                    }
                    session.finishTasksAndInvalidate()
                })
            }).resume()
        } else {
            completion(nil, NSError(domain: "FullScreenImageBrowserDomain", code: -2, userInfo: [ NSLocalizedDescriptionKey: "Image URL not found."]))
        }
    }
}
