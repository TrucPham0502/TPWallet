//
//  StatictisView.swift
//  TPWallet
//
//  Created by Truc Pham on 28/07/2022.
//

import SwiftUI

struct StatictisView: View {
    @State var dataLineGraph : [Double] = [
        21095.608738177565,
        21558.096084853874,
        22941.878147936724,
        22613.62933558064,
        23023.361113451934,
        23576.349218660864,
        22025.80497091374,
    ]
    @Namespace var animation
    @State var currentStatictisTab : String = "Income"
    @State var currenSegmentTab : String = "Week"
    var body: some View {
        VStack {
            let segment : [String] = ["Week", "Month", "Year"]
            HStack {
                ForEach(segment, id: \.self) {item in
                    Text(item)
                        .foregroundColor(currenSegmentTab == item ? .white : Color("7B78AA"))
                        .font(.system(size: 15))
                        .padding(.vertical, 6)
                        .padding(.horizontal, 30)
                        .contentShape(Rectangle())
                        .frame(height: 44)
                        .background(
                            currenSegmentTab == item ? RoundedRectangle(cornerRadius: 10).fill(LinearGradient(colors: [Color("0DA6C2"), Color("0E39C6")], startPoint: .leading, endPoint: .trailing))
                                .matchedGeometryEffect(id: "SEGMENTEDTAB", in: animation) : nil
                        )
                        .onTapGesture {
                            withAnimation{
                                currenSegmentTab = item
                            }
                        }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous).stroke(lineWidth: 0.5).fill(Color.white.opacity(0.5))
            )
            .padding(.bottom, 30)
            Text("Total Spendings").foregroundColor(Color("7B78AA"))
                .font(.system(size: 15))
                .padding(.bottom, 10)
            Text("$3,660.00").foregroundColor(.white)
                .font(.system(size: 20))
                .padding(.bottom, 30)
            ZStack(alignment: .top) {
                Circle().fill(Color("00D7FF")).frame(width: 150, height: 150).offset(x: 100, y: 50).blur(radius: 100)
                VStack(alignment: .leading) {
                    let statictis = ["Income", "Outcome"]
                    TPTabView(data: statictis, onTap: { st in
                        switch st {
                        case "Income":
                            dataLineGraph = [
                                21095.608738177565,
                                21558.096084853874,
                                22941.878147936724,
                                22613.62933558064,
                                23023.361113451934,
                                23576.349218660864,
                                22025.80497091374,
                            ]
                        case "Outcome":
                            dataLineGraph = [
                                22025.80497091374,
                                23576.349218660864,
                                23023.361113451934,
                                22613.62933558064,
                                22941.878147936724,
                                21558.096084853874,
                                21095.608738177565,
                                
                            ]
                        default:
                            dataLineGraph = [0,0,0,0,0,0,0]
                        }
                    }).padding()
                    
                    Text("Overview").foregroundColor(.white)
                        .font(.system(size: 17))
                        .padding(.horizontal)
                        .padding(.bottom)
                    
                    
                    LineGraph(data: dataLineGraph)
                }.padding(.bottom, 80).background(
                    ZStack {
                        RoundedCorner(radius: 20, corners: [.topLeft, .topRight]).stroke(lineWidth: 1)
                            .fill(Color.white.opacity(0.1))
                        RoundedCorner(radius: 20, corners: [.topLeft, .topRight]).fill(Color("19173D").opacity(0.5))
                    }
                   
                )
                .overlay(
                    Text("Your spending decreased from\n 5% the last week. Good job!")
                        .foregroundColor(.white.opacity(0.87))
                        .font(.system(size: 15))
                        .padding()
                        .padding(.horizontal, 30)
                        .background(
                            ZStack {
                                VisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
                                    .cornerRadius(30)
                                RoundedRectangle(cornerRadius: 30).stroke(lineWidth: 1).fill(.white.opacity(0.5))
                            }
                        )
                        .offset(y: -160)
                    , alignment: .bottom)

            }
                       
            
            
        }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(Color("262450").opacity(1).ignoresSafeArea())
           
    }
}

struct RoundedCorner: Shape {

    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

struct StatictisView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


