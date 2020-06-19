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
        headerView.swappableDelegate = self
        tableView.tableHeaderView = headerView
        
        get(subreddit: .aww)
    }
}

// MARK: - SubredditSwappable
extension SubredditTableViewController: SubredditSwappable {
    func get(subreddit: SubReddit) {
        NetworkController.get(subreddit: subreddit) { posts in
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
