//
//  AudioPlayer.swift
//  survey
//
//  Created by Xinyu Sun on 28/1/20.
//  Copyright © 2020 Xinyu Sun. All rights reserved.
//

import Foundation

import SwiftUI
import Combine
import AVFoundation

class AudioPlayer: NSObject, ObservableObject, AVAudioPlayerDelegate {
	
	@Published var isPlaying = false
	
	var audioPlayer: AVAudioPlayer!
	
	func startPlayback(audio: URL) {
		
		do {
			audioPlayer = try AVAudioPlayer(contentsOf: audio)
			audioPlayer.delegate = self
			audioPlayer.play()
			isPlaying = true
		} catch {
			print("Playback failed.")
		}
	}
	
	func stopPlayback() {
		audioPlayer.stop()
		isPlaying = false
	}
	
	// stop playing after the audio is finished
	func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
		if flag {
			isPlaying = false
		}
	}
	
	
}
