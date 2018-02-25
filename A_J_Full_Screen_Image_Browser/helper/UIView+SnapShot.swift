//
//  UIView+SnapShot.swift
//  A_J_Full_Screen_Image_Browser
//
//  Created by Junliang Jiang on 25/2/18.
//  Copyright © 2018 Junliang Jiang. All rights reserved.
//

import UIKit

public extension UIView {

    /// Create snapshot view with layer transform information if available
    ///
    /// - Returns: A new view object based on a snapshot of the current view’s rendered contents
    public func aj_snapshotView() -> UIView {
        guard let contents = layer.contents else {
            return snapshotView(afterScreenUpdates: true) ?? UIView()
        }

        var snapshotedView: UIView!

        if let view = self as? UIImageView {
            snapshotedView = type(of: view).init(image: view.image)
            snapshotedView.bounds = view.bounds
        } else {
            snapshotedView = UIView(frame: frame)
            snapshotedView.layer.contents = contents
            snapshotedView.layer.bounds = layer.bounds
        }
        snapshotedView.layer.cornerRadius = layer.cornerRadius
        snapshotedView.layer.masksToBounds = layer.masksToBounds
        snapshotedView.contentMode = contentMode
        snapshotedView.transform = transform

        return snapshotedView
    }

    /// Converts a point from the coordinate space of the current object to the container view coordinate space.
    ///
    /// - Parameter containerView: container view for the point
    /// - Returns: A point specified in the container view coordinate space.
    public func aj_translatedCenterPointToContainerView(_ containerView: UIView) -> CGPoint {
        var centerPoint = center

        if let scrollView = self.superview as? UIScrollView , scrollView.zoomScale != 1.0 {
            centerPoint.x += (scrollView.bounds.width - scrollView.contentSize.width) / 2.0 + scrollView.contentOffset.x
            centerPoint.y += (scrollView.bounds.height - scrollView.contentSize.height) / 2.0 + scrollView.contentOffset.y
        }
        return self.superview?.convert(centerPoint, to: containerView) ?? .zero
    }
}
