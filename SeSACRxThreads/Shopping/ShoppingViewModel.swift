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
    
    // input
    let items = BehaviorSubject<[Todo]>(value: [])
    let inputQuery = PublishSubject<String>()
    let inputReturnButtonTap = PublishSubject<Void>()
    
    // output

    let disposeBag = DisposeBag()
    
    init() {
        inputQuery
            .debounce(.seconds(1), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .bind(with: self) { owner, searchText in                                
                let searchedTodoList = searchText.isEmpty ? owner.todoList : owner.todoList.filter { $0.item.contains(searchText) }
                owner.items.onNext(searchedTodoList)
            }
            .disposed(by: disposeBag)
        
        inputReturnButtonTap
            .withLatestFrom(inputQuery)
            .debounce(.seconds(1), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .bind(with: self) { owner, searchText in
               
                let searchedTodoList = searchText.isEmpty ? owner.todoList : owner.todoList.filter { $0.item.contains(searchText) }
                owner.items.onNext(searchedTodoList)
            }
            .disposed(by: disposeBag)
    }
}
