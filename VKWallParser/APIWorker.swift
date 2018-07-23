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
    
    class func authorize() {
        VK.sessions.default.logIn(
            onSuccess: { info in
                print("success authorize with", info)
        },
            onError: { error in
                print("authorize failed with", error)
        }
        )
    }
    
    class func logout() {
        VK.sessions.default.logOut()
        print("LogOut")
    }
    
    class func wallGet(_ domain: String, _ handler: @escaping (Wall) -> Void) {
        VK.API.Wall.get([.domain : domain, .count : "50", .extended : "1"])
            .onSuccess {
                print($0)
                let decoder = JSONDecoder()
                let wall = try! decoder.decode(Wall.self, from: $0)
                handler(wall)
            }
            .onError { print("wall.get failed with \n \($0)") }
            .send()
    }

}
