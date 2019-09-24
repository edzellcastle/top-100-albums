//
//  AlbumTableViewCell.swift
//  Top 100 Albums
//
//  Created by David Lindsay on 8/20/19.
//  Copyright © 2019 Tapinfuse, LLC. All rights reserved.
//

import UIKit

class AlbumTableViewCell: UITableViewCell {
    
    let albumNameLabel = UILabel()
    let artistNameLabel = UILabel()
    let albumImageView = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(albumImageView)
        albumImageView.translatesAutoresizingMaskIntoConstraints = false
        albumImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        albumImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        albumImageView.heightAnchor.constraint(equalToConstant: 75.0).isActive = true
        albumImageView.widthAnchor.constraint(equalToConstant: 75.0).isActive = true
        
        contentView.addSubview(albumNameLabel)
        albumNameLabel.translatesAutoresizingMaskIntoConstraints = false
        albumNameLabel.leadingAnchor.constraint(equalTo: albumImageView.trailingAnchor, constant: 10).isActive = true
        albumNameLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        albumNameLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        albumNameLabel.heightAnchor.constraint(equalToConstant: 35.0).isActive = true
        albumNameLabel.numberOfLines = 0
        albumNameLabel.font = UIFont(name: "AvenirNext-DemiBold", size: 16)
        
        contentView.addSubview(artistNameLabel)
        artistNameLabel.translatesAutoresizingMaskIntoConstraints = false
        artistNameLabel.leadingAnchor.constraint(equalTo: albumImageView.trailingAnchor, constant: 10).isActive = true
        artistNameLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        artistNameLabel.topAnchor.constraint(equalTo: albumNameLabel.bottomAnchor).isActive = true
        artistNameLabel.heightAnchor.constraint(equalToConstant: 25.0).isActive = true
        artistNameLabel.numberOfLines = 0
        artistNameLabel.font = UIFont(name: "Avenir-Book", size: 12)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
