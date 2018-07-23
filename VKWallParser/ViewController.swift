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
                if self.wall.items.count > 0 {
                    self.imageCache.removeAllObjects()
                    self.isExpanded = []
                    self.tableView.reloadData()
                    self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                }
            }
        }
    }
    
    let imageCache = NSCache<NSString, UIImage>()
    var isExpanded: [IndexPath] = []
    var imagePresented = false
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchField: UITextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(searchTapped))
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50
        
        
    }

    @objc func searchTapped() {
        if let searchString = searchField.text {
            if searchString != "" {
                APIWorker.wallGet(searchString) { (wall) in
                    self.wall = wall
                }
            }
        }
    }
    
}

extension WallViewController: UITableViewDelegate, UITableViewDataSource {
    
    @objc func imageTapped(_ sender: UITapGestureRecognizer) {
        if !imagePresented {
            let imageView = sender.view as! UIImageView
            let newImageView = UIImageView(image: imageView.image)
            newImageView.frame = UIScreen.main.bounds
            newImageView.backgroundColor = .black
            newImageView.contentMode = .scaleAspectFit
            newImageView.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
            newImageView.addGestureRecognizer(tap)
            tableView.isUserInteractionEnabled = false
            self.view.addSubview(newImageView)
            self.navigationController?.isNavigationBarHidden = true
            self.tabBarController?.tabBar.isHidden = true
            imagePresented = true
        }
    }
    
