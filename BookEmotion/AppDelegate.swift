//
//  AppDelegate.swift
//  BookEmotion
//
//  Created by Xinyu Sun on 5/2/20.
//  Copyright © 2020 Xinyu Sun. All rights reserved.
//

import Firebase
import UIKit
import UserNotifications
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate
{
    private let categoryIdentifier = "AcceptOrDecline"
    private enum ActionIdentifier: String { case accept, reject }
	var documentsUrl: URL {
		return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
	}
	
	lazy var persistentContainer: NSPersistentContainer = {
		let container = NSPersistentContainer(name: "BookDataModel")
		container.loadPersistentStores { description, error in
			if let error = error {
				// Add your error UI here
			}
		}
		return container
	}()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {
        // Override point for customization after application launch.
//		deleteAllRecords(entityName: "Books")
//		deleteAllRecords(entityName: "StartRecordings")
//		deleteAllRecords(entityName: "HalfwayRecordings")
//		deleteAllRecords(entityName: "FinishRecordings")
		
		
		saveContext()
		
//		try? FileManager.default.removeItem(at: documentsUrl)
//		print("remove current directory")
		
		
        FirebaseApp.configure()

        Messaging.messaging().delegate = self

        if #available(iOS 10.0, *)
        {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self

            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(options: authOptions,
                                                                    completionHandler: { _, _ in })
        }
        else
        {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
        }

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration
    {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>)
    {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        completionHandler([.alert, .badge, .sound])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void)
    {
        print("didReceive")
        defer { completionHandler() }
        let payload = response.notification.request.content
        let bookName = payload.userInfo["bookName"] as! String
		let url = payload.attachments[0].url
		let startQuestion = payload.userInfo["start"] as! String
		let halfwayQuestion = payload.userInfo["halfway"] as! String
		let finishQuestion = payload.userInfo["finish"] as! String
		let author = payload.userInfo["author"] as! String

		print("title \(bookName)")
		print("url is \(url)")
		
		// add customized action to notifications
		switch response.actionIdentifier {
			case "accept":
				print("You pressed accept")
				if !hasSaved(bookName: bookName) {
					saveBook(bookName: bookName, tempURL: url, startQuestion: startQuestion, halfwayQuestion: halfwayQuestion, finishQuestion: finishQuestion,
							 author: author)
				} else {
					print("duplicate book")
				}
				break
			case "reject":
				break
			default:
				break
		}
		completionHandler()
		
    }
	
	// save book data locally
	func saveBook(bookName: String, tempURL: URL, startQuestion: String, halfwayQuestion: String, finishQuestion: String, author: String) {
		let destination = documentsUrl.appendingPathComponent(bookName)
		if tempURL.startAccessingSecurityScopedResource() {
			do {
				let data = try Data(contentsOf: tempURL)
				try data.write(to: destination)
					
			} catch {
				print(error)			}
		}
		tempURL.stopAccessingSecurityScopedResource()
		
		let context = persistentContainer.viewContext
		let newBook = Books(context: context)
		newBook.name = bookName
		newBook.createdAt = Date()
		newBook.imageURL = destination
		newBook.startQuestion = startQuestion
		newBook.halfwayQuestion = halfwayQuestion
		newBook.finishQuestion = finishQuestion
		newBook.author = author
		do {
			try context.save()
		} catch {
			print(error)
		}
		
		// upload userInfo to database
		let userRef = Firestore.firestore().collection("users").document()
		let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "UserInfo")
		do {
			let userInfo = try context.fetch(fetchRequest)[0] as! UserInfo
			let uploadInfo = ["age": userInfo.age, "gender": userInfo.gender, "educationLevel": userInfo.educationLevel, "book": bookName, "continent": userInfo.continent, "user": userInfo.email]
			userRef.setData(uploadInfo as [String : Any])
			print("info upload complete")
		} catch {
			print(error)
		}
		
	}
	
	// check if the book has saved before
	func hasSaved(bookName: String) -> Bool {
		let context = persistentContainer.viewContext
		let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Books")
		request.predicate = NSPredicate(format: "name == %@", bookName)
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


    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void)
    {
        // Print full message.
        print(userInfo)

        completionHandler(UIBackgroundFetchResult.newData)
    }

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String)
    {
        InstanceID.instanceID().instanceID
        { result, error in
            if let error = error
            {
                print("Error fetching remote instance ID: \(error)")
            }
            else if let result = result
            {
                print("Remote instance ID token: \(result.token)")
				
				UserDefaults.standard.set(result.token, forKey: "token")
            }
        }
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data)
    {
        print("App has registered for remote notification")
        //		let token = deviceToken.reduce("") { $0 + String(format: "%02x", $1) }
//
        //		print("deviceToken is \(token)")
        registerCustomActions()
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error)
    {
        print("Fail error is \(error)")
    }
	
	// Check whether the context has changes and commits them
	func saveContext () {
		let context = persistentContainer.viewContext
		if context.hasChanges {
			do {
				try context.save()
			} catch {
				// Show the error here
			}
		}
	}

    private func registerCustomActions()
    {
        let accept = UNNotificationAction(identifier: ActionIdentifier.accept.rawValue, title: "Accept")

        let decline = UNNotificationAction(identifier: ActionIdentifier.reject.rawValue, title: "Decline")

        let category = UNNotificationCategory(identifier: categoryIdentifier, actions: [accept, decline], intentIdentifiers: [])

        UNUserNotificationCenter.current().setNotificationCategories([category])
    }
	
	// Empty core data
	func deleteAllRecords(entityName: String) {
		let context = persistentContainer.viewContext
		
		let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
		let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
		
		do {
			try context.execute(deleteRequest)
			try context.save()
		} catch {
			print ("There was an error")
		}
	
	}
	
}
