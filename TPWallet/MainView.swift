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
            Text("Cards").tag(TabBar.cards)
            Text("Profile").tag(TabBar.profile)
            Text("Statictis").tag(TabBar.statistic)
        }
        .overlay(TabBarView(tabBarEffect: tabEffect, currentTab: $tabSelected), alignment: .bottom)
        
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
