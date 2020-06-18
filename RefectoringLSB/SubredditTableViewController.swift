//
//  AwwTableViewController.swift
//  RefectoringLSB
//
//  Created by Matthew Dias on 6/13/20.
//  Copyright © 2020 Matthew Dias. All rights reserved.
//

import UIKit

enum SubReddit: String, CaseIterable {
    case aww
    case earthporn
    case battlestations
}
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

class SubredditTableViewController: UITableViewController {
    
    var posts = [Post]() {
        didSet {
            tableView.reloadData()
        }
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
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

    // MARK: - Table view data source
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
      super.viewWillTransition(to: size, with: coordinator)
      DispatchQueue.main.async {
        self.tableView.tableHeaderView?.layoutIfNeeded()
        self.tableView.tableHeaderView = self.tableView.tableHeaderView
      }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
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

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        guard let modal = segue.destination as? FullImageViewController, let cell = sender as? PostCell else {
            return
        }
        
        let indexPath = tableView.indexPath(for: cell)!
        
        modal.image = posts[indexPath.row].image
        
    }
    
}
