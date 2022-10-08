//
//  PrettyPopoverManager.swift
//  PrettyPopover
//
//  Created by 梁光辉 on 2022/9/25.
//  Copyright © 2022 Guanghui Liang. All rights reserved.
//

import Foundation
import UIKit

public final
class PrettyPopoverManager: NSObject {
    private override init() {
        super.init()
    }
    
    @objc public static let sharedInstance = PrettyPopoverManager()
    
    private var popover: PrettyPopover?
    
    var popoverScreenOverlay: UIControl?
    
    private var dismissHandler: (() -> Void)?
    
    
}

public extension PrettyPopoverManager {
    @objc func show(WithSourceView sourceView: UIView?,
                               inView: UIView?,
                               customView: UIView,
                               config: PrettyPopoverConfig,
                               didShowHandler: (() -> Void)? = nil,
                               dismissHandler: (() -> Void)? = nil) {
        popoverScreenOverlay = UIControl()
        popoverScreenOverlay?.addTarget(self, action: #selector(dismiss), for: .touchUpInside)
        popoverScreenOverlay?.backgroundColor = config.popoverScreenOverlayColor
        
        guard let keywindow = getKeyWindow(), let overlay = popoverScreenOverlay else {
            return
        }
        
        keywindow.addSubview(overlay)
        overlay.frame = CGRect(x: 0, y: 0, width: keywindow.bounds.width, height: keywindow.bounds.height)
        popover = PrettyPopover(withConfig: config)
        
        if let inView = inView {
            let view = UIControl()
            view.backgroundColor = .clear
            view.addTarget(self, action: #selector(dismiss), for: .touchUpInside)
            
            overlay.addSubview(view)
            
            let inViewRect = overlay.convert(inView.frame, from: inView.superview)
            view.frame = inViewRect
            
            overlay.layoutIfNeeded()
            popover?.kep_show(withSourceView: sourceView, inView: view, customView: customView, didShowHandler: didShowHandler)
        } else {
            overlay.layoutIfNeeded()
            popover?.kep_show(withSourceView: sourceView, inView: overlay, customView: customView, didShowHandler: didShowHandler)
        }
    }
    
    @objc func update(width: CGFloat, height: CGFloat, animationTime: TimeInterval, completeHandler: (() -> Void)?) {
        popover?.update(width: width, height: height, animationTime: animationTime, completeHandler: completeHandler)
    }
    
    @objc func dismiss() {
        popoverScreenOverlay?.isHidden = true
        popoverScreenOverlay?.subviews.forEach({ sub in
            sub.removeFromSuperview()
        })
        popoverScreenOverlay?.removeFromSuperview()
        popoverScreenOverlay = nil
        
        dismissHandler?()
    }
}

// MARK: - Utils
extension PrettyPopoverManager {
    private func getKeyWindow() -> UIView? {
        for window in UIApplication.shared.windows.reversed() {
            let isWindowOnMainScreen: Bool = window.screen == UIScreen.main
            let isWindowVisible = !window.isHidden && window.alpha > 0
            let isKeyWindow = window.isKeyWindow
            
            if isWindowOnMainScreen && isWindowVisible && isKeyWindow {
                return window
            }
        }
        
        return nil
    }
}
