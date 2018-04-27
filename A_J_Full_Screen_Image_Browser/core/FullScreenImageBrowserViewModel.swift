//
//  FullScreenImageBrowserViewModel.swift
//  A_J_Full_Screen_Image_Browser
//
//  Created by Alex Jiang on 26/2/18.
//  Copyright © 2018 Junliang Jiang. All rights reserved.
//

import Foundation

public struct FullScreenImageBrowserViewModel {

    /// Designated Initializer for Full Screen Image Browser View Model
    ///
    /// - Parameters:
    ///   - imageURLs: image urls
    ///   - videos: video dictionary, key as video urls, value as associated video thumbnail image urls
    public init(imageURLs: [URL], videos: [URL: URL] = [:]) {
        self.imageURLs = imageURLs
        self.videoUrls = Array(videos.keys)
        let thumbnailImages = Array(videos.values).map { SingleImage(imageURL: $0, isVideoThumbnail: true) }
        self.videoThumbnails = thumbnailImages

        images = imageURLs.map { SingleImage(imageURL: $0) } + thumbnailImages
    }

    public private(set) var imageURLs: [URL]
    public private(set) var videoUrls: [URL]
    public private(set) var videoThumbnails: [ImageAsyncDownloadable] = []

    // the images contain both static image and video thumbnail images
    public private(set) var images: [ImageAsyncDownloadable] = []

    // MARK: - Image

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

    // MARK: - Video

    public var shouldShowVideo: Bool {
        return videoUrls.count != 0
    }

    public func videoURLAtIndex(_ index: Int) -> URL? {
        guard index < images.count && index > 0 else { return nil }
        let videoIdx = index + 1 - images.count
        guard videoIdx >= 0 else { return nil }

        return videoUrls[videoIdx]
    }

    public func videoURLForImage(_ image: ImageAsyncDownloadable) -> URL? {
        guard image.isVideoThumbnail == true else { return nil}
        guard let idx = indexOfImage(image) else { return nil }

        return videoURLAtIndex(idx)
    }
}
