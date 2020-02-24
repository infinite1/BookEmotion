//
//  ContentView.swift
//  BookEmotion
//
//  Created by Xinyu Sun on 5/2/20.
//  Copyright © 2020 Xinyu Sun. All rights reserved.
//

import SwiftUI

struct ContentView: View {
	
	@EnvironmentObject var sessionStore: SessionStore
	
    var body: some View {
		Group {
			if (sessionStore.session != nil) {
				BottomBarView()
			} else {
				LogInView()
			}
		}.onAppear(perform: getUser)
    }
	
	// check if users is logged in
	func getUser() {
		sessionStore.listen()
	}
	
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(SessionStore())
    }
}
