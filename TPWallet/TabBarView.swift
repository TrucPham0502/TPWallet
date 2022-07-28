//
//  TabBar.swift
//  TPWallet
//
//  Created by Truc Pham on 27/07/2022.
//

import SwiftUI

struct TabBarView: View {
    var tabBarEffect : Namespace.ID
    @Binding var currentTab : TabBar
    var body: some View {
        HStack {
            ForEach(TabBar.allCases, id: \.rawValue) {tab in
                tabButton(tab)
            }
        }
        .background(
            Color("7B78AA").blur(radius: 60).clipShape(BottomCurve(centerX: self.getCenterXValue())).shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: -5)
                .ignoresSafeArea(.container, edges: .bottom).matchedGeometryEffect(id: "shapeEffect", in: tabBarEffect).animation(.spring())
            
        )
    }
    func getCenterXValue() -> CGFloat {
        let width = UIScreen.main.bounds.width / CGFloat(TabBar.allCases.count)
        guard let index = TabBar.allCases.firstIndex(where: { $0.rawValue == currentTab.rawValue }) else { return 0 }
        return (width * CGFloat((index + 1))) - width / 2
    }
    @ViewBuilder
    func tabButton(_ tab: TabBar) -> some View {
        GeometryReader {proxy in
            Button {
                withAnimation(.spring()) {
                    currentTab = tab
                }
            } label: {
                Image(tab.rawValue)
                    .resizable()
                    .renderingMode(.template)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 25, height: 25)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 30)
                    .foregroundColor(currentTab == tab ? Color("00D7FF") : Color("7B78AA"))
                    .contentShape(Rectangle())
            }
            
        }.frame(height: 50)
    }
}

enum TabBar : String, CaseIterable {
    case home = "Home"
    case cards = "Cards"
    case profile = "Profile"
    case statistic = "Statistic"
}

struct BottomCurve: Shape {
    var animatableData: CGFloat {
        get { return centerX }
        set { centerX = newValue }
    }
    var centerX : CGFloat
    func path(in rect: CGRect) -> Path {
        print("centerX: \(centerX)")
        let f : CGFloat = 15
        let b : CGFloat = 5
        let padding : CGFloat = 10
        let imageSize : CGFloat = 30
        
        return Path {path in
            path.move(to: .zero)
            path.addLine(to: .init(x: centerX - (imageSize / 2) - padding - f, y: 0))
            
            path.addQuadCurve(to: .init(x: centerX - (imageSize / 2) - padding, y: b), control: .init(x: centerX - (imageSize / 2) - (f), y: 0))
            
            path.addQuadCurve(to: .init(x: centerX + (imageSize / 2) + padding, y: b), control: .init(x: centerX , y: (imageSize / 2) + padding + b))
            
            path.addQuadCurve(to: .init(x: centerX + (imageSize / 2) + padding + f, y: 0), control: .init(x: centerX + (imageSize / 2) + padding + (f/2), y: 0))
            
            path.addLine(to: .init(x: rect.maxX, y: 0))
            path.addLine(to: .init(x: rect.maxX, y: rect.maxY))
            path.addLine(to: .init(x: 0, y: rect.maxY))
        }
    }
}
struct TabBar_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
