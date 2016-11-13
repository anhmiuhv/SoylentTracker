//
//  CounterView.swift
//  Flo
//
//  Created by Linh Hoang on 10/21/16.
//  Copyright © 2016 Linh Hoang. All rights reserved.
//

import UIKit

let NoOfGlasses = 8
let π:CGFloat = CGFloat(M_PI)

@IBDesignable class CounterView: UIView {

    @IBInspectable var counter: Int = 5
        {
        didSet {
            if counter <=  NoOfGlasses {
                //the view needs to be refreshed
                setNeedsDisplay()
            }
        }
    }

    @IBInspectable var outlineColor: UIColor = UIColor.blue
    @IBInspectable var counterColor: UIColor = UIColor.orange

    override func draw(_ rect: CGRect) {
        // 1
        let center = CGPoint(x:bounds.width/2, y: bounds.height/2)

        // 2
        let radius: CGFloat = max(bounds.width, bounds.height)

        // 3
        let arcWidth: CGFloat = 76

        // 4
        let startAngle: CGFloat = 3 * π / 4
        let endAngle: CGFloat = π / 4

        // 5
        let path = UIBezierPath(arcCenter: center,
                                radius: radius/2 - arcWidth/2,
                                startAngle: startAngle,
                                endAngle: endAngle,
                                clockwise: true)

        // 6
        path.lineWidth = arcWidth
        counterColor.setStroke()
        path.stroke()

        //Draw the outline

        //1 - first calculate the difference between the two angles
        //ensuring it is positive
        let angleDifference: CGFloat = 2 * π - startAngle + endAngle

        //then calculate the arc for each single glass
        let arcLengthPerGlass = angleDifference / CGFloat(NoOfGlasses)

        //then multiply out by the actual glasses drunk
        let outlineEndAngle = arcLengthPerGlass * CGFloat(counter) + startAngle

        //2 - draw the outer arc
        let outlinePath = UIBezierPath(arcCenter: center,
                                       radius: bounds.width/2 - 2.5,
                                       startAngle: startAngle,
                                       endAngle: outlineEndAngle,
                                       clockwise: true)

        //3 - draw the inner arc
        outlinePath.addArc(withCenter: center,
                           radius: bounds.width/2 - arcWidth + 2.5,
                           startAngle: outlineEndAngle,
                           endAngle: startAngle,
                           clockwise: false)

        //4 - close the path
        outlinePath.close()

        outlineColor.setStroke()
        outlinePath.lineWidth = 5.0
        outlinePath.stroke()

        //Counter View markers

        let context = UIGraphicsGetCurrentContext()

        //1 - save original state
        context!.saveGState()
        outlineColor.setFill()

        let markerWidth:CGFloat = 5.0
        let markerSize:CGFloat = 10.0

        //2 - the marker rectangle positioned at the top left
        let markerPath = UIBezierPath(rect:
            CGRect(x: -markerWidth/2,
                   y: 0,
                   width: markerWidth,
                   height: markerSize))

        //3 - move top left of context to the previous center position
        context!.translateBy(x: rect.width/2,
                             y: rect.height/2)

        for i in 1...NoOfGlasses {
            //4 - save the centred context
            context!.saveGState()

            //5 - calculate the rotation angle
            let angle = arcLengthPerGlass * CGFloat(i) + startAngle - π/2

            //rotate and translate
            context!.rotate(by: angle)
            context!.translateBy(x: 0,
                                 y: rect.height/2 - markerSize)

            //6 - fill the marker rectangle
            markerPath.fill()

            //7 - restore the centred context for the next rotate
            context!.restoreGState()
        }

        //8 - restore the original state in case of more painting
        context!.restoreGState()
    }
}
