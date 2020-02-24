//
//  AudioRecorder.swift
//  survey
//
//  Created by Xinyu Sun on 27/1/20.
//  Copyright © 2020 Xinyu Sun. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import AVFoundation
import CoreData

class AudioRecorder: ObservableObject {
	
	@Published var recording = false
		
	var audioRecorder: AVAudioRecorder!
	var documentsUrl: URL {
		return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
	}
	var fileManager = FileManager.default
	let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
	
	func stopRecording() {
		audioRecorder.stop()
		recording = false
		
		let audioSession = AVAudioSession.sharedInstance()
		
		do {
			try audioSession.setCategory(.playback, options: .defaultToSpeaker)
			try audioSession.setActive(false)
		} catch {
			print(error)
		}
	}
	
	// check if the recording at selected stage exists
	func hasSaved(bookName: String, entity: String) -> Bool {
		let request = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
		request.predicate = NSPredicate(format: "bookName == %@", bookName)
		do {
			let count = try context.count(for: request)
			if count == 0 {
				// no matching object
				return false
			}
		}
		catch {
			print(error)
		}
		return true
	}
		
	func startRecording(stage: String, bookName: String) {
		let recordingSession = AVAudioSession.sharedInstance()
		do {
			try recordingSession.setCategory(.record, mode: .default)
			try recordingSession.setActive(true)
		} catch {
			print("Failed to set up recording session")
		}
		
		let audioFilename = documentsUrl.appendingPathComponent("\(bookName)-\(stage).m4a")
		
		// at each stage, if recording is not exist, create new one and save its url
		switch stage {
		case "start":
			if !hasSaved(bookName: bookName, entity: "StartRecordings") {
				let newStartRecording = StartRecordings(context: context)
				newStartRecording.bookName = bookName
				newStartRecording.audioURL = audioFilename
				newStartRecording.createdAt = Date()
				do {
					try context.save()
				} catch {
					print("failed to save recording ",error)
				}
				print("saved url \(audioFilename)")
			} else {
				print("start recordings for \(bookName) exists")
			}
		case "halfway":
			if !hasSaved(bookName: bookName, entity: "HalfwayRecordings") {
				
				let newHalfwayRecording = HalfwayRecordings(context: context)
				newHalfwayRecording.bookName = bookName
				newHalfwayRecording.audioURL = audioFilename
				newHalfwayRecording.createdAt = Date()
				do {
					try context.save()
				} catch {
					print("failed to save recording ",error)
				}
				print("saved url \(audioFilename)")
			} else {
				print("halfway recordings for \(bookName) exists")
			}
		case "finish":
			if !hasSaved(bookName: bookName, entity: "FinishRecordings") {
				
				let newFinishRecording = FinishRecordings(context: context)
				newFinishRecording.bookName = bookName
				newFinishRecording.audioURL = audioFilename
				newFinishRecording.createdAt = Date()
				do {
					try context.save()
				} catch {
					print("failed to save recording ",error)
				}
				print("saved url \(audioFilename)")
			} else {
				print("finish recordings for \(bookName) exists")
			}
			
		default:
			print("No matched stage")
		}
				
		let settings = [
			AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
			AVSampleRateKey: 16000,
			AVNumberOfChannelsKey: 2,
			AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
		]
		
		// start recording
		do {
			audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
			audioRecorder.record()
			
			recording = true
			
			
		} catch {
			print("Could not start recording")
		}
	}
	
}
