//
//  Book.swift
//  BookEmotion
//
//  Created by Xinyu Sun on 5/2/20.
//  Copyright © 2020 Xinyu Sun. All rights reserved.
//

import Foundation

struct Book: Hashable, Identifiable {
	var id = UUID()
	let bookName: String
	let imageName: String
	
	static func data() -> [Book] {
		return [
			Book(bookName: "To Kill a Mockingbird", imageName: "1.jpg"),
			Book(bookName: "Pride and Prejudice", imageName: "2.jpg"),
			Book(bookName: "Lebs", imageName: "3.jpg"),
			Book(bookName: "The Swan Book", imageName: "4.jpg"),
			Book(bookName: "The Big Sleep", imageName: "5.jpg"),
			Book(bookName: "Gone Girl", imageName: "6.jpg"),
			Book(bookName: "Lord of the Rings: Fellowship of the Ring", imageName: "7.jpg"),
			Book(bookName: "The Fifth Season", imageName: "8.jpg"),
			Book(bookName: "Eleanor & Park", imageName: "9.jpg"),
			Book(bookName: "Harry Potter and the Philosopher's Stone", imageName: "10.jpg")
		]
	}
}
