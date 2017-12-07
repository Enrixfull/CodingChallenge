//
//  MovieDetailViewController.swift
//  CodingChallenge
//
//  Created by Omar Ramos González on 04/12/17.
//  Copyright © 2017 Omar Ramos González. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class MovieDetailViewController: UIViewController {
    @IBOutlet weak var backDropImage: UIImageView!
    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var movieDate: UILabel!
    @IBOutlet weak var movieDescription: UITextView!
    @IBOutlet weak var downloadButton: UIButton!
    var movie: Movie?
    let movieDownloaded: Variable<Bool> = Variable(false)
    let viewModel: DetailViewModel = DetailViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if movie != nil{
            movieTitle.text = movie?.name
            movieDate.text = movie?.date
            movieDescription.text = movie?.description
            getBackDropImage(backdropPath: (movie?.backdropPath)!)
            let dbCodingChallege = DBCodingChallenge()
            dbCodingChallege.initDB()
            let movies = dbCodingChallege.getMovies()
            for mov in movies{
                if mov.id == movie?.id{
                    movieDownloaded.value = true
                }
            }
        }
        movieDownloaded.asObservable().subscribe(onNext: { value in
            if value {
                DispatchQueue.main.async {
                    self.downloadButton.setTitle("Delete", for: [])
                    self.downloadButton.setImage(UIImage(named: "delete"), for: [])
                }
            } else{
                DispatchQueue.main.async {
                    self.downloadButton.setTitle("Download", for: [])
                    self.downloadButton.setImage(UIImage(named: "download"), for: [])
                }
            }
            
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func donwloadMovie(_ sender: Any) {
        let dbCodingChallege = DBCodingChallenge()
        dbCodingChallege.initDB()
        if movieDownloaded.value {
            if dbCodingChallege.deleteMovie(id: (movie?.id)!){
                movieDownloaded.value = false
            }
        } else{
            var path = movie?.posterPath ?? ""
            self.viewModel.saveImageFromWeb(url: "https://image.tmdb.org/t/p/w154",imagePath: path, isPosterPath: true)
            self.viewModel.savePosterPath.asObservable().subscribe(onNext: { value in
                if value != ""{
                    self.movie?.posterPath = value
                }
            })
            path = movie?.backdropPath ?? ""
            self.viewModel.saveImageFromWeb(url: "https://image.tmdb.org/t/p/w300", imagePath: path, isPosterPath: false)
            self.viewModel.saveBackdropPath.asObservable().subscribe(onNext: { value in
                if value != ""{
                    self.movie?.backdropPath = value
                    if dbCodingChallege.insertMovie(movie: self.movie!){
                        self.movieDownloaded.value = true
                    }
                }
            })
            
        }
        
    }
    
    @IBAction func close(_ sender: Any) {
        dismiss(animated: true)
    }
    
    func getBackDropImage(backdropPath: String) {
        if viewModel.connectedToNetwork() {
            let url = URL(string: "https://image.tmdb.org/t/p/w300" + backdropPath)!
            let task = URLSession.shared.dataTask(with: url){ (data, response, error) in
                if let e = error {
                    print("Error downloading picture: \(e)")
                } else {
                    // No errors found.
                    if (response as? HTTPURLResponse) != nil {
                        if let imageData = data {
                            //Convert data to image
                            let backdrop = UIImage(data: imageData)
                            DispatchQueue.main.async {
                                self.backDropImage.image = backdrop
                            }
                        } else {
                            print("Couldn't get image")
                        }
                    } else {
                        print("Couldn't get response code for some reason")
                    }
                }
            }
            task.resume()
        }else {
            self.backDropImage.image = UIImage(named: backdropPath)
            print("backdrop: " + backdropPath)
        }
    }
    
    
}
