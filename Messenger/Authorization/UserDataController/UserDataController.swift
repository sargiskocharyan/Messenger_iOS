//
//  UserDataController.swift
//  Messenger
//
//  Created by Sargis Kocharyan on 6/17/20.
//  Copyright © 2020 Employee1. All rights reserved.
//

import Foundation
import UIKit.UIApplication

class UserDataController {
    
    func saveUserInfo() {
        let user = SharedConfigs.shared.signedUser
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(user) {
            let defaults = UserDefaults.standard
            defaults.set(encoded, forKey: "signedUser")
            defaults.synchronize()
        }
    }
    
    func loadUserInfo() {
        let defaults = UserDefaults.standard
        if let user = defaults.object(forKey: "signedUser") as? Data {
            let decoder = JSONDecoder()
            if let loadedUser = try? decoder.decode(UserModel.self, from: user) {
                SharedConfigs.shared.signedUser = loadedUser
            }
        }
        loadUserSensitiveData()
    }
    
    private func deleteUserInfo() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "signedUser")
        defaults.synchronize()
        self.removeUserSensitiveData()
    }
    
    func saveUserSensitiveData(token:String) {
        let data = token.data(using: .utf8)!
        let saved = KeyChain.save(key: Keys.TOKEN_KEYCHAIN_ID_KEY, data: data)
        if saved == noErr {
            SharedConfigs.shared.signedUser?.token = token
        }
    }
    
    private func loadUserSensitiveData() {
        let token = KeyChain.load(key: Keys.TOKEN_KEYCHAIN_ID_KEY)?.toString()
        if token != nil {
            SharedConfigs.shared.signedUser?.token = token
        }
    }
    
    private func removeUserSensitiveData() {
        let _ = KeyChain.remove(key: Keys.TOKEN_KEYCHAIN_ID_KEY)
    }
    
    func logOutUser(){
        deleteUserInfo()
        SharedConfigs.shared.signedUser?.token = nil
        SharedConfigs.shared.adminMessages = []
        SharedConfigs.shared.unreadMessages = []
        SharedConfigs.shared.contactRequests = []
        SharedConfigs.shared.missedCalls = []
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    func populateUserProfile(model: UserModel ) {
        SharedConfigs.shared.signedUser = model
        saveUserInfo()
    }
}
