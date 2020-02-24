//
//  User.swift
//  BookEmotion
//
//  Created by Xinyu Sun on 5/2/20.
//  Copyright © 2020 Xinyu Sun. All rights reserved.
//

import Foundation

class User {
	var uid: String
	var email: String?
	var displayName: String?
	
	init(uid: String, displayName: String?, email: String?) {
		self.uid = uid
		self.email = email
		self.displayName = displayName
	}
}
