//
//  LineGraph.swift
//  TPWallet
//
//  Created by Truc Pham on 28/07/2022.
//

import SwiftUI

struct LineGraph: View {
    var data : [Double]
    let days = ["Mon", "Tue", "Wed", "Tru", "Fri", "Sat", "Sun"]
    @State var currentPlot = ""
    @State var currentDay = ""
    var profit : Bool = true
    //Offset
    @State var offset : CGSize = .zero
    @State var showPlot : Bool = false
    @State var translation : CGFloat = 0
    @State var plotSize : CGSize = .zero
    
    @GestureState var isDrag : Bool = false
    
    @State var graphProgress : CGFloat = 0
    
    var body: some View {
        GeometryReader {proxy in
            let frame = proxy.frame(in: .global)
            let height = frame.height
            let width : CGFloat = proxy.size.width / CGFloat(data.count - 1)
            
            let maxPoint = data.max() ?? 0
            let minPoint = data.min() ?? 0
            
            let points = data.enumerated().map({item -> CGPoint in
                
                //getting progress and multiplyinh winh height
                let progress = (item.element - minPoint) / (maxPoint - minPoint)
                let pathHeight = progress * max(height - 70, 0)
                
                //with
                let pathWidth = width * CGFloat(item.offset)
                
                // Since we need peak to top not bottom
                return .init(x: pathWidth, y: max(height - pathHeight - 50, 0))
            })
            
            ZStack {
                
                // convert plot as points
                //path
                AnimatedGraphPath(dataPoints: points)  .trim(from: 0, to: graphProgress).stroke(lineWidth: 2).fill(
                    LinearGradient(colors: [Color("00D7FF")], startPoint: .leading, endPoint: .trailing)
                    )
                GirdPath(progress: graphProgress, points: points).fill(LinearGradient(colors: [Color("00D7FF"), Color.clear], startPoint: .top, endPoint: .bottom))
                // Path background coloring
                LinearGradient(colors: [
                    Color("00D7FF").opacity(0.5),
                    Color.clear,
                ], startPoint: .top, endPoint: .bottom)
                .clipShape(
                        AnimatedGraphPath(isFill: true, dataPoints: points)
                    )
                    .opacity(graphProgress)
            }
            .overlay(
                VStack(spacing: 0) {
                    Text(currentPlot)
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 10)
                        .background(
                            ZStack {
                                PopperShape(arrowPositionX: translation < plotSize.width ? 0 : (translation > proxy.size.width - plotSize.width ? plotSize.width : (plotSize.width - 20) / 2)).fill(Color("262450").opacity(0.7))
                                PopperShape(arrowPositionX: translation < plotSize.width ? 0 : (translation > proxy.size.width - plotSize.width ? plotSize.width : (plotSize.width - 20) / 2)).stroke(lineWidth: 1).fill(Color.white.opacity(0.5))
                            }
                            
                        )
                        .offset(x: translation < plotSize.width ? plotSize.width / 2 - 10 : 0)
                        .offset(x: translation > proxy.size.width - plotSize.width ? -plotSize.width / 2 + 10 : 0)
                }
                //Fix frame..
                //For gesture calcutation
                    .offset(offset)
                    .opacity(showPlot ? 1 : 0)
                
                ,alignment: .topLeading
                
            )
            .gesture(DragGesture().onChanged({value in
                withAnimation{ showPlot = true }
               
                let translation = value.location.x
                
                // get index
                let index = max(min(Int((translation / width).rounded()), data.count - 1), 0)
                currentPlot = Double(data[index]).convertToCurrency()
                self.translation = translation
                let textAttr = NSAttributedString(string: currentPlot, attributes: [.font : UIFont.preferredFont(forTextStyle: .caption1)])
                let constraintBox = CGSize(width: proxy.size.width, height: .greatestFiniteMagnitude)
                let textSize = textAttr.boundingRect(with: constraintBox, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil).integral.size
                var _plotSize = textSize
                _plotSize.width += 20
                _plotSize.height += 12
                plotSize = _plotSize
                currentDay = days[max(min(index, days.count - 1), 0)]
                //remove half width
                offset = CGSize(width: points[index].x - (_plotSize.width / 2), height: points[index].y - _plotSize.height - 10 - (50 / 2))
                
            }).onEnded({ value in
                withAnimation{
                    showPlot = false
                    currentDay = ""
                }
                
            }).updating($isDrag, body: {value , out, _ in
                out = true
            }))
            .background(
                ZStack {
                    let widthDay = proxy.size.width / CGFloat(data.count)
                    HStack(alignment: .bottom) {
                        ForEach(days, id: \.self) {d in
                            Text(d).foregroundColor(currentDay == d ? Color("00D7FF") : Color("7B78AA"))
                                .font(.system(size: 13).bold())
                                .shadowBlur(radius: currentDay == d ? 10 : 0)
                                .frame(width: widthDay)
                                
                        }
                    }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                        .padding(.horizontal, widthDay)
                    
                }

            )
            .onChange(of: isDrag){newValue in
                if !isDrag { showPlot = false }
            }
            .onAppear{
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.easeInOut(duration: 1.2)){
                        graphProgress = 1
                    }
                }
            }
            .onChange(of: data){ newValue in
                graphProgress = 0
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.easeInOut(duration: 1.2)){
                        graphProgress = 1
                    }
                }
            }
            
        }
        
    }
    
}

