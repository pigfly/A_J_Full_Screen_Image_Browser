//
//  MaskImageViewer.swift
//  A_J_Full_Screen_Image_Browser
//
//  Created by Junliang Jiang on 25/2/18.
//  Copyright © 2018 Junliang Jiang. All rights reserved.
//

import UIKit

public protocol MaskImageViewable:class {
    weak var imagesBrowser: FullScreenImageBrowser? { get set }

    func populateWithImage(_ image: ImageAsyncDownloadable)
    func setHidden(_ hidden: Bool, animated: Bool)
    func view() -> UIView
}

public extension MaskImageViewable where Self: UIView {
    public func view() -> UIView {
        return self
    }
}

public final class MaskImageView: UIView , MaskImageViewable {
    public private(set) var navigationBar: UINavigationBar!

    public private(set) var navigationItem: UINavigationItem!
    public weak var imagesBrowser: FullScreenImageBrowser?
    private var currentImage: ImageAsyncDownloadable?

    private var topShadow: CAGradientLayer!
    private var bottomShadow: CAGradientLayer!

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
        setupShadows()
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
        // The navigation bar has a different intrinsic content size upon rotation, so we must update to that new size.
        // Do it without animation to more closely match the behavior in `UINavigationController`
        UIView.performWithoutAnimation { () -> Void in
            self.navigationBar.invalidateIntrinsicContentSize()
            self.navigationBar.layoutIfNeeded()
        }
        super.layoutSubviews()
        updateShadowFrames()
    }

    public func setHidden(_ hidden: Bool, animated: Bool) {
        if isHidden == hidden { return }

        if animated {
            isHidden = false
            alpha = hidden ? 1.0 : 0.0

            UIView.animate(withDuration: 0.2, delay: 0.0, options: [.allowAnimatedContent, .allowUserInteraction], animations: { () -> Void in
                self.alpha = hidden ? 0.0 : 1.0
            }, completion: { result in
                self.alpha = 1.0
                self.isHidden = hidden
            })
        } else {
            isHidden = hidden
        }
    }

    public func populateWithImage(_ image: ImageAsyncDownloadable) {
        currentImage = image

        guard let _imagesBrowser = imagesBrowser else { return }

        if let index = imagesBrowser.dataSource.indexOfPhoto(image) {
            navigationItem.title = String(format:NSLocalizedString("%d of %d",comment:""), index+1, photosViewController.dataSource.numberOfPhotos)
        }
    }

    @objc private func closeButtonTapped(_ sender: UIBarButtonItem) {
        imagesBrowser?.dismiss(animated: true, completion: nil)
    }

    @objc private func actionButtonTapped(_ sender: UIBarButtonItem) {

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
        addConstraints([topConstraint, widthConstraint, horizontalConstraint])

        if let bundlePath = Bundle(for: type(of: self)).path(forResource: "AJFullScreenImageBrowser", ofType: "bundle") {
            let bundle = Bundle(path: bundlePath)
            leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "close", in: bundle, compatibleWith: nil), landscapeImagePhone: UIImage(named: "close", in: bundle, compatibleWith: nil), style: .plain, target: self, action: #selector(MaskImageView.closeButtonTapped(_:)))
        } else {
            leftBarButtonItem = UIBarButtonItem(title: "CLOSE".uppercased(), style: .plain, target: self, action: #selector(MaskImageView.closeButtonTapped(_:)))
        }

        rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(MaskImageView.actionButtonTapped(_:)))
    }

    private func setupShadows() {
        let startColor = UIColor.black.withAlphaComponent(0.5)
        let endColor = UIColor.clear

        topShadow = CAGradientLayer()
        topShadow.colors = [startColor.cgColor, endColor.cgColor]
        layer.insertSublayer(topShadow, at: 0)

        bottomShadow = CAGradientLayer()
        bottomShadow.colors = [endColor.cgColor, startColor.cgColor]
        layer.insertSublayer(bottomShadow, at: 0)

        updateShadowFrames()
    }

    private func updateShadowFrames(){
        topShadow.frame = CGRect(x: 0, y: 0, width: frame.width, height: 60)
        bottomShadow.frame = CGRect(x: 0, y: frame.height - 60, width: frame.width, height: 60)
    }
}
