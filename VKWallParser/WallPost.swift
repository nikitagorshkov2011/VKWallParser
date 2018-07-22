//
//  WallPost.swift
//  VKWallParser
//
//  Created by Admin on 20/07/2018.
//  Copyright © 2018 nikitagorshkov. All rights reserved.
//

import Foundation

struct Wall: Codable {
    
    let items: [WallPost]
    let profiles: [User]?
    let groups: [Group]?
}

struct WallPost: Codable {
    
    let date: Int
    let text: String
    
    let attachments: [Attachment]?
    
    let copy_history: [WallPost]?
    
    let comments: Comments
    let likes: Likes
    let reposts: Reposts
    let views: Views?
        
}

struct Comments: Codable {
    let count: Int
}

struct Likes: Codable {
    let count: Int
}

struct Reposts: Codable {
    let count: Int
}

struct Views: Codable {
    let count: Int
}

struct Attachment: Codable {
    let type: String
    let photo: Photo?
    let video: Video?
    
}

struct Photo: Codable {
    let text: String
    let sizes: [PhotoSize]
}

struct PhotoSize: Codable {
    let type: String
    let url: String
    let width: Int
    let height: Int
}

struct Video: Codable {
    let title: String
    let duration: Int
    let photo_130: String
    let photo_320: String
}
    
    

