//
//  SocialLoginDTO.swift
//  stepin
//
//  Created by wooseokcho on 2023/04/06.
//

import Foundation

struct SocialLoginDTO: Codable {
    private var type: String // 추가
    private var accessToken: String
    
    init(type: String,
         accessToken: String) {
        self.type = type
        self.accessToken = accessToken
    }
}

