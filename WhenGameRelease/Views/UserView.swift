//
//  UserView.swift
//  WhenGameRelease
//
//  Created by Андрей on 01.03.2021.
//

import SwiftUI

struct UserView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var controller = UserController.shared
    
    @State private var showUserSettings = false
    @State private var name = "Buy"
    @State private var secondName = "Skyrim"
    
    private var bgColor: Color {
        return colorScheme == .dark ? GlobalConstants.ColorDarkTheme.darkGray : GlobalConstants.ColorLightTheme.white
    }
    
    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Button(action: {
                            showUserSettings.toggle()
                        }, label: {
                            Image(systemName: "tag.fill").font(.system(size: 24, weight: .regular))
                                .foregroundColor(colorScheme == .dark ?
                                                    GlobalConstants.ColorDarkTheme.white :
                                                    GlobalConstants.ColorLightTheme.grayDark)
                        })
                        Spacer()
                    }
                    HStack {
                        VStack(alignment: .leading) {
                            Text(name)
                                .font(Font.system(size: 34, weight: .bold))
                            Text(secondName)
                                .font(Font.system(size: 34, weight: .bold))
                        }
                        
                        Spacer()
                        
                        Image("Todd Howard")
                            .resizable()
                            .clipped()
                            .clipShape(Circle())
                            .frame(width: 90, height: 90)
                        
                    }
                    .padding(.bottom, 5)
                    
                    Divider()
                    
                    Section {
                        VStack(alignment: .leading) {
                            Text("Want to play")
                                .font(.headline)
                            
                            GridView(columns: 2, width: proxy.size.width - 22, list: controller.wantedGames) { (game) in
                                GameCell(game: game)
                                    .padding(6)
                            }
                            .padding(.leading, -6)
                            .padding(.trailing, -6)
                        }
                    }
                }
            }
            .padding()
        }
        .background(bgColor.edgesIgnoringSafeArea(.all))
        .sheet(isPresented: $showUserSettings) {
            UserSettingsView(name: $name, secondName: $secondName, image: Image("Todd Howard"))
        }
    }
}


private struct GameCell: View, Equatable {
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.game.id == rhs.game.id
    }
    
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject var imageLoader: ImageLoader = ImageLoader()
    @ObservedObject var gameDetail: GameDetail = GameDetail.shared
    
    var game: GameListModel
    
    var body: some View {
        ZStack {
            PosterImageView(image: imageLoader.image, iconSize: 24)
                .aspectRatio(3/4, contentMode: .fill)
            if let status = game.releasedStatus {
                GeometryReader { proxy in
                    Section {
                        BadgeText(text: status)
                    }
                    .padding()
                    .frame(width: proxy.size.width, height: proxy.size.height, alignment: Alignment(horizontal: .trailing, vertical: .bottom))
                }
            }
        }
        .background(Color(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)))
        .cornerRadius(8)
        .onTapGesture {
            gameDetail.showGameDetailView(showGameDetail: true, game: game, image: imageLoader.image)
        }
        .onAppear() {
            imageLoader.getCover(with: game.cover?.imageId)
        }
    }
}

private struct UserSettingsView: View {
    
    @Environment(\.colorScheme) private var colorScheme
    
    @Binding var name: String
    @Binding var secondName: String
    @State var image: Image
    @State var notificationsIsEnabled = true
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    
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
                            TextField("", text: $secondName)
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
                                
                                Image(systemName: "plus")
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
                        Button(action: {}, label: {
                            Text("Save")
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
    
    func loadImage() {
        guard let inputImage = inputImage else { return }
        image = Image(uiImage: inputImage)
    }
}

struct UserView_Previews: PreviewProvider {
    
    static var user: UserController {
        let controller = UserController()
        controller.wantedGames = [GameListModel(), GameListModel()]
        return controller
    }
    
    static var previews: some View {
        UserView(controller: user)
    }
}

struct UserSettingsView_Previews: PreviewProvider {
    
    @State static var name = "Buy"
    @State static var secondName = "Skyrim"
    static var image = Image("Todd Howard")
    
    static var previews: some View {
        UserSettingsView(name: $name, secondName: $secondName, image: image)
    }
}
