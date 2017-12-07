//
//  DBCodingChallenge.swift
//  CodingChallenge
//
//  Created by Omar Ramos González on 05/12/17.
//  Copyright © 2017 Omar Ramos González. All rights reserved.
//

import Foundation

class DBCodingChallenge {
    let dbName = "codingDB.swift"
    let table = "Movies"
    let fileManager = FileManager.default
    var sqliteDB: OpaquePointer? = nil
    var dbURL: NSURL? = nil
    
    func initDB() {
        do{
            let baseUrl = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            dbURL = baseUrl.appendingPathComponent(dbName) as NSURL
        }catch{
            print(error)
        }
        
        if dbURL != nil{
            let flags = SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE
            let status = sqlite3_open_v2(dbURL?.absoluteString?.cString(using: String.Encoding.utf8), &sqliteDB, flags, nil)
            if status == SQLITE_OK{
                let errorMsessage: UnsafeMutablePointer<UnsafeMutablePointer<Int8>?>! = nil
                let sqlStatement = "create table if not exists " + table + "(id Integer not null, name Text, rate Float, popularity Float, date Text, description Text, poster_path Text, backdrop_path Text);"
                if sqlite3_exec(sqliteDB, sqlStatement, nil, nil, errorMsessage) == SQLITE_OK{
                    print("Table created")
                } else{
                    print("Table not created")
                }
            }
        }
    }
    
    func insertMovie(movie: Movie) -> Bool {
        var statement: OpaquePointer? = nil
        let insertStatement = "insert into " + table + " (id, name, rate, popularity, date, description, poster_path, backdrop_path) values ('\(movie.id)', '\(movie.name.replacingOccurrences(of: "'", with: "''"))', '\(movie.rate)', '\(movie.popularity)', '\(movie.date)', '\(movie.description.replacingOccurrences(of: "'", with: "''"))', '\(movie.posterPath)', '\(movie.backdropPath)');"
        sqlite3_prepare_v2(sqliteDB, insertStatement, -1, &statement, nil)
        if sqlite3_step(statement) == SQLITE_DONE{
            sqlite3_finalize(statement)
            return true
        } else{
            sqlite3_finalize(statement)
            return false
        }
    }
    
    func getMovies() -> [Movie] {
        var movies: [Movie] = []
        var statement: OpaquePointer? = nil
        let insertStatement = "select * from " + table + ";"
        if sqlite3_prepare_v2(sqliteDB, insertStatement, -1, &statement, nil) == SQLITE_OK{
            while sqlite3_step(statement) == SQLITE_ROW{
                let id = Int(sqlite3_column_int(statement, 0))
                let name = String.init(cString: sqlite3_column_text(statement, 1))
                let rate = sqlite3_column_double(statement, 2)
                let popularity = sqlite3_column_double(statement, 3)
                let date = String.init(cString: sqlite3_column_text(statement, 4))
                let description = String.init(cString: sqlite3_column_text(statement, 5))
                let posterPath = String.init(cString: sqlite3_column_text(statement, 6))
                let backdropPath = String.init(cString: sqlite3_column_text(statement, 7))
                movies.append(Movie(id: id, name: name, rate: rate, popularity: popularity, date: date, description: description, posterPath: posterPath, backdropPath: backdropPath))
            }
        }
        sqlite3_finalize(statement)
        return movies
    }
    
    func deleteMovie(id: Int) -> Bool {
        var statement: OpaquePointer? = nil
        let insertStatement = "delete from " + table + " where id = \(id);"
        sqlite3_prepare_v2(sqliteDB, insertStatement, -1, &statement, nil)
        if sqlite3_step(statement) == SQLITE_DONE{
            sqlite3_finalize(statement)
            return true
        } else{
            sqlite3_finalize(statement)
            return false
        }
    }
}
