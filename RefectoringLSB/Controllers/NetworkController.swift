//
//  NetworkController.swift
//  RefectoringLSB
//
//  Created by Matthew Dias on 6/18/20.
//  Copyright © 2020 Matthew Dias. All rights reserved.
//

import UIKit

struct NetworkController {
    
    static func get(subreddit: SubReddit, completion: @escaping ([Post]) -> Void) {
        guard let url = URL(string: "http://reddit.com/r/\(subreddit).json") else { return }
        var posts = [Post]()
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else { return }
            
            let response = try! JSONDecoder().decode(SubredditResponse.self, from: data)
            let responsePosts = response.data.children.map({ $0.data })
            
            responsePosts.forEach { post in
                dispatchGroup.enter()
                guard let imageURL = URL(string: post.url) else { return }
                
                URLSession.shared.dataTask(with: imageURL) { (data, response, error) in
                    dispatchGroup.leave()
                    guard let data = data else { return }
                    guard let image = UIImage(data: data) else { return }
                    
                    var postWithImage = post
                    postWithImage.image = image
                    posts.append(postWithImage)
                }.resume()
            }
            
            dispatchGroup.leave()
        }.resume()
        
        dispatchGroup.notify(queue: DispatchQueue.main) {
            completion(posts)
        }
    }
}
