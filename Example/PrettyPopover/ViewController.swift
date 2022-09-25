//
//  ViewController.swift
//  PrettyPopover
//
//  Created by Lguanghui on 09/20/2022.
//  Copyright (c) 2022 Lguanghui. All rights reserved.
//

import UIKit
import SnapKit
import LoveUIKit
import PrettyPopover

var is_iPad: Bool {
    if UIDevice.current.userInterfaceIdiom == .pad {
        return true;
    } else {
        return false
    }
}

class ViewController: UINavigationController {
    public override func viewDidLoad() {
        super.viewDidLoad()
        let demoVC = DemoViewController()
        pushViewController(demoVC, animated: false)
    }
}

final class DemoViewController: UIViewController {
    public override func viewDidLoad() {
        super.viewDidLoad()
        title = "PrettyPopover Demo"
        setupViews()
    }
    
    private lazy var mainScrollView = UIScrollView()
    
    private var titles = ["Click me", "Click me",
                          "Automatic direction",
                          "Slide to different positions and click",
                          "Random direction",
                          "Gradient backgound",
                          "Custom content view",
                          "Show without trigger element",
                          "Update size with animation",
                          "Set offset (triangle fixed)",
                          "Set offset (trigonometric follow)",
                          "Low damping, high initial speed"]

