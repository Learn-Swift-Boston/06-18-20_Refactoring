//
//  AwwTableViewController.swift
//  RefectoringLSB
//
//  Created by Matthew Dias on 6/13/20.
//  Copyright © 2020 Matthew Dias. All rights reserved.
//

import UIKit

class SubredditTableViewController: UITableViewController {
    
    var posts = [Post]() {
        didSet {
            tableView.reloadData()
        }
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()

        let headerView = Bundle.main.loadNibNamed("TableHeaderView", owner: nil, options: nil)!.first as! TableHeaderView
        headerView.textField.text = SubReddit.aww.rawValue
        tableView.tableHeaderView = headerView
        
        get(subreddit: .aww)
    }
    
    func get(subreddit: SubReddit) {
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
            self.posts = posts
        }
    }
    
}

// MARK: - Navigation
extension SubredditTableViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let modal = segue.destination as? FullImageViewController,
              let cell = sender as? PostCell,
              let indexPath = tableView.indexPath(for: cell) else {
                
            return
        }
        
        modal.image = posts[indexPath.row].image
    }
}

// MARK: - Table view data source
extension SubredditTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as? PostCell else {
            return UITableViewCell()
        }
        
        let post = posts[indexPath.row]
        cell.postImage.image = post.image
        cell.postTitle.text = post.title

        return cell
    }
}
