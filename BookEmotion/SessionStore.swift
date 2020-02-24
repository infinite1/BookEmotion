//
//  SessionStore.swift
//  BookEmotion
//
//  Created by Xinyu Sun on 5/2/20.
//  Copyright © 2020 Xinyu Sun. All rights reserved.
//

import SwiftUI
import Firebase
import Combine

final class SessionStore: ObservableObject {
	
	// session checks if the user has logged in or not
	@Published var session: User?
	var handle: AuthStateDidChangeListenerHandle?
	
	func listen() {
		// monitor authentication changes in firebase
		handle = Auth.auth().addStateDidChangeListener {
			(auth, user) in
			if let user = user {
				print("User is \(user)")
				self.session = User(
					uid: user.uid,
					displayName: user.displayName,
					email: nil
				)
			} else {
				self.session = nil
			}
		}
	}
	
	func signUp(
		email: String,
		password: String,
		handler: @escaping AuthDataResultCallback
	) {
		Auth.auth().createUser(withEmail: email, password: password, completion: handler)
		Auth.auth().signIn(withEmail: email, password: password, completion: handler)
		registerForPushNotifications()
		updateFirestorePushTokenIfNeeded(userId: email)
	}
	
	func signIn(
		email: String,
		password: String,
		handler: @escaping AuthDataResultCallback
	) {
		Auth.auth().signIn(withEmail: email, password: password, completion: handler)
		registerForPushNotifications()
		updateFirestorePushTokenIfNeeded(userId: email)
	}
	
	func signOut() {
		try! Auth.auth().signOut()
	}
	
	
	// register at APNS for push notification
	func registerForPushNotifications() {
		guard let application = UIApplication.shared as UIApplication? else { return }
		application.registerForRemoteNotifications()
	}
	
	// upload FCM token to database
	func updateFirestorePushTokenIfNeeded(userId: String) {
		if let token = Messaging.messaging().fcmToken {
			let usersRef = Firestore.firestore().collection("users_table").document(userId)
			usersRef.setData(["fcmToken": token], merge: true)
		}
	}
	

	
}
