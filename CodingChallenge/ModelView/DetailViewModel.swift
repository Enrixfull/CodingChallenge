//
//  DetailViewModel.swift
//  CodingChallenge
//
//  Created by Omar Ramos González on 06/12/17.
//  Copyright © 2017 Omar Ramos González. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import SystemConfiguration

class DetailViewModel {
    let savePosterPath: Variable<String> = Variable("")
    let saveBackdropPath: Variable<String> = Variable("")
    
    //Function that saves images from web, need an url, the image path of de movie
    //and the kind of path: PosterPath or BackdropPath as a Bool
    func saveImageFromWeb(url: String, imagePath: String, isPosterPath: Bool){
        
        let url = URL(string: url + imagePath)!
        let task = URLSession.shared.dataTask(with: url){ (data, response, error) in
            if let e = error {
                print("Error downloading picture: \(e)")
            } else {
                // No errors found.
                if (response as? HTTPURLResponse) != nil {
                    //Save Image downloaded
                    let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
                    var documenDirectory: String?
                    if path.count > 0 {
                        documenDirectory = path[0]
                        if isPosterPath{
                            self.savePosterPath.value = documenDirectory! + imagePath
                            FileManager.default.createFile(atPath: self.savePosterPath.value, contents: data, attributes: nil)
                        }else{
                            self.saveBackdropPath.value = documenDirectory! + imagePath
                            FileManager.default.createFile(atPath: self.saveBackdropPath.value, contents: data, attributes: nil)
                        }
                    } else {
                        print("Couldn't save image")
                    }
                } else {
                    print("Couldn't get response code for some reason")
                }
            }
        }
        task.resume()
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
