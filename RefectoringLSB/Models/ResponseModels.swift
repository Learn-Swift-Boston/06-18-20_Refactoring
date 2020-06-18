//
//  ResponseModels.swift
//  RefectoringLSB
//
//  Created by Matthew Dias on 6/18/20.
//  Copyright © 2020 Matthew Dias. All rights reserved.
//

import UIKit

struct Post: Codable {
    var title: String
    var url: String
    var image: UIImage?
    
    private enum CodingKeys: String, CodingKey {
        case title, url
    }
}

struct SubredditChildren: Codable {
    var data: Post
}

struct SubredditData: Codable {
    var children: [SubredditChildren]
}

struct SubredditResponse: Codable {
    var data: SubredditData
}
