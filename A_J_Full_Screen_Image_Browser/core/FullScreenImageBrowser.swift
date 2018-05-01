//
//  FullScreenImageBrowser.swift
//  A_J_Full_Screen_Image_Browser
//
//  Created by Junliang Jiang on 25/2/18.
//  Copyright © 2018 Junliang Jiang. All rights reserved.
//

import UIKit
import AVKit

public final class FullScreenImageBrowser: UIViewController {

    // MARK: - Property
    public var viewModel: FullScreenImageBrowserViewModel
    public private(set) var pageViewController: UIPageViewController
    public let transitionAnimator: FullScreenImageTransitionAnimator = FullScreenImageTransitionAnimator()

    public private(set) lazy var singleTapGestureRecognizer: UITapGestureRecognizer = {
        return UITapGestureRecognizer(target: self, action: #selector(FullScreenImageBrowser.handleSingleTapGestureRecognizer(_:)))
    }()
    public private(set) lazy var panGestureRecognizer: UIPanGestureRecognizer = {
        return UIPanGestureRecognizer(target: self, action: #selector(FullScreenImageBrowser.handlePanGestureRecognizer(_:)))
    }()
    
    /*
     * The mask view displayed over images
     */
    public var maskView: MaskImageView = MaskImageView(frame: .zero) {
        willSet {
            maskView.removeFromSuperview()
        }
        didSet {
            maskView.imagesBrowser = self
            maskView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            maskView.frame = view.bounds
            view.addSubview(maskView)
        }
    }

    public var currentMedia: MediaDownloadable? {
        return currentImageViewer?.media
    }

    private var statusBarHidden = false

    // MARK: - Init
    required public init?(coder aDecoder: NSCoder) {
        viewModel = FullScreenImageBrowserViewModel(media: [])
        pageViewController = UIPageViewController()
        super.init(nibName: nil, bundle: nil)
        initialSetupWithImage(nil)
    }

    public override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: Bundle!) {
        viewModel = FullScreenImageBrowserViewModel(media: [])
        pageViewController = UIPageViewController()
        super.init(nibName: nil, bundle: nil)
        initialSetupWithImage(nil)
    }

    /**
     The designated initializer

     - parameter viewModel:     View model instance for Full Screen Image Browser.
     - parameter startingImage: The image to be displayed at first place when launching image browser.
     - parameter referenceView: The view from which to animate.

     - returns: an instance of full screen image browser
     */
    public required init(viewModel: FullScreenImageBrowserViewModel,
                startingImage: MediaDownloadable? = nil,
                referenceView: UIView? = nil) {
        self.viewModel = viewModel
        pageViewController = UIPageViewController()
        super.init(nibName: nil, bundle: nil)

        initialSetupWithImage(startingImage == nil ? viewModel.media.first : startingImage)
        transitionAnimator.startingView = referenceView
        transitionAnimator.endingView = currentImageViewer?.zoomableImageview.imageView
    }

    private func initialSetupWithImage(_ image: MediaDownloadable? = nil) {
        maskView.imagesBrowser = self
        setupPageViewControllerWith(image)

        modalPresentationStyle = .custom
        transitioningDelegate = self
        modalPresentationCapturesStatusBarAppearance = true

        let textColor = view.tintColor ?? UIColor.white
        #if swift(>=4.0)
            maskView.titleTextAttributes = [NSAttributedStringKey.foregroundColor: textColor]
        #else
            maskView.titleTextAttributes = [NSForegroundColorAttributeName: textColor]
        #endif
    }

    private func setupPageViewControllerWith(_ image: MediaDownloadable? = nil) {
        pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: [UIPageViewControllerOptionInterPageSpacingKey: 16.0])
        pageViewController.view.backgroundColor = .clear
        pageViewController.delegate = self
        pageViewController.dataSource = self

        if let _image = image, viewModel.containsMedia(_image) {
            changeToImage(_image, animated: false)
        } else if let _image = viewModel.media.first {
            changeToImage(_image, animated: false)
        }
    }

    private func setupMaskView() {
        maskView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        maskView.frame = view.bounds
        view.addSubview(maskView)
        maskView.setHidden(true, animated: false)
    }

    deinit {
        pageViewController.delegate = nil
        pageViewController.dataSource = nil
    }

