//
//  APIWorker.swift
//  VKWallParser
//
//  Created by Admin on 19/07/2018.
//  Copyright © 2018 nikitagorshkov. All rights reserved.
//

import Foundation
import SwiftyVK


final class APIWorker {
    
    class func action(_ tag: Int) {
        switch tag {
        case 1:
            authorize()
        case 2:
            logout()
        default:
            print("Unrecognized action!")
        }
    }
    
    class func authorize() {
        VK.sessions.default.logIn(
            onSuccess: { info in
                print("SwiftyVK: success authorize with", info)
        },
            onError: { error in
                print("SwiftyVK: authorize failed with", error)
        }
        )
    }
    
    class func logout() {
        VK.sessions.default.logOut()
        print("SwiftyVK: LogOut")
    }
    
    class func wallGet(_ domain: String, _ handler: @escaping (Wall) -> Void) {
        VK.API.Wall.get([.domain : domain, .count : "50", .extended : "1"])
            .onSuccess {
                print($0)
                let decoder = JSONDecoder()
                let wall = try! decoder.decode(Wall.self, from: $0)
//                for item in wall.items {
//                    if let reposts = item.copy_history {
//                        if let repost = reposts.last {
//                            print(repost.text)
//                        }
//                    }
//                    print(item.text, "\n")
//                }
                handler(wall)
            }
            .onError { print("SwiftyVK: wall.get failed with \n \($0)") }
            .send()
    }

}
