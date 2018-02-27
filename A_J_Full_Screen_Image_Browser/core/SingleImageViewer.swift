//
//  SingleImageViewer.swift
//  A_J_Full_Screen_Image_Browser
//
//  Created by Junliang Jiang on 25/2/18.
//  Copyright © 2018 Junliang Jiang. All rights reserved.
//

import UIKit

public final class SingleImageViewer: UIViewController, UIScrollViewDelegate {

    // MARK: - Property
    public var asyncImage: ImageAsyncDownloadable

    public lazy private(set) var zoomableImageview: ZoomableImageView = {
        return ZoomableImageView()
    }()

    public lazy private(set) var doubleTapGestureRecognizer: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(SingleImageViewer.handleDoubleTapWithGestureRecognizer(_:)))
        gesture.numberOfTapsRequired = 2
        return gesture
    }()

    public lazy private(set) var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
        activityIndicator.startAnimating()
        return activityIndicator
    }()

    // MARK: - Init
    public init(image: ImageAsyncDownloadable) {
        asyncImage = image
        super.init(nibName: nil, bundle: nil)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        zoomableImageview.delegate = nil
    }

    //  MARK: - View Controller Life Cycle
    public override func viewDidLoad() {
        super.viewDidLoad()

        zoomableImageview.delegate = self
        zoomableImageview.frame = view.bounds
        zoomableImageview.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(zoomableImageview)

        view.addSubview(activityIndicator)
        activityIndicator.center = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
        activityIndicator.autoresizingMask = [.flexibleTopMargin, .flexibleLeftMargin, .flexibleRightMargin, .flexibleBottomMargin]
        activityIndicator.sizeToFit()

        view.addGestureRecognizer(doubleTapGestureRecognizer)

        if let image = asyncImage.image {
            zoomableImageview.image = image
            activityIndicator.stopAnimating()
        } else {
            loadAsyncImage()
        }
    }

    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        zoomableImageview.frame = view.bounds
    }

    // MARK: - Private
    private func loadAsyncImage() {
        view.bringSubview(toFront: activityIndicator)
        asyncImage.loadImageWithCompletionHandler({ [weak self] (image, error) -> () in
            let completeLoading = {
                self?.activityIndicator.stopAnimating()
                self?.zoomableImageview.image = image
            }

            if Thread.isMainThread {
                completeLoading()
            } else {
                DispatchQueue.main.async(execute: { () -> Void in
                    completeLoading()
                })
            }
        })
    }

    @objc private func handleDoubleTapWithGestureRecognizer(_ recognizer: UITapGestureRecognizer) {
        let pointInView = recognizer.location(in: zoomableImageview.imageView)
        var newZoomScale = zoomableImageview.maximumZoomScale

        if zoomableImageview.zoomScale >= zoomableImageview.maximumZoomScale ||
            abs(zoomableImageview.zoomScale - zoomableImageview.maximumZoomScale) <= 0.01 {
            newZoomScale = zoomableImageview.minimumZoomScale
        }

        let scrollViewSize = zoomableImageview.bounds.size
        let width = scrollViewSize.width / newZoomScale
        let height = scrollViewSize.height / newZoomScale
        let originX = pointInView.x - (width / 2.0)
        let originY = pointInView.y - (height / 2.0)

        let rectToZoom = CGRect(x: originX, y: originY, width: width, height: height)
        zoomableImageview.zoom(to: rectToZoom, animated: true)
    }

    // MARK:- UIScrollViewDelegate
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return zoomableImageview.imageView
    }

    public func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        scrollView.panGestureRecognizer.isEnabled = true
    }

    public func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        if (scrollView.zoomScale == scrollView.minimumZoomScale) {
            scrollView.panGestureRecognizer.isEnabled = false
        }
    }
}