    // MARK: - View Controller Life Cycle
    override public func viewDidLoad() {
        super.viewDidLoad()
        view.tintColor = .white
        view.backgroundColor = .black
        pageViewController.view.backgroundColor = .clear

        pageViewController.view.addGestureRecognizer(panGestureRecognizer)
        pageViewController.view.addGestureRecognizer(singleTapGestureRecognizer)

        addChildViewController(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        pageViewController.didMove(toParentViewController: self)

        setupMaskView()
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // This fix issue that navigationBar animate to up
        // when presentingViewController is UINavigationViewController
        statusBarHidden = true
        UIView.animate(withDuration: 0.25) { self.setNeedsStatusBarAppearanceUpdate() }
        updateCurrentImageInfo()
    }

    // MARK: - Public

    /**
     Displays the specified image. Can be called before the view controller is displayed.

     - parameter media:    The photo to make the currently displayed photo.
     - parameter animated: Whether to animate the transition to the new photo.
     */
    public func changeToImage(_ media: MediaDownloadable,
                              animated: Bool,
                              direction: UIPageViewControllerNavigationDirection = .forward) {
        if !viewModel.containsMedia(media) { return }

        let imageViewer = SingleMediaViewerFor(media)
        pageViewController.setViewControllers([imageViewer], direction: direction, animated: animated, completion: nil)
        updateCurrentImageInfo()
    }

    private func updateCurrentImageInfo() {
        if let _currentImage = currentMedia {
            maskView.populateWithImage(_currentImage)
        }
    }
}

// MARK: - UIPageViewController DataSource Delegate
extension FullScreenImageBrowser: UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    /*
     * Currently displayed by page view controller
     */
    public var currentImageViewer: SingleMediaViewer? {
        return pageViewController.viewControllers?.first as? SingleMediaViewer
    }

    public func SingleMediaViewerFor(_ media: MediaDownloadable) -> SingleMediaViewer {
        let imageViewer = SingleMediaViewer(media: media)
        singleTapGestureRecognizer.require(toFail: imageViewer.doubleTapGestureRecognizer)

        return imageViewer
    }

    @objc public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let imageViewer = viewController as? SingleMediaViewer,
            let index = viewModel.indexOfMedia(imageViewer.media),
            let newImage = viewModel.mediaAtIndex(index - 1) else {
                return nil
        }
        return SingleMediaViewerFor(newImage)
    }

    @objc public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let imageViewer = viewController as? SingleMediaViewer,
            let index = viewModel.indexOfMedia(imageViewer.media),
            let newImage = viewModel.mediaAtIndex(index + 1) else {
                return nil
        }
        return SingleMediaViewerFor(newImage)
    }

    @objc public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            updateCurrentImageInfo()
        }
    }
}

// MARK: - UIViewController Transitioning Delegate
extension FullScreenImageBrowser: UIViewControllerTransitioningDelegate {
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transitionAnimator.dismissing = false
        return transitionAnimator
    }

    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transitionAnimator.dismissing = true
        return transitionAnimator
    }
}

// MARK: - Gesture Recognizer
extension FullScreenImageBrowser {
    @objc private func handleSingleTapGestureRecognizer(_ gestureRecognizer: UITapGestureRecognizer) {
        maskView.setHidden(!maskView.isHidden, animated: true)

        guard let currentMedia = currentMedia, currentMedia.isVideoThumbnail == true else { return }
        playVideo()
    }

    @objc private func handlePanGestureRecognizer(_ gestureRecognizer: UIPanGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - Status Bar
extension FullScreenImageBrowser {
    public override var prefersStatusBarHidden: Bool {
        if let parentStatusBarHidden = presentingViewController?.prefersStatusBarHidden , parentStatusBarHidden == true {
            return parentStatusBarHidden
        }
        return statusBarHidden
    }

    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

    public override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .fade
    }
}

// MARK: - Video Showcase
extension FullScreenImageBrowser {
    public func playVideo() {
        guard let currentMedia = currentMedia else { return }
        guard let videoURL = currentMedia.videoURL else { debugPrint("\(#file) invalid url found for video"); return }
        let player = AVPlayer(url: videoURL)
        let playerController = AVPlayerViewController()
        playerController.player = player
        present(playerController, animated: true, completion: nil)
    }
}
