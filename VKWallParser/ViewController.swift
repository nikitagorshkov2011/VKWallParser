//
//  ViewController.swift
//  VKWallParser
//
//  Created by Admin on 19/07/2018.
//  Copyright © 2018 nikitagorshkov. All rights reserved.
//

import UIKit

class WallViewController: UIViewController {
    
    var wall = Wall(items: [], profiles: [], groups: []) {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    var isExpanded = -1
    
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50
        APIWorker.wallGet("pikabu") { (wall) in
             self.wall = wall
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension WallViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wall.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WallPostCell", for: indexPath) as! WallPostCell
        _ = cell.imagesView.subviews.map { $0.removeFromSuperview() }
        cell.imagesViewHeight.constant = 0
        cell.postText.text = wall.items[indexPath.row].text
        if indexPath.row == isExpanded {
            cell.postText.numberOfLines = 0
        } else {
            cell.postText.numberOfLines = 2
        }
        cell.postText.font = UIFont.systemFont(ofSize: 13)
        let date = Date(timeIntervalSince1970: TimeInterval(wall.items[indexPath.row].date))
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "HH:mm dd-MM-yyyy"
        cell.dateLabel.text = dateFormatter.string(from: date)
        cell.dateLabel.textColor = UIColor.gray
        cell.dateLabel.font = UIFont.systemFont(ofSize: 10)
        cell.nameLabel.textColor = UIColor.blue
        cell.nameLabel.font = UIFont.systemFont(ofSize: 15)
        if let groups = wall.groups {
            if groups.count > 0 {
                let group = groups[0]
                cell.nameLabel.text = group.name
                DispatchQueue.global().async {
                    if let url = URL(string: group.photo_50) {
                        if let data = try? Data(contentsOf: url) {
                            DispatchQueue.main.async {
                                if let updateCell = tableView.cellForRow(at: indexPath) {
                                    let updateCell = updateCell as! WallPostCell
                                    let image = UIImage(data: data)
                                    updateCell.avatar.layer.cornerRadius = cell.avatar.frame.size.width / 2
                                    updateCell.avatar.layer.masksToBounds = true
                                    updateCell.avatar.image = image
                                }
                            }
                        }
                    }
                }
            }
        }
        if let users = wall.profiles {
            if users.count > 0 {
                let user = users[0]
                cell.nameLabel.text = user.first_name + " " + user.last_name
                DispatchQueue.global().async {
                    if let url = URL(string: user.photo_50) {
                        if let data = try? Data(contentsOf: url) {
                            DispatchQueue.main.async {
                                if let updateCell = tableView.cellForRow(at: indexPath) {
                                    let updateCell = updateCell as! WallPostCell
                                    let image = UIImage(data: data)
                                    updateCell.avatar.layer.cornerRadius = cell.avatar.frame.size.width / 2
                                    updateCell.avatar.layer.masksToBounds = true
                                    updateCell.avatar.image = image
                                }
                            }
                        }
                    }
                }
            }
        }
        cell.likesLabel.text = "♡ " + String(wall.items[indexPath.row].likes.count)
        cell.repostsLabel.text = "↩︎ " + String(wall.items[indexPath.row].reposts.count)
        cell.commentsLabel.text = "✎ " + String(wall.items[indexPath.row].comments.count)
        if let views = wall.items[indexPath.row].views {
            cell.viewsLabel.text = "☺︎ " + String(views.count)
        }
        var images: [Photo] = []
        if let attachments = wall.items[indexPath.row].attachments {
            for attachment in attachments {
                if attachment.type == "photo" {
                    if let image = attachment.photo {
                        images.append(image)
                    }
                }
            }
        }
        if images.count > 0 {
            let imageViewHeightMultiplier : [CGFloat] = [1, 1/2, 1/3, 4/3, 5/6, 2/3, 5/3, 7/6, 1, 11/12]
            cell.imagesViewHeight.constant = cell.imagesView.bounds.size.width * imageViewHeightMultiplier[images.count - 1]
            var imageCounter = 0
            var rowNumber = 0
            let numbersOfImagesInRow = [[1,0,0],[2,0,0],[3,0,0],[3,1,0],[3,2,0],[3,3,0],[3,3,1],[3,3,2],[3,3,3],[3,3,4]][images.count - 1]
            var globalY : CGFloat = 0
            let contentMode = images.count > 1 ? UIViewContentMode.scaleToFill : UIViewContentMode.scaleAspectFit
            for image in images {
                let width = (cell.imagesView.bounds.width - 6) / CGFloat(numbersOfImagesInRow[rowNumber])
                let height = width
                let x = cell.imagesView.bounds.width / CGFloat(numbersOfImagesInRow[rowNumber]) * CGFloat(imageCounter - rowNumber * 3)
                let y = globalY
                
                let imageType = numbersOfImagesInRow[rowNumber] == 1 ? "q" : "p"
                for size in image.sizes {
                    if size.type == imageType {
                        DispatchQueue.global().async {
                            if let url = URL(string: size.url) {
                                if let data = try? Data(contentsOf: url) {
                                    DispatchQueue.main.async {
                                        if let updateCell = tableView.cellForRow(at: indexPath) {
                                            let updateCell = updateCell as! WallPostCell
                                            let image = UIImage(data: data)
                                            let imageView = UIImageView(image: image)
                                            imageView.frame = CGRect(x: x, y: y, width: width, height: height)
                                            imageView.contentMode = contentMode
                                            updateCell.imagesView.addSubview(imageView)
                                        }
                                    }
                                }
                            }
                        }
                        break
                    }
                }
                
                if [2,5].contains(imageCounter) {
                    globalY += cell.imagesView.bounds.width / CGFloat(numbersOfImagesInRow[rowNumber])
                    rowNumber += 1
                }
                imageCounter += 1
            }
        }
        
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        isExpanded = indexPath.row
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    
    
}

