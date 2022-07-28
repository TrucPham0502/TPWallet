//
//  StatictisView.swift
//  TPWallet
//
//  Created by Truc Pham on 28/07/2022.
//

import SwiftUI

struct StatictisView: View {
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
            
            VStack(alignment: .leading) {
                let statictis = ["Income", "Outcome"]
                HStack {
                    ForEach(statictis, id: \.self) {st in
                        Button {
                            withAnimation{
                                currentStatictisTab = st
                            }
                        } label: {
                            VStack {
                                Text(st).padding(.bottom, 10)
                                    .foregroundColor(currentStatictisTab == st ? .white : Color("7B78AA"))
                                    .font(.system(size: 15))
                                if currentStatictisTab == st {
                                    Rectangle().fill(Color("00D7FF")).frame(maxWidth: CGFloat.infinity, maxHeight: 2).shadowBlur().matchedGeometryEffect(id: "STATISTICTAB", in: animation)
                                }
                              
                            }
                        }.frame(maxWidth: CGFloat.infinity)
                    }
                }.padding()
                
                Text("Overview").foregroundColor(.white)
                    .font(.system(size: 17))
                    .padding(.horizontal)
                    .padding(.bottom)
                
                
                LineGraph(data: [
                    0,
                    22613.62933558064,
                    23023.361113451934,
                    23076.349218660864,
                    22941.878147936724,
                    21158.096084853874,
                    21095.608738177565,
                    23025.80497091374,
                    0
                ])
            }.padding(.bottom, 60).background(RoundedCorner(radius: 20, corners: [.topLeft, .topRight]).fill(Color("262450")))
            
            
        }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(Color("19173D").ignoresSafeArea())
           
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


