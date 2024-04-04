//
//  ShoppingViewModel.swift
//  SeSACRxThreads
//
//  Created by SUCHAN CHANG on 4/4/24.
//

import Foundation
import RxSwift
import RxCocoa

class ShoppingViewModel {
    
    var todoList: [Todo] = [
        .init(item: "그립톡 구매하기"),
        .init(item: "사이다 구매"),
        .init(item: "아이패드 케이스 최저가 알아보기"),
        .init(item: "양말"),
    ]
    
    let disposeBag = DisposeBag()
    
    struct Input {
        let addButtonTap: ControlEvent<Void>
        let itemSelected: ControlEvent<IndexPath>
        let searchText: ControlProperty<String>
        let returnButtonTap: ControlEvent<Void>
    }
    
    struct Output {
        let items: Driver<[Todo]>
        let addButtonTap: ControlEvent<Void>
        let itemSelected: ControlEvent<IndexPath>
    }
    
    
    func transform(input: Input) -> Output {
        let items = BehaviorSubject<[Todo]>(value: [])
        
        let inputQuery = input.searchText
        inputQuery
            .debounce(.seconds(1), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe(with: self) { owner, searchText in
                let searchedTodoList = searchText.isEmpty ? owner.todoList : owner.todoList.filter { $0.item.contains(searchText) }
                items.onNext(searchedTodoList)
            }
            .disposed(by: disposeBag)
        
        input.returnButtonTap
            .withLatestFrom(inputQuery)
            .debounce(.seconds(1), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe(with: self) { owner, searchText in
                let searchedTodoList = searchText.isEmpty ? owner.todoList : owner.todoList.filter { $0.item.contains(searchText) }
                items.onNext(searchedTodoList)
            }
            .disposed(by: disposeBag)
        
        input.addButtonTap
            .subscribe(with: self) { owner, _ in
                owner.todoList.append(.init(item: "테스트\(Int.random(in: 1..<100))"))
                items.onNext(owner.todoList)
            }
            .disposed(by: disposeBag)
        
        return Output(items: items.asDriver(onErrorJustReturn: []),
                      addButtonTap: input.addButtonTap,
                      itemSelected: input.itemSelected)
    }
}