struct AnimatedGraphPath : Shape {
    var isFill : Bool = false
    let dataPoints : [CGPoint]
    func path(in rect: CGRect) -> Path {
        Path {path in
            guard let firstPoint = dataPoints.first else {
                return
            }
            path.move(to: firstPoint)
            var previousPoint = firstPoint
            for index in 1 ..< dataPoints.count {
                let nextPoint = dataPoints[index]
                path.addCurve(to: nextPoint,
                              control1: CGPoint(x: previousPoint.x + (nextPoint.x - previousPoint.x) / 2,
                                                y: previousPoint.y),
                              control2: CGPoint(x: nextPoint.x - (nextPoint.x - previousPoint.x) / 2,
                                                y: nextPoint.y))
                previousPoint = nextPoint
            }
            if isFill {
                path.addLine(to: .init(x: rect.width, y: rect.height))
                path.addLine(to: .init(x: 0, y: rect.height))
                path.closeSubpath()
            }
        }
        
    }
}

struct PopperShape : Shape {
    var arrowSize : CGSize = .init(width: 20, height: 10)
    var arrowPositionX : CGFloat = 0
    var animatableData: CGFloat {
        get { arrowPositionX }
        set { arrowPositionX = newValue }
    }
    func path(in rect: CGRect) -> Path {
        Path {path in
            let radius : CGFloat = 10
            
            let start : CGPoint = .init(x: radius, y: 0)
            
            path.move(to: start)
            path.addLine(to: .init(x: rect.width - radius, y: 0))
            
            path.addQuadCurve(to: .init(x: rect.width, y: radius), control: .init(x: rect.width, y: 0))
            
            path.addLine(to: .init(x: rect.width, y: rect.height - radius))
            
            path.addQuadCurve(to: .init(x: rect.width - radius, y: rect.height), control: .init(x: rect.width, y: rect.height))
            
            path.addLine(to: .init(x: min(max(arrowPositionX + (arrowSize.width), 0), rect.width - radius), y: rect.height))
            path.addLine(to: .init(x: min(max(arrowPositionX + (arrowSize.width/2), 0), rect.width - (arrowSize.width / 2)), y: rect.height + arrowSize.height))
            path.addLine(to: .init(x: min(max(arrowPositionX, radius), rect.width - arrowSize.width), y: rect.height))
            
            path.addLine(to: .init(x: radius, y: rect.height))
            
            path.addQuadCurve(to: .init(x: 0, y: rect.height - radius), control: .init(x: 0, y: rect.height))
            
            path.addLine(to: .init(x: 0, y: radius))
            
            path.addQuadCurve(to: start, control: .init(x: 0, y: 0))
            
            path.closeSubpath()
            
        }
    }
}

struct GirdPath : Shape {
    var progress : CGFloat
    var points : [CGPoint]
    var animatableData: CGFloat {
        get { return progress }
        set { progress = newValue }
    }
    func path(in rect: CGRect) -> Path {
        Path {path in
            guard let firstPoint = points.first else { return }
            var prevPoint : CGPoint = firstPoint
            for index in 1 ..< points.count {
                let newPoint = points[index]
                path.move(to: .init(x: prevPoint.x, y: rect.height - 50))
                path.addLine(to: prevPoint)
                prevPoint = newPoint
            }
            path.move(to: .init(x: prevPoint.x, y: rect.height - 50))
            path.addLine(to: prevPoint)
        }
        .trimmedPath(from: 0, to: progress)
        .strokedPath(StrokeStyle(lineWidth: 0.5, dash: [5]))
        
    }
}

extension Double {
    func convertToCurrency() -> String {
        let formater = NumberFormatter()
        formater.numberStyle = .currency
        return formater.string(from: .init(value: self)) ?? ""
    }
}




struct LineGraph_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
extension CGPoint {
    func CGPointDistanceSquared(from: CGPoint, to: CGPoint) -> CGFloat {
        return (from.x - to.x) * (from.x - to.x) + (from.y - to.y) * (from.y - to.y)
    }
    func CGPointDistance(to: CGPoint) -> CGFloat {
        return sqrt(CGPointDistanceSquared(from: self, to: to))
    }
}
