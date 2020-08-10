//
//  RecentMessagesViewModel.swift
//  Messenger
//
//  Created by Employee1 on 6/15/20.
//  Copyright © 2020 Employee1. All rights reserved.
//

import UIKit
import CoreData

struct FetchedCall {
    let id: UUID
    var isHandleCall: Bool
    var time: Date
    var callDuration: Int?
    let calleeId: String
}
class RecentMessagesViewModel {
     var calls: [CallHistory] = []
    private var privateCalls: [NSManagedObject] = []
    func getHistory(completion: @escaping ([CallHistory])->()) {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                    completion([])
                    return
            }
            let managedContext = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CallEntity")
            do {
                let callsFetched = try managedContext.fetch(fetchRequest)
                self.privateCalls = callsFetched
                self.calls = callsFetched.map({ (call) -> CallHistory in
                    return CallHistory(type: call.value(forKey: "type") as? String, status: call.value(forKey: "status") as? String, participants: call.value(forKey: "participants") as! [String], callSuggestTime: call.value(forKey: "callSuggestTime") as? String, _id: call.value(forKey: "id") as? String, createdAt: call.value(forKey: "createdAt") as? String, caller: call.value(forKey: "caller") as? String, callEndTime: call.value(forKey: "callEndTime") as? String, callStartTime: call.value(forKey: "callStartTime") as? String)
                })
                completion(self.calls)
                return
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
                completion([])
            }
    }
    
    func saveCalls(calls: [CallHistory], completion: @escaping ([CallHistory]?, NetworkResponse?)->()) {
        var count = 0
        for call in calls {
            save(newCall: call) {
                count += 1
                print("pahec")
                if count == calls.count {
                    completion(calls, nil)
                    return
                }
            }
        }
    }
    
    func deleteItem(index: Int) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CallEntity")
        
        // Configure Fetch Request
        fetchRequest.includesPropertyValues = false
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        do {
            managedContext.delete(privateCalls[privateCalls.count - index - 1])
            privateCalls.remove(at: privateCalls.count - index - 1)
            calls.remove(at: index)
            try managedContext.save()
            
        } catch {
            // Error Handling
            // ...
        }
    }
    
    func getChats(completion: @escaping ([Chat]?, NetworkResponse?)->()) {
        HomeNetworkManager().getChats() { (chats, error) in
            completion(chats, error)
        }
    }
    func getuserById(id: String, completion: @escaping (User?, NetworkResponse?)->()) {
        HomeNetworkManager().getuserById(id: id) { (user, error) in
            completion(user, error)
        }
    }
    func onlineUsers(arrayOfId: [String], completion: @escaping (OnlineUsers?, NetworkResponse?)->()) {
           HomeNetworkManager().onlineUsers(arrayOfId: arrayOfId) { (user, error) in
               completion(user, error)
           }
       }
    
    
    func save(newCall: CallHistory, completion: @escaping ()->()) {
        let appDelegate = AppDelegate.shared as AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "CallEntity", in: managedContext)!
        let call = NSManagedObject(entity: entity, insertInto: managedContext)
        call.setValue(newCall._id, forKeyPath: "id")
        call.setValue(newCall.type, forKeyPath: "type")
        call.setValue(newCall.status, forKeyPath: "status")
        call.setValue(newCall.callEndTime, forKeyPath: "callEndTime")
        call.setValue(newCall.callSuggestTime, forKeyPath: "callSuggestTime")
        call.setValue(newCall.caller, forKeyPath: "caller")
        call.setValue(newCall.participants, forKeyPath: "participants")
        call.setValue(newCall.createdAt, forKeyPath: "createdAt")
        call.setValue(newCall.callStartTime, forKeyPath: "callStartTime")
        
        do {
            try managedContext.save()
            privateCalls.append(call)
            calls.append(newCall)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
//                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CallEntity")
//        fetchRequest.predicate = NSPredicate(format: "id == %@", newCall.id as CVarArg)
//                do {
//                    let fetchResults = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
//                    for fetchedResult in fetchResults {
//                        if fetchedResult.value(forKey: "image") as? String != newCall.imageURL {
//
//                            fetchedResult.setValue(newCall.imageURL, forKey: "image")
//                            try managedContext.save()
//                        }
//                    }
//                } catch let error {
//                    print(error.localizedDescription)
//                }
        print(calls)
//        var newCalls: [FetchedCall] = []
//        for var call in calls {
//            if call.id == newCall.id && call.imageURL != newCall.imageURL {
//                call.imageURL = newCall.imageURL
//            }
//            newCalls.append(call)
//        }
//        calls = newCalls
        completion()
       return
    }
}
