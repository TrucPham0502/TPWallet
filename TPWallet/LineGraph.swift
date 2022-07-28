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
                // Path background coloring
                fillBG()
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
                        .padding(.vertical, 6)
                        .padding(.horizontal, 10)
                        .background(Color.gray)
                        .offset(x: translation < plotSize.width ? plotSize.width / 2 - 2 : 0)
                        .offset(x: translation > proxy.size.width - plotSize.width ? -plotSize.width / 2 + 2 : 0)
                    
                    Rectangle().fill(Color.yellow)
                        .frame(width: 1, height: 40)
                        .padding(.top, 10)
                    
                    Circle().fill(Color.yellow)
                        .frame(width: 22, height: 22)
                        .overlay(
                            Circle().fill(.white)
                                .frame(width: 10, height: 10)
                        )
                    Rectangle().fill(Color.yellow)
                        .frame(width: 1, height: 40)
                }
                //Fix frame..
                //For gesture calcutation
                    .offset(offset)
                    .opacity(showPlot ? 1 : 0)
                
                ,alignment: .topLeading
                
            )
            .contentShape(Rectangle())
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
                currentDay = days[max(min(index - 1, days.count - 1), 0)]
                //remove half width
                offset = CGSize(width: points[index].x - (_plotSize.width / 2), height: points[index].y - _plotSize.height - 10 - ((40 + 22 + 40) / 2))
                
            }).onEnded({ value in
                withAnimation{
                    showPlot = false
                    currentDay = ""
                }
                
            }).updating($isDrag, body: {value , out, _ in
                out = true
            }))
            .background(
                VStack {
                    Spacer()
                    HStack(alignment: .bottom) {
                        ForEach(days, id: \.self) {d in
                            Text(d).foregroundColor(currentDay == d ? Color("00D7FF") : Color("7B78AA"))
                                .font(.system(size: 13).bold())
                                .shadowBlur(radius: currentDay == d ? 10 : 0)
                            Spacer()
                        }
                    }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                        .padding(.horizontal, width / CGFloat(data.count))
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
    
    
    @ViewBuilder
    func fillBG() -> some View {
        LinearGradient(colors: [
            Color("00D7FF").opacity(0.5),
            Color.clear,
        ], startPoint: .top, endPoint: .bottom)
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


struct GirdPath : Shape {
    var progress : CGFloat
    var points : [CGPoint]
    var animatableData: CGFloat {
        get { return progress }
        set { progress = newValue }
    }
    func path(in rect: CGRect) -> Path {
        Path {path in
            let minPoint : CGPoint = points.min(by: {p1, p2 in
                p1.y > p2.y
            }) ?? .zero
            let maxPoint : CGPoint = points.max(by: { p1, p2 in
                p1.y > p2.y
            }) ?? .zero
            let centerPoint : CGPoint = .init(x: 0, y: (minPoint.y + maxPoint.y) / 2)
            let startPoint : CGPoint = .init(x: 0, y: rect.height)
            path.move(to: startPoint)
            let _points : [CGPoint] = [minPoint, centerPoint, maxPoint, .zero]
            _points.forEach{
                let point : CGPoint = .init(x: 0, y: $0.y)
                path.addLine(to: point)
                guard $0 != .zero else { return }
                path.addLine(to: .init(x: rect.width, y: point.y))
                path.move(to: point)
            }
        }
        .trimmedPath(from: 0, to: progress)
        .strokedPath(StrokeStyle(lineWidth: 1, lineCap: .round, lineJoin: .round))
        
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
