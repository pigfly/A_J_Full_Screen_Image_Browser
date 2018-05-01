//
//  ViewController.swift
//  A_J_Full_Screen_Image_Browser
//
//  Created by Junliang Jiang on 25/2/18.
//  Copyright © 2018 Junliang Jiang. All rights reserved.
//

import UIKit

final class ViewController: UIViewController {

    lazy var testVideo: MediaDownloadable = {
        return SingleMedia(imageURL: URL(string: "https://dummyimage.com/600&text=thumbnail")!,
                    isVideoThumbnail: true,
                    videoURL: URL(string: "http://jplayer.org/video/m4v/Big_Buck_Bunny_Trailer.m4v")!)
    }()

    lazy var media: [MediaDownloadable] = {
        return [testVideo,
                SingleMedia(imageURL: URL(string: "https://dummyimage.com/300")!),
                SingleMedia(imageURL: URL(string: "https://dummyimage.com/600")!),
                testVideo]
    }()

    @IBAction func onButtonTapped(_ sender: UIButton) {
        let vm = FullScreenImageBrowserViewModel(media: media)
        let x = FullScreenImageBrowser(viewModel: vm)
        present(x, animated: true, completion: nil)
    }

}

