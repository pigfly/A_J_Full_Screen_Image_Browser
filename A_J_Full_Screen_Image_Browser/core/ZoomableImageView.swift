//
//  ZoomableImageView.swift
//  A_J_Full_Screen_Image_Browser
//
//  Created by Junliang Jiang on 25/2/18.
//  Copyright © 2018 Junliang Jiang. All rights reserved.
//

import UIKit

final public class INSScalingImageView: UIScrollView {

    // MARK: - Property
    public lazy var imageView: UIImageView = {
        let imageView = UIImageView(frame: bounds)
        addSubview(imageView)
        return imageView
    }()

    public var image: UIImage? {
        didSet {
            updateImage(image)
        }
    }

    override public var frame: CGRect {
        didSet {
            updateZoomScale()
            centerScrollViewContents()
        }
    }

    // MARK: - Init
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupImageScrollView()
        updateZoomScale()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupImageScrollView()
        updateZoomScale()
    }

    private func setupImageScrollView() {
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false;
        bouncesZoom = true;
        decelerationRate = UIScrollViewDecelerationRateFast;
    }

    // MARK: - View Life Cycle
    override public func didAddSubview(_ subview: UIView) {
        super.didAddSubview(subview)
        centerScrollViewContents()
    }

    func centerScrollViewContents() {
        var horizontalInset: CGFloat = 0
        var verticalInset: CGFloat = 0

        if (contentSize.width < bounds.width) {
            horizontalInset = (bounds.width - contentSize.width) * 0.5
        }

        if (contentSize.height < bounds.height) {
            verticalInset = (bounds.height - contentSize.height) * 0.5
        }

        if (window?.screen.scale < 2.0) {
            horizontalInset = floor(horizontalInset)
            verticalInset = floor(verticalInset)
        }

        contentInset = UIEdgeInsetsMake(verticalInset, horizontalInset, verticalInset, horizontalInset);
    }

    private func updateImage(_ image: UIImage?) {
        let size = image?.size ?? CGSize.zero

        imageView.transform = CGAffineTransform.identity
        imageView.image = image
        imageView.frame = CGRect(origin: .zero, size: size)
        contentSize = size

        updateZoomScale()
        centerScrollViewContents()
    }

    private func updateZoomScale() {
        guard let image = imageView.image else { return }

        let scrollViewFrame = bounds
        let scaleWidth = scrollViewFrame.size.width / image.size.width
        let scaleHeight = scrollViewFrame.size.height / image.size.height
        let minScale = min(scaleWidth, scaleHeight)

        minimumZoomScale = minScale
        maximumZoomScale = max(minScale, maximumZoomScale)

        zoomScale = minimumZoomScale
        panGestureRecognizer.isEnabled = false
    }
}


/// Make binary `<` operator to accept optional
///
/// - Parameters:
///   - lhs: expression on the left hand side of the `<`
///   - rhs: expression on the right hand side of the `<`
/// - Returns: Boolen value of the comparsion
private func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}
