//
//  Image+AsyncDownload.swift
//  A_J_Full_Screen_Image_Browser
//
//  Created by Junliang Jiang on 25/2/18.
//  Copyright © 2018 Junliang Jiang. All rights reserved.
//

import UIKit

public protocol ImageAsyncDownloadable: class {
    var image: UIImage? { get }
    var imageURL: URL? { get }

    func loadImageWithCompletionHandler(_ completion: @escaping (_ image: UIImage?, _ error: NSError?) -> ())
}
