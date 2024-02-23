//
//  ResponseData.swift
//  GovTech
//
//  Created by Islam Temirbek on 23.02.2024.
//

import Foundation

struct ResponseData: Codable {
    let requestId: String
    let type: String
    let payload: Payload
    
    struct Payload: Codable {
        var token: String?
    }
}
