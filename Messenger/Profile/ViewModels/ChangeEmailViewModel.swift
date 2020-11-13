//
//  ChangeEmailViewModel.swift
//  Messenger
//
//  Created by Employee1 on 8/12/20.
//  Copyright © 2020 Dynamic LLC. All rights reserved.
//

import Foundation

class ChangeEmailViewModel {
    
    func changeEmail(email: String, completion: @escaping (MailExistsResponse?, NetworkResponse?)->() ) {
        ProfileNetworkManager().changeEmail(email: email) { (responseObj, error) in
            completion(responseObj, error)
        }
    }
    
    func verifyEmail(email: String, code: String, completion: @escaping (ChangeEmailResponse?, NetworkResponse?)->() ) {
        ProfileNetworkManager().verifyEmail(email: email, code: code) { (responseObj, error) in
            completion(responseObj, error)
        }
    }
    
    func changePhone(phone: String, completion: @escaping (PhoneExistsResponse?, NetworkResponse?)->()) {
        ProfileNetworkManager().changePhone(phone: phone) { (response, error) in
            completion(response, error)
        }
    }
    
    func verifyPhone(phone: String, code: String, completion: @escaping (ChangeEmailResponse?, NetworkResponse?)->()) {
        ProfileNetworkManager().verifyPhone(phone: phone, code: code) { (response, error) in
            completion(response, error)
        }
    }
    
}
