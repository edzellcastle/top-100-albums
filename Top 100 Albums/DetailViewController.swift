//
//  DetailViewController.swift
//  Top 100 Albums
//
//  Created by David Lindsay on 8/20/19.
//  Copyright © 2019 Tapinfuse, LLC. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    let labelBackgroundColor = UIColor.white
    let albumNameLabel = UILabel()
    let artistNameLabel = UILabel()
    let albumImageView = UIImageView()
    let genreLabel = UILabel()
    let releaseDateLabel = UILabel()
    let copyrightLabel = UILabel()
    let albumPageButton = UIButton()
    
    var albumName: String?
    var artistName: String?
    var artworkUrl100: String?
    var genre: String?
    var releaseDate: String?
    var copyright: String?
    var albumPage: String?
    var image: UIImage?
    
    var task: URLSessionDownloadTask!
    var session: URLSession!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        self.navigationItem.title = "Album Detail"
    }
    
    func configureViews() {
        view.backgroundColor = .white
        view.addSubview(albumImageView)
        if let image = image {
            albumImageView.image = image
        } else {
            if let artworkUrl = artworkUrl100 {
                if let url = URL(string: artworkUrl) {
                    
                    // Download the artwork images asynchronously
                    task = session.downloadTask(with: url, completionHandler: { (location, response, error) -> Void in
                        if let data = try? Data(contentsOf: url) {
                            
                            // Place the image on the user interface using the main thread
                            DispatchQueue.main.async(execute: { () -> Void in
                                if let img = UIImage(data: data) {
                                    self.albumImageView.image = img
                                }
                            })
                        }
                    })
                    task.resume()
                }
            }
        }
        albumImageView.translatesAutoresizingMaskIntoConstraints = false
        albumImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        albumImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 10).isActive = true
        albumImageView.heightAnchor.constraint(equalToConstant: 200.0).isActive = true
        albumImageView.widthAnchor.constraint(equalToConstant: 200.0).isActive = true
       
        view.addSubview(albumNameLabel)
        albumNameLabel.text = albumName ?? ""
        albumNameLabel.backgroundColor = labelBackgroundColor
        albumNameLabel.textColor = .black
        albumNameLabel.translatesAutoresizingMaskIntoConstraints = false
        albumNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        albumNameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        albumNameLabel.topAnchor.constraint(equalTo: albumImageView.bottomAnchor, constant: 10).isActive = true
        albumNameLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        view.addSubview(artistNameLabel)
        artistNameLabel.text = artistName ?? ""
        artistNameLabel.backgroundColor = labelBackgroundColor
        artistNameLabel.textColor = .black
        artistNameLabel.translatesAutoresizingMaskIntoConstraints = false
        artistNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        artistNameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        artistNameLabel.topAnchor.constraint(equalTo: albumNameLabel.bottomAnchor, constant: 10).isActive = true
        artistNameLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
      
        view.addSubview(genreLabel)
        genreLabel.text = genre ?? ""
        genreLabel.textColor = .black
        genreLabel.backgroundColor = labelBackgroundColor
        genreLabel.translatesAutoresizingMaskIntoConstraints = false
        genreLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        genreLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        genreLabel.topAnchor.constraint(equalTo: artistNameLabel.bottomAnchor, constant: 10).isActive = true
        genreLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        view.addSubview(releaseDateLabel)
        releaseDateLabel.text = releaseDate ?? ""
        releaseDateLabel.textColor = .black
        releaseDateLabel.backgroundColor = labelBackgroundColor
        releaseDateLabel.translatesAutoresizingMaskIntoConstraints = false
        releaseDateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        releaseDateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        releaseDateLabel.topAnchor.constraint(equalTo: genreLabel.bottomAnchor, constant: 10).isActive = true
        releaseDateLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        view.addSubview(copyrightLabel)
        copyrightLabel.text = copyright ?? ""
        copyrightLabel.textColor = .black
        copyrightLabel.backgroundColor = labelBackgroundColor
        copyrightLabel.numberOfLines = 0
        copyrightLabel.translatesAutoresizingMaskIntoConstraints = false
        copyrightLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        copyrightLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        copyrightLabel.topAnchor.constraint(equalTo: releaseDateLabel.bottomAnchor, constant: 10).isActive = true
        copyrightLabel.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        albumPageButton.backgroundColor = UIColor.blue
        albumPageButton.setTitle("Album Page", for: .normal)
        albumPageButton.addTarget(self, action: #selector(showAlbumPage), for: .touchUpInside)
        view.addSubview(albumPageButton)
        albumPageButton.translatesAutoresizingMaskIntoConstraints = false
     
        albumPageButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        albumPageButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        albumPageButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20.0).isActive = true
        albumPageButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    @objc func showAlbumPage() {
        if let albumPage = albumPage {
            UIApplication.shared.open(NSURL(string: albumPage)! as URL)
        }
    }
}
