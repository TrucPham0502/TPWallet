//
//  HomeView.swift
//  TPWallet
//
//  Created by Truc Pham on 27/07/2022.
//

import SwiftUI
struct WalletModel : Identifiable {
    let id : String
    let image : String
    let name : String
    let date : Date
    let money : Double
}
struct HomeView: View {
    @State var currentProgress : CGFloat = 0
    let walletData : [WalletModel] = [
        .init(id: UUID().uuidString, image: "Amazon WC", name: "Amazon", date: Date(), money: -103.56),
        .init(id: UUID().uuidString,image: "Mcdonalds WC", name: "Mcdonalds", date: Date(), money: -34.78),
        .init(id: UUID().uuidString,image: "Apple WC", name: "Apple", date: Date(), money: -1000.97),
        .init(id: UUID().uuidString,image: "Starbucks WC", name: "Starbucks", date: Date(), money: -13.67),
        .init(id: UUID().uuidString,image: "Mastercard WC", name: "Mastercard", date: Date(), money: -1223.56),
    ]
    var body: some View {
        VStack {
            HStack {
                Image("Avatar")
                    .resizable()
                    .frame(width: 44, height: 44, alignment: .leading)
                VStack(alignment: .leading) {
                    Text("Wellcom back!")
                        .foregroundColor(.white)
                        .font(.system(size: 15, weight: .medium))
                    Text("Sandy Chungus").foregroundColor(Color("7B78AA"))
                        .font(.system(size: 13, weight: .medium))
                    
                }
                Spacer()
                Button {
                    
                } label: {
                    Image("Huge-icon")
                        .resizable()
                        .frame(width: 24, height: 24)
                }
                Button {
                    
                } label: {
                    Image("More_Vertical")
                        .resizable()
                        .frame(width: 24, height: 24)
                }
            }.padding(.bottom, 20)
            .padding(.horizontal, 20)
            VStack {
                ZStack {
                    let circleSize : CGFloat = 220
                    let inCircleSize : CGFloat = 160
                    Circle().stroke(.white.opacity(0.15),style: .init(lineWidth: 1, lineCap: .round))
                        .frame(width: circleSize + 1, height: circleSize + 1)
                    
                    Circle().stroke(.white.opacity(0.15),style: .init(lineWidth: 1, lineCap: .round))
                        .frame(width: inCircleSize, height: inCircleSize)
                    
                    Circle().stroke(LinearGradient(colors: [Color("2D2E53"),Color("201F3F")], startPoint: .topLeading, endPoint: .bottomTrailing),style: .init(lineWidth: (circleSize - inCircleSize) / 2, lineCap: .round))
                        .frame(width: inCircleSize + ((circleSize - inCircleSize) / 2), height: inCircleSize + ((circleSize - inCircleSize) / 2))

                    Circle().trim(from: currentProgress, to: currentProgress + 0.2).stroke(LinearGradient(colors: [Color("0DA6C2"), Color("61DE70")], startPoint: .top, endPoint: .bottom),style: .init(lineWidth: 36, lineCap: .round))
                       
                        .frame(width: inCircleSize + ((circleSize - inCircleSize) / 2), height:inCircleSize + ((circleSize - inCircleSize) / 2))
                        .shadow()
                        .rotationEffect(.init(radians: 180))
  
                    Circle().trim(from: currentProgress + 0.15, to: currentProgress + 0.35).stroke(LinearGradient(colors: [Color("0DA6C2"), Color("0E39C6")], startPoint: .top, endPoint: .bottom),style: .init(lineWidth: 36, lineCap: .round))
                        .frame(width: inCircleSize + ((circleSize - inCircleSize) / 2), height: inCircleSize + ((circleSize - inCircleSize) / 2))
                        .shadow()
                        .rotationEffect(.init(radians: 180))

                    Circle().trim(from: currentProgress + 0.3, to: currentProgress + 0.5).stroke(LinearGradient(colors: [Color("9327F0"), Color("320DAF")], startPoint: .trailing, endPoint: .leading),style: .init(lineWidth: 36, lineCap: .round))
                        .frame(width: inCircleSize + ((circleSize - inCircleSize) / 2), height: inCircleSize + ((circleSize - inCircleSize) / 2))
                        .shadow()
                        .rotationEffect(.init(radians: 180))
                    
                    VStack(spacing: 5) {
                        Text("$5,643.50").foregroundColor(.white)
                            .font(.system(size: 20, weight: .heavy))
                        Text("Available Balance").foregroundColor(Color("7B78AA"))
                            .font(.system(size: 13))
                    }
                }.frame(maxWidth: .infinity)
                    .padding(.bottom, 40)
                
                VStack(alignment : .leading) {
                    Text("My transaction").foregroundColor(.white)
                        .font(.system(size: 17, weight: .bold))
                    ScrollView(.vertical, showsIndicators: false) {
                        ForEach(walletData, id: \.id) {item in
                            itemWallet(item).onTapGesture {
                                withAnimation{
                                    currentProgress = Double.random(min: 0, max: 1)
                                }
                            }
                        }
                    }.padding(.bottom, 30)
                    
                }.frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(
                ZStack {
                    HomeBackgroudShape(startY: 110).stroke(Color("7B78AA"), lineWidth: 1)
                    Rectangle()
                    .fill(Color("262450"))
                    .clipShape(HomeBackgroudShape(startY: 110)).ignoresSafeArea()
                }
                
            )
            .onAppear{
                withAnimation{
                    currentProgress = 0.3
                }
            }
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(Color("19173D").ignoresSafeArea())
        
    }
    
    
    @ViewBuilder
    func itemWallet(_ data : WalletModel) -> some View {
        HStack{
            Image(data.image)
                .resizable()
                .frame(width: 48, height: 48)
            VStack(alignment: .leading){
                Text(data.name)
                    .foregroundColor(.white)
                    .font(.system(size: 13).bold())
                Text(data.date.format("MMM dd, yyyy"))
                    .foregroundColor(Color("7B78AA"))
                    .font(.system(size: 13))
            }
            Spacer()
            Text(String(format: "$ %.2f", data.money))
                .foregroundColor(.white)
                .font(.system(size: 13))
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .frame(width: 90, height: 44)
                .overlay(RoundedRectangle(cornerRadius: 25)
                    .stroke(Color.white.opacity(0.87), lineWidth: 0.5))
        }.frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .padding(.vertical)
            .background(RoundedRectangle(cornerRadius: 45).fill(Color("19173D")))
            .overlay(RoundedRectangle(cornerRadius: 45)
                .stroke(Color.white.opacity(0.87), lineWidth: 0.5))
            .padding(.bottom, 10)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct HomeBackgroudShape : Shape {
    var startY : CGFloat = 0
    func path(in rect: CGRect) -> Path {
        let centerX : CGFloat = rect.width / 2
        let f1 : CGFloat = 45
        let b : CGFloat = 25
        let padding : CGFloat = 20
        let imageSize : CGFloat = 220
        
        return Path {path in
            let startPoint = CGPoint(x: 0, y: startY)
            path.move(to: startPoint)
            path.addLine(to: .init(x: centerX - (imageSize / 2) - padding - f1, y: startY))
            
            path.addQuadCurve(to: .init(x: centerX - (imageSize / 2) - padding - 10, y: startY + b), control: .init(x: centerX - (imageSize / 2) - padding - 20, y: startY))
            
            path.addCurve(to: .init(x: centerX + (imageSize / 2) + padding + 10, y: startY + b), control1: .init(x: centerX - (imageSize / 2) , y: startY + (imageSize / 2) + padding + 40), control2: .init(x: centerX + (imageSize / 2), y: startY + (imageSize / 2) + padding + 40))
            
            path.addQuadCurve(to: .init(x: centerX + (imageSize / 2) + padding + f1, y: startY), control: .init(x: centerX + (imageSize / 2) + padding + 20, y: startY))
            
            path.addLine(to: .init(x: rect.maxX, y: startY))
            path.addLine(to: .init(x: rect.maxX, y: rect.maxY))
            path.addLine(to: .init(x: 0, y: rect.maxY))
        }
    }
}
extension Date {
   func format(_ format: String) -> String {
        let dateformat = DateFormatter()
        dateformat.dateFormat = format
        return dateformat.string(from: self)
    }
}

public extension Double {

    /// Returns a random floating point number between 0.0 and 1.0, inclusive.
    static var random: Double {
        return Double(arc4random()) / 0xFFFFFFFF
    }

    /// Random double between 0 and n-1.
    ///
    /// - Parameter n:  Interval max
    /// - Returns:      Returns a random double point number between 0 and n max
    static func random(min: Double, max: Double) -> Double {
        return Double.random * (max - min) + min
    }
}
