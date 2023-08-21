//
//  AuthLoginInfo.swift
//  stepin
//
//  Created by wooseokcho on 2023/04/08.
//

import Foundation


enum AuthLoginInfo {
    static var googleAccessToken = "googleAccessToken"
    static var facebookAccessToken = "facebookAccessToken"
    static var appleAccessToken = "appleAccessToken"
    
    static var googleEmail = "googleEmail"
    static var facebookEmail = "facebookEmail"
    static var appleEmail = "appleEmail"
    
    static var type = ""
    static var password = "password1234!!"
    
    static let emailType = "EMAIL"
    static let googleType = "GOOGLE"
    static let facebookType = "FACEBOOK"
    static let appleType = "APPLE"
    
    static var isSocialLogin = false
    
    
}
