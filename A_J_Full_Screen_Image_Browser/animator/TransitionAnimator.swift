//
//  TransitionAnimator.swift
//  A_J_Full_Screen_Image_Browser
//
//  Created by Junliang Jiang on 25/2/18.
//  Copyright © 2018 Junliang Jiang. All rights reserved.
//

import UIKit

public final class TransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    var dismissing: Bool = false

    var startingView: UIView?
    var endingView: UIView?

    var startingViewForAnimation: UIView?
    var endingViewForAnimation: UIView?

    var animationDurationWithZooming = 0.5
    var animationDurationWithoutZooming = 0.3
    var animationDurationFadeRatio = 4.0 / 9.0 {
        didSet(value) {
            animationDurationFadeRatio = min(value, 1.0)
        }
    }
    var animationDurationEndingViewFadeInRatio = 0.1 {
        didSet(value) {
            animationDurationEndingViewFadeInRatio = min(value, 1.0)
        }
    }
    var animationDurationStartingViewFadeOutRatio = 0.05 {
        didSet(value) {
            animationDurationStartingViewFadeOutRatio = min(value, 1.0)
        }
    }
    var zoomingAnimationSpringDamping = 0.9

    var shouldPerformZoomingAnimation: Bool {
        get {
            return self.startingView != nil && self.endingView != nil
        }
    }

    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        if shouldPerformZoomingAnimation {
            return animationDurationWithZooming
        }
        return animationDurationWithoutZooming
    }

    func fadeDurationForTransitionContext(_ transitionContext: UIViewControllerContextTransitioning) -> TimeInterval {
        if shouldPerformZoomingAnimation {
            return transitionDuration(using: transitionContext) * animationDurationFadeRatio
        }
        return transitionDuration(using: transitionContext)
    }

    // MARK:- UIViewControllerAnimatedTransitioning
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        setupTransitionContainerHierarchyWithTransitionContext(transitionContext)

        if shouldPerformZoomingAnimation {
            performZoomingAnimationWithTransitionContext(transitionContext)
        }
        performFadeAnimationWithTransitionContext(transitionContext)
    }

    func setupTransitionContainerHierarchyWithTransitionContext(_ transitionContext: UIViewControllerContextTransitioning) {

        if let toView = transitionContext.view(forKey: UITransitionContextViewKey.to),
            let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) {
            toView.frame = transitionContext.finalFrame(for: toViewController)
            let containerView = transitionContext.containerView

            if !toView.isDescendant(of: containerView) {
                containerView.addSubview(toView)
            }
        }

        if dismissing {
            if let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from) {
                transitionContext.containerView.bringSubview(toFront: fromView)
            }
        }
    }

    func performFadeAnimationWithTransitionContext(_ transitionContext: UIViewControllerContextTransitioning) {
        let fadeView = dismissing ? transitionContext.view(forKey: UITransitionContextViewKey.from) : transitionContext.view(forKey: UITransitionContextViewKey.to)
        let beginningAlpha: CGFloat = dismissing ? 1.0 : 0.0
        let endingAlpha: CGFloat = dismissing ? 0.0 : 1.0

        fadeView?.alpha = beginningAlpha

        UIView.animate(withDuration: fadeDurationForTransitionContext(transitionContext), animations: { () -> Void in
            fadeView?.alpha = endingAlpha
        }) { finished in
            if !self.shouldPerformZoomingAnimation {
                self.completeTransitionWithTransitionContext(transitionContext)
            }
        }
    }

    func performZoomingAnimationWithTransitionContext(_ transitionContext: UIViewControllerContextTransitioning) {

        let containerView = transitionContext.containerView
        guard let startingView = startingView, let endingView = endingView else {
            return
        }
        guard let startingViewForAnimation = self.startingViewForAnimation ?? self.startingView?.aj_snapshotView(),
            let endingViewForAnimation = self.endingViewForAnimation ?? self.endingView?.aj_snapshotView() else {
                return
        }

        let finalEndingViewTransform = endingView.transform
        let endingViewInitialTransform = startingViewForAnimation.frame.height / endingViewForAnimation.frame.height
        let translatedStartingViewCenter = startingView.aj_translatedCenterPointToContainerView(containerView)

        startingViewForAnimation.center = translatedStartingViewCenter

        endingViewForAnimation.transform = endingViewForAnimation.transform.scaledBy(x: endingViewInitialTransform, y: endingViewInitialTransform)
        endingViewForAnimation.center = translatedStartingViewCenter
        endingViewForAnimation.alpha = 0.0

        containerView.addSubview(startingViewForAnimation)
        containerView.addSubview(endingViewForAnimation)

        endingView.alpha = 0.0
        startingView.alpha = 0.0

        let fadeInDuration = transitionDuration(using: transitionContext) * animationDurationEndingViewFadeInRatio
        let fadeOutDuration = transitionDuration(using: transitionContext) * animationDurationStartingViewFadeOutRatio

        UIView.animate(withDuration: fadeInDuration, delay: 0.0, options: [.allowAnimatedContent,.beginFromCurrentState], animations: { () -> Void in
            endingViewForAnimation.alpha = 1.0
        }) { result in
            UIView.animate(withDuration: fadeOutDuration, delay: 0.0, options: [.allowAnimatedContent,.beginFromCurrentState], animations: { () -> Void in
                startingViewForAnimation.alpha = 0.0
            }, completion: { result in
                startingViewForAnimation.removeFromSuperview()
            })
        }

        let startingViewFinalTransform = 1.0 / endingViewInitialTransform
        let translatedEndingViewFinalCenter = endingView.aj_translatedCenterPointToContainerView(containerView)

        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0.0, usingSpringWithDamping:CGFloat(zoomingAnimationSpringDamping), initialSpringVelocity:0, options: [.allowAnimatedContent,.beginFromCurrentState], animations: { () -> Void in
            endingViewForAnimation.transform = finalEndingViewTransform
            endingViewForAnimation.center = translatedEndingViewFinalCenter
            startingViewForAnimation.transform = startingViewForAnimation.transform.scaledBy(x: startingViewFinalTransform, y: startingViewFinalTransform)
            startingViewForAnimation.center = translatedEndingViewFinalCenter

        }) { result in
            endingViewForAnimation.removeFromSuperview()
            endingView.alpha = 1.0
            startingView.alpha = 1.0
            self.completeTransitionWithTransitionContext(transitionContext)
        }
    }

    func completeTransitionWithTransitionContext(_ transitionContext: UIViewControllerContextTransitioning) {
        if transitionContext.isInteractive {
            if transitionContext.transitionWasCancelled {
                transitionContext.cancelInteractiveTransition()
            } else {
                transitionContext.finishInteractiveTransition()
            }
        }
        transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
    }
}
