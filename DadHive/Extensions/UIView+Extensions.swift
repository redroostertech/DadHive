import UIKit

extension UIView {

    func loadNib(nibName: String) -> UIView {
        let bundle = Bundle(for: type(of: self))
        //let nibName = type(of: self).description().components(separatedBy: ".").last!
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as! UIView
    }
    
    func addGradientLayer(using colors: [CGColor]) {
        applyClipsToBounds(true)
        self.backgroundColor = .clear
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds
        gradientLayer.colors = colors
        //  gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        guard let button = self as? UIButton else {
            self.layer.insertSublayer(gradientLayer,
                                      at: 0)
            return
        }
        button.layer.insertSublayer(gradientLayer,
                                   below: button.imageView?.layer)
        
    }
    
    func applyBorder(withColor color: UIColor, andThickness width: CGFloat) {
        self.layer.borderColor = color.cgColor
        self.layer.borderWidth = width
    }
    
    func applyCornerRadius(_ radius: CGFloat = 0.50) {
        applyClipsToBounds(true)
        self.layer.cornerRadius = self.frame.height * radius
    }
    
    func applyClipsToBounds(_ bool: Bool) {
        self.clipsToBounds = bool
    }
    
    public func convertToImage() -> UIImage {
        UIGraphicsBeginImageContext(bounds.size)
        drawHierarchy(in: bounds, afterScreenUpdates: false)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    public func applyTopCornerStyle(_ cornerRadius: CGFloat) {
        let maskPath = UIBezierPath(roundedRect: self.bounds,
                                    byRoundingCorners: [.topLeft, .topRight],
                                    cornerRadii: CGSize(width: cornerRadius,
                                                        height: cornerRadius))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path = maskPath.cgPath
        self.layer.mask = maskLayer
    }
    
    public func applyBottomCornerStyle(_ cornerRadius: CGFloat) {
        let maskPath = UIBezierPath(roundedRect: self.bounds,
                                    byRoundingCorners: [.bottomLeft, .bottomRight],
                                    cornerRadii: CGSize(width: cornerRadius,
                                                        height: cornerRadius))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path = maskPath.cgPath
        self.layer.mask = maskLayer
    }

    enum LayoutDirection {
        case horizontal
        case vertical
    }
    
    @objc func clear() {
        subviews.forEach { (view) in
            view.removeFromSuperview()
        }
    }
    
    public func makeHeightZero() {
        let verticalSpaceConstraint = self.superview!.constraints.filter({(constraint) -> Bool in
            return constraint.secondItem as? UIView == self && constraint.secondAttribute == NSLayoutConstraint.Attribute.bottom
        }).first
        
        let superViewHeightConstraint = self.superview!.constraints.filter({(constraint) -> Bool in
            return constraint.firstAttribute == NSLayoutConstraint.Attribute.height
        }).first
        
        superViewHeightConstraint?.constant -= verticalSpaceConstraint?.constant ?? 0 + self.frame.height
        verticalSpaceConstraint?.constant = 0
        
        let heightConstraint = self.constraints.filter({(constraint) -> Bool in
            return constraint.firstAttribute == NSLayoutConstraint.Attribute.height
        }).first
        if heightConstraint != nil {self.removeConstraint(heightConstraint!)}
        
        let constH = NSLayoutConstraint(item: self,
                                        attribute: NSLayoutConstraint.Attribute.height,
                                        relatedBy: NSLayoutRelation.equal,
                                        toItem: nil,
                                        attribute: NSLayoutAttribute.notAnAttribute,
                                        multiplier: 1, constant: 0)
        
        self.addConstraint(constH)
        self.isHidden = true
    }
    
    public func removeHeightConstraint() {
        let constHt = self.constraints.filter { $0.firstAttribute == .height}.first
        if let htConstFound = constHt {
            self.removeConstraint(htConstFound)
        }
    }
    
    public func setHeightConstraint(constant: CGFloat) {
        removeHeightConstraint()
        let constH = NSLayoutConstraint(item: self,
                                        attribute: .height,
                                        relatedBy: .equal,
                                        toItem: nil,
                                        attribute: .notAnAttribute,
                                        multiplier: 1,
                                        constant: constant)
        self.addConstraint(constH)
    }
    
    @objc public func addSubViewWithFillConstraints(_ subView: UIView) {
        addSubview(subView)
        fillConstraintsWithConstants(subView)
    }
    
    public func addSubViewAtCenter(_ subView: UIView) {
        addSubview(subView)
        constraintView(subView, forAttribute: .centerX)
        constraintView(subView, forAttribute: .centerY)
        constraintView(subView, forAttribute: .height)
        constraintView(subView, forAttribute: .width)
    }
    
    public func centerSubView(_ subView: UIView) {
        addSubview(subView)
        constraintView(subView, forAttribute: .centerX)
        constraintView(subView, forAttribute: .centerY)
        constraintView(subView, forAttribute: .height)
    }
    
    func constraintAdjacentSubviews(firstView: UIView,
                                    secondView: UIView,
                                    spacing: CGFloat = 0,
                                    priority: UILayoutPriority = .required,
                                    direction: LayoutDirection) {
        var const = NSLayoutConstraint()
        
        switch direction {
        case .horizontal:
            const = NSLayoutConstraint(item: firstView,
                                       attribute: .trailing,
                                       relatedBy: .equal,
                                       toItem: secondView,
                                       attribute: .leading,
                                       multiplier: 1,
                                       constant: 0)
        case .vertical:
            const = NSLayoutConstraint(item: firstView,
                                       attribute: .bottom,
                                       relatedBy: .equal,
                                       toItem: secondView,
                                       attribute: .top,
                                       multiplier: 1,
                                       constant: 0)
        }
        
        const.priority = priority
        addConstraint(const)
    }
    
    public func fillConstraintsWithConstants(_ target: UIView,
                                             leading: CGFloat = 0,
                                             trailing: CGFloat = 0,
                                             top: CGFloat = 0,
                                             bottom: CGFloat = 0) {
        constraintView(target, forAttribute: .leading, constant: leading)
        constraintView(target, forAttribute: .top, constant: top)
        constraintView(target, forAttribute: .trailing, constant: trailing)
        constraintView(target, forAttribute: .bottom, constant: bottom)
    }
    
    public func constraintView(_ target: UIView,
                               forAttribute attrib: NSLayoutConstraint.Attribute,
                               multiplier: CGFloat = 1,
                               constant: CGFloat = 0,
                               priority: UILayoutPriority = .required ) {
        let constraint = NSLayoutConstraint(item: target,
                                            attribute: attrib,
                                            relatedBy: .equal,
                                            toItem: self,
                                            attribute: attrib,
                                            multiplier: multiplier,
                                            constant: constant)
        constraint.priority = priority
        addConstraint(constraint)
    }
    
    public func removeAllConstraintsInGraph() {
        self.subviews.forEach {(view) in
            view.removeAllConstraintsInGraph()
        }
        self.constraints.forEach { (constraint) in
            self.removeConstraint(constraint)
        }
    }
}

@objc extension UIView {
    public func constraint(_ view: UIView) -> Constraint {
        return Constraint(self, view: view)
    }
}
