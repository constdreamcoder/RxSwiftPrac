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
import RxGesture

struct Todo: Identifiable {
    let id = UUID()
    
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
    }
    
    private func bind() {
        
        let input = ShoppingViewModel.Input(
            addButtonTap: addButton.rx.tap,
            itemSelected: tableView.rx.itemSelected,
            searchText: searchTextField.rx.text.orEmpty,
            returnButtonTap: searchTextField.rx.controlEvent(.editingDidEndOnExit)
        )
        
        let output = viewModel.transform(input: input)
        
        output.items
            .drive(tableView.rx.items(cellIdentifier: ShoppingTableViewCell.identifier, cellType: ShoppingTableViewCell.self)) { row, element, cell in
    
                cell.updateCheckmarkButtonImage(isFinished: element.isFinished)
                cell.updatedFavoriteButton(isChecked: element.isChecked)
                
                cell.checkmarkButton.rx.tap
                    .bind(with: self) { owner, _ in
                        let todo = owner.getChangedTodo(with: element, isChecked: true)
                        cell.updateCheckmarkButtonImage(isFinished: todo.isFinished)
                    }
                    .disposed(by: cell.disposeBag)
                
                cell.favoriteButton.rx.tap
                    .bind(with: self) { owner, _  in
                        let todo = owner.getChangedTodo(with: element, isChecked: true)
                        cell.updatedFavoriteButton(isChecked: todo.isChecked)
                    }
                    .disposed(by: cell.disposeBag)
                
                cell.itemLabel.text = element.item
            }
            .disposed(by: disposeBag)
        
        output.itemSelected
            .bind(with: self) { owner, indexPath in
                let nextPageVC = NextPageViewController()
                owner.navigationController?.pushViewController(nextPageVC, animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    // MARK: - Custom Methods
    private func getChangedTodo(with element: Todo, isChecked: Bool) -> Todo {
        viewModel.todoList.enumerated().forEach { value in
            if value.element.id == element.id {
                if isChecked {
                    viewModel.todoList[value.offset].isChecked.toggle()
                } else {
                    viewModel.todoList[value.offset].isFinished.toggle()
                }
            }
        }

        return viewModel.todoList.filter { $0.id == element.id }[0]
    }
    
    // MARK: - User Events
    @objc func backgroundViewTapped(_ gesture: UIGestureRecognizer) {
        view.endEditing(true)
    }
}

