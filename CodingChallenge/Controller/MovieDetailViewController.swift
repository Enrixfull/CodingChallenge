//
//  MovieDetailViewController.swift
//  CodingChallenge
//
//  Created by Omar Ramos González on 04/12/17.
//  Copyright © 2017 Omar Ramos González. All rights reserved.
//

import UIKit

class MovieDetailViewController: UIViewController {
    @IBOutlet weak var backDropImage: UIImageView!
    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var movieDate: UILabel!
    @IBOutlet weak var movieDescription: UITextView!
    var movie: Movie?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if movie != nil{
            movieTitle.text = movie?.name
            movieDate.text = movie?.date
            movieDescription.text = movie?.description
            getBackDropImage(backdropPath: (movie?.backdropPath)!)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func donwloadMovie(_ sender: Any) {
        
    }
    
    @IBAction func close(_ sender: Any) {
        dismiss(animated: true)
    }
    
    func getBackDropImage(backdropPath: String) {
        let url = URL(string: "https://image.tmdb.org/t/p/w300" + backdropPath)!
        let task = URLSession.shared.dataTask(with: url){ (data, response, error) in
            if let e = error {
                print("Error downloading picture: \(e)")
            } else {
                // No errors found.
                if (response as? HTTPURLResponse) != nil {
                    //print("Downloaded picture with response code \(res.statusCode)")
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
    }
    
}
