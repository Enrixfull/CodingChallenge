//
//  ViewController.swift
//  CodingChallenge
//
//  Created by Omar Ramos González on 28/11/17.
//  Copyright © 2017 Omar Ramos González. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class PopularViewController: UIViewController, UICollectionViewDelegate {
    @IBOutlet weak var popularCollectionView: UICollectionView!
    let disposeBag = DisposeBag()
    let viewModel: MovieViewModel = MovieViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setupCellConfiguration()
        viewModel.getMoviesPopular()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupCellConfiguration(){
        popularCollectionView.register(UINib(nibName:"MovieCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "customCollectionCell")
        viewModel.movies.asObservable().bind(to: self.popularCollectionView.rx.items(cellIdentifier: "customCollectionCell", cellType: MovieCollectionViewCell.self)) { row, data, cell in
                cell.getImageWeb(posterPath: data.posterPath)
            }.disposed(by: disposeBag)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "fromPopularToShow", sender: indexPath.row)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let nextViewController = segue.destination as! MovieDetailViewController
        let indexPath = sender as! Int
        nextViewController.movie = viewModel.movies.value[indexPath]
    }
    
}

