//
//  LibraryView.swift
//  BookEmotion
//
//  Created by Xinyu Sun on 5/2/20.
//  Copyright © 2020 Xinyu Sun. All rights reserved.
//

import CoreData
import SwiftUI

struct LibraryView: View
{
    @Environment(\.managedObjectContext) var managedObjectContext

    @FetchRequest(entity: Books.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Books.createdAt, ascending: false)]) var fetchedBooks: FetchedResults<Books>

    @State private var showReocrdingView = false

    @State var selectedBook: String = ""

    var body: some View
    {
        NavigationView
        {
            Group
            {
                if !fetchedBooks.isEmpty
                {
                    ScrollView(.horizontal, showsIndicators: false)
                    {
                        HStack
                        {
                            ForEach(fetchedBooks, id: \.self)
                            { book in
                                GeometryReader
                                { gr in
                                    self.renderBook(book, angle: gr.frame(in: .global).minX / -10)
                                }.frame(width: UIScreen.main.bounds.width)
                            }
                        }
                    }
                }
                else
                {
                    EmptyLibraryView(assetName: "openBook", message: "You haven't been invited for any books")
                }
            }.navigationBarTitle("Library")
                .sheet(isPresented: $showReocrdingView)
            {
                RecordingView(bookName: self.selectedBook)
            }
        }
		
    }

	// render book view with rotational effect
    func renderBook(_ book: Books, angle: CGFloat) -> some View
    {
        let bookName = book.name!
        let image = loadImage(fileURL: book.imageURL!)!
        return Button(action: {
			self.selectedBook = bookName
            self.showReocrdingView.toggle()
        })
        {
            BookView(bookName: bookName, image: image)
                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 10)
                .frame(width: UIScreen.main.bounds.width)
                .rotation3DEffect(Angle(degrees: Double(angle)), axis: (x: 0, y: 10.0, z: 0))
        }.buttonStyle(PlainButtonStyle())
    }

    private func loadImage(fileURL: URL) -> UIImage?
    {
        do
        {
            let imageData = try Data(contentsOf: fileURL)
            return UIImage(data: imageData)
        }
        catch
        {
            print("Error loading image : \(error)")
        }
        return nil
    }
}

struct BookView: View
{
    var bookName: String
    var image: UIImage

    var body: some View
    {
        VStack(spacing: 0)
        {
            Spacer()
            Text(bookName)
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .padding()
            Image(uiImage: image)
                .renderingMode(.original)
                .resizable()
                .scaledToFit()
			.cornerRadius(15)
                .frame(width: 400, height: 400)

            Spacer()
        }.padding()
    }
}

struct LibraryView_Previews: PreviewProvider
{
    static var previews: some View
    {
        LibraryView()
    }
}
