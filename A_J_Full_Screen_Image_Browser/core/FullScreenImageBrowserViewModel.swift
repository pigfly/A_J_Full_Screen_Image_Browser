//
//  FullScreenImageBrowserViewModel.swift
//  A_J_Full_Screen_Image_Browser
//
//  Created by Alex Jiang on 26/2/18.
//  Copyright © 2018 Junliang Jiang. All rights reserved.
//

import Foundation

public struct FullScreenImageBrowserViewModel {


    public init(media: [MediaDownloadable]) {
        self.media = media
    }

    public private(set) var media: [MediaDownloadable]

    // MARK: - Image

    public var numberOfImages: Int {
        return media.count
    }

    public func mediaAtIndex(_ index: Int) -> MediaDownloadable? {
        if (index < media.count && index >= 0) {
            return media[index]
        }
        return nil
    }

    public func indexOfMedia(_ media: MediaDownloadable) -> Int? {
        return self.media.index(where: { $0 === media })
    }

    public func containsMedia(_ media: MediaDownloadable) -> Bool {
        return indexOfMedia(media) != nil
    }

    // MARK: - Video

    public var shouldShowVideo: Bool {
        return media.contains { $0.isVideoThumbnail == true }
    }

    public func videoURLAtIndex(_ index: Int) -> URL? {
        guard index < media.count && index > 0 else { return nil }
        guard let videoURL = media[index].videoURL else { return nil }

        return videoURL
    }
}
