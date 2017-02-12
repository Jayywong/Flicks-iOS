//
//  MovieCollectionViewController.swift
//  MovieViewer
//
//  Created by Jason Wong on 2/11/17.
//  Copyright © 2017 Jason Wong. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MovieCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    
    @IBOutlet weak var moviesCollectionView: UICollectionView!
    
    
    var movies: [NSDictionary]?
    let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
    var endpoint: String!
    

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        
        moviesCollectionView.dataSource = self
        moviesCollectionView.delegate = self
        
        
        loadFromAPI()
        
        let refreshControl = UIRefreshControl()
        
        refreshControl.addTarget(self, action: #selector(refreshControlAction(refreshControl:)), for: UIControlEvents.valueChanged)
        
        moviesCollectionView.insertSubview(refreshControl, at: 0)
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refreshControlAction(refreshControl: UIRefreshControl)
    {
        let url = URL(string: "https://api.themoviedb.org/3/movie/\(endpoint!)?api_key=\(apiKey)")!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task: URLSessionDataTask = session.dataTask(with: request)
        { (data: Data?, response: URLResponse?, error: Error?) in
            if let data = data
            {
                if let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary
                {
                    print(dataDictionary)
                    
                    self.movies = dataDictionary["results"] as! [NSDictionary]
                    self.moviesCollectionView.reloadData()
                }
            }
        }
        
        moviesCollectionView.reloadData()
        refreshControl.endRefreshing()
        
        task.resume()
        
        
    }

    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        
        if let movies = movies
        {
            return movies.count
        }else
        {
            return 0
        }

    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        
        let cell = moviesCollectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCell", for: indexPath)
            as! CollectionCell
        
        
        let movie = movies![indexPath.row]
        
        let baseURL = "https://image.tmdb.org/t/p/w500"
        
        if let posterImgPath = movie["poster_path"] as? String
        {
            if let imageURL = URL(string: baseURL + posterImgPath){
                cell.movieImageView?.setImageWith(imageURL)

            }
        }
        
            
        return cell
        
    }
    
    
    
    func loadFromAPI()
    {
        let url = URL(string: "https://api.themoviedb.org/3/movie/\(endpoint!)?api_key=\(apiKey)")!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        
        //print(url)
        
        //loading animation
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        let task: URLSessionDataTask = session.dataTask(with: request)
        { (data: Data?, response: URLResponse?, error: Error?) in
            if let data = data
            {
                if let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary
                {
                    print(dataDictionary)
                    
                    self.movies = dataDictionary["results"] as! [NSDictionary]
                    self.moviesCollectionView.reloadData()
                }
            }
            
            //removes loading animation when data from api call is received and displays on screen
            MBProgressHUD.hide(for: self.view, animated: true)
        }
        
        task.resume()
        
    }


    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let cell = sender as! UICollectionViewCell //determines which cell was clicked
        let indexPath = moviesCollectionView.indexPath(for: cell) //gets index from tableView
        let movie = movies?[(indexPath?.row)!]
        
        let detailViewController = segue.destination as! DetailViewController //cast viewController to DetailViewController
        detailViewController.movie = movie
        
    }
    
}
