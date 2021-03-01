//
//  UserController.swift
//  WhenGameRelease
//
//  Created by Андрей on 01.03.2021.
//

import Foundation

class UserController: ObservableObject {
    
    static let shared = UserController()
    
    @Published var showSettings = false
    @Published var wantedGames: [GameListModel] = []
}
