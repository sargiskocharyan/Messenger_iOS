//
//  ChatMessagesViewModel.swift
//  Messenger
//
//  Created by Employee1 on 6/16/20.
//  Copyright © 2020 Employee1. All rights reserved.
//

import Foundation

class ChatMessagesViewModel {
    
    func getChatMessages(id: String, completion: @escaping ([Message]?, String?, Int?)->()) {
        HomeNetworkManager().getChatMessages(id: id) { (messages, error, code) in
            completion(messages, error, code)
        }
    }
}
