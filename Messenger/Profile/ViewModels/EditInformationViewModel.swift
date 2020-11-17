//
//  EditInformationViewModel.swift
//  Messenger
//
//  Created by Employee1 on 7/8/20.
//  Copyright © 2020 Dynamic LLC. All rights reserved.
//

import Foundation

class EditInformationViewModel {
    func deleteAccount(completion: @escaping (NetworkResponse?)->()) {
        ProfileNetworkManager().deleteAccount() { (error) in
            completion(error)
        }
    }
    
    func deactivateAccount(completion: @escaping (NetworkResponse?)->()) {
        ProfileNetworkManager().deactivateAccount() { (error) in
            completion(error)
        }
    }
    
    func editInformation(name: String?, lastname: String?, username: String?, info: String?, gender: String?, birthDate: String?, completion: @escaping (UserModel?, NetworkResponse?)->()) {
        ProfileNetworkManager().editInformation(name: name, lastname: lastname, username: username, info: info, gender: gender, birthDate: birthDate) { (user, error) in
            completion(user, error)
        }
    }
    
    func hideData(isHideData: Bool, completion: @escaping (NetworkResponse?)->()) {
        ProfileNetworkManager().hideData(isHideData: isHideData) { (error) in
            completion(error)
        }
    }
}
