//
//  ResponseModels.swift
//  Messenger
//
//  Created by Employee1 on 6/4/20.
//  Copyright © 2020 Employee1. All rights reserved.
//

import Foundation

struct User: Codable {
    var name: String?
    let lastname: String?
    let university: String?
    let _id: String
    let username: String?
    let avatarURL: String?
    let email: String?
    let info: String?
    let phoneNumber: String?
    let birthday: String?
    let address: String?
    let gender: String?
}

struct Users: Codable { 
    let users: [User]
}

struct Sender: Codable{
    let id: String?
    let name: String?
}

struct Message: Codable {
    let _id: String?
    let reciever: String?
    var text: String?
    let createdAt: String?
    let updatedAt: String?
    let owner: String?
    let sender: Sender?
}

struct Chat: Codable {
    let id: String
    let name: String?
    let lastname: String?
    let username: String?
    var message: Message?
    var recipientAvatarURL: String?
}

struct UserById: Codable {
    let name: String?
    let username: String?
    let lastname: String?
    let id: String
    let avatarURL: String?
}

