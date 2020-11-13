//
//  ContactsViewModel.swift
//  Messenger
//
//  Created by Employee1 on 6/4/20.
//  Copyright © 2020 Employee1. All rights reserved.
//

import Foundation
import CoreData


class ContactsViewModel {
    var contacts: [User] = []
    var otherContacts: [User] = []
    
    func getContacts(completion: @escaping ([User]?, NetworkResponse?)->()) {
        ProfileNetworkManager().getUserContacts() { (contacts, error) in
            completion(contacts, error)
        }
    }
    
    func findUsers(term: String, completion: @escaping (Users?, NetworkResponse?)->()) {
        ProfileNetworkManager().findUsers(term: term) { (responseObject, error) in
            completion(responseObject, error)
        }
    }
    
    func addContact(id: String, completion: @escaping (NetworkResponse?)->()) {
        ProfileNetworkManager().addContact(id: id) { (error) in
            completion(error)
        }
    }
    
    func getMessages(id: String, dateUntil: String?, completion: @escaping (Messages?, NetworkResponse?)->()) {
        ChatNetworkManager().getChatMessages(id: id, dateUntil: dateUntil) { (messages, error) in
            completion(messages, error)
        }
    }
    
    func removeContact(id: String, completion: @escaping (NetworkResponse?)->()) {
        ProfileNetworkManager().removeContact(id: id) { (error) in
            completion(error)
        }
    }
    
    func getRequests(completion: @escaping ([Request]?, NetworkResponse?)->())  {
        ProfileNetworkManager().getRequests { (requests, error) in
            completion(requests, error)
        }
    }
    
    func getAdminMessages(completion: @escaping ([AdminMessage]?, NetworkResponse?)->())  {
        ProfileNetworkManager().getAdminMessages { (adminMessages, error) in
            completion(adminMessages, error)
        }
    }
    
    func deleteRequest(id: String, completion: @escaping (NetworkResponse?) -> ()) {
        ProfileNetworkManager().deleteRequest(id: id) { (error) in
            completion(error)
        }
    }
    
    func retrieveData(completion: @escaping ([User]?)->()) {
        let appDelegate = AppDelegate.shared
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ContactsEntity")
        do {
            let result = try managedContext.fetch(fetchRequest)
            var i = 0
            for data in result as! [NSManagedObject] {
                let mContacts = data.value(forKey: "contacts") as! Contacts
                self.contacts = mContacts.contacts
                completion(mContacts.contacts)
                i = i + 1
            }
        } catch {
            self.contacts = []
            completion(nil)
        }
    }
    
    func retrieveOtherContactData(completion: @escaping ([User]?)->()) {
        let appDelegate = AppDelegate.shared
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "OtherContactEntity")
        do {
            let result = try managedContext.fetch(fetchRequest)
            var i = 0
            for data in result as! [NSManagedObject] {
                let mOtherContacts = data.value(forKey: "otherContacts") as! Contacts
                self.otherContacts = mOtherContacts.contacts
                completion(mOtherContacts.contacts)
                i = i + 1
            }
        } catch {
            self.contacts = []
            completion(nil)
        }
    }
    
    func addContactToCoreData(newContact: User, completion: @escaping (NSError?)->()) {
        let appDelegate = AppDelegate.shared
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "ContactsEntity", in: managedContext)!
        let cmsg = NSManagedObject(entity: entity, insertInto: managedContext)
        contacts.append(newContact)
        let mContacts = Contacts(contacts: contacts)
        cmsg.setValue(mContacts, forKeyPath: "contacts")
        do {
            try managedContext.save()
            completion(nil)
            
        } catch let error as NSError {
            completion(error)
        }
    }
    
    func removeContactFromCoreData(id: String, completion: @escaping (NSError?)->()) {
        let appDelegate = AppDelegate.shared
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "ContactsEntity", in: managedContext)!
        let cmsg = NSManagedObject(entity: entity, insertInto: managedContext)
        contacts = contacts.filter { (contact) -> Bool in
            return contact._id != id
        }
        let mContacts = Contacts(contacts: contacts)
        cmsg.setValue(mContacts, forKeyPath: "contacts")
        do {
            try managedContext.save()
            completion(nil)
        } catch let error as NSError {
            completion(error)
        }
    }
}
