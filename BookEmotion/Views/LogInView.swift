//
//  LogInView.swift
//  BookEmotion
//
//  Created by Xinyu Sun on 5/2/20.
//  Copyright © 2020 Xinyu Sun. All rights reserved.
//

import SwiftUI

struct LogInView: View {
	
	@EnvironmentObject var sessionStore: SessionStore
	
	@State var email: String = ""
	@State var password: String = ""
	@State var loading = false
	@State var error = false
	@State var showSignUpView = false
	
    var body: some View {
		NavigationView {
			
			VStack {
				
				Text("Welcome!")
					.font(.system(size: 30, weight: .semibold, design: .rounded))
					.padding(.bottom, 20)
				
				Image("user")
					.resizable()
					.aspectRatio(contentMode: .fill)
					.frame(width: 140, height: 140)
					.background(Color.pink)
					.clipped()
					.cornerRadius(150)
					.padding(.bottom, 75)
				
			
				TextField("Email Address", text: $email)
					.textFieldStyle(RoundedBorderTextFieldStyle())
					.autocapitalization(.none)
					.keyboardType(.emailAddress)
					.padding()
				
				SecureField("Password", text: $password)
					.textFieldStyle(RoundedBorderTextFieldStyle())
					.padding()
				Spacer()
				
				
				
				VStack(spacing: 20) {
					Button(action: {
						self.signIn()
					}) {
						Text("LOGIN")
							.font(.headline)
							.foregroundColor(.white)
							.padding()
							.frame(width: 220, height: 60)
							.background(Color.blue)
							.cornerRadius(15.0)
					}
					NavigationLink(destination: SignUpView(email: $email, password: $password)) {
						Text("SIGNUP")
							.font(.headline)
							.foregroundColor(.white)
							.padding()
							.frame(width: 220, height: 60)
							.background(Color.blue)
							.cornerRadius(15.0)
					}
				}
	
				
				Spacer()
			}
		}
		.navigationViewStyle(StackNavigationViewStyle())
    }
	
	func signIn() {
		loading = true
		error = false
		sessionStore.signIn(email: email, password: password) { (result, error) in
			self.loading = false
			if error != nil {
				self.error = true
			} else {
				self.email = ""
				self.password = ""
			}
		}
	}
}

struct LogInView_Previews: PreviewProvider {
    static var previews: some View {
        LogInView()
    }
}
