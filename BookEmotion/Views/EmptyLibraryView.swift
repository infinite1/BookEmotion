//
//  EmptyView.swift
//  BookEmotion
//
//  Created by Xinyu Sun on 11/2/20.
//  Copyright © 2020 Xinyu Sun. All rights reserved.
//

import SwiftUI

struct EmptyLibraryView: View {
	
	var assetName: String
	var message: String
	
    var body: some View {
		
		VStack(alignment: .center, spacing: 10) {
			Image(assetName)
				.resizable()
				.aspectRatio(contentMode: .fit)
				.frame(width: 200)
			
			Text(message)
				.frame(width: 300)
				.multilineTextAlignment(.center)
				.font(.system(size: 25, weight: .bold, design: .rounded))
		}
		
    }
}

struct EmptyView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyLibraryView(assetName: "recording", message: "You haven't added any recordings yet")
    }
}
