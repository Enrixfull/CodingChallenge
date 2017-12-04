//
//  UpcomingViewController.swift
//  CodingChallenge
//
//  Created by Omar Ramos González on 03/12/17.
//  Copyright © 2017 Omar Ramos González. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class UpcomingViewController: UIViewController {
    @IBOutlet weak var upcomingCollectionView: UICollectionView!
    let disposeBag = DisposeBag()
    let viewModel: MovieViewModel = MovieViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupCellConfiguration()
        viewModel.getMoviesUpcoming()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupCellConfiguration(){
        upcomingCollectionView.register(UINib(nibName:"MovieCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "customCollectionCell")
        viewModel.movies.asObservable().bind(to: self.upcomingCollectionView.rx.items(cellIdentifier: "customCollectionCell", cellType: MovieCollectionViewCell.self)) { row, data, cell in
            cell.getImageWeb(posterPath: data.posterPath)
            }.disposed(by: disposeBag)
    }

}
