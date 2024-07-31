//
//  Path+Extensions.swift
//  SwiftExtensionCheatSheet
//
//  Created by Itsuki on 2024/07/30.
//

import SwiftUI

extension Path {
    var elementsCount: Int {
        // ex: 200 100 m 400 130 90 400 q 200 200 l 50 100 180 300 200 200 c h
        let descriptionArray = self.description.lowercased().components(separatedBy: CharacterSet.lowercaseLetters)
        return descriptionArray.count - 1
    }
    
    // starting point of the path
    var startPoint: CGPoint? {
        if self.description.isEmpty {
            return nil
        }
        let descriptionArray = self.description.lowercased().components(separatedBy: CharacterSet.lowercaseLetters)
        guard let move = descriptionArray.first?.trimmingCharacters(in: .whitespaces) else {
            return nil
        }
        let pointsArray = move.components(separatedBy: .whitespaces)
        if pointsArray.count != 2 {
            return nil
        }
        guard let x = Double(pointsArray[0]),  let y = Double(pointsArray[1]) else {
            return nil
        }
  
        return CGPoint(x: x, y: y)
    }
    
    
    func points(totalPoints: Int) -> [CGPoint] {
        if self.description.isEmpty {
            return []
        }
        
        guard let startPoint = self.startPoint else {
            return  []
        }
        
        let timeInterval: CGFloat = 1/CGFloat(totalPoints)
        var currentTime: CGFloat = 0
        var points: [CGPoint] = [startPoint]
        
        while currentTime <= 1 {
            if let currentPoint = self.trimmedPath(from: 0, to: currentTime).currentPoint {
                points.append(currentPoint)
            }
            currentTime = currentTime + timeInterval
        }
        return points
    }
    

    func points(pointsPerElement: [Int]) -> [CGPoint] {
        if self.description.trimmingCharacters(in: .whitespaces).isEmpty {
            return []
        }
        
        if pointsPerElement.count != self.elementsCount {
            return []
        }
        
        guard let pathStart = self.startPoint else {
            return  []
        }
        
        var points: [CGPoint] = []

        var currentPoint: CGPoint = pathStart
        var segmentIndex = 0
        
        self.forEach { element in
            
            switch element {
            case .move(to: let point):
                if pointsPerElement[segmentIndex] > 0 {
                    points.append(point)
                }
                currentPoint = point
                break
                
            case .line(to: let end):
                let pointsInLine = pointsInLine(start: currentPoint, end: end, totalPoints: pointsPerElement[segmentIndex]).dropFirst()
                points.append(contentsOf: pointsInLine)
                currentPoint = end
                break
                
            case .quadCurve(to: let end, control: let control):
                let pointsInQuad = pointsInQuadCurve(start: currentPoint, end: end, control: control, totalPoints: pointsPerElement[segmentIndex]).dropFirst()
                points.append(contentsOf: pointsInQuad)
                currentPoint = end
                break
                
            case .curve(to: let end, control1: let control1, control2: let control2):
                let pointsInCurve = pointsInCurve(start: currentPoint, end: end, control1: control1, control2: control2, totalPoints: pointsPerElement[segmentIndex]).dropFirst()
                points.append(contentsOf: pointsInCurve)
                currentPoint = end
                break
                
            case .closeSubpath:
                let pointsInLine = pointsInLine(start: currentPoint, end: pathStart, totalPoints: pointsPerElement[segmentIndex]).dropFirst()
                points.append(contentsOf: pointsInLine)
                currentPoint = pathStart
                
                break
            }
            segmentIndex += 1
        }
        return points
    }
    
