//
//  MovieViewModel.swift
//  CodingChallenge
//
//  Created by Omar Ramos González on 02/12/17.
//  Copyright © 2017 Omar Ramos González. All rights reserved.
//

import Foundation
import RxSwift
import SystemConfiguration

class MovieViewModel {
    let apiKey = "3f97490b8e3d47713954977903141f93"
    let movies: Variable<[Movie]> = Variable([])
    let searchPopularMovies: Variable<[Movie]> = Variable([])
    let searchTopMovies: Variable<[Movie]> = Variable([])
    let searchUpcomingMovies: Variable<[Movie]> = Variable([])
}

extension MovieViewModel{
    
    //Function to get Movies by popularity
    func getMoviesPopular() {
        if connectedToNetwork(){
            let url = URL(string: "https://api.themoviedb.org/3/movie/popular?api_key=" + apiKey + "&page=1")!
            getMoviesFromURL(url: url)
        }else{
            let dbCodingChallenge = DBCodingChallenge()
            dbCodingChallenge.initDB()
            self.movies.value = dbCodingChallenge.getMovies()
            self.movies.value = (movies.value.sorted(by: { $0.popularity > $1.popularity }))
        }
        
    }
    //Function to get Top rated Movies
    func getMoviesTop() {
        if connectedToNetwork(){
            let url = URL(string: "https://api.themoviedb.org/3/movie/top_rated?api_key=" + apiKey + "&page=1")!
            getMoviesFromURL(url: url)
        }else{
            let dbCodingChallenge = DBCodingChallenge()
            dbCodingChallenge.initDB()
            self.movies.value = dbCodingChallenge.getMovies()
            self.movies.value = (movies.value.sorted(by: { $0.rate > $1.rate }))
        }
        
    }
    //Function to get Upcoming Movies
    func getMoviesUpcoming() {
        if connectedToNetwork(){
            let url = URL(string: "https://api.themoviedb.org/3/movie/upcoming?api_key=" + apiKey + "&page=1")!
            getMoviesFromURL(url: url)
        }else{
            let dbCodingChallenge = DBCodingChallenge()
            dbCodingChallenge.initDB()
            self.movies.value = dbCodingChallenge.getMovies()
            self.searchUpcomingMovies.value.removeAll()
            for movie in self.movies.value{
                //Get current date
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                let releaseDate = formatter.date(from: movie.date) ?? Date()
                if releaseDate > Date(){
                    self.searchUpcomingMovies.value.append(movie)
                }
            }
            self.movies.value = self.searchUpcomingMovies.value
        }
    }
    //Funtion to search movies
    func searchMovies(query: String) {
        if connectedToNetwork(){
            var finalQuery = query.replacingOccurrences(of: " ", with: "%20")
            finalQuery = finalQuery.replacingOccurrences(of: "ñ", with: "n")
            let url = URL(string: "https://api.themoviedb.org/3/search/movie?api_key=" + apiKey + "&query=" + finalQuery + "&page=1")!
            getMoviesFromURL(url: url)
        }else{
            let dbCodingChallenge = DBCodingChallenge()
            dbCodingChallenge.initDB()
            let downloadedMovies = dbCodingChallenge.getMovies()
            self.movies.value = downloadedMovies.filter({
                $0.name.range(of: query, options: .caseInsensitive) != nil
            })
        }
        sortMovies()
    }
    func getMoviesFromURL(url: URL){
        let task = URLSession.shared.dataTask(with: url) {
            data, response, error in
            
            if error != nil {
                print("error=\(error!)")
            }else{
                //no error
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
                    //Get data from JSON if its correct
                    if let array = jsonData!["results"] as? NSArray{
                        for data in array{
                            let id = ((data as? NSDictionary)?["id"] as? Int)!
                            let name = ((data as? NSDictionary)?["original_title"] as? String)!
                            let rate = ((data as? NSDictionary)?["vote_average"] as? Double)!
                            let popularity = ((data as? NSDictionary)?["popularity"] as? Double)!
                            let date = ((data as? NSDictionary)?["release_date"] as? String)!
                            let description = ((data as? NSDictionary)?["overview"] as? String) ?? "0000-00-00"
                            let posterPath = ((data as? NSDictionary)?["poster_path"] as? String) ?? "/"
                            let backdropPath = ((data as? NSDictionary)?["backdrop_path"] as? String) ?? "/"
                            self.movies.value.append(Movie(id: id, name: name, rate: rate, popularity: popularity, date: date, description: description, posterPath: posterPath, backdropPath: backdropPath))
                        }
                    }
                }
            }
        }
        task.resume()
    }
    //Function that sorts search data in Categories
    func sortMovies() {
        self.movies.asObservable().subscribe({ value in
            self.searchPopularMovies.value = (value.element?.sorted(by: { $0.popularity > $1.popularity }))!
            self.searchTopMovies.value = (value.element?.sorted(by: { $0.rate > $1.rate }))!
            for movie in self.movies.value{
                //Get current date
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                let releaseDate = formatter.date(from: movie.date) ?? Date()
                if releaseDate > Date(){
                    self.searchUpcomingMovies.value.append(movie)
                }
            }
        })
        
    }
    
    //Function that return if the device is connected to the network

    func connectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        return (isReachable && !needsConnection)
    }
    
}
