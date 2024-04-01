//
//  SearchViewController.swift
//  SeSACRxThreads
//
//  Created by jack on 2024/04/01.
//

import UIKit
import RxSwift
import RxCocoa

class SearchViewController: UIViewController {
    
    private let tableView: UITableView = {
        let view = UITableView()
        view.register(SearchTableViewCell.self, forCellReuseIdentifier: SearchTableViewCell.identifier)
        view.backgroundColor = .white
        view.rowHeight = 180
        view.separatorStyle = .none
        return view
    }()
    
    let searchBar = UISearchBar()
    
    var data = ["A", "B", "C", "AB", "D", "ABC", "BBB", "EC", "SA", "AAAB", "ED", "F", "G", "H"]
//    var data = ["A"]
    
    lazy var items = BehaviorSubject(value: data)
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        configure()
        setSearchController()
        bind()
    }
    
    private func setSearchController() {
        view.addSubview(searchBar)
        navigationItem.titleView = searchBar
        
//        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "추가", style: .plain, target: self, action: #selector(plusButtonClicked))
    }
    
    @objc func plusButtonClicked() {
        let sample = ["A", "B", "C", "D", "E"]
        data.append(sample.randomElement()!)
        
        items.onNext(data)
    }
    
    
    private func configure() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func bind() {
        items
            .bind(to: tableView.rx.items(cellIdentifier: SearchTableViewCell.identifier, cellType: SearchTableViewCell.self)) { row, element, cell in
                
                cell.appNameLabel.text = "테스트 \(element)"
                cell.appIconImageView.backgroundColor = .systemBlue
                
                cell.downloadButton.rx.tap
                    .observe(on: MainScheduler.instance)
                    .subscribe(with: self, onNext: { owner, _ in
                        owner.navigationController?.pushViewController(BirthdayViewController(), animated: true)
                    })
                    .disposed(by: cell.disposeBag)
            }
            .disposed(by: disposeBag)
        
        Observable.zip(
            tableView.rx.itemSelected,
            tableView.rx.modelSelected(String.self)
        ).bind(with: self) { owner, value in
            print(value.0, value.1)
            
            owner.data.remove(at: value.0.row)
            owner.items.onNext(owner.data)
        }
        .disposed(by: disposeBag)
        
        
//        tableView.rx.itemSelected
//            .bind(with: self) { owner, indexPath in
//                print(indexPath)
//            }
//            .disposed(by: disposeBag)
//
//        tableView.rx.modelSelected(String.self)
//            .withUnretained(self)
//            .bind { owner, model in
//                print(model)
//            }
//            .disposed(by: disposeBag)
        
        /*
         문제 상황 1. 서치바에 타이핑될 때마다 과도한 콜수 발생
         해결법: 유저가 타이핑을 끝낸 시점에 일정 시간이 흐른 후 이벤트 발생(debounce)
        */
        /*
         문제 상황 2. 직전 검색어와 동일한 검색어를 작성했을 때 불필요한 네크워크 통신 발생
         해결법: 직전 검색어와 동일한 검색어를 작성시 불필요한 네트워크 통신을 없앰(distinctUntilChanged)
         */
        searchBar.rx.text.orEmpty
            .debounce(.seconds(1), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe(with: self) { owner, searchText in
                let result = searchText.isEmpty ? owner.data : owner.data.filter { $0.contains(searchText) }
                owner.items.onNext(result)
            }
            .disposed(by: disposeBag)
        
        /*
         상황: 검색 버튼 클릭 + 서치바 텍스트
         */
        searchBar.rx.searchButtonClicked
            .withLatestFrom(searchBar.rx.text.orEmpty)
            .distinctUntilChanged()
            .subscribe(with: self, onNext: { owner, searchText in
                print("검색 버튼 클릭: \(searchText)")
                let result = searchText.isEmpty ? owner.data : owner.data.filter { $0.contains(searchText) }
                owner.items.onNext(result)
            })
            .disposed(by: disposeBag)
    }
}
