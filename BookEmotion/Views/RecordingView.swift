//
//  RecordingView.swift
//  BookEmotion
//
//  Created by Xinyu Sun on 11/2/20.
//  Copyright © 2020 Xinyu Sun. All rights reserved.
//

import CoreData
import SwiftUI
import Firebase

struct RecordingView: View
{
    var bookName: String

	@State var showLoading = false
	let audioStorageRoot = Storage.storage().reference().child("audio")
    @State private var selectedStage = 0
    @State private var selectedEmotion = 0
	
	@ObservedObject var audioRecorder = AudioRecorder()
	@ObservedObject var audioPlayer = AudioPlayer()
	@Environment(\.presentationMode) var presentationMode
	
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    private let stages = ["start", "halfway", "finish"]
    private let emotions = ["happy", "neutral", "angry", "shocked", "sad"]
	private var currentQuestion: String {
		return getQuestion()
	}

    var body: some View
    {
		ZStack {
			
			NavigationView
				{
					Form
						{
							Section(header:
								Text("How much have you read this book?").headerStyle())
							{
								Picker(selection: $selectedStage, label: Text("Stage"))
								{
									ForEach(0 ..< stages.count, id: \.self)
									{
										Text(self.stages[$0])
									}
								}.pickerStyle(SegmentedPickerStyle())
							}
							
							Section(header: Text("How do you feel so far?").headerStyle())
							{
								Picker(selection: $selectedEmotion, label: Text("Emotion"))
								{
									ForEach(0 ..< emotions.count, id: \.self)
									{
										emojiView(emoji: self.emotions[$0])
									}
								}
							}
							
							Section(header: Text(currentQuestion).headerStyle()) {
								Group {
									
									if audioRecorder.recording == false {
										HStack {
											Text("Record your opinion")
											Spacer()
											Button(action: {
												self.audioRecorder.startRecording(stage: self.stages[self.selectedStage], bookName: self.bookName)
												print("start recording")
											}) {
												Image(systemName: "mic.circle.fill")
													.resizable()
													.aspectRatio(contentMode: .fill)
													.frame(width: 50, height: 50)
													.clipped()
													.foregroundColor(.red)
											}
										}
									} else {
										HStack {
											Text("Press to stop")
											Spacer()
											Button(action: {
												self.audioRecorder.stopRecording()
											}) {
												Image(systemName: "stop.circle.fill")
													.resizable()
													.aspectRatio(contentMode: .fill)
													.frame(width: 50, height: 50)
													.clipped()
													.foregroundColor(.red)
											}
										}
									}
								}
							}
							
							Group {
								if audioPlayer.isPlaying == false {
									HStack {
										Text("Play your recording")
										Spacer()
										Button(action: {
											if let audioURL = self.getAudioURL() {
												print("the retrieved url is \(audioURL)")
												self.audioPlayer.startPlayback(audio: audioURL)
												print("start playing")
											}
										}) {
											Image(systemName: "play.circle")
												.resizable()
												.aspectRatio(contentMode: .fill)
												.frame(width: 50, height: 50)
												.clipped()
												.foregroundColor(.red)
										}
									}
								} else {
									HStack {
										Text("Press to stop")
										Spacer()
										Button(action: {
											self.audioPlayer.stopPlayback()
										}) {
											Image(systemName: "stop.fill")
												.resizable()
												.aspectRatio(contentMode: .fill)
												.frame(width: 50, height: 50)
												.clipped()
												.foregroundColor(.red)
										}
									}
								}
							}
							
							Section {
								
								Button(action: {
									self.showLoading.toggle()
									self.upload()
									
								}) {
									Text("Submit")
								}
							}
							
							
					}
					.navigationBarTitle("Questions")
					
			}
			.navigationViewStyle(StackNavigationViewStyle())
			
			// show loading circle after user click submit
			if self.showLoading {
				GeometryReader { _ in
					Loader()
				}.background(Color.black.opacity(0.45)
					.edgesIgnoringSafeArea(.all))
			}
		}
		
    }

