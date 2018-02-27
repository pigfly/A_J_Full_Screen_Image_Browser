//
//  FullScreenImageBrowserViewModel.swift
//  A_J_Full_Screen_Image_Browser
//
//  Created by Alex Jiang on 26/2/18.
//  Copyright © 2018 Junliang Jiang. All rights reserved.
//

import Foundation

public struct FullScreenImageBrowserViewModel {

    public init(urls: [URL?], videoUrl: URL? = nil) {
        self.urls = urls
        self.videoUrl = videoUrl

        images = urls.flatMap { SingleImage(imageURL: $0) }
    }

    public private(set) var urls: [URL?]
    public private(set) var videoUrl: URL?
    public private(set) var images: [ImageAsyncDownloadable] = []

    public var shouldShowVideo: Bool {
        return videoUrl != nil
    }

    public var numberOfImages: Int {
        return images.count
    }

    public func imageAtIndex(_ index: Int) -> ImageAsyncDownloadable? {
        if (index < images.count && index >= 0) {
            return images[index]
        }
        return nil
    }

    public func indexOfImage(_ image: ImageAsyncDownloadable) -> Int? {
        return images.index(where: { $0 === image })
    }

    public func containsImage(_ image: ImageAsyncDownloadable) -> Bool {
        return indexOfImage(image) != nil
    }
}
