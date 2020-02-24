//
//  SignUpView.swift
//  BookEmotion
//
//  Created by Xinyu Sun on 5/2/20.
//  Copyright © 2020 Xinyu Sun. All rights reserved.
//

import SwiftUI
import CoreData

struct SignUpView: View
{
    @EnvironmentObject var sessionStore: SessionStore
    @Environment(\.managedObjectContext) var managedObjectContext

    @State private var username = ""
    

    @Binding var email: String
    @Binding var password: String

    @State private var selectedAge = 0
    @State private var selectedGender = 0
    @State private var selectedEducation = 0
    @State private var selectedContinent = 0
	
	private var validPassword: Bool {
		return password.count >= 6
	}
	
	private var validUsername: Bool {
		return username.count > 0
	}
	
	private var validEmail: Bool {
		let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
		
		let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
		return emailPred.evaluate(with: email)
	}

    private let ageRanges = ["10-19", "20-29", "30-39", "40-49", "50+"]
    private let genders = ["Male", "Female"]
    private let educationLevels = ["High School Certificate", "Diploma", "Bachelor Degree", "Postgraduate Degree"]
    private let continents = ["Asia", "Africa", "Australia", "Europe", "North America", "South America", "Antarctica"]

    var body: some View
    {
        Form
        {
            Section(header: Text("ACCOUNT"))
            {
                TextField("Username", text: $username)
                    .autocapitalization(.none)
                    .keyboardType(.default)
				// check validity of username
				RequirementText(iconName: validUsername ? "checkmark.square" : "xmark.square", iconColor: validUsername ? Color.green : Color(red: 251.0/255.0, green: 128.0/255.0, blue: 128.0/255.0), text: "Enter you username", isStrikeThrough: validUsername ? true : false)

                TextField("Email Address", text: $email)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
				// check validity of email address
				RequirementText(iconName: validEmail ? "checkmark.square" : "xmark.square", iconColor: validEmail ? Color.green : Color(red: 251.0/255.0, green: 128.0/255.0, blue: 128.0/255.0), text: "Valid email address", isStrikeThrough: validEmail ? true : false)

				SecureField("Password", text: $password)
				
				// check validity of password
				RequirementText(iconName: validPassword ? "checkmark.square" : "lock.open", iconColor: validPassword ? Color.green : Color(red: 251.0/255.0, green: 128.0/255.0, blue: 128.0/255.0), text: "A minimum of 6 characters", isStrikeThrough: validPassword ? true : false)
                
            }
			

            Section(header: Text("AGE"))
            {
                Picker(selection: $selectedAge, label: Text("Age Range").font(.system(.body, design: .rounded))
                    .bold()
                    .foregroundColor(.black))
                {
                    ForEach(0 ..< ageRanges.count, id: \.self)
                    {
                        Text(self.ageRanges[$0])
                    }
                }.pickerStyle(SegmentedPickerStyle())
            }

            Section(header: Text("GENDER"))
            {
                Picker(selection: $selectedGender, label: Text("Gender").font(.system(.body, design: .rounded))
                    .bold()
                    .foregroundColor(.black))
                {
                    ForEach(0 ..< genders.count, id: \.self)
                    {
                        Text(self.genders[$0])
                    }
                }.pickerStyle(SegmentedPickerStyle())
            }

            Section
            {
                Picker(selection: $selectedEducation, label: Text("Qualifications").font(.system(.body, design: .rounded))
                    .foregroundColor(.black))
                {
                    ForEach(0 ..< educationLevels.count, id: \.self)
                    {
                        Text(self.educationLevels[$0])
                    }
                }
            }

            Section
            {
                Picker(selection: $selectedContinent, label: Text("Continent").font(.system(.body, design: .rounded))
                    .foregroundColor(.black))
                {
                    ForEach(0 ..< continents.count, id: \.self)
                    {
                        Text(self.continents[$0])
                    }
                }
            }

            Button(action: {
                self.signUp()
            })
            {
                Text("Submit")
                    .font(.system(.body, design: .rounded))
                    .bold()
                    .foregroundColor(.black)
                    .frame(minWidth: 0, maxWidth: .infinity)
            }
			
			
        }
    }

    func signUp()
    {
        sessionStore.signUp(email: email, password: password)
        { _, error in
            if error == nil
            {
                print("sign up successfully")
                self.email = ""
                self.password = ""
            }
        }

		// Check if userinfo exists, if not, create userinfo, otherwise, update current one
		let fetchRequest = NSFetchRequest<UserInfo>(entityName: "UserInfo")
		do {
			let count = try self.managedObjectContext.count(for: fetchRequest)
			if count == 0 {
				print("new start userinfo")
				let userInfo = UserInfo(context: managedObjectContext)
				userInfo.age = ageRanges[selectedAge]
				userInfo.continent = continents[selectedContinent]
				userInfo.educationLevel = educationLevels[selectedEducation]
				userInfo.gender = genders[selectedGender]
				userInfo.email = email
				userInfo.username = username
				try managedObjectContext.save()
				print("User Info created successfully")
			} else {
				print("update current userinfo")
				let userInfo = try self.managedObjectContext.fetch(fetchRequest)[0]
				userInfo.age = ageRanges[selectedAge]
				userInfo.continent = continents[selectedContinent]
				userInfo.educationLevel = educationLevels[selectedEducation]
				userInfo.gender = genders[selectedGender]
				userInfo.email = email
				userInfo.username = username
				try managedObjectContext.save()
				print("User Info updated successfully")
			}
			
		} catch {
			print(error)
		}
		
		
		
        
    }
}

struct SignUpView_Previews: PreviewProvider
{
    static var previews: some View
    {
        SignUpView(email: .constant(""), password: .constant(""))
    }
}

struct RequirementText: View {
	
	var iconName = "xmark.square"
	var iconColor = Color(red: 251/255, green: 128/255, blue: 128/255)
	
	var text = ""
	var isStrikeThrough = false
	
	var body: some View {
		HStack {
			Image(systemName: iconName)
				.foregroundColor(iconColor)
			Text(text)
				.font(.system(.body, design: .rounded))
				.foregroundColor(.secondary)
				.strikethrough(isStrikeThrough)
			Spacer()
		}
	}
}
