//
//  ViewController.swift
//  A_J_Full_Screen_Image_Browser
//
//  Created by Junliang Jiang on 25/2/18.
//  Copyright © 2018 Junliang Jiang. All rights reserved.
//

import UIKit

final class ViewController: UIViewController {

    lazy var images: [ImageAsyncDownloadable] = {
        return [SingleImage(imageURL: URL(string: "https://images.unsplash.com/photo-1445264918150-66a2371142a2?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=79730c9ec106e3ccee026c648c624e5f&auto=format&fit=crop&w=3800&q=80")!),
                SingleImage(imageURL: URL(string: "https://images.unsplash.com/photo-1483086431886-3590a88317fe?ixlib=rb-0.3.5&s=96129ab02a4a277f5c27273d14323a9a&auto=format&fit=crop&w=3668&q=80")!)]
    }()

    lazy var urls = [URL(string: "https://images.unsplash.com/photo-1502899576159-f224dc2349fa?ixlib=rb-0.3.5&s=4f3943a5d663f9bb062d7d380c8d6fdf&auto=format&fit=crop&w=3700&q=80")!,
                     URL(string: "https://images.unsplash.com/photo-1445264918150-66a2371142a2?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=79730c9ec106e3ccee026c648c624e5f&auto=format&fit=crop&w=3800&q=80")!]

    // videos are just tuple array
    // $0: video url
    // $1: thumbnail url for associated video url
    lazy var videos = [(URL(string: "http://jplayer.org/video/m4v/Big_Buck_Bunny_Trailer.m4v")!, URL(string: "https://images.unsplash.com/photo-1502899576159-f224dc2349fa?ixlib=rb-0.3.5&s=4f3943a5d663f9bb062d7d380c8d6fdf&auto=format&fit=crop&w=3700&q=80")!), (URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, URL(string: "https://images.unsplash.com/photo-1502899576159-f224dc2349fa?ixlib=rb-0.3.5&s=4f3943a5d663f9bb062d7d380c8d6fdf&auto=format&fit=crop&w=3700&q=80")!)]

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

