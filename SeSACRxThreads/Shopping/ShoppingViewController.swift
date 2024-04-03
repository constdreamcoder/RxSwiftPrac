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
        
    let viewModel = ShoppingViewModel()
    
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
        viewModel.items
            .bind(to: tableView.rx.items(cellIdentifier: ShoppingTableViewCell.identifier, cellType: ShoppingTableViewCell.self)) { row, element, cell in
                      
                cell.checkmarkButton.rx.tap
                    .withUnretained(self)
                    .bind { owner, _ in
                        owner.viewModel.todoList[row].isFinished.toggle()
                        
                        if owner.viewModel.todoList[row].isFinished {
                            cell.checkmarkButton.setImage(UIImage(systemName: "checkmark.square.fill"), for: .normal)
                        } else {
                            cell.checkmarkButton.setImage(UIImage(systemName: "checkmark.square"), for: .normal)
                        }
                    }
                    .disposed(by: cell.disposeBag)
                
                cell.favoriteButton.rx.tap
                    .withUnretained(self)
                    .bind { owner, _  in
                        owner.viewModel.todoList[row].isChecked.toggle()
                        if owner.viewModel.todoList[row].isChecked {
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
        
        searchTextField.rx.text.orEmpty
            .bind(to: viewModel.inputQuery)
            .disposed(by: disposeBag)
        
        searchTextField.rx.controlEvent(.editingDidEndOnExit)
            .bind(to: viewModel.inputReturnButtonTap)
            .disposed(by: disposeBag)
    }
    
    // MARK: - User Events
    @objc func backgroundViewTapped(_ gesture: UIGestureRecognizer) {
        view.endEditing(true)
    }
    
    @objc func addButtonTapped(_ button: UIButton) {
        viewModel.todoList.append(.init(item: "테스트\(Int.random(in: 1..<100))"))
        viewModel.items.onNext(viewModel.todoList)
    }
}