    private func setupViews() {
        view.backgroundColor = .gray
        view.addSubview(mainScrollView)
        
        mainScrollView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
        }
        mainScrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        view.layoutSubviews()
        installButtons()
    }
    
    private func installButtons() {
        var preview: UIView?
        let buttonWidth: CGFloat = is_iPad ? 200 : 100
        for (index, title) in titles.enumerated() {
            let button = createButton()
            button.setTitle(title, for: .normal)
            button.tag = index + 100
            mainScrollView.addSubview(button)
            
            let remainder = (index + 1) % 3
            
            button.snp.makeConstraints { make in
                if let preview = preview {
                    make.top.equalTo(preview.snp.bottom).offset(is_iPad ? 100 : 20)
                } else {
                    make.top.equalToSuperview().offset(100)
                }
                make.width.equalTo(buttonWidth)
                make.height.equalTo(70)
                
                if index < 4 {
                    if remainder == 1 {
                        make.left.equalToSuperview().offset(30)
                    } else if remainder == 2 {
                        make.centerX.equalToSuperview()
                    } else {
                        make.right.equalTo(UIScreen.main.bounds.size.width - 30)
                    }
                } else {
                    make.centerX.equalToSuperview()
                }
                
                if index + 1 == titles.count {
                    make.bottom.equalTo(mainScrollView).offset(-100)
                }
            }
            
            preview = button
        }
    }
    
    @objc private func onTapButtonAction(_ button: UIButton) {
        let config = PrettyPopoverConfig()
        var customView: UIView?
        switch button.tag {
        case 100:
            config.popoverScreenOverlayColor = UIColor.black.withAlphaComponent(0.2)
            config.popoverGradientColors = [UIColor.color(fromHex: 0xDDFFF2), UIColor.white]
            config.popoverGradientLocations = [0, 1]
            config.popoverGradientStartPoint = CGPoint(x: 0.5, y: 0)
            config.popoverGradientEndPoint = CGPoint(x: 1, y: 1)
            config.direction = .auto
        case 101:
            config.popoverScreenOverlayColor = UIColor.clear
            config.popoverBackgroundColor = .cyan
            config.direction = .auto
        case 102:
            config.popoverBackgroundColor = .orange
            config.direction = .auto
        case 103:
            config.popoverScreenOverlayColor = UIColor.black.withAlphaComponent(0.2)
            config.direction = .auto
        case 104:
            // Random direction
            config.popoverScreenOverlayColor = UIColor.black.withAlphaComponent(0.2)
            config.popoverGradientColors = [UIColor.color(fromHex: 0xDDFFF2), UIColor.cyan]
            config.popoverGradientLocations = [0, 1]
            config.popoverGradientStartPoint = CGPoint(x: 0.5, y: 0)
            config.popoverGradientEndPoint = CGPoint(x: 1, y: 1)
            let randomInt = Int.random(in: 0..<PrettyPopoverDirection.allCases.count)
            config.direction = PrettyPopoverDirection(rawValue: randomInt) ?? .auto
        case 105:
            // Gradient backgound
            config.popoverScreenOverlayColor = UIColor.black.withAlphaComponent(0.2)
            config.popoverGradientColors = [UIColor.color(fromHex: 0xDDFFF2), UIColor.white]
            config.popoverGradientLocations = [0, 1]
            config.popoverGradientStartPoint = CGPoint(x: 0.5, y: 0)
            config.popoverGradientEndPoint = CGPoint(x: 1, y: 1)
            config.direction = .auto
        case 106:
            // Custom content view
            customView = UIView().then({ cus in
                cus.backgroundColor = .clear
                cus.layer.cornerRadius = 12
                cus.layer.masksToBounds = true
            })
            let image = UIImageView(image: UIImage(named: "Doraemon"))
            image.contentMode = .scaleAspectFill
            customView?.addSubview(image)
            image.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            config.popoverBackgroundColor = UIColor.cyan
            config.direction = .auto
        case 107:
            // Show without trigger element
            config.popoverBackgroundColor = .white
            config.popoverScreenOverlayColor = UIColor.black.withAlphaComponent(0.2)
            config.popoverGradientColors = [UIColor.color(fromHex: 0xDDFFF2), UIColor.white]
            config.popoverGradientLocations = [0, 1]
            config.popoverGradientStartPoint = CGPoint(x: 0.5, y: 0)
            config.popoverGradientEndPoint = CGPoint(x: 1, y: 1)
            PrettyPopoverManager.sharedInstance.show(WithSourceView: nil, inView: mainScrollView, customView: customView ?? UIView(), config: config)
            return
        case 108:
            // Update size with animation
            config.popoverBackgroundColor = .white
            config.popoverScreenOverlayColor = UIColor.black.withAlphaComponent(0.2)
            config.popoverGradientColors = [UIColor.color(fromHex: 0xDDFFF2), UIColor.white]
            config.popoverGradientLocations = [0, 1]
            config.popoverGradientStartPoint = CGPoint(x: 0.5, y: 0)
            config.popoverGradientEndPoint = CGPoint(x: 1, y: 1)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                let newConfig = config
                newConfig.height = config.height + 100
                newConfig.width = config.width + 100
                PrettyPopoverManager.sharedInstance.update(width: config.width, height: config.height, animationTime: 0.3) {
                    print("Popover update！")
                }
            }
        case 109:
            // Set offset (triangle fixed)
            config.popoverScreenOverlayColor = UIColor.black.withAlphaComponent(0.2)
            config.popoverOffset = UIOffset(horizontal: 50, vertical: 0)
            config.angleOffsetWithPopover = false
        case 110:
            // Set offset (trigonometric follow)
            config.popoverScreenOverlayColor = UIColor.black.withAlphaComponent(0.2)
            config.popoverOffset = UIOffset(horizontal: 50, vertical: 0)
            config.angleOffsetWithPopover = true
        case 111:
            // Low damping, high initial speed
            config.dampingRatio = 0.3
            config.springVelocity = 6
            config.popoverScreenOverlayColor = UIColor.black.withAlphaComponent(0.2)
        default:
            break
        }
        
        PrettyPopoverManager.sharedInstance.show(WithSourceView: button, inView: mainScrollView, customView: customView ?? UIView(), config: config)
    }
    
    private func createButton() -> UIButton {
        let button: UIButton = UIButton(type: .custom)
        button.backgroundColor = UIColor.color(fromHex: 0x24c789)
        button.layer.cornerRadius = 15
        button.addTarget(self, action: #selector(onTapButtonAction(_:)), for: .touchUpInside)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.numberOfLines = 2
        return button
    }
}

