//
//  HistoryView.swift
//  BookEmotion
//
//  Created by Xinyu Sun on 13/2/20.
//  Copyright © 2020 Xinyu Sun. All rights reserved.
//

import CoreData
import SwiftUI

struct HistoryView: View
{
    private let stages = ["start", "halfway", "finish"]
    @State private var selectedStage = 0
    @Environment(\.managedObjectContext) var managedObjectContext
    @ObservedObject var audioPlayer = AudioPlayer()

	// fetch recordings at stage "start"
    @FetchRequest(entity: StartRecordings.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \StartRecordings.createdAt, ascending: false)]) var fetchedStartRecordings: FetchedResults<StartRecordings>

	// fetch recordings at stage "halfway"
    @FetchRequest(entity: HalfwayRecordings.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \HalfwayRecordings.createdAt, ascending: false)]) var fetchedHalfwayRecordings: FetchedResults<HalfwayRecordings>

	// fetch recordings at stage "finish"
    @FetchRequest(entity: FinishRecordings.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \FinishRecordings.createdAt, ascending: false)]) var fetchedFinishRecordings: FetchedResults<FinishRecordings>

    var body: some View
    {
        NavigationView
        {
            VStack
            {
                Picker(selection: $selectedStage, label: Text("Stages"))
                {
                    ForEach(0 ..< stages.count)
                    {
                        Text(self.stages[$0])
                    }
                }.pickerStyle(SegmentedPickerStyle())
				Spacer()
                Group
                {
                    if stages[selectedStage] == "start"
                    {
                        Group
                        {
                            if !fetchedStartRecordings.isEmpty
                            {
                                ScrollView
                                {
                                    VStack
                                    {
                                        ForEach(fetchedStartRecordings, id: \.self)
                                        { recording in
                                            self.renderStartRecording(recording)
                                        }
                                    }
                                }
                            }
                            else
                            {
                                EmptyLibraryView(assetName: "recording", message: "You haven't added any recordings yet")
                            }
                        }
                    }
                    else if stages[selectedStage] == "halfway"
                    {
                        Group
                        {
                            if !fetchedHalfwayRecordings.isEmpty
                            {
                                ScrollView
                                {
                                    VStack
                                    {
                                        ForEach(fetchedHalfwayRecordings, id: \.self)
                                        { recording in
                                            self.renderHalfwayRecording(recording)
                                        }
                                    }
                                }
                            }
                            else
                            {
                                EmptyLibraryView(assetName: "recording", message: "You haven't added any recordings yet")
                            }
                        }
					} else if stages[selectedStage] == "finish"
					{
						Group
							{
								if !fetchedFinishRecordings.isEmpty
								{
									ScrollView {
										
										VStack
											{
												ForEach(fetchedFinishRecordings, id: \.self)
												{ recording in
													self.renderFinishRecording(recording)
												}
										}
									}
								}
								else
								{
									EmptyLibraryView(assetName: "recording", message: "You haven't added any recordings yet")
								}
						}
					}
                }.padding(.vertical)
				Spacer()

            }

            .navigationBarTitle("History")
        }
    }

	// update view at stage "start"
    func renderStartRecording(_ recording: StartRecordings) -> some View
    {
        let bookName = recording.bookName!
        let audioURL = recording.audioURL!
        let image = getImage(bookName: bookName)!
        let author = getAuthor(bookName: bookName)!

        return BookRow(author: author, image: image, bookName: bookName, audioPlayer: audioPlayer, audioURL: audioURL)
    }

	// update view at stage "halfway"
    func renderHalfwayRecording(_ recording: HalfwayRecordings) -> some View
    {
        let bookName = recording.bookName!
        let audioURL = recording.audioURL!
        let image = getImage(bookName: bookName)!
        let author = getAuthor(bookName: bookName)!

        return BookRow(author: author, image: image, bookName: bookName, audioPlayer: audioPlayer, audioURL: audioURL)
    }
	
	// update view at stage "finish"
    func renderFinishRecording(_ recording: FinishRecordings) -> some View
    {
        let bookName = recording.bookName!
        let audioURL = recording.audioURL!
        let image = getImage(bookName: bookName)!
        let author = getAuthor(bookName: bookName)!

        return BookRow(author: author, image: image, bookName: bookName, audioPlayer: audioPlayer, audioURL: audioURL)
    }

	// get image of a book
    func getImage(bookName: String) -> UIImage?
    {
        let fetchRequest = NSFetchRequest<Books>(entityName: "Books")
        fetchRequest.predicate = NSPredicate(format: "name == %@", bookName)
        do
        {
            let book = try managedObjectContext.fetch(fetchRequest)[0]
            let imageData = try Data(contentsOf: book.imageURL!)
            return UIImage(data: imageData)
        }
        catch
        {
            // something went wrong, print the error.
            print("can't load image in historyView, \(error)")
        }
        return nil
    }

	// get author of a book
    func getAuthor(bookName: String) -> String?
    {
        let fetchRequest = NSFetchRequest<Books>(entityName: "Books")
        fetchRequest.predicate = NSPredicate(format: "name == %@", bookName)
        do
        {
            let book = try managedObjectContext.fetch(fetchRequest)[0]
            return book.author!
        }
        catch
        {
            print("can't retrive author. \(error)")
        }
        return nil
    }
}

struct BookRow: View
{
    var author: String
    var image: UIImage
    var bookName: String
    var audioPlayer: AudioPlayer
    var audioURL: URL

    var body: some View
    {
        Group
        {
            HStack
            {
                Image(uiImage: image)
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(15)
                    .frame(width: 150, height: 150)
				
				Spacer()

                VStack(alignment: .leading, spacing: 10)
                {
                    Text(bookName)
                        .lineLimit(100)
                        .headerStyle()
                    Text(author)
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                }

                if audioPlayer.isPlaying == false
                {
					Spacer()
					
                    Button(action: {
                        self.audioPlayer.startPlayback(audio: self.audioURL)
                        print("start playing")

                    })
                    {
                        Image(systemName: "play.circle")
                            .resizable()
                            .scaledToFit()
                            .clipped()
                            .foregroundColor(.red)
                            .frame(width: 40, height: 40)
                    }.padding(.horizontal)
                }
                else
                {
					Spacer()

                    Button(action: {
                        self.audioPlayer.stopPlayback()
                    })
                    {
                        Image(systemName: "stop.fill")
                            .resizable()
                            .scaledToFit()
                            .clipped()
                            .foregroundColor(.red)
                            .frame(width: 40, height: 40)
                    }.padding(.horizontal)
                }
            }
        }
    }
}

struct HistoryView_Previews: PreviewProvider
{
    static var previews: some View
    {
        HistoryView()
    }
}
