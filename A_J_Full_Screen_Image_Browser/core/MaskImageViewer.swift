//
//  MaskImageViewer.swift
//  A_J_Full_Screen_Image_Browser
//
//  Created by Junliang Jiang on 25/2/18.
//  Copyright © 2018 Junliang Jiang. All rights reserved.
//

import UIKit

public protocol MaskImageViewable: class {
    weak var imagesBrowser: FullScreenImageBrowser? { get set }

    func populateWithImage(_ image: ImageAsyncDownloadable)
    func setHidden(_ hidden: Bool, animated: Bool)
}

public final class MaskImageView: UIView , MaskImageViewable {
    public private(set) var navigationBar: UINavigationBar!

    public private(set) var navigationItem: UINavigationItem!
    public weak var imagesBrowser: FullScreenImageBrowser?
    private var currentImage: ImageAsyncDownloadable?

    public var shouldShowVideoButton: Bool = false {
        didSet {
            guard !shouldShowVideoButton else { return }
            rightBarButtonItem = nil
        }
    }

    public var leftBarButtonItem: UIBarButtonItem? {
        didSet {
            navigationItem.leftBarButtonItem = leftBarButtonItem
        }
    }
    public var rightBarButtonItem: UIBarButtonItem? {
        didSet {
            navigationItem.rightBarButtonItem = rightBarButtonItem
        }
    }

    #if swift(>=4.0)
    public var titleTextAttributes: [NSAttributedStringKey : AnyObject] = [:] {
        didSet {
            navigationBar.titleTextAttributes = titleTextAttributes
        }
    }
    #else
    public var titleTextAttributes: [String : AnyObject] = [:] {
        didSet {
            navigationBar.titleTextAttributes = titleTextAttributes
        }
    }
    #endif

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupNavigationBar()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if let hitView = super.hitTest(point, with: event) , hitView != self {
            return hitView
        }
        return nil
    }

    public override func layoutSubviews() {
        UIView.performWithoutAnimation {
            self.navigationBar.invalidateIntrinsicContentSize()
            self.navigationBar.layoutIfNeeded()
        }
        super.layoutSubviews()
    }

    public func setHidden(_ hidden: Bool, animated: Bool) {
        if isHidden == hidden { return }
        if !animated { isHidden = hidden; return }

        isHidden = false
        alpha = hidden ? 1.0 : 0.0

        UIView.animate(withDuration: 0.2,
                       delay: 0.0,
                       options: [.allowAnimatedContent, .allowUserInteraction],
                       animations: { self.alpha = hidden ? 0.0 : 1.0 },
                       completion: { _ in self.alpha = 1.0; self.isHidden = hidden })
    }

    public func populateWithImage(_ image: ImageAsyncDownloadable) {
        currentImage = image

        guard let _imagesBrowser = imagesBrowser,
              let index = imagesBrowser?.viewModel.indexOfImage(image) else { return }

        navigationItem.title = String(format:NSLocalizedString("%d of %d",comment:""),
                                      index+1,
                                      _imagesBrowser.viewModel.numberOfImages)
    }

    @objc private func closeButtonTapped(_ sender: UIBarButtonItem) {
        imagesBrowser?.dismiss(animated: true, completion: nil)
    }

    @objc private func actionButtonTapped(_ sender: UIBarButtonItem) {
        imagesBrowser?.playVideo()
    }

    private func setupNavigationBar() {
        navigationBar = UINavigationBar()
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        navigationBar.backgroundColor = UIColor.clear
        navigationBar.barTintColor = nil
        navigationBar.isTranslucent = true
        navigationBar.shadowImage = UIImage()
        navigationBar.setBackgroundImage(UIImage(), for: .default)

        navigationItem = UINavigationItem(title: "")
        navigationBar.items = [navigationItem]
        addSubview(navigationBar)

        let topConstraint: NSLayoutConstraint
        if #available(iOS 11.0, *) {
            topConstraint = navigationBar.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor)
        } else {
            topConstraint = navigationBar.topAnchor.constraint(equalTo: self.topAnchor)
        }
        let widthConstraint = navigationBar.widthAnchor.constraint(equalTo: self.widthAnchor)
        let horizontalConstraint = navigationBar.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        NSLayoutConstraint.activate([topConstraint, widthConstraint, horizontalConstraint])

        if let bundlePath = Bundle(for: type(of: self)).path(forResource: "FullScreenImageBrowser", ofType: "bundle") {
            let bundle = Bundle(path: bundlePath)
            leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "close", in: bundle, compatibleWith: nil),
                                                style: .plain,
                                                target: self,
                                                action: #selector(MaskImageView.closeButtonTapped(_:)))
        } else {
            leftBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Close",comment:""),
                                                style: .plain,
                                                target: self,
                                                action: #selector(MaskImageView.closeButtonTapped(_:)))
        }

        rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Video",comment:""),
                                             style: .plain,
                                             target: self,
                                             action: #selector(MaskImageView.actionButtonTapped(_:)))
    }
}
