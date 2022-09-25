//
//  PrettyPopoverConfig.swift
//  PrettyPopover
//
//  Created by 梁光辉 on 2022/9/24.
//  Copyright © 2022 Guanghui Liang. All rights reserved.
//

import Foundation

/// The position of the popper relative to the trigger element
@objc public enum PrettyPopoverDirection: Int, CaseIterable {
    /// Automatic calculation. bottom > top > right > left
    case auto = 0
    case top
    case bottom
    case left
    case right
}

@objcMembers public final
class PrettyPopoverConfig: NSObject {
    // MARK: - View Config

    public var popoverScreenOverlayColor: UIColor = .clear
    
    public var popoverBackgroundColor: UIColor = .white
    
    public var direction: PrettyPopoverDirection = .auto

    public var width: CGFloat = 375
    
    public var height: CGFloat = 324
    
    public var containerCornerRadius: CGFloat = 12
    
    public var edgeInsets: UIEdgeInsets = .zero
    
    public var popoverOffset: UIOffset = .zero
    
    /// Set whether the triangle is offset along with the popover. **The default value is false, which means that the triangle always points to the middle of the trigger element.**
    public var angleOffsetWithPopover: Bool = false
    
    // MARK: - Gradient Config

    public var popoverGradientColors: [UIColor]?
    
    public var popoverGradientLocations: [CGFloat]?
    
    public var popoverGradientStartPoint: CGPoint = CGPoint(x: 0.5, y: 0)
    
    public var popoverGradientEndPoint: CGPoint = CGPoint(x: 0.5, y: 1)
    
    // MARK: - Angle Config
    
    public var needHideAngle: Bool = false {
        didSet {
            if needHideAngle {
                angleSize = .zero
            }
        }
    }
    
    /// Note that the width of the triangle refers to the width on the side contacting the container.
    public var angleSize: CGSize = CGSize(width: 20, height: 10)
    
    // MARK: - Animation Config
    
    public var animationTime: (inTime: CGFloat, outTime: CGFloat) = (0.5, 0)
    
    public var dampingRatio: CGFloat = 0.8
    
    public var springVelocity: CGFloat = 3
}