	// if current book at selected stage has not read before, upload a new submission, otherwise update the current one
	func upload() {
		
		guard let audioURL = getAudioURL() else {
			print("No availabile audioURL")
			return
		}
		
		let fetchRequest = NSFetchRequest<Submission>(entityName: "Submission")
		fetchRequest.predicate = NSPredicate(format: "bookName == %@ && stage = %@", bookName, stages[selectedStage])
		
		do
		{
			let count = try context.count(for: fetchRequest)
			if count == 0 {
				let uuid = UUID().uuidString
				let newSubmission = Submission(context: context)
				newSubmission.id = uuid
				newSubmission.bookName = bookName
				newSubmission.stage = stages[selectedStage]
				
				uploadDatabase(uuid: uuid, audioURL: audioURL)
				
			} else {
				let submission = try context.fetch(fetchRequest)[0]
				let uuid = submission.id!
				
				uploadDatabase(uuid: uuid, audioURL: audioURL)
			}
			
		}
		catch
		{
			print("Can't find submission, \(error)")
		}
		
		
	}
	
	// upload submission to server
	func uploadDatabase(uuid: String, audioURL: URL) {
		let fileName = "\(uuid).m4a"
		let audioRef = audioStorageRoot.child(fileName)
		let audioRefStr = "gs://\(audioRef.bucket)/audio/\(fileName)"
		print(audioRefStr)
		
		let uploadTask = audioRef.putFile(from: audioURL)
		
		uploadTask.observe(.success) {(snapshot) in
			snapshot.reference.downloadURL(completion: {(url, error) in
				guard let url = url else {
					return
				}
				
				let submissionRef = Firestore.firestore().collection("submissions").document(uuid)
				
				
				let audioStorageURL = url.absoluteString
				
				let token = UserDefaults.standard.string(forKey: "token")
				
				let submitInfo = ["audioStorageURL": audioStorageURL, "book": self.bookName, "emotion": self.emotions[self.selectedEmotion],
								  "session": self.stages[self.selectedStage],
								  "text": "null", "uri": audioRefStr, "token": token]
				
				submissionRef.setData(submitInfo as [String : Any], merge: true)
				
				self.showLoading.toggle()
				self.presentationMode.wrappedValue.dismiss()
				print("Adding successfully")
			})
		}
	}
	
	// retrieve questions for selected book
    func getQuestion() -> String
    {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Books")
        fetchRequest.predicate = NSPredicate(format: "name == %@", bookName)
        do
        {
            let book = try context.fetch(fetchRequest)[0] as! Books
			switch stages[selectedStage] {
			case "start":
				return book.startQuestion!
			case "halfway":
				return book.halfwayQuestion!
			case "finish":
				return book.finishQuestion!
			default:
				return "No Question"
			}
        }
        catch
        {
            print(error)
        }
		return "No Question"
    }
	
	// retrive recordings of selected reading stage of selected book
	func getAudioURL() -> URL? {
		print("i'm here")
		let predicate = NSPredicate(format: "bookName == %@", bookName)
		switch stages[selectedStage] {
		case "start":
			let fetchRequest = NSFetchRequest<StartRecordings>(entityName: "StartRecordings")
			fetchRequest.predicate = predicate
			do {
				let recording = try context.fetch(fetchRequest)[0]
				return recording.audioURL!
			} catch {
				print(error)
			}
		case "halfway":
			let fetchRequest = NSFetchRequest<HalfwayRecordings>(entityName: "HalfwayRecordings")
			fetchRequest.predicate = predicate
			do {
				let recording = try context.fetch(fetchRequest)[0]
				return recording.audioURL!
			} catch {
				print(error)
			}
		case "finish":
			let fetchRequest = NSFetchRequest<FinishRecordings>(entityName: "FinishRecordings")
			fetchRequest.predicate = predicate
			do {
				let recording = try context.fetch(fetchRequest)[0]
				return recording.audioURL!
			} catch {
				print(error)
			}
		default:
			return nil
		}
		return nil
	}
}


struct emojiView: View
{
    var emoji: String

    var body: some View
    {
        HStack
        {
            Image(emoji)
                .renderingMode(.original)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50, height: 50)
            Text(emoji)
		}.padding(.vertical)
    }
}

struct RecordingView_Previews: PreviewProvider
{
    static var previews: some View
    {
        RecordingView(bookName: "Harry Potter and the Philosopher's Stone")
    }
}
