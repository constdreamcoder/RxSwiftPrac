//
//  SampleViewController.swift
//  SeSACRxThreads
//
//  Created by SUCHAN CHANG on 4/1/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class SampleViewController: UIViewController {
    
    let inputTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .line
        return textField
    }()
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    var itemDataList: [String] = []
    lazy var items = BehaviorSubject<[String]>(value: itemDataList)
    
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureConstraints()
        configureSettings()
        bind()
    }
    
    func configureConstraints() {
        view.addSubview(inputTextField)
        view.addSubview(tableView)
        
        inputTextField.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(16.0)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(inputTextField.snp.bottom).offset(16.0)
            $0.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    func configureSettings() {
        view.backgroundColor = .white
    }
    
    func bind() {
        items
            .bind(to: tableView.rx.items(cellIdentifier: "cell", cellType: UITableViewCell.self)) { row, element, cell in
                cell.textLabel?.text = "\(element)"
            }
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .bind(with: self) { owner, indexPath in
                owner.itemDataList.remove(at: indexPath.row)
                owner.items.onNext(owner.itemDataList)
            }
            .disposed(by: disposeBag)
                
        inputTextField.rx.controlEvent(.editingDidEndOnExit)
            .bind(with: self) { owner, _ in
                print("엔터눌림")
                guard  let text = owner.inputTextField.text else { return }
                
                if text.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                    owner.itemDataList.append(text)
                    owner.items.onNext(owner.itemDataList)
                    owner.inputTextField.text = ""
                }
            }
            .disposed(by: disposeBag)
    }
}
