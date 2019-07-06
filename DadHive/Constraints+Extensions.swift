import Foundation
import UIKit

@objc public class Constraint: NSObject {
    let view: UIView
    let superView: UIView
    
    public init(_ superView: UIView, view: UIView) {
        self.view = view
        self.superView = superView
        
        self.view.translatesAutoresizingMaskIntoConstraints = false
    }
    
    // MARK: Align Top Edges
    
    @discardableResult public func alignTopEdges(by constant: CGFloat, priority: UILayoutPriority) -> Self {
        removeConstraints(onView: view, forAttributes: [.top])
        superView.constraintView(view, forAttribute: .top, constant: constant, priority: priority)
        return self
    }
    
    @objc @discardableResult public func alignTopEdges(by constant: CGFloat) -> Self {
        return alignTopEdges(by: constant, priority: .required)
    }
    
    @objc @discardableResult public func alignTopEdges() -> Self {
        return alignTopEdges(by: 0, priority: .required)
    }
    
    // MARK: Align Bottom Edges
    
    @discardableResult public func alignBottomEdges(by constant: CGFloat, priority: UILayoutPriority) -> Self {
        removeConstraints(onView: view, forAttributes: [.bottom])
        superView.constraintView(view, forAttribute: .bottom, constant: constant, priority: priority)
        return self
    }
    
    @objc @discardableResult public func alignBottomEdges(by constant: CGFloat) -> Self {
        return alignBottomEdges(by: constant, priority: .required)
    }
    
    @objc @discardableResult public func alignBottomEdges() -> Self {
        return alignBottomEdges(by: 0, priority: .required)
    }
    
    // MARK: Align Left Edges
    
    @discardableResult public func alignLeftEdges(by constant: CGFloat, priority: UILayoutPriority) -> Self {
        removeConstraints(onView: view, forAttributes: [.leading])
        superView.constraintView(view, forAttribute: .leading, constant: constant, priority: priority)
        return self
    }
    
    @objc @discardableResult public func alignLeftEdges(by constant: CGFloat) -> Self {
        return alignLeftEdges(by: constant, priority: .required)
    }
    
    @objc @discardableResult public func alignLeftEdges() -> Self {
        return alignLeftEdges(by: 0, priority: .required)
    }
    
    // MARK: Align Right Edges
    
    @discardableResult public func alignRightEdges(by constant: CGFloat, priority: UILayoutPriority) -> Self {
        removeConstraints(onView: view, forAttributes: [.trailing])
        superView.constraintView(view, forAttribute: .trailing, constant: constant, priority: priority)
        return self
    }
    
    @objc @discardableResult public func alignRightEdges(by constant: CGFloat) -> Self {
        return alignRightEdges(by: constant, priority: .required)
    }
    
    @objc @discardableResult public func alignRightEdges() -> Self {
        return alignRightEdges(by: 0, priority: .required)
    }
    
    // MARK: Center
    
    @discardableResult public func center() -> Self {
        return self.centerHorizontally().centerVertically()
    }
    
    @discardableResult public func centerHorizontally() -> Self {
        return centerHorizontally(offset: 0)
    }
    
    @discardableResult public func centerHorizontally(offset: CGFloat) -> Self {
        superView.constraintView(view, forAttribute: .centerX, constant: offset)
        return self
    }
    
    @objc @discardableResult public func centerVertically() -> Self {
        return centerVertically(offset: 0)
    }
    
    @discardableResult public func centerVertically(offset: CGFloat) -> Self {
        superView.constraintView(view, forAttribute: .centerY, constant: offset)
        return self
    }
    
    // MARK: Fit and Fill
    
    @discardableResult public func fill(top: CGFloat, bottom: CGFloat, left: CGFloat, right: CGFloat) -> Constraint {
        superView.fillConstraintsWithConstants(view, leading: left, trailing: right, top: top, bottom: bottom)
        return Constraint(superView, view: view)
    }
    
    @discardableResult public func fill() -> Constraint {
        return fill(top: 0, bottom: 0, left: 0, right: 0)
    }
    
    @discardableResult public func fitContent() -> Constraint {
        let priority = UILayoutPriority(UILayoutPriority.defaultLow.rawValue + 1.0)
        view.setContentHuggingPriority(priority, for: .horizontal)
        view.setContentHuggingPriority(priority, for: .vertical)
        return Constraint(superView, view: view)
    }
    
    // MARK: Size
    
    @objc @discardableResult public func width(_ constant: CGFloat) -> Constraint {
        return constrain(attribute: .width, to: constant, relatedBy: .equal)
    }
    
    @discardableResult public func minWidth(_ constant: CGFloat) -> Constraint {
        return constrain(attribute: .width, to: constant, relatedBy: .greaterThanOrEqual)
    }
    
    @objc @discardableResult public func height(_ constant: CGFloat) -> Constraint {
        return constrain(attribute: .height, to: constant)
    }
    
    @discardableResult public func minHeight(_ constant: CGFloat) -> Constraint {
        return constrain(attribute: .height, to: constant, relatedBy: .greaterThanOrEqual)
    }
    
    @objc @discardableResult public func heightToWidth(multiplier: CGFloat) -> Self {
        removeConstraints(onView: view, forAttributes: [.height])
        view.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: multiplier).isActive = true
        return self
    }
    
    @discardableResult public func matchParentWidth() -> Self {
        removeConstraints(onView: view, forAttributes: [.width])
        superView.constraintView(view, forAttribute: .width, constant: 0)
        return self
    }
    
    // MARK: Place Next
    
    @discardableResult public func placeNext(_ nextView: UIView, by constant: CGFloat, priority: UILayoutPriority) -> Constraint {
        superView.constraintAdjacentSubviews(firstView: view, secondView: nextView, spacing: constant, priority: priority, direction: .horizontal)
        return Constraint(superView, view: nextView)
    }
    
    @discardableResult public func placeNext(_ nextView: UIView, priority: UILayoutPriority) -> Constraint {
        return placeNext(nextView, by: 0, priority: priority)
    }
    
    @discardableResult public func placeNext(_ nextView: UIView) -> Constraint {
        return placeNext(nextView, by: 0, priority: .required)
    }
    
    // MARK: Place Above
    
    @discardableResult public func placeAbove(_ lowerView: UIView, by constant: CGFloat, priority: UILayoutPriority) -> Constraint {
        superView.constraintAdjacentSubviews(firstView: view, secondView: lowerView, spacing: constant, priority: priority, direction: .vertical)
        return Constraint(superView, view: lowerView)
    }
    
    @discardableResult public func placeAbove(_ lowerView: UIView) -> Constraint {
        return placeAbove(lowerView, by: 0, priority: .required)
    }
    
    // MARK: Remove Constraints
    
    private func removeConstraints(onView view: UIView, forAttributes: [NSLayoutConstraint.Attribute]) {
        forAttributes.forEach { (attrib) in
            let const = view.constraints.filter {$0.firstAttribute == attrib}
            superView.removeConstraints(const)
        }
    }
    
    // MARK: Internal helpers
    
    private func constrain(attribute: NSLayoutConstraint.Attribute, to value: CGFloat, relatedBy relation: NSLayoutConstraint.Relation = .equal) -> Constraint {
        removeConstraints(onView: view, forAttributes: [attribute])
        view.addConstraint(NSLayoutConstraint(item: view,
                                              attribute: attribute,
                                              relatedBy: relation,
                                              toItem: nil,
                                              attribute: .notAnAttribute,
                                              multiplier: 1, constant: value))
        return Constraint(superView, view: view)
    }
}
