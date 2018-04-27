<p align="center">
    <img src="https://github.com/pigfly/A_J_Full_Screen_Image_Browser/blob/master/assets/logo.png?raw=true">
</p>

# A-J-Full-Screen-Image-Browser

![Travis](https://img.shields.io/travis/USER/REPO.svg)
![Code](https://img.shields.io/badge/code-%E2%98%85%E2%98%85%E2%98%85%E2%98%85%E2%98%85-brightgreen.svg)
![Swift](https://img.shields.io/badge/Swift-%3E%3D%203.1-orange.svg)
![npm](https://img.shields.io/npm/l/express.svg)

A-J-Full-Screen-Image-Browser is an drop-in solution for full screen image and video browser

## Features

- [x] No Dependency, 100% iOS Native
- [x] Support both iPad and iPhone family
- [x] Support image resizing on different screen orientation
- [x] Support multiple videos and images
- [x] Image can be panned, zoomed and rotated
- [x] Double tap to zoom all the way in and again to zoom all the way out
- [x] Swipe to dismiss
- [x] High level diagram
- [x] MVVM architecture
- [x] Full documentation
- [x] Easy to customise

## Requirements

- iOS 8.0+ / macOS 10.10+ / tvOS 9.0+ / watchOS 2.0+
- Xcode 8.3+
- Swift 3.1+

## Installation

- drag and drop the entire `A_J_Full_Screen_Image_Browser` into your project

## Full Usage Example

```swift
import UIKit

final class ViewController: UIViewController {

    lazy var images: [ImageAsyncDownloadable] = {
        return [SingleImage(imageURL: URL(string: "https://images.unsplash.com/photo-1445264918150-66a2371142a2?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=79730c9ec106e3ccee026c648c624e5f&auto=format&fit=crop&w=3800&q=80")!),
                SingleImage(imageURL: URL(string: "https://images.unsplash.com/photo-1483086431886-3590a88317fe?ixlib=rb-0.3.5&s=96129ab02a4a277f5c27273d14323a9a&auto=format&fit=crop&w=3668&q=80")!)]
    }()

    lazy var urls = [URL(string: "https://images.unsplash.com/photo-1502899576159-f224dc2349fa?ixlib=rb-0.3.5&s=4f3943a5d663f9bb062d7d380c8d6fdf&auto=format&fit=crop&w=3700&q=80")!,
                     URL(string: "https://images.unsplash.com/photo-1445264918150-66a2371142a2?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=79730c9ec106e3ccee026c648c624e5f&auto=format&fit=crop&w=3800&q=80")!]

    // videos are just key-value pair
    // key: video url
    // value: thumbnail url for associated video url
    lazy var videos = [URL(string: "http://jplayer.org/video/m4v/Big_Buck_Bunny_Trailer.m4v")!: URL(string: "https://images.unsplash.com/photo-1502899576159-f224dc2349fa?ixlib=rb-0.3.5&s=4f3943a5d663f9bb062d7d380c8d6fdf&auto=format&fit=crop&w=3700&q=80")!]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func onButtonTapped(_ sender: UIButton) {
        let vm = FullScreenImageBrowserViewModel(imageURLs: urls, videos: videos)
        let x = FullScreenImageBrowser(viewModel: vm)
        present(x, animated: true, completion: nil)
    }

}
```

## AlamofireImage Support

> By default, `FullScreenImageBrowser` doesn't use any 3rd library, the `SingleImage` uses `URLSession` to fetch image. However it's designed to be compatible with any networking library, one good example is [AlamofireImage](https://github.com/Alamofire/AlamofireImage)

The following code snippet shows an example how to use `AlamofireImage` to seamlessly integrated with `FullScreenImageBrowser`.

```swift
import Foundation
import AlamofireImage

public class FullScreenImage: ImageAsyncDownloadable {
    public var image: UIImage?
    public var imageURL: URL?

    private let downloader = ImageDownloader()

    public init(imageURL: URL?) {
        self.imageURL = imageURL
    }

    public func loadImageWithCompletionHandler(_ completion: @escaping (UIImage?, NSError?) -> Void) {
        if let image = image {
            completion(image, nil)
            return
        }
        loadImageWithURL(imageURL, completion: completion)
    }

    // use any network calls you like
    public func loadImageWithURL(_ url: URL?, completion: @escaping (_ image: UIImage?, _ error: NSError?) -> Void) {
        guard let _url = url else {
            completion(nil, NSError(domain: "FullScreenImageBrowserDomain",
                                    code: -2,
                                    userInfo: [ NSLocalizedDescriptionKey: "Image URL not found."]))
            return
        }
        let urlRequest = URLRequest(url: _url)

        downloader.download(urlRequest) { [weak self] response in
            debugPrint(response.result)

            if let remoteImage = response.result.value {
                self?.image = remoteImage
                completion(remoteImage, nil)
            } else {
                completion(nil, NSError(domain: "FullScreenImageBrowserDomain",
                                        code: -1,
                                        userInfo: [ NSLocalizedDescriptionKey: "Couldn't load image from remote"]))
            }
        }
    }
}
```

## Folder Structure

```shell
├── animator
│   └── FullScreenImageTransitionAnimator.swift
├── asset
│   └── FullScreenImageBrowser.bundle
│       ├── close.png
│       ├── close@2x.png
│       └── close@3x.png
├── core
│   ├── FullScreenImageBrowser.swift
│   ├── FullScreenImageBrowserViewModel.swift
│   ├── Image+AsyncDownload.swift
│   ├── MaskImageViewer.swift
│   ├── SingleImageViewer.swift
│   └── ZoomableImageView.swift
└── helper
    ├── SingleImage.swift
    └── UIView+SnapShot.swift
```

| File                                 | Responsiblity                                                                        |
|--------------------------------------|--------------------------------------------------------------------------------------|
| animator                             | customised fade in/fade out animations with damping factors                          |
| asset                                | customised static image asset for the full screen image/video browser navigation bar |
| core/FullScreenImageBrowser          | manager class to be responsible for full screen image/video browser                  |
| core/FullScreenImageBrowserViewModel | datasource and business logic for full screen image/video browser                    |
| core/Image+AsyncDownload             | protocol to define images to be able to asynchronously download                      |
| core/MaskImageViewer                 | `customised` overlay view for full screen image/video browser                        |
| core/SingleImageViewer               | view controller to be responsible for single image rendering on the full screen      |
| core/ZoomableImageView               | view to add support for image to zoom, pin, rotate, and animation                    |

## Demo

<p align="center">
    <img src="https://github.com/pigfly/A_J_Full_Screen_Image_Browser/blob/master/assets/demo.gif?raw=true">
</p>

<p align="center">
    <img src="https://github.com/pigfly/A_J_Full_Screen_Image_Browser/blob/master/assets/demo2.gif?raw=true">
</p>

<p align="center">
    <img src="https://github.com/pigfly/A_J_Full_Screen_Image_Browser/blob/master/assets/demo3.gif?raw=true">
</p>

<p align="center">
    <img src="https://github.com/pigfly/A_J_Full_Screen_Image_Browser/blob/master/assets/demo4.gif?raw=true">
</p>

<p align="center">
    <img src="https://github.com/pigfly/A_J_Full_Screen_Image_Browser/blob/master/assets/demo5.gif?raw=true">
</p>

<p align="center">
    <img src="https://github.com/pigfly/A_J_Full_Screen_Image_Browser/blob/master/assets/demo6.gif?raw=true">
</p>

## HLD

<p align="center">
    <img src="https://github.com/pigfly/A_J_Full_Screen_Image_Browser/blob/master/assets/hld.png?raw=true">
</p>


## Credits

A-J-Full-Screen-Image-Browser is owned and maintained by the [Alex Jiang](https://pigfly.github.io). Thanks [iTMan.design](https://itman.design) for providing computational resources.

## License

A-J-Full-Screen-Image-Browser is released under the MIT license.