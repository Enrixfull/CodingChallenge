//
//  Movie.swift
//  CodingChallenge
//
//  Created by Omar Ramos González on 02/12/17.
//  Copyright © 2017 Omar Ramos González. All rights reserved.
//

import Foundation

struct Movie {
    var id = 0
    var name = ""
    var rate = 0.0
    var popularity = 0.0
    var date = ""
    var description = ""
    var posterPath = ""
    var backdropPath = ""
    
    init(id: Int, name: String, rate: Double, popularity: Double, date: String, description: String, posterPath: String, backdropPath: String) {
        self.id = id
        self.name = name
        self.rate = rate
        self.popularity = popularity
        self.date = date
        self.description = description
        self.posterPath = posterPath
        self.backdropPath = backdropPath
    }
}