    func points(pointsPerElement: Int) -> [CGPoint] {
        return self.points(pointsPerElement: Array.init(repeating: pointsPerElement, count: self.elementsCount))
    }

    
    func pointsWithTangents(pointsPerElement: [Int]) -> [(CGPoint, Angle)] {
        if self.description.trimmingCharacters(in: .whitespaces).isEmpty {
            return []
        }
        
        if pointsPerElement.count != self.elementsCount {
            return []
        }
        
        guard let pathStart = self.startPoint else {
            return  []
        }
        
        var pointsWithTangents: [(CGPoint, Angle)] = []
        var currentPoint: CGPoint = pathStart
        var elementIndex = 0
        var previousIsMove: Bool = false
        
        self.forEach { element in
            
            switch element {
            case .move(to: let point):
                // last element is move
                if pointsPerElement[elementIndex] > 0 &&  elementIndex == self.elementsCount - 1 {
                    pointsWithTangents.append((point, Angle(degrees: 0)))
                } else if pointsPerElement[elementIndex] > 0 &&  previousIsMove {
                    pointsWithTangents.append((point, Angle(degrees: 0)))
                }
                
                currentPoint = point
                break
                
            case .line(to: let end):
                pointsWithTangents.append(contentsOf: pointsTangentsInLine(start: currentPoint, end: end, totalPoints: pointsPerElement[elementIndex]).dropFirst(previousIsMove ? 0 : 1))
                currentPoint = end
                break
                
            case .quadCurve(to: let end, control: let control):
                pointsWithTangents.append(contentsOf: pointsTangentsInQuadCurve(start: currentPoint, end: end, control: control, totalPoints: pointsPerElement[elementIndex]).dropFirst(previousIsMove ? 0 : 1))
                currentPoint = end
                break
                
            case .curve(to: let end, control1: let control1, control2: let control2):
                pointsWithTangents.append(contentsOf: pointsTangentsInCurve(start: currentPoint, end: end, control1: control1, control2: control2, totalPoints: pointsPerElement[elementIndex]).dropFirst(previousIsMove ? 0 : 1))
                currentPoint = end
                break
                
            case .closeSubpath:
                pointsWithTangents.append(contentsOf: pointsTangentsInLine(start: currentPoint, end: pathStart, totalPoints: pointsPerElement[elementIndex]).dropFirst(previousIsMove ? 0 : 1))
                currentPoint = pathStart
            
                break
            }
            previousIsMove = if case .move = element {
                true
            } else {
                false
            }

            elementIndex += 1
        }
        return pointsWithTangents
    }
    
    
    func pointsWithTangents(pointsPerElement: Int = 10) -> [(CGPoint, Angle)] {
        return self.pointsWithTangents(pointsPerElement: Array.init(repeating: pointsPerElement, count: self.elementsCount))
    }
    
 
    
//    MARK: line
//    y(x) = mx + c
//    y'(x) = m
    private func pointsInLine(start: CGPoint, end: CGPoint, totalPoints: Int) -> [CGPoint] {
        var points: [CGPoint] = []

        // vertical line
        if end.x == start.x {
            let yTickInterval = abs(end.y - start.y)/CGFloat(totalPoints)

            var currentY = start.y
            if currentY >= end.y {
                while currentY >= end.y {
                    points.append(CGPoint(x: start.x, y: currentY))
                    currentY = currentY - yTickInterval
                }
            } else {
                while currentY <= end.y {
                    points.append(CGPoint(x: start.x, y: currentY))
                    currentY = currentY + yTickInterval
                }
            }
            return points
        }
        
        let xTickInterval = abs(start.x - end.x)/CGFloat(totalPoints)
        let slope: CGFloat = (end.y - start.y) / (end.x - start.x)
        let intercept: CGFloat = start.y - slope * start.x
        var currentX = start.x
        
        if currentX >= end.x {
            while currentX >= end.x {
                let currentY = slope * currentX + intercept
                points.append(CGPoint(x: currentX, y: currentY))
                currentX = currentX - xTickInterval
            }
        } else {
            while currentX <= end.x {
                let currentY = slope * currentX + intercept
                points.append(CGPoint(x: currentX, y: currentY))
                currentX = currentX + xTickInterval
            }
        }
        
        return points
    }
    
    
    private func pointsTangentsInLine(start: CGPoint, end: CGPoint, totalPoints: Int) -> [(CGPoint, Angle)] {
        let points = pointsInLine(start: start, end: end, totalPoints: totalPoints)
        let tangent = lineTangent(start: start, end: end)
        let tangents = Array(repeating: tangent, count: points.count)
        
        return Array(zip(points, tangents))
    }
    
    
    private func lineTangent(start: CGPoint, end: CGPoint) -> Angle {
        if (end.x == start.x) {
            if (end.y > start.y) {
                return Angle(degrees: 90)
            } else {
                return Angle(degrees: -90)
            }
        }
        
        let atan = atan2((end.y - start.y), (end.x - start.x))
        return Angle(radians: atan)
    }
    
    
    
//    MARK: cubic Bézier curve:
//    B(t)=(1−t)^3*P0+3(1−t)^2*t*P1+3(1−t)*t^2*P2+t^3*P3
//    P0 – start point
//    P1 – first control point (close to P0)
//    P2 – second control point (close to P3)
//    P3 – end point
//    B′(t)=−3(1−t)^2*P0+3(3t^2−4t+1)*P1+3(2t−3t^2)P2+3t^2*P3
    private func pointsInCurve(start: CGPoint, end: CGPoint, control1: CGPoint, control2: CGPoint, totalPoints: Int) -> [CGPoint] {
        let tTickInterval: CGFloat = 1/CGFloat(totalPoints)
        var points: [CGPoint] = []
        // when time = 1, endpoint reached
        var time: CGFloat = 0
        while time <= 1.0 {
            points.append(curvePointAtTime(start: start, end: end, control1: control1, control2: control2, t: time))
            time = time + tTickInterval
        }
        return points
    }
    
