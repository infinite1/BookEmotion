//
//  SwiftUIView.swift
//  BookEmotion
//
//  Created by Xinyu Sun on 12/2/20.
//  Copyright © 2020 Xinyu Sun. All rights reserved.
//

import SwiftUI

struct SwiftUIView: View {
    var body: some View {
		
		Form {
			
			
			
			HStack {
				Spacer()
				Text("Record your opinion")
				
				Spacer()
				
				Button(action: {
					
				}) {
					Image(systemName: "mic.circle.fill")
						.resizable()
						.aspectRatio(contentMode: .fill)
						.frame(width: 50, height: 50)
						.clipped()
						.foregroundColor(.red)
				}
				Spacer()
			}
		}
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUIView()
    }
}
