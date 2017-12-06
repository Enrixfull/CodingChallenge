//
//  TopViewController.swift
//  CodingChallenge
//
//  Created by Omar Ramos González on 03/12/17.
//  Copyright © 2017 Omar Ramos González. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class TopViewController: UIViewController, UICollectionViewDelegate {
    @IBOutlet weak var topCollectionView: UICollectionView!
    let disposeBag = DisposeBag()
    let viewModel: MovieViewModel = MovieViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupCellConfiguration()
        viewModel.getMoviesTop()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupCellConfiguration(){
        topCollectionView.register(UINib(nibName:"MovieCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "customCollectionCell")
        viewModel.movies.asObservable().bind(to: self.topCollectionView.rx.items(cellIdentifier: "customCollectionCell", cellType: MovieCollectionViewCell.self)) { row, data, cell in
            cell.getImageWeb(posterPath: data.posterPath)
            }.disposed(by: disposeBag)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "fromTopToShow", sender: indexPath.row)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let nextViewController = segue.destination as! MovieDetailViewController
        let indexPath = sender as! Int
        nextViewController.movie = viewModel.movies.value[indexPath]
    }
}
