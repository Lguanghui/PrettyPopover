//
//  PrettyPopover.swift
//  PrettyPopover
//
//  Created by 梁光辉 on 2022/9/21.
//  Copyright © 2022 Guanghui Liang. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import Then

/// the distance between Popper and trigger element
fileprivate let POPOVER_MARGIN: CGFloat = 8.0
/// distance from triangle arrow to Popover edge
fileprivate let ANGLE_MARGIN: CGFloat = 16.0

public class PrettyPopover: UIView {
    // MARK: - Initializers
    init(withConfig config: PrettyPopoverConfig) {
        super.init(frame: .zero)
        backgroundColor = .clear
        self.config = config
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Properties
    
    var config: PrettyPopoverConfig!
    
    private lazy var containerOfCustomView = UIView().then { view in
        view.backgroundColor = .clear
    }
    
    private var customView: UIView?
    
    /// Trigger Element
    weak var sourceView: UIView?
    
    weak var inView: UIView?
    
    var didShowHandler: (() -> Void)?
    
    private var dismissHandler: (() -> Void)?
    
    // MARK: - Override
    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        /*
         For the convenience of understanding, draw in clockwise order according to the real world.
         */
        
        let cornerRadius = config.containerCornerRadius
        
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(config.popoverBackgroundColor.cgColor)
        
        // roundedRect
        let roundedRectPath = UIBezierPath(roundedRect: containerOfCustomView.frame, cornerRadius: cornerRadius)
        context?.addPath(roundedRectPath.cgPath)

        // angle
        if let (p1, p2, p3) = getAnglePositions() {
            context?.move(to: p1)
            context?.addArc(tangent1End: p3, tangent2End: p2, radius: 3)
            context?.addLine(to: p2)
            context?.addLine(to: p1)
        }
        
        // gradient
        if let colors = config.popoverGradientColors, let locations = config.popoverGradientLocations {
            let cgColors: [CGColor] = colors.compactMap({ $0.cgColor })
            let colorspace = CGColorSpaceCreateDeviceRGB()
            let gradientPoint = convertPoint(startPoint: config.popoverGradientStartPoint, endPoint: config.popoverGradientEndPoint)
            if let gradient = CGGradient(colorsSpace: colorspace, colors: cgColors as CFArray, locations: locations) {
                context?.saveGState()
                context?.clip()
                context?.drawLinearGradient(gradient, start: gradientPoint.startPoint, end: gradientPoint.endPoint, options: [.drawsAfterEndLocation, .drawsBeforeStartLocation])
                context?.restoreGState()
            }
        }
        
        context?.closePath()
        context?.fillPath()
    }
}

// MARK: - Internal
extension PrettyPopover {
    func kep_show(withSourceView sourceView: UIView?,
                  inView: UIView,
                  customView: UIView,
                  didShowHandler: (() -> Void)? = nil) {
        
        self.sourceView = sourceView
        self.customView = customView
        self.didShowHandler = didShowHandler
        self.inView = inView
        
        setupViews()
        setupNotis()
        
        // 异步一下，防止视图还没有完全布局
        DispatchQueue.main.async {
            self.correctDirection()
            self.layoutPopoverPosition()
            self.show()
        }
    }
    
    func update(width newWidth: CGFloat, height newHeight: CGFloat, animationTime: TimeInterval, completeHandler: (() -> Void)?) {
        config.width = newWidth
        config.height = newHeight
        setNeedsDisplay()
        
        var newFrame: CGRect
        let currentCenterX = frame.origin.x + frame.width / 2
        let currentCenterY = frame.origin.y + frame.size.height / 2
        switch config.direction {
        case .bottom, .auto:
            newFrame = CGRect(x: currentCenterX - newWidth / 2, y: frame.origin.y, width: newWidth, height: newHeight)
        case .top:
            let currentBottomY = frame.origin.y + frame.size.height
            newFrame = CGRect(x: currentCenterX - newWidth / 2, y: currentBottomY - newHeight, width: newWidth, height: newHeight)
        case .left:
            newFrame = CGRect(x: (frame.origin.x + frame.size.width) - newWidth, y: currentCenterY - newHeight / 2, width: newWidth, height: newHeight)
        case .right:
            newFrame = CGRect(x: frame.origin.x, y: currentCenterY - newHeight / 2, width: newWidth, height: newHeight)
        }
        
        UIView.animate(withDuration: animationTime) {
            self.frame = newFrame
        } completion: { _ in
            completeHandler?()
        }
    }
}

