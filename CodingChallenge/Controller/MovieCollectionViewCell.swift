//
//  MovieCollectionViewCell.swift
//  CodingChallenge
//
//  Created by Omar Ramos González on 02/12/17.
//  Copyright © 2017 Omar Ramos González. All rights reserved.
//

import UIKit
import RxSwift

class MovieCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var moviePoster: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func getImageWeb(posterPath: String) {
        let url = URL(string: "https://image.tmdb.org/t/p/w130" + posterPath)!
        let task = URLSession.shared.dataTask(with: url){ (data, response, error) in
            if let e = error {
                print("Error downloading picture: \(e)")
            } else {
                // No errors found.
                if let res = response as? HTTPURLResponse {
                    //print("Downloaded picture with response code \(res.statusCode)")
                    if let imageData = data {
                        //Convert data to image
                        let poster = UIImage(data: imageData)
                        DispatchQueue.main.async {
                            self.moviePoster.image = poster
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
