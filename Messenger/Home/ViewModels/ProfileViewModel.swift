//
//  ProfileViewModel.swift
//  Messenger
//
//  Created by Employee1 on 6/15/20.
//  Copyright © 2020 Employee1. All rights reserved.
//

import Foundation
class ProfileViewModel {
    func logout(completion: @escaping (String?, Int?)->()) {
        HomeNetworkManager().logout() { (error, code) in
            completion(error, code)
        }
    }
}
