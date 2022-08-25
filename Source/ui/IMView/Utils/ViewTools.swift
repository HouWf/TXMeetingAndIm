//
//  ViewTools.swift
//  TUIMeeting
//
//  Created by 候文福 on 2022/8/14.
//

import Foundation

extension UIView{
    // 贝塞尔画圆角
    func cornerRadius(radius:CGFloat, corners:UIRectCorner){
        let bezierPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let radiusLayer = CAShapeLayer()
        radiusLayer.frame = self.bounds
        radiusLayer.path = bezierPath.cgPath
        self.layer.mask = radiusLayer
    }
    
    func cornerRadius(radius: CGFloat, corners: UIRectCorner, color: UIColor, lineWidth: CGFloat) {
        let bezierPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let radiusLayer = CAShapeLayer()
        radiusLayer.frame = self.bounds
        radiusLayer.path = bezierPath.cgPath
        self.layer.mask = radiusLayer
        // 添加border
        let borderLayer = CAShapeLayer()
        borderLayer.frame = self.bounds
        borderLayer.path = bezierPath.cgPath
        borderLayer.lineWidth = lineWidth
        borderLayer.strokeColor = color.cgColor
        borderLayer.fillColor = UIColor.clear.cgColor
        if let layers: NSArray = self.layer.sublayers as? NSArray {
            if let last = layers.lastObject as? AnyObject {
                if last.isKind(of: CAShapeLayer.self) {
                    last.removeFromSuperlayer()
                }
            }
        }
        self.layer.addSublayer(borderLayer)
    }
    
    func cornerRadius(radius: CGFloat, corners: UIRectCorner, bounds: CGRect) {
        let bezierPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let radiusLayer = CAShapeLayer()
        radiusLayer.frame = bounds
        radiusLayer.path = bezierPath.cgPath
        self.layer.mask = radiusLayer
    }
    
    
}
