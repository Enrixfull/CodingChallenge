//
//  SearchViewController.swift
//  CodingChallenge
//
//  Created by Omar Ramos González on 03/12/17.
//  Copyright © 2017 Omar Ramos González. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SearchViewController: UIViewController, UICollectionViewDelegate {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var popularCollectionView: UICollectionView!
    @IBOutlet weak var topCollectionRated: UICollectionView!
    @IBOutlet weak var upcomingCollectionView: UICollectionView!
    let disposeBag = DisposeBag()
    let viewModel: MovieViewModel = MovieViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupCellConfiguration()
        searchBar.rx.text.subscribe(onNext: { value in
            
            self.viewModel.movies.value.removeAll()
            self.viewModel.searchMovies(query: value ?? "")
        }).disposed(by: disposeBag)
        //hide keyboard
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SearchViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupCellConfiguration(){
        //Configuration popularCollectionViewCell
        popularCollectionView.register(UINib(nibName:"MovieCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "customCollectionCell")
        viewModel.searchPopularMovies.asObservable().bind(to: self.popularCollectionView.rx.items(cellIdentifier: "customCollectionCell", cellType: MovieCollectionViewCell.self)) { row, data, cell in
                cell.getImage(posterPath: data.posterPath)
            }.disposed(by: disposeBag)
        //Configuration topColectionViewCell
        topCollectionRated.register(UINib(nibName:"MovieCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "customCollectionCell")
        viewModel.searchTopMovies.asObservable().bind(to: self.topCollectionRated.rx.items(cellIdentifier: "customCollectionCell", cellType: MovieCollectionViewCell.self)) { row, data, cell in
                cell.getImage(posterPath: data.posterPath)
            }.disposed(by: disposeBag)
        //Configuration upcomingCollectionViewCell
        upcomingCollectionView.register(UINib(nibName:"MovieCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "customCollectionCell")
        viewModel.searchUpcomingMovies.asObservable().bind(to: self.upcomingCollectionView.rx.items(cellIdentifier: "customCollectionCell", cellType: MovieCollectionViewCell.self)) { row, data, cell in
                cell.getImage(posterPath: data.posterPath)
            }.disposed(by: disposeBag)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "fromSearchToShow", sender: indexPath.row)
    }
    
    //Override de prepare function to pass a movie object
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let nextViewController = segue.destination as! MovieDetailViewController
        let indexPath = sender as! Int
        nextViewController.movie = viewModel.movies.value[indexPath]
    }
    
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

}
