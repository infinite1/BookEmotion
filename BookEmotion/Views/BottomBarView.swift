//
//  BottomBarView.swift
//  BookEmotion
//
//  Created by Xinyu Sun on 5/2/20.
//  Copyright © 2020 Xinyu Sun. All rights reserved.
//

import SwiftUI

struct BottomBarView: View {
    var body: some View {
		TabView {
			LibraryView().tabItem {
				VStack {
					Image(systemName: "book")
						.resizable()
					Text("Library")
				}
			}.tag(0)
			
			HistoryView().tabItem {
				VStack {
					Image(systemName: "clock")
						.resizable()
					Text("History")
				}
			}.tag(1)
			
			SettingsView().tabItem {
				VStack {
					Image(systemName: "person.crop.circle")
						.resizable()
					Text("Account")
				}
			}.tag(2)
		}
    }
}

struct BottomBarView_Previews: PreviewProvider {
    static var previews: some View {
        BottomBarView()
    }
}
