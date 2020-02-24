//
//  SettingsView.swift
//  BookEmotion
//
//  Created by Xinyu Sun on 5/2/20.
//  Copyright © 2020 Xinyu Sun. All rights reserved.
//

import CoreData
import SwiftUI

struct SettingsView: View
{
    @EnvironmentObject var sessionStore: SessionStore
    @Environment(\.managedObjectContext) var managedObjectContext

	// fetch local books
    @FetchRequest(entity: Books.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Books.createdAt, ascending: false)]) var fetchedBooks: FetchedResults<Books>

	// fetch local recordings at stage "start"
    @FetchRequest(entity: StartRecordings.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \StartRecordings.createdAt, ascending: false)]) var fetchedStartRecordings: FetchedResults<StartRecordings>

	// fetch local recordings at stage "halfway"
    @FetchRequest(entity: HalfwayRecordings.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \HalfwayRecordings.createdAt, ascending: false)]) var fetchedHalfwayRecordings: FetchedResults<HalfwayRecordings>

	// fetch local recordings at stage "finish"
    @FetchRequest(entity: FinishRecordings.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \FinishRecordings.createdAt, ascending: false)]) var fetchedFinishRecordings: FetchedResults<FinishRecordings>
	
	
	@State var username = ""
	@State var email = ""

    var body: some View
    {
        NavigationView
        {
            VStack(spacing: 20)
            {
				
				HStack {
					Image("user")
						.renderingMode(.original)
						.resizable()
						.aspectRatio(contentMode: .fill)
						.frame(width: 100, height: 100)
						.background(Color.pink)
						.clipped()
						.cornerRadius(150)
						.padding(.leading, 20)
					VStack(alignment: .leading, spacing: 15) {
						Text(username)
							.font(.system(size: 28, weight: .bold, design: .rounded))
						Text(email)
							.font(.system(size: 18, weight: .regular, design: .rounded))
					}.padding(.leading, 40)
					
					Spacer()
				}
				
				
                HStack(spacing: 15)
                {
                    HStack
                    {
                        VStack(alignment: .leading)
                        {
                            Text("Books").fontWeight(.bold)
                            Text("\(fetchedBooks.count)").fontWeight(.bold).font(.system(size: 20))
                        }

                        Spacer(minLength: 0)
                    }.padding()
                        .frame(width: (UIScreen.main.bounds.width - 45) / 2)
                        .background(Color.blue)
                        .cornerRadius(15)

                    HStack
                    {
                        VStack(alignment: .leading)
                        {
                            Text("Recordings").fontWeight(.bold)
                            Text("\(fetchedStartRecordings.count + fetchedHalfwayRecordings.count + fetchedFinishRecordings.count)").fontWeight(.bold).font(.system(size: 20)).animation(.spring())
                        }

                        Spacer(minLength: 0)
                    }.padding()
                        .frame(width: (UIScreen.main.bounds.width - 45) / 2)
                        .background(Color.pink)
                        .cornerRadius(15)
                }.foregroundColor(.white)
                    .padding(.top)

				// empty local data after signout
                Button(action: {
                    self.sessionStore.signOut()
					self.deleteAllRecords(entityName: "Books")
					self.deleteAllRecords(entityName: "StartRecordings")
					self.deleteAllRecords(entityName: "HalfwayRecordings")
					self.deleteAllRecords(entityName: "FinishRecordings")
                })
                {
                    HStack(spacing: 15)
                    {
                        Image(systemName: "power").renderingMode(.original)
                            .padding()
                            .clipShape(Circle())
                        Text("Logout")
                        Spacer()
                        Image(systemName: "arrow.right").renderingMode(.original)
                    }.padding()
                        .background(Color("Color"))
                        .foregroundColor(.black)
                }.cornerRadius(15)

                Spacer()
            }
            .padding()
            .padding(.top)

            .navigationBarTitle("Account")
		}.onAppear {
			self.retriveUerInfo()
		}
    }
	
	 func retriveUerInfo() {
		let fetchRequest = NSFetchRequest<UserInfo>(entityName: "UserInfo")
		do {
			let userInfo = try self.managedObjectContext.fetch(fetchRequest)[0]
			username = userInfo.username ?? "No Name"
			email = userInfo.email ?? "No Email"
		} catch {
			print(error)
		}
	}
	
	// Empty core data
	func deleteAllRecords(entityName: String) {
		let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
		let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
		
		do {
			try managedObjectContext.execute(deleteRequest)
			try managedObjectContext.save()
		} catch {
			print ("There was an error")
		}
		
	}
}

struct SettingsView_Previews: PreviewProvider
{
    static var previews: some View
    {
        SettingsView()
    }
}