    @objc func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = false
        sender.view?.isHidden = true
        sender.view?.removeFromSuperview()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
            self.imagePresented = false
            self.tableView.isUserInteractionEnabled = true
        }
    }
    
    @objc func expandPostText(_ sender: UITapGestureRecognizer) {
        print("pressed")
        if let cell = sender.view?.superview?.superview as? WallPostCell {
            print("inside")
            if let indexPath = tableView.indexPath(for: cell) {
                if isExpanded.contains(indexPath) {
                    isExpanded = isExpanded.filter { $0 != indexPath }
                } else {
                    isExpanded.append(indexPath)
                }
                tableView.reloadRows(at: [indexPath], with: .fade)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wall.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WallPostCell", for: indexPath) as! WallPostCell
        
        for subview in cell.imagesView.subviews {
            subview.removeFromSuperview()
        }
        cell.imagesViewHeight.constant = 0
        for subview in cell.audioView.subviews {
            subview.removeFromSuperview()
        }
        cell.audioViewHeight.constant = 0
      
        setPostText(cell: cell, indexPath: indexPath)
        setFooter(cell: cell, indexPath: indexPath)
        setDate(cell: cell, indexPath: indexPath)
        setPostHeader(cell: cell, indexPath: indexPath)
        

        var audio: [Audio] = []
        var attachmentImages: [Attachment] = []
        if let attachments = wall.items[indexPath.row].attachments {
            for attachment in attachments {
                switch attachment.type {
                case "photo" : if let _ = attachment.photo {
                    attachmentImages.append(attachment)
                    }
                case "audio" :  if let audioFile = attachment.audio {
                    audio.append(audioFile)
                    }
                case "posted_photo" : if let _ = attachment.posted_photo {
                    attachmentImages.append(attachment)
                    }
                case "video" : if let _ = attachment.video {
                    attachmentImages.append(attachment)
                    }
                default: break
                }
            }
        }
        
        if attachmentImages.count > 0 {
            cell.postTextAndImagesDist.constant = 15
            if audio.count > 0 {
                cell.audioAndImagesDist.constant = 25
            }
        }
        
        setImages(attachmentImages :attachmentImages , cell: cell, indexPath: indexPath)
        setAudio(audio: audio, cell: cell, indexPath: indexPath)
        
        return cell
    }
    
    
    func setDate(cell: WallPostCell, indexPath: IndexPath) {
        let date = Date(timeIntervalSince1970: TimeInterval(wall.items[indexPath.row].date))
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "HH:mm dd-MM-yyyy"
        cell.dateLabel.text = dateFormatter.string(from: date)
        cell.dateLabel.textColor = UIColor.gray
        cell.dateLabel.font = UIFont.systemFont(ofSize: 10)
    }
    
    
    func setPostText(cell: WallPostCell, indexPath: IndexPath) {
        cell.postText.text = wall.items[indexPath.row].text
        cell.postText.numberOfLines = isExpanded.contains(indexPath) ? 0 : 3
        cell.postText.font = UIFont.systemFont(ofSize: 13)
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.expandPostText(_ :)))
        cell.postText.addGestureRecognizer(tap)
        cell.postText.isUserInteractionEnabled = true
    }
    
    
    func setFooter(cell: WallPostCell, indexPath: IndexPath) {
        if let likes = wall.items[indexPath.row].likes {
            cell.likesLabel.text = "♡ " + String(likes.count)
            cell.likesLabel.font = UIFont.systemFont(ofSize: 13)
        }
        if let reposts = wall.items[indexPath.row].reposts {
            cell.repostsLabel.text = "↩︎ " + String(reposts.count)
            cell.repostsLabel.font = UIFont.systemFont(ofSize: 13)
        }
        if let comments = wall.items[indexPath.row].comments {
            cell.commentsLabel.text = "✎ " + String(comments.count)
            cell.commentsLabel.font = UIFont.systemFont(ofSize: 13)
        }
        if let views = wall.items[indexPath.row].views {
            cell.viewsLabel.text = "☺︎ " + String(views.count)
            cell.viewsLabel.font = UIFont.systemFont(ofSize: 13)
        }
    }
    
    
    func setImages (attachmentImages: [Attachment], cell: WallPostCell ,indexPath: IndexPath) {
        
        func completion(image: UIImage, frame: CGRect, contentMode: UIViewContentMode) {
            DispatchQueue.main.async {
                if let updateCell = self.tableView.cellForRow(at: indexPath) {
                    let updateCell = updateCell as! WallPostCell
                    
                    let imageView = UIImageView(image: image)
                    imageView.frame = frame
                    imageView.contentMode = contentMode
                    let imageTap = UITapGestureRecognizer(target: self, action: #selector(self.imageTapped(_:)))
                    imageTap.cancelsTouchesInView = false
                    imageView.addGestureRecognizer(imageTap)
                    imageView.isUserInteractionEnabled = true
                    updateCell.imagesView.addSubview(imageView)
                }
            }
        }
        
        func imageProcessing(urlString: String, frame: CGRect, contentMode: UIViewContentMode) {
            if let cachedImage = imageCache.object(forKey: urlString as NSString) {
                completion(image: cachedImage, frame: frame, contentMode: contentMode)
            } else {
                DispatchQueue.global().async {
                    if let url = URL(string: urlString) {
                        if let data = try? Data(contentsOf: url) {
                            if let image = UIImage(data: data) {
                                self.imageCache.setObject(image, forKey: urlString as NSString)
                                completion(image: image, frame: frame, contentMode: contentMode)
                            }
                        }
                    }
                }
            }
        }
        
        func calculatingPosition(numberOfImagesInRow: Int, imageCounter: Int, rowNumber: Int, globalY: CGFloat) -> CGRect {
            let width = (cell.imagesView.bounds.width - 6) / CGFloat(numberOfImagesInRow)
            let height = width
            let x = cell.imagesView.bounds.width / CGFloat(numberOfImagesInRow) * CGFloat(imageCounter - rowNumber * 3)
            let y = globalY
            return CGRect(x: x, y: y, width: width, height: height)
        }
        
        
        
        if attachmentImages.count > 0 {
            let imageViewHeightMultiplier : [CGFloat] = [1, 1/2, 1/3, 4/3, 5/6, 2/3, 5/3, 7/6, 1, 11/12]
            cell.imagesViewHeight.constant = cell.imagesView.bounds.size.width * imageViewHeightMultiplier[attachmentImages.count - 1]
            cell.setNeedsLayout()
            var imageCounter = 0
            var rowNumber = 0
            let numbersOfImagesInRow = [[1,0,0],[2,0,0],[3,0,0],[3,1,0],[3,2,0],[3,3,0],[3,3,1],[3,3,2],[3,3,3],[3,3,4]][attachmentImages.count - 1]
            var globalY : CGFloat = 0
            let contentMode = attachmentImages.count > 1 ? UIViewContentMode.scaleToFill : UIViewContentMode.scaleAspectFit
            
            for attachment in attachmentImages {
                
                let frame = calculatingPosition(numberOfImagesInRow: numbersOfImagesInRow[rowNumber], imageCounter: imageCounter, rowNumber: rowNumber, globalY: globalY)
                switch attachment.type {
                case "photo" : if let image = attachment.photo {
                        let imageType = numbersOfImagesInRow[rowNumber] == 1 ? "q" : "p"
                        for size in image.sizes {
                            if size.type == imageType {
                                imageProcessing(urlString: size.url, frame: frame, contentMode: contentMode)
                                break
                            }
                        }
                    }
                case "posted_photo" : if let postedImage = attachment.posted_photo {
                        imageProcessing(urlString: postedImage.photo_130, frame: frame, contentMode: contentMode)
                        break
                    }
                case "video" : if let video = attachment.video {
                        imageProcessing(urlString: video.photo_320, frame: frame, contentMode: contentMode)
                        break
                    }
                default: break
                }
                
                if [2,5].contains(imageCounter) {
                    globalY += cell.imagesView.bounds.width / CGFloat(numbersOfImagesInRow[rowNumber])
                    rowNumber += 1
                }
                imageCounter += 1
            }
        }
        
    }
    
    
    func setAudio(audio: [Audio], cell: WallPostCell, indexPath: IndexPath) {
        
        if audio.count > 0 {
            cell.audioViewHeight.constant = CGFloat(audio.count * 20)
            var globalY : CGFloat = cell.audioView.bounds.minY
            for audioFile in audio {
                let width = cell.audioView.bounds.width
                let height: CGFloat = 20
                let x = cell.audioView.bounds.minX
                let y = globalY
                globalY += height
                
                let audioLabel = UILabel(frame: CGRect(x: x, y: y, width: width, height: height))
                audioLabel.contentMode = .left
                audioLabel.text = "🎵 " + audioFile.artist + " - " + audioFile.title + " "
                audioLabel.font = UIFont.systemFont(ofSize: 13)
                cell.audioView.addSubview(audioLabel)
            }
        }
        
    }
    
    
    func setPostHeader(cell: WallPostCell, indexPath: IndexPath) {
        
        func completion(image: UIImage){
            DispatchQueue.main.async {
                if let updateCell = self.tableView.cellForRow(at: indexPath) {
                    let updateCell = updateCell as! WallPostCell
                    updateCell.avatar.layer.cornerRadius = cell.avatar.frame.size.width / 2
                    updateCell.avatar.layer.masksToBounds = true
                    updateCell.avatar.image = image
                }
            }
        }
        
        cell.nameLabel.textColor = UIColor.blue
        cell.nameLabel.font = UIFont.systemFont(ofSize: 15)
        
        if let groups = wall.groups {
            if groups.count > 0 {
                for group in groups {
                    if abs(group.id) == abs(wall.items[indexPath.row].from_id) {
                        cell.nameLabel.text = group.name
                        if let cachedImage = imageCache.object(forKey: group.photo_50 as NSString) {
                            completion(image: cachedImage)
                        } else {
                            DispatchQueue.global().async {
                                if let url = URL(string: group.photo_50) {
                                    if let data = try? Data(contentsOf: url) {
                                        if let image = UIImage(data: data) {
                                            self.imageCache.setObject(image, forKey: group.photo_50 as NSString)
                                            completion(image: image)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        if let users = wall.profiles {
            if users.count > 0 {
                for user in users {
                    if abs(user.id) == abs(wall.items[indexPath.row].from_id) {
                        cell.nameLabel.text = user.first_name + " " + user.last_name
                        if let cachedImage = imageCache.object(forKey: user.photo_50 as NSString) {
                            completion(image: cachedImage)
                        } else {
                            DispatchQueue.global().async {
                                if let url = URL(string: user.photo_50) {
                                    if let data = try? Data(contentsOf: url) {
                                        if let image = UIImage(data: data) {
                                            self.imageCache.setObject(image, forKey: user.photo_50 as NSString)
                                            completion(image: image)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
}

