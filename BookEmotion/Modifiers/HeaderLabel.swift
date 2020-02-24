//
//  HeaderLabel.swift
//  BookEmotion
//
//  Created by Xinyu Sun on 12/2/20.
//  Copyright © 2020 Xinyu Sun. All rights reserved.
//

import SwiftUI

struct HeaderLabel: ViewModifier {
	func body(content: Content) -> some View {
		content
			.font(.system(size: 20, weight: .bold, design: .rounded))
	}
}
