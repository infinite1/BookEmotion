//
//  ViewExtension.swift
//  BookEmotion
//
//  Created by Xinyu Sun on 12/2/20.
//  Copyright © 2020 Xinyu Sun. All rights reserved.
//

import SwiftUI

extension View {
	func headerStyle() -> some View {
		self.modifier(HeaderLabel())
	}
}
