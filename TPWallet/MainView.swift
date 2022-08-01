//
//  MainView.swift
//  TPWallet
//
//  Created by Truc Pham on 27/07/2022.
//

import SwiftUI

struct MainView: View {
    @Namespace var tabEffect
    @State var tabSelected : TabBar = .home
    init() {
        UITabBar.appearance().isHidden = true
    }
    var body: some View {
        TabView(selection: $tabSelected){
            HomeView().tag(TabBar.home)
            Text("Cards").foregroundColor(.white).frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .background(Color("262450").ignoresSafeArea()).tag(TabBar.cards)
            Text("Profile").foregroundColor(.white).frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .background(Color("262450").ignoresSafeArea()).tag(TabBar.profile)
            StatictisView().tag(TabBar.statistic)
        }
        .overlay(TabBarView(tabBarEffect: tabEffect, currentTab: $tabSelected), alignment: .bottom)
        
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
