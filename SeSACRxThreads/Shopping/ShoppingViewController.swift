//
//  ShoppingViewController.swift
//  SeSACRxThreads
//
//  Created by SUCHAN CHANG on 4/3/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

struct Todo {
    var isFinished: Bool = false
    let item: String
    var isChecked: Bool = false
    
    init(item: String) {
        self.item = item
    }
}

final class ShoppingViewController: UIViewController {
    
    let searchTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "검색어를 입력해주세요"
        return textField
    }()
    
    let addButton: UIButton = {
        let button = UIButton()
        var configuration = UIButton.Configuration.filled()
        configuration.title = "추가"
        configuration.baseBackgroundColor = .lightGray
        configuration.contentInsets = .init(top: 8, leading: 12, bottom: 8, trailing: 12)
        button.configuration = configuration
        return button
    }()
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(ShoppingTableViewCell.self, forCellReuseIdentifier: ShoppingTableViewCell.identifier)
        return tableView
    }()
    
    var todoList: [Todo] = [
        .init(item: "그립톡 구매하기"),
        .init(item: "사이다 구매"),
        .init(item: "아이패드 케이스 최저가 알아보기"),
        .init(item: "양말"),
    ]
    
    lazy var items = BehaviorSubject(value: todoList)
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureConstraints()
        configureUI()
        configureUserEvents()
        bind()
    }
    
    private func configureConstraints() {
        [
            searchTextField,
            addButton,
            tableView
        ].forEach { view.addSubview($0) }
        
        searchTextField.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.equalTo(view.safeAreaLayoutGuide).inset(16.0)
            $0.trailing.equalTo(addButton.snp.leading).offset(-16.0)
        }
        
        addButton.snp.makeConstraints {
            $0.trailing.equalTo(view.safeAreaLayoutGuide).inset(16.0)
            $0.center.equalTo(searchTextField)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(searchTextField.snp.bottom).offset(16.0)
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(16.0)
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
    }
    
    private func configureUserEvents() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(backgroundViewTapped))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
    }
    
    private func bind() {
        items
            .bind(to: tableView.rx.items(cellIdentifier: ShoppingTableViewCell.identifier, cellType: ShoppingTableViewCell.self)) { row, element, cell in
                      
                cell.checkmarkButton.rx.tap
                    .withUnretained(self)
                    .bind { owner, _ in
                        owner.todoList[row].isFinished.toggle()
                        
                        if owner.todoList[row].isFinished {
                            cell.checkmarkButton.setImage(UIImage(systemName: "checkmark.square.fill"), for: .normal)
                        } else {
                            cell.checkmarkButton.setImage(UIImage(systemName: "checkmark.square"), for: .normal)
                        }
                    }
                    .disposed(by: cell.disposeBag)
                
                cell.favoriteButton.rx.tap
                    .withUnretained(self)
                    .bind { owner, _  in
                        owner.todoList[row].isChecked.toggle()
                        if owner.todoList[row].isChecked {
                            cell.favoriteButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
                        } else {
                            cell.favoriteButton.setImage(UIImage(systemName: "star"), for: .normal)
                        }
                    }
                    .disposed(by: cell.disposeBag)
                
                cell.itemLabel.text = element.item
            }
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .bind(with: self) { owner, indexPath in
                let nextPageVC = NextPageViewController()
                owner.navigationController?.pushViewController(nextPageVC, animated: true)
            }
            .disposed(by: disposeBag)
        
        searchTextField.rx.text
            .debounce(.seconds(1), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .bind(with: self) { owner, searchText in
                guard let searchText else { return }
                                
                let searchedTodoList = searchText.isEmpty ? owner.todoList : owner.todoList.filter { $0.item.contains(searchText) }
                owner.items.onNext(searchedTodoList)
            }
            .disposed(by: disposeBag)
        
        searchTextField.rx.controlEvent(.editingDidEndOnExit)
            .withLatestFrom(searchTextField.rx.text.orEmpty)
            .debounce(.seconds(1), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .bind(with: self) { owner, searchText in
                print("f")
                let searchedTodoList = searchText.isEmpty ? owner.todoList : owner.todoList.filter { $0.item.contains(searchText) }
                owner.items.onNext(searchedTodoList)
            }
            .disposed(by: disposeBag)
    }
    
    // MARK: - User Events
    @objc func backgroundViewTapped(_ gesture: UIGestureRecognizer) {
        view.endEditing(true)
    }
    
    @objc func addButtonTapped(_ button: UIButton) {
        todoList.append(.init(item: "테스트\(Int.random(in: 1..<100))"))
        items.onNext(todoList)
    }
}