// MARK: - Private
extension PrettyPopover {
    private func setupViews() {
        guard let inView = inView, let customView = customView else {
            return
        }
        
        inView.addSubview(self)
        addSubview(containerOfCustomView)
        containerOfCustomView.addSubview(customView)
        
        customView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(config.edgeInsets)
        }
    }
    
    private func setupNotis() {
        NotificationCenter.default.addObserver(self, selector: #selector(willChangeStatusBarOrientation(_:)), name: UIApplication.willChangeStatusBarOrientationNotification, object: nil)
    }
    
    private func correctDirection() {
        guard let sourceView = sourceView else {
            containerOfCustomView.snp.remakeConstraints { make in
                make.edges.equalToSuperview()
            }
            return
        }
        
        let angleSize = config.angleSize
        var containerInsets = UIEdgeInsets.zero
        
        if config.direction == .auto, let inView = inView, let superViewOfSourceView = sourceView.superview {
            let sourceViewOrigin: CGPoint = superViewOfSourceView.convert(sourceView.frame.origin, to: inView)
            
            if sourceViewOrigin.y + sourceView.frame.height + config.angleSize.height + config.height + config.popoverOffset.vertical + POPOVER_MARGIN <= inView.frame.height {
                config.direction = .bottom
            } else if config.height + config.angleSize.height + POPOVER_MARGIN <= sourceViewOrigin.y - config.popoverOffset.vertical {
                config.direction = .top
            } else if config.width + config.angleSize.height + sourceViewOrigin.x + sourceView.frame.width + config.popoverOffset.horizontal + POPOVER_MARGIN < inView.frame.width {
                config.direction = .right
            } else {
                config.direction = .left
            }
        }
        
        switch config.direction {
        case .top:
            containerInsets = UIEdgeInsets(top: 0, left: 0, bottom: angleSize.height, right: 0)
        case .bottom, .auto:
            containerInsets = UIEdgeInsets(top: angleSize.height, left: 0, bottom: 0, right: 0)
        case .left:
            containerInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: angleSize.height)
        case .right:
            containerInsets = UIEdgeInsets(top: 0, left: angleSize.height, bottom: 0, right: 0)
        }
        
        containerOfCustomView.snp.remakeConstraints { make in
            make.edges.equalToSuperview().inset(containerInsets)
        }
    }
    
    private func layoutPopoverPosition() {
        guard let inView = inView else {
            return
        }
        setNeedsDisplay()
        
        var origin: CGPoint = .zero
        
        if let sourceView = sourceView {
            let angleSize = config.angleSize
            let angleHalfWidth: CGFloat = angleSize.width / 2
            
            let sourceViewRect = sourceView.convert(sourceView.bounds, to: self)
            let sourceViewCenterX = sourceViewRect.origin.x + sourceViewRect.width / 2
            let sourceViewCenterY = sourceViewRect.origin.y + sourceViewRect.height / 2
            let sourceViewRightX = sourceViewRect.origin.x + sourceViewRect.width   // 触发元素右边缘的横坐标
            let sourceViewBottomY = sourceViewRect.origin.y + sourceViewRect.height // 触发元素下边缘的纵坐标
            
            switch config.direction {
            case .bottom, .auto:
                /*
                 the width of the inView is divided into three equal parts, based on which the position of the popper is determined.
                 */
                if sourceViewCenterX >= inView.bounds.width * 2 / 3 {
                    origin.x = sourceViewCenterX + ANGLE_MARGIN + angleHalfWidth - config.width
                    origin.y = sourceViewBottomY + POPOVER_MARGIN
                } else if sourceViewCenterX < inView.bounds.width * 1 / 3 {
                    origin.x = sourceViewCenterX - ANGLE_MARGIN - angleHalfWidth
                    origin.y = sourceViewBottomY + POPOVER_MARGIN
                } else {
                    origin.x = sourceViewCenterX - config.width / 2
                    origin.y = sourceViewBottomY + POPOVER_MARGIN
                }
            case .top:

                if sourceViewCenterX >= inView.bounds.width * 2 / 3 {
                    origin.x = sourceViewCenterX + ANGLE_MARGIN + angleHalfWidth - config.width
                    origin.y = sourceViewRect.origin.y - POPOVER_MARGIN - config.height
                } else if sourceViewCenterX < inView.bounds.width * 1 / 3 {
                    origin.x = sourceViewCenterX - ANGLE_MARGIN - angleHalfWidth
                    origin.y = sourceViewRect.origin.y - POPOVER_MARGIN - config.height
                } else {
                    origin.x = sourceViewCenterX - config.width / 2
                    origin.y = sourceViewRect.origin.y - POPOVER_MARGIN - config.height
                }
            case .left:
                if sourceViewCenterY < inView.bounds.height * 1 / 3 {
                    origin.x = sourceViewRect.origin.x - POPOVER_MARGIN - config.width
                    origin.y = sourceViewCenterY - ANGLE_MARGIN - angleHalfWidth
                } else if sourceViewCenterY >= inView.bounds.height * 2 / 3 {
                    origin.x = sourceViewRect.origin.x - POPOVER_MARGIN - config.width
                    origin.y = sourceViewCenterY + ANGLE_MARGIN + angleHalfWidth - config.height
                } else {
                    origin.x = sourceViewRect.origin.x - POPOVER_MARGIN - config.width
                    origin.y = sourceViewCenterY - config.height / 2
                }
            case .right:
                if sourceViewCenterY < inView.bounds.height * 1 / 3 {
                    origin.x = sourceViewRightX + POPOVER_MARGIN
                    origin.y = sourceViewCenterY - ANGLE_MARGIN - angleHalfWidth
                } else if sourceViewCenterY >= inView.bounds.height * 2 / 3 {
                    origin.x = sourceViewRightX + POPOVER_MARGIN
                    origin.y = sourceViewCenterY + ANGLE_MARGIN + angleHalfWidth - config.height
                } else {
                    origin.x = sourceViewRightX + POPOVER_MARGIN
                    origin.y = sourceViewCenterY - config.height / 2
                }
            }
        } else {
            origin.x = inView.bounds.midX - config.width / 2
            origin.y = inView.bounds.midY - config.height / 2
        }
        
        origin.x = origin.x + config.popoverOffset.horizontal
        origin.y = origin.y + config.popoverOffset.vertical
        
        frame = CGRect(origin: origin, size: CGSize(width: config.width, height: config.height))
    }
    
    private func show() {
        var anchorPoint: CGPoint
        if let (_, _, anglePoint_p3) = getAnglePositions() {
            anchorPoint = getAnchorPoint(withAngleCuspPoint: anglePoint_p3)
        } else {
            anchorPoint = CGPoint(x: 0.5, y: 0.5)
        }
        
        let lastAnchorPoint = layer.anchorPoint
        layer.anchorPoint = anchorPoint
        let positionX = layer.position.x + (anchorPoint.x - lastAnchorPoint.x) * layer.bounds.size.width
        let positionY = layer.position.y + (anchorPoint.y - lastAnchorPoint.y) * layer.bounds.size.height
        layer.position = CGPoint(x: positionX, y: positionY)

        transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
        UIView.animate(withDuration: config.animationTime.inTime, delay: 0, usingSpringWithDamping: config.dampingRatio, initialSpringVelocity: config.springVelocity) {
            self.transform = CGAffineTransform.identity
        } completion: { [weak self] _ in
            self?.didShowHandler?()
        }
    }
    
    /// Returns the coordinates of the three points of the triangle arrow.
    /// - Returns: p1 and p2 are the two vertices of the edge next to the triangle arrow and the container. In real world clockwise order, p1 comes first and p2 comes last. P3 is a triangular arrow
    private func getAnglePositions() -> (p1: CGPoint, p2: CGPoint, p3: CGPoint)? {
        guard let sourceView = sourceView else {
            return nil
        }

        var p1: CGPoint = .zero
        var p2: CGPoint = .zero
        let angleSize = config.angleSize

        let sourceViewRect = sourceView.convert(sourceView.bounds, to: self)
        let sourceViewCenterX = sourceViewRect.origin.x + sourceViewRect.width / 2
        let sourceViewCenterY = sourceViewRect.origin.y + sourceViewRect.height / 2

        switch config.direction {
        case .bottom, .auto:
            p1.x = sourceViewCenterX - angleSize.width / 2
            p2.x = p1.x + angleSize.width
            p1.y = angleSize.height
            p2.y = p1.y
        case .top:
            p1.x = sourceViewCenterX + angleSize.width / 2
            p2.x = p1.x - angleSize.width
            p1.y = bounds.height - angleSize.height
            p2.y = p1.y
        case .right:
            p1.y = sourceViewCenterY + angleSize.width / 2
            p2.y = p1.y - angleSize.width
            p1.x = angleSize.height
            p2.x = p1.x
        case .left:
            p1.y = sourceViewCenterY - angleSize.width / 2
            p2.y = p1.y + angleSize.width
            p1.x = bounds.width - angleSize.height
            p2.x = p1.x
        }
        
        if config.angleOffsetWithPopover {
            switch config.direction {
            case .bottom, .top, .auto:
                p1.x = p1.x + config.popoverOffset.horizontal
                p2.x = p2.x + config.popoverOffset.horizontal
            case .left, .right:
                p1.y = p1.y + config.popoverOffset.vertical
                p2.y = p2.y + config.popoverOffset.vertical
            }
        }
        
        var p3 = CGPoint(x: p1.x + angleSize.width / 2, y: 0)
        switch config.direction {
        case .top:
            p3 = CGPoint(x: p1.x - angleSize.width / 2, y: bounds.height)
        case .bottom, .auto:
            p3 = CGPoint(x: p1.x + angleSize.width / 2, y: 0)
        case .left:
            p3 = CGPoint(x: bounds.width, y: p1.y + angleSize.width / 2)
        case .right:
            p3 = CGPoint(x: 0, y: p1.y - angleSize.width / 2)
        }
        
        return (p1, p2, p3)
    }
    
    private func getAnchorPoint(withAngleCuspPoint cuspPoint: CGPoint) -> CGPoint {
        var anchorPoint: CGPoint
        
        switch config.direction {
        case .top:
            anchorPoint = CGPoint(x: cuspPoint.x / frame.size.width, y: 1)
        case .bottom, .auto:
            anchorPoint = CGPoint(x: cuspPoint.x / frame.size.width, y: 0)
        case .left:
            anchorPoint = CGPoint(x: 1, y: cuspPoint.y / frame.size.height)
        case .right:
            anchorPoint = CGPoint(x: 0, y: cuspPoint.y / frame.size.height)
        }
        
        return anchorPoint
    }
}

// MARK: - Noti Handler
extension PrettyPopover {
    @objc private func willChangeStatusBarOrientation(_ noti: Notification) {
        PrettyPopoverManager.sharedInstance.dismiss()
    }
}

// MARK: - Utils
extension PrettyPopover {
    private func convertPoint(startPoint: CGPoint, endPoint: CGPoint) -> (startPoint: CGPoint, endPoint: CGPoint) {
        let start = CGPoint(x: startPoint.x * bounds.width, y: startPoint.y * bounds.height)
        let end = CGPoint(x: endPoint.x * bounds.width, y: endPoint.y * bounds.height)
        return (start, end)
    }
}
