//
//  TabView.swift
//  TPWallet
//
//  Created by Truc Pham on 29/07/2022.
//

import SwiftUI

struct TPTabView: View {
    @Namespace var animation
    let data : [String]
    let onTap : (String) -> ()
    @State var currentTab : String = ""
    init(data : [String], onTap: @escaping (String) -> ()){
        currentTab = data.first ?? ""
        self.onTap = onTap
        self.data = data
    }
   
    var body: some View {
        HStack(spacing: 0) {
            ForEach(data, id: \.self) {st in
                Button {
                    withAnimation{
                        currentTab = st
                    }
                    onTap(st)
                    
                } label: {
                    VStack {
                        Text(st).padding(.bottom, 10)
                            .foregroundColor(currentTab == st ? .white : Color("7B78AA"))
                            .font(.system(size: 15))
                        if currentTab == st {
                            Rectangle().fill(Color("00D7FF")).frame(maxWidth: CGFloat.infinity, maxHeight: 2).shadowBlur().matchedGeometryEffect(id: "STATISTICTAB", in: animation)
                        }
                        else {
                            Rectangle().fill(Color.white.opacity(0.5)).frame(maxWidth: CGFloat.infinity, maxHeight: 2)
                        }
                      
                    }
                }.frame(maxWidth: CGFloat.infinity)
            }
        }.frame(height: 50)
    }
}

struct TabView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
