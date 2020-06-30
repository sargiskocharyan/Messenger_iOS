//
//  Constants.swift
//  Messenger
//
//  Created by Employee1 on 5/25/20.
//  Copyright © 2020 Employee1. All rights reserved.
//

import Foundation

struct Environment {
    static let baseURL = "http://192.168.0.105:3000"
}

struct AUTHUrls {
    static let MailisExist      = "/mailExists"
    static let Login            = "/login"
    static let Register         = "/register"
    static let UpdateUser       = "/updateuser"
    static let VerifyToken      = "/tokenExists"
    static let GetUniversities  = "/university/all"
    static let GetUserContacts  = "/contacts"
    static let FindUsers        = "/findusers"
    static let AddContact       = "/addcontact"
    static let Logout           = "/user/logout"
    static let GetChats         = "/chats"
    static let GetChatMessages  = "/chats/"
    static let GetUserById      = "/user/"
    static let GetImage         = "/avatars"
}

struct AppLangKeys {
     
     static let Rus = "ru"
     static let Eng = "en"
     static let Arm = "hy"
}

struct Keys {
    static let TOKEN_KEYCHAIN_ID_KEY = "token"
    static let APP_Language = "appLanguage"
}