    private func pointsTangentsInCurve(start: CGPoint, end: CGPoint, control1: CGPoint, control2: CGPoint, totalPoints: Int) -> [(CGPoint, Angle)] {
        let tTickInterval: CGFloat = 1/CGFloat(totalPoints)
        var points: [CGPoint] = []
        var tangents: [Angle] = []

        // when time = 1, endpoint reached
        var time: CGFloat = 0        
        while time <= 1.0 {
            tangents.append(curveTangentAtTime(start: start, end: end, control1: control1, control2: control2, t: time))
            points.append(curvePointAtTime(start: start, end: end, control1: control1, control2: control2, t: time))
            time = time + tTickInterval
        }
        return Array(zip(points, tangents))
    }

    
    private func curvePointAtTime(start: CGPoint, end: CGPoint, control1: CGPoint, control2: CGPoint, t: CGFloat) -> CGPoint {
        let (startX, startY) = (start.x, start.y)
        let (endX, endY) = (end.x, end.y)
        let (control1X, control1Y) = (control1.x, control1.y)
        let (control2X, control2Y) = (control2.x, control2.y)

        let pointX = pow((1-t),3)*startX + 3*pow((1-t),2)*t*control1X + 3*(1-t)*pow(t,2)*control2X + pow(t,3)*endX
        let pointY = pow((1-t),3)*startY + 3*pow((1-t),2)*t*control1Y + 3*(1-t)*pow(t,2)*control2Y + pow(t,3)*endY
        return CGPoint(x: pointX, y: pointY)
    }

    private func curveTangentAtTime(start: CGPoint, end: CGPoint, control1: CGPoint, control2: CGPoint, t: CGFloat) -> Angle {
        let (startX, startY) = (start.x, start.y)
        let (endX, endY) = (end.x, end.y)
        let (control1X, control1Y) = (control1.x, control1.y)
        let (control2X, control2Y) = (control2.x, control2.y)
        
        let dx = -3*pow((1-t),2)*startX + 3*(3*t*t-4*t+1)*control1X + 3*(2*t-3*t*t)*control2X + 3*pow(t,2)*endX
        let dy = -3*pow((1-t),2)*startY + 3*(3*t*t-4*t+1)*control1Y + 3*(2*t-3*t*t)*control2Y + 3*pow(t,2)*endY
        let atan = atan2(dy, dx)
        return Angle(radians: atan)
    }
    
    
    
//    MARK: quadratic Bézier curve
//    B(t)=(1−t)^2*P0+2(1−t)*t*P1+t^2*P2
//    P0 – start point
//    P1 – control point
//    P2 – end point
//    B'(t)=2(1−t)*(P1-P0)+2t(P2-P1)
    private func pointsInQuadCurve(start: CGPoint, end: CGPoint, control: CGPoint, totalPoints: Int) -> [CGPoint] {
        let tTickInterval: CGFloat = 1/CGFloat(totalPoints)
        var points: [CGPoint] = []

        // when time = 1, endpoint reached
        var time: CGFloat = 0
        while time <= 1.0 {
            points.append(quadPointAtTime(start: start, end: end, control: control, t: time))
            time = time + tTickInterval
        }

        return points
    }
    
    private func pointsTangentsInQuadCurve(start: CGPoint, end: CGPoint, control: CGPoint, totalPoints: Int) -> [(CGPoint, Angle)] {
        let tTickInterval: CGFloat = 1/CGFloat(totalPoints)
        var points: [CGPoint] = []
        var tangents: [Angle] = []
        
        // when time = 1, endpoint reached
        var time: CGFloat = 0
        while time <= 1.0 {
            points.append(quadPointAtTime(start: start, end: end, control: control, t: time))
            tangents.append(quadTangentAtTime(start: start, end: end, control: control, t: time))
            time = time + tTickInterval
        }
        return Array(zip(points, tangents))
    }

    
    private func quadPointAtTime(start: CGPoint, end: CGPoint, control: CGPoint, t: CGFloat) -> CGPoint {
        let (startX, startY) = (start.x, start.y)
        let (endX, endY) = (end.x, end.y)
        let (controlX, controlY) = (control.x, control.y)
    
        let pointX = pow((1-t),2)*startX + 2*(1-t)*t*controlX + pow(t,2)*endX
        let pointY = pow((1-t),2)*startY + 2*(1-t)*t*controlY + pow(t,2)*endY
        return CGPoint(x: pointX, y: pointY)
    }
    
    private func quadTangentAtTime(start: CGPoint, end: CGPoint, control: CGPoint, t: CGFloat) -> Angle {
        let (startX, startY) = (start.x, start.y)
        let (endX, endY) = (end.x, end.y)

        let (controlX, controlY) = (control.x, control.y)
        
        let dx = 2*(1-t)*(controlX-startX) + 2*t*(endX-controlX)
        let dy = 2*(1-t)*(controlY-startY) + 2*t*(endY-controlY)
        let atan = atan2(dy, dx)
        return Angle(radians: atan)
    }

}
