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
    ///   - videos: video array, $0 as video urls, $1 as associated video thumbnail image urls
    public init(imageURLs: [URL], videos: [(URL, URL)] = []) {
        self.imageURLs = imageURLs
        self.videoUrls = videos.map { $0.0 }
        let thumbnailImages = videos.map { SingleMedia(imageURL: $0.1, isVideoThumbnail: true) }
        self.videoThumbnails = thumbnailImages

        images = imageURLs.map { SingleMedia(imageURL: $0) } + thumbnailImages
    }

    public private(set) var imageURLs: [URL]
    public private(set) var videoUrls: [URL]
    public private(set) var videoThumbnails: [MediaDownloadable] = []

    // the images contain both static image and video thumbnail images
    public private(set) var images: [MediaDownloadable] = []

    // MARK: - Image

    public var numberOfImages: Int {
        return images.count
    }

    public func imageAtIndex(_ index: Int) -> MediaDownloadable? {
        if (index < images.count && index >= 0) {
            return images[index]
        }
        return nil
    }

    public func indexOfImage(_ image: MediaDownloadable) -> Int? {
        return images.index(where: { $0 === image })
    }

    public func containsImage(_ image: MediaDownloadable) -> Bool {
        return indexOfImage(image) != nil
    }

    // MARK: - Video

    public var shouldShowVideo: Bool {
        return videoUrls.count != 0
    }

    public func videoURLAtIndex(_ index: Int) -> URL? {
        guard index < images.count && index > 0 else { return nil }
        let videoIdx = index - imageURLs.count
        guard videoIdx >= 0 else { return nil }

        return videoUrls[videoIdx]
    }

    public func videoURLForImage(_ image: MediaDownloadable) -> URL? {
        guard image.isVideoThumbnail == true else { return nil}
        guard let idx = indexOfImage(image) else { return nil }

        return videoURLAtIndex(idx)
    }
}
