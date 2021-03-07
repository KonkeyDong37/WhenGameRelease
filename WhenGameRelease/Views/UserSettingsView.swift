//
//  UserSettingsView.swift
//  WhenGameRelease
//
//  Created by Андрей on 06.03.2021.
//

import SwiftUI

struct UserSettingsView: View {
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(entity: User.entity(), sortDescriptors: []) var user: FetchedResults<User>
    
    @Binding var isPresented: Bool
    @State var name: String
    @State var secondName: String
    @State var image: Image
    @State var notificationsIsEnabled: Bool
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @State private var isLoding = false
    @State private var setNewImage = false
    
    private var notificationText: String {
        return notificationsIsEnabled ? "Enabled" : "Disabled"
    }
    private var bgColor: Color {
        return colorScheme == .dark ? GlobalConstants.ColorDarkTheme.darkGray : GlobalConstants.ColorLightTheme.white
    }
    
    var body: some View {
        NavigationView {
            Form {
                
                Section(header: Text("User").padding(.leading)) {
                    HStack {
                        VStack {
                            TextField("Name", text: $name)
                            Divider()
                            TextField("Second name", text: $secondName)
                        }
                        
                        Button(action: {
                            self.showingImagePicker.toggle()
                        }, label: {
                            ZStack(alignment: .bottomTrailing) {
                                image
                                    .resizable()
                                    .clipped()
                                    .clipShape(Circle())
                                    .frame(width: 70, height: 70)
                                
                                Image(systemName: "pencil")
                                    .foregroundColor(.white)
                                    .frame(width: 25, height: 25)
                                    .background(Color.blue)
                                    .clipShape(Circle())
                            }
                        })
                        .padding(.leading)
                        
                    }
                }
                
                Section(header: Text("Notifications").padding(.leading)) {
                    Toggle(isOn: $notificationsIsEnabled, label: {
                        Text(notificationText)
                    })
                }
                
                Section {
                    HStack(alignment: .center) {
                        Spacer()
                        Button(action: {
                            isLoding = true
                            refreshUserData()
                        }, label: {
                            if isLoding {
                                ActivityIndicator()
                            } else {
                                Text("Save")
                            }
                        })
                        Spacer()
                    }
                }
            }
            .background(bgColor.edgesIgnoringSafeArea(.all))
            .navigationTitle("Settings")
            .onAppear {
                UITableView.appearance().backgroundColor = .clear
            }
            .onDisappear {
                UITableView.appearance().backgroundColor = .none
            }
            .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
                ImagePicker(image: self.$inputImage)
            }
        }
    }
    
    func refreshUserData() {
        let user = (self.user.first != nil) ? self.user[0] : User(context: moc)
        
        user.name = name
        user.secondName = secondName
        user.notificationsIsEnabled = notificationsIsEnabled
        
        if setNewImage {
            user.avatar = image.asUIImage().jpegData(compressionQuality: 0.5)
        }
        
        saveContext()
    }
    
    func saveContext() {
        do {
            try moc.save()
            self.isLoding = false
            self.isPresented.toggle()
        } catch {
            print("Error saving managed object context: \(error)")
        }
    }
    
    func loadImage() {
        guard let inputImage = inputImage else { return }
        image = Image(uiImage: inputImage)
        setNewImage = true
    }
}
