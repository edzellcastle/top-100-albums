//
//  MainViewController.swift
//  Top 100 Albums
//
//  Created by David Lindsay on 8/20/19.
//  Copyright © 2019 Tapinfuse, LLC. All rights reserved.
//

import UIKit
import CoreData

class MainViewController: UITableViewController {
    let albumTableView = UITableView()
    let fetchButton = UIButton()
    
    var detailViewController: DetailViewController? = nil

    var task: URLSessionDownloadTask!
    var session: URLSession!
    var imageCache = NSCache<NSString, UIImage>()
    
    private let persistentContainer = NSPersistentContainer(name: "Top_100_Albums")
    var moc: NSManagedObjectContext?
    
    fileprivate lazy var fetchedResultsController: NSFetchedResultsController<AlbumData> = {
        // Create Fetch Request
        let fetchRequest: NSFetchRequest<AlbumData> = AlbumData.fetchRequest()
        
        // Configure Fetch Request
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "albumName", ascending: true)]
        
        // Create Fetched Results Controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        persistentContainer.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        persistentContainer.viewContext.shouldDeleteInaccessibleFaults = true
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
        definesPresentationContext = true

        persistentContainer.loadPersistentStores { (persistentStoreDescription, error) in
            if let error = error {
                print("\(error), \(error.localizedDescription)")
            } else {
                do {
                    try self.fetchedResultsController.performFetch()
                    
                } catch {
                    let fetchError = error as NSError
                    print("\(fetchError), \(fetchError.localizedDescription)")
                }
            }
        }
        moc = persistentContainer.viewContext
        session = URLSession.shared
        task = URLSessionDownloadTask()
        self.navigationItem.title = "Top 100 Albums"
        fetchTop100Data()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        imageCache.removeAllObjects()
    }
    
    func configureTableView() {
        tableView.register(AlbumTableViewCell.self, forCellReuseIdentifier: albumTableViewCellReuseIdentifier)
        view.addSubview(albumTableView)
        albumTableView.translatesAutoresizingMaskIntoConstraints = false
        albumTableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        albumTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        albumTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        albumTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
    // MARK: - Fetch Data
    
    func fetchTop100Data() {
        let defaultString = ""
        if let url = URL(string: top100Link) {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data {
                    if let jsonString = String(data: data, encoding: .utf8) {
                        let jsonData = jsonString.data(using: .utf8)!
                        if let topLevel = try? JSONDecoder().decode(TopLevel.self, from: jsonData) {
                            let results = topLevel.feed.results
                            for i in 0..<results.count {
                                let artistName = results[i].artistName
                                let albumName = results[i].name
                                let artworkUrl100 = results[i].artworkUrl100
                                let genre = results[i].genres.first?.name ?? defaultString
                                let releaseDate = results[i].releaseDate
                                let copyright = results[i].copyright
                                let id = results[i].id
                                let albumPage = results[i].url
                                if i == results.count - 1 {
                                    self.saveAlbumData(albumName: albumName, artistName: artistName, artworkURL: artworkUrl100, genre: genre, releaseDate: releaseDate, copyright: copyright, id: id, albumPage: albumPage, saveContext: true)
                                } else {
                                    self.saveAlbumData(albumName: albumName, artistName: artistName, artworkURL: artworkUrl100, genre: genre, releaseDate: releaseDate, copyright: copyright, id: id, albumPage: albumPage, saveContext: false)
                                }
                            }
                        }
                    }
                }
            }.resume()
        }
    }
    
    // MARK: - Save Data
    
    func saveAlbumData(albumName: String, artistName: String, artworkURL: String, genre: String, releaseDate: String, copyright: String, id: String, albumPage: String, saveContext: Bool) {
    
        persistentContainer.performBackgroundTask { context in
            context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            guard let albumData = NSEntityDescription.insertNewObject(forEntityName: "AlbumData", into: context) as?  AlbumData else {
                return
            }
            albumData.setValue(albumName, forKeyPath: "albumName")
            albumData.setValue(artistName, forKeyPath: "artistName")
            albumData.setValue(artworkURL, forKey: "artworkUrl100")
            albumData.setValue(genre, forKey: "genre")
            albumData.setValue(releaseDate, forKey: "releaseDate")
            albumData.setValue(copyright, forKey: "copyright")
            albumData.setValue(id, forKey: "id")
            albumData.setValue(albumPage, forKey: "albumPage")
            if saveContext {
                do {
                    try context.save()
                } catch {
                    fatalError("Failure to save context: \(error)")
                }
            }
        }
    }
    
    // MARK: - Table View
    
    func tableView (tableView: UITableView, heightForHeaderInSection section:Int) -> Float {
        return 20.0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 77.0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: albumTableViewCellReuseIdentifier, for: indexPath) as? AlbumTableViewCell else {
            fatalError("Unexpected Index Path")
        }
        
        // Fetch album info
        let AlbumInfo = fetchedResultsController.object(at: indexPath)
        
        // Fill in the text fields for the cell
        cell.albumNameLabel.text = AlbumInfo.albumName
        cell.artistNameLabel.text = AlbumInfo.artistName
        
        cell.albumImageView.image = UIImage(named: "placeholder")
        if let id = AlbumInfo.id {
            // Use image in cache if it is available
            if (imageCache.object(forKey: id as NSString)) != nil {
                cell.albumImageView.image = self.imageCache.object(forKey: id as NSString)
            } else {
                if let artworkUrl = AlbumInfo.artworkUrl100 {
                    if let url = URL(string: artworkUrl) {
                        
                        // Download the artwork images asynchronously
                        task = session.downloadTask(with: url, completionHandler: { (location, response, error) -> Void in
                            if let data = try? Data(contentsOf: url) {
                                
                                // Place the image on the user interface using the main thread
                                DispatchQueue.main.async(execute: { () -> Void in
                                    // If the cell is visible, place the image on the UI
                                    if tableView.visibleCells.contains(cell) {
                                        if let img = UIImage(data: data) {
                                            cell.albumImageView.image = img
                                            self.imageCache.setObject(img, forKey: id as NSString)
                                        }
                                    }
                                })
                            }
                        })
                        task.resume()
                    }
                }
            }
        }
        return cell
    }
    
    // Prepare to display detail view controller.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailViewController = DetailViewController()
        // Fetch album info
        let AlbumInfo = fetchedResultsController.object(at: indexPath)
     
        detailViewController.albumName = AlbumInfo.albumName
        detailViewController.artistName = AlbumInfo.artistName
        detailViewController.artworkUrl100 = AlbumInfo.artworkUrl100
        detailViewController.genre = AlbumInfo.genre
        detailViewController.releaseDate = AlbumInfo.releaseDate
        detailViewController.copyright = AlbumInfo.copyright
        detailViewController.albumPage = AlbumInfo.albumPage
        detailViewController.session = session
        
        if let id = AlbumInfo.id {
            // Use image in cache if it is available
            if (imageCache.object(forKey: id as NSString)) != nil {
                detailViewController.image = self.imageCache.object(forKey: id as NSString)
            }
        }
        navigationController?.pushViewController(detailViewController, animated: true)
    }
}

// Use a fetched results controller to manage data from Core Data and update the album table view.

extension MainViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        albumTableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        albumTableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch (type) {
        case .insert:
            if let indexPath = newIndexPath {
                albumTableView.insertRows(at: [indexPath], with: .fade)
            }
            break
        case .delete:
            if let indexPath = indexPath {
                albumTableView.deleteRows(at: [indexPath], with: .fade)
            }
            break
        default:
            break
        }
    }
}


