//
//  SwipeActionButton.swift
//
//  Created by Jeremy Koch.
//  Copyright © 2017 Jeremy Koch. All rights reserved.
//

import UIKit

class SwipeActionButton: UIButton {
    var spacing: CGFloat = 8
    var shouldHighlight = true
    var highlightedBackgroundColor: UIColor?

    var maximumImageHeight: CGFloat = 0
    var verticalAlignment: SwipeVerticalAlignment = .centerFirstBaseline
    
    var currentSpacing: CGFloat {
        return (currentTitle?.isEmpty == false && imageHeight > 0) ? spacing : 0
    }
    
    var alignmentRect: CGRect {
        let contentRect = self.contentRect(forBounds: bounds)
        let titleHeight = titleBoundingRect(with: verticalAlignment == .centerFirstBaseline ? CGRect.infinite.size : contentRect.size).integral.height
        let totalHeight = imageHeight + titleHeight + currentSpacing

        return contentRect.center(size: CGSize(width: contentRect.width, height: totalHeight))
    }
    
    private var imageHeight: CGFloat {
        get {
            return imageViewSize == .zero ? 0 : maximumImageHeight
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: contentEdgeInsets.top + alignmentRect.height + contentEdgeInsets.bottom)
    }
    
    var imageViewRadius: SwipeAction.ImageViewRadius = .none
    
    var imageViewSize: CGSize = .zero
    
    convenience init(action: SwipeAction) {
        self.init(frame: .zero)

        contentHorizontalAlignment = .center
        
        tintColor = action.textColor ?? .white
        let highlightedTextColor = action.highlightedTextColor ?? tintColor
        highlightedBackgroundColor = action.highlightedBackgroundColor ?? UIColor.black.withAlphaComponent(0.1)

        titleLabel?.font = action.font ?? UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.medium)
        titleLabel?.textAlignment = .center
        titleLabel?.lineBreakMode = .byWordWrapping
        titleLabel?.numberOfLines = 0
        
        accessibilityLabel = action.accessibilityLabel
        
        setTitle(action.title, for: .normal)
        setTitleColor(tintColor, for: .normal)
        setTitleColor(highlightedTextColor, for: .highlighted)
        setImage(action.image, for: .normal)
        setImage(action.highlightedImage ?? action.image, for: .highlighted)
        
        imageViewRadius = action.imageViewRadius
        imageViewSize = action.imageViewSize
        imageView?.backgroundColor = action.imageViewBackgroundColor
        imageView?.tintColor = action.imageViewTintColor
        imageView?.contentMode = .center
    }
    
    override var isHighlighted: Bool {
        didSet {
            guard shouldHighlight else { return }
            
            backgroundColor = isHighlighted ? highlightedBackgroundColor : .clear
        }
    }
    
    func preferredWidth(maximum: CGFloat) -> CGFloat {
        let width = maximum > 0 ? maximum : CGFloat.greatestFiniteMagnitude
        let textWidth = titleBoundingRect(with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)).width
        let imageWidth = imageViewSize.width
        
        return min(width, max(textWidth, imageWidth) + contentEdgeInsets.left + contentEdgeInsets.right)
    }
    
    func titleBoundingRect(with size: CGSize) -> CGRect {
        guard let title = currentTitle, let font = titleLabel?.font else { return .zero }
        
        return title.boundingRect(with: size,
                                  options: [.usesLineFragmentOrigin],
                                  attributes: [NSAttributedString.Key.font: font],
                                  context: nil).integral
    }
    
    override func titleRect(forContentRect contentRect: CGRect) -> CGRect {
        var rect = contentRect.center(size: titleBoundingRect(with: contentRect.size).size)
        rect.origin.y = alignmentRect.minY + imageHeight + currentSpacing
        return rect.integral
    }
    
    override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        var rect = contentRect.center(size: imageViewSize)
        rect.origin.y = alignmentRect.minY + (imageHeight - rect.height) / 2
        return rect
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let imageView = self.imageView {
            
            if imageViewSize != .zero {
                imageView.frame.size = imageViewSize
            }
            
            switch self.imageViewRadius {
            case .circle: imageView.cornerRadius = imageView.frame.width / 2
            case .radius(let radius): imageView.cornerRadius = radius
            default: break
            }
        }
    }
}

extension CGRect {
    func center(size: CGSize) -> CGRect {
        let dx = width - size.width
        let dy = height - size.height
        return CGRect(x: origin.x + dx * 0.5, y: origin.y + dy * 0.5, width: size.width, height: size.height)
    }
}

fileprivate extension UIView {
    
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.masksToBounds = true
            layer.cornerRadius = abs(CGFloat(Int(newValue * 100)) / 100)
        }
    }
    
}

