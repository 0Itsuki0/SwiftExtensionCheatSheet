//
//  AnimationAlongPath.swift
//  SwiftExtensionCheatSheet
//
//  Created by Itsuki on 2024/07/30.
//

import SwiftUI


struct AnimationAlongPath: View {
    var body: some View {
        VStack (spacing: 50) {
            NavigationLink {
                AnimationAlongPathNoTangent()
            } label: {
                Text("No Tangent, \nConstant Speed")
                    .multilineTextAlignment(.center)
                    .lineSpacing(12.0)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(RoundedRectangle(cornerRadius: 16).fill(.black))
            }
            
            
            NavigationLink {
                AnimationAlongPathWithTangent()
            } label: {
                Text("With Tangent, \nDerivative dependent speed")
                    .multilineTextAlignment(.center)
                    .lineSpacing(12.0)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(RoundedRectangle(cornerRadius: 16).fill(.black))
            }
        }
        .foregroundStyle(.white)
        .font(.system(size: 24))
        .fixedSize(horizontal: true, vertical: false)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .background(.gray.opacity(0.2))
    }
}


// animation along a path with no tangent, moving at a constant speed
fileprivate struct AnimationAlongPathNoTangent: View {
    private static let totalDuration: CGFloat = 2
    private static let totalPoints: Int = 50

    private static let path = Path { path in
        path.move(to: CGPoint(x: 200, y: 100))
        path.addQuadCurve(to: CGPoint(x: 90, y: 400), control: CGPoint(x: 400, y: 130))
        path.addLine(to: CGPoint(x: 200, y: 200))
        path.addCurve(to: CGPoint(x: 200, y: 200), control1: CGPoint(x: 50, y: 100), control2: CGPoint(x: 180, y: 300))
    }
    
    private var points: [CGPoint] = Self.path.points(totalPoints: Self.totalPoints)
    
    @State private var index: Int = 0
    @State private var sliderValue: Double = 0

    var timer = Timer.publish(every: Self.totalDuration/Double(Self.totalPoints), on: .main, in: .common).autoconnect()

    @State var isRunning: Bool = false

    var body: some View {
        ZStack {
            Self.path
                .stroke()
                .onReceive(timer) { input in
                    if !isRunning || index+1 > points.count - 1 {
                        return
                    }
                    withAnimation(.smooth(duration: Self.totalDuration/Double(Self.totalPoints))) {
                        self.index = index + 1
                        if index >= points.count-1 {
                            isRunning = false
                        }
                        
                    }
                }
                .overlay(content: {
                    Image(systemName: "checkmark.seal.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40)
                        .position(points[index])
                })
                .frame(maxHeight: .infinity, alignment: .top)

            
            VStack {
                Button(action: {
                    if isRunning {
                        return
                    }
                    index = 0
                    isRunning = true
                }, label: {
                    Text(isRunning ? "Running" : "Run")
                        .foregroundStyle(.white)
                        .padding()
                        .frame(width: 100)
                        .background(RoundedRectangle(cornerRadius: 8).fill(.black))
                })
                
                
                Slider(
                    value: $sliderValue,
                    in: 0...Double(Self.totalPoints-1),
                    step: 1.0,
                    label: {
                        Text("\(sliderValue)")
                    }, minimumValueLabel: {
                        Text("0")
                    }, maximumValueLabel: {
                        Text("\(Self.totalPoints-1)")
                    }
                )
                .padding()
                .onChange(of: sliderValue, {
                    self.index = Int(sliderValue)
                })
                .disabled(isRunning)
                
                Text("Point Index: \(Int(sliderValue))")

            }
            .padding(.top, Self.path.boundingRect.height)

        }
        .frame(maxHeight: .infinity)
        .background(.yellow.opacity(0.2))
    }
}

// animation along a path with tangent, moving at a speed dependent on the first derivative of the path
fileprivate struct AnimationAlongPathWithTangent: View {
    private static let totalDuration: CGFloat = 2
    private static let totalPoints: Int = Self.pointsAndTangent.count

    private static let path = Path { path in
        path.move(to: CGPoint(x: 200, y: 100))
        path.addQuadCurve(to: CGPoint(x: 90, y: 400), control: CGPoint(x: 400, y: 130))
        path.addLine(to: CGPoint(x: 200, y: 200))
        path.addCurve(to: CGPoint(x: 200, y: 200), control1: CGPoint(x: 50, y: 100), control2: CGPoint(x: 180, y: 300))
    }
    
    private static let pointsAndTangent: [(CGPoint, Angle)] = Self.path.pointsWithTangents()
    
    @State private var index: Int = 0
    @State private var sliderValue: Double = 0

    var timer = Timer.publish(every: Self.totalDuration/Double(Self.totalPoints), on: .main, in: .common).autoconnect()

    @State var isRunning: Bool = false

    var body: some View {
        ZStack {
            Self.path
                .stroke()
                .onReceive(timer) { input in
                    if !isRunning || index+1 > Self.pointsAndTangent.count - 1 {
                        return
                    }
                    withAnimation(.smooth(duration: Self.totalDuration/Double(Self.totalPoints))) {
                        self.index = index + 1
                        if index >= Self.pointsAndTangent.count-1 {
                            isRunning = false
                        }
                        
                    }
                }
                .overlay(content: {
                    Image(systemName: "airplane.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40)
                        .rotationEffect(Self.pointsAndTangent[index].1)
                        .position(Self.pointsAndTangent[index].0)
                })
                .frame(maxHeight: .infinity, alignment: .top)

            
            VStack {
                Button(action: {
                    if isRunning {
                        return
                    }
                    index = 0
                    isRunning = true
                }, label: {
                    Text(isRunning ? "Running" : "Run")
                        .foregroundStyle(.white)
                        .padding()
                        .frame(width: 100)
                        .background(RoundedRectangle(cornerRadius: 8).fill(.black))
                })
                
                
                Slider(
                    value: $sliderValue,
                    in: 0...Double(Self.totalPoints-1),
                    step: 1.0,
                    label: {
                        Text("\(sliderValue)")
                    }, minimumValueLabel: {
                        Text("0")
                    }, maximumValueLabel: {
                        Text("\(Self.totalPoints-1)")
                    }
                )
                .padding()
                .onChange(of: sliderValue, {
                    self.index = Int(sliderValue)
                })
                .disabled(isRunning)
                
                Text("Point Index: \(Int(sliderValue))")


            }
            .padding(.top, Self.path.boundingRect.height)


        }
        .frame(maxHeight: .infinity)
        .background(.yellow.opacity(0.2))
    }
}


#Preview {
    AnimationAlongPathWithTangent()
}

