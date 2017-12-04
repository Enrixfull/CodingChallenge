//
//  MovieViewModel.swift
//  CodingChallenge
//
//  Created by Omar Ramos González on 02/12/17.
//  Copyright © 2017 Omar Ramos González. All rights reserved.
//

import Foundation
import RxSwift

class MovieViewModel {
    let movies: Variable<[Movie]> = Variable([])
    
}

extension MovieViewModel{
    func getMoviesPopular() {
        let url = URL(string: "https://api.themoviedb.org/3/discover/movie?api_key=3f97490b8e3d47713954977903141f93&sort_by=popularity.desc")!
        let task = URLSession.shared.dataTask(with: url) {
            data, response, error in
            
            if error != nil {
                print("error=\(error!)")
            }else{
                print("response = \(response!)")
                let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                print("responseString = \(responseString!)")
                var flag: Bool = true
                var jsonData: NSDictionary?
                do{
                    jsonData = try JSONSerialization.jsonObject(with: data! as Data, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
                }catch{
                    flag = false
                    print("error al decodificar jSON")
                }
                if flag{
                    let array = jsonData!["results"] as! NSArray
                    for data in array{
                        let id = ((data as? NSDictionary)?["id"] as? Int)!
                        let name = ((data as? NSDictionary)?["original_title"] as? String)!
                        let rate = ((data as? NSDictionary)?["vote_average"] as? Double)!
                        let popularity = ((data as? NSDictionary)?["popularity"] as? Double)!
                        let date = ((data as? NSDictionary)?["release_date"] as? String)!
                        let description = ((data as? NSDictionary)?["overview"] as? String)!
                        let posterPath = ((data as? NSDictionary)?["poster_path"] as? String)!
                        let backdropPath = ((data as? NSDictionary)?["backdrop_path"] as? String)!
                        self.movies.value.append(Movie(id: id, name: name, rate: rate, popularity: popularity, date: date, description: description, posterPath: posterPath, backdropPath: backdropPath))
                    }
                }
            }
        }
        task.resume()
    }
    
}
