//
//  Contacts.swift
//  Messenger
//
//  Created by Employee1 on 7/28/20.
//  Copyright © 2020 Dynamic LLC. All rights reserved.
//

import Foundation

public class Contacts: NSObject, NSCoding {
    
    public var contacts: [User] = []
    
    enum Key:String {
        case contacts = "contacts"
    }
    
    init(contacts: [User]) {
        self.contacts = contacts
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(contacts, forKey: Key.contacts.rawValue)
    }
    
    public required convenience init?(coder aDecoder: NSCoder) {
        let mContacts = aDecoder.decodeObject(forKey: Key.contacts.rawValue) as! [User]
        
        self.init(contacts: mContacts)
    }
    
    
}

public class User: NSObject,  Codable, NSCoding {
    public var name: String?
    public var lastname: String?
    public var university: String?
    public var _id: String?
    public var username: String?
    public var avatarURL: String?
    public var email: String?
    public var info: String?
    public var phoneNumber: String?
    public var birthday: String?
    public var address: String?
    public var gender: String?
    
    init(name: String?, lastname: String?, university: String?, _id: String, username: String?, avaterURL: String?, email: String?, info: String?, phoneNumber: String?, birthday: String?, address: String?, gender: String?) {
        self.name = name
        self.lastname = lastname
        self.university = university
        self._id = _id
        self.username = username
        self.avatarURL = avaterURL
        self.email = email
        self.info = info
        self.phoneNumber = phoneNumber
        self.birthday = birthday
        self.address = address
        self.gender = gender
    }
    
    public override init() {
        super.init()
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "name")
        aCoder.encode(lastname, forKey: "lastname")
        aCoder.encode(university, forKey: "university")
        aCoder.encode(_id, forKey: "_id")
        aCoder.encode(username, forKey: "username")
        aCoder.encode(avatarURL, forKey: "avatarURL")
        aCoder.encode(email, forKey: "email")
        aCoder.encode(info, forKey: "info")
        aCoder.encode(phoneNumber, forKey: "phoneNumber")
        aCoder.encode(birthday, forKey: "birthday")
        aCoder.encode(address, forKey: "address")
        aCoder.encode(gender, forKey: "gender")
    }

    public required convenience init?(coder aDecoder: NSCoder) {
        let mName = aDecoder.decodeObject(forKey: "name") as? String
        let mLastname = aDecoder.decodeObject(forKey: "lastname") as? String
        let mUniversity = aDecoder.decodeObject(forKey: "university") as? String
        let mId = aDecoder.decodeObject(forKey: "_id") as? String
        let mUsername = aDecoder.decodeObject(forKey: "username") as? String
        let mEmailL = aDecoder.decodeObject(forKey: "email") as? String
        let mInfo = aDecoder.decodeObject(forKey: "info") as? String
        let mPhoneNumber = aDecoder.decodeObject(forKey: "phoneNumber") as? String
        let mAvatarURL = aDecoder.decodeObject(forKey: "avatarURL") as? String
        let mBirthday = aDecoder.decodeObject(forKey: "birthday") as? String
        let mAddress = aDecoder.decodeObject(forKey: "address") as? String
        let mGender = aDecoder.decodeObject(forKey: "gender") as? String
        self.init(name: mName, lastname: mLastname, university: mUniversity, _id: mId!, username: mUsername, avaterURL: mAvatarURL, email: mEmailL, info: mInfo, phoneNumber: mPhoneNumber, birthday: mBirthday, address: mAddress, gender: mGender)
    }
    
}


public class Range: NSObject, NSCoding {

    public var location: Int = 0
    public var length: Int = 0

    enum Key:String {
        case location = "location"
        case length = "length"
    }

    init(location: Int, length: Int) {
        self.location = location
        self.length = length
    }

    public override init() {
        super.init()
    }

    public func encode(with aCoder: NSCoder) {
        aCoder.encode(location, forKey: "name")
        aCoder.encode(length, forKey: "lastname")
        
    }

    public required convenience init?(coder aDecoder: NSCoder) {
        let mlocation = aDecoder.decodeInt32(forKey: Key.location.rawValue)
        let mlength = aDecoder.decodeInt32(forKey: Key.length.rawValue)

        self.init(location: Int(mlocation), length:
            Int(mlength))
    }
}
