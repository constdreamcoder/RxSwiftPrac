//
//  PhoneViewController.swift
//  SeSACRxThreads
//
//  Created by jack on 2023/10/30.
//
 
import UIKit
import SnapKit
import RxSwift
import RxCocoa

class PhoneViewController: UIViewController {
   
    let phoneTextField = SignTextField(placeholderText: "연락처를 입력해주세요")
    let nextButton = PointButton(title: "다음")
    
    var phoneNumber = Observable<String>.just("010")
    
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Color.white
        
        configureLayout()
        
        phoneNumber
            .bind(to: phoneTextField.rx.text)
            .disposed(by: disposeBag)
        
        let phoneNumberFirstValid = phoneTextField.rx.text.orEmpty
            .map { $0.count >= 10 }
        
        let phoneNumberSecondValid = phoneTextField.rx.text.orEmpty
            .map { Int($0) }
            .map { $0 != nil }
        
        let phoneNumberThirdValid = phoneTextField.rx.text.orEmpty
            .map { $0.contains("010") }
        
        let everythingValid = Observable.combineLatest(phoneNumberFirstValid, phoneNumberSecondValid, phoneNumberThirdValid) { $0 && $1 && $2 }
        
        everythingValid
            .bind(with: self, onNext: { owner, isValid in
                owner.nextButton.isEnabled = isValid
                owner.nextButton.backgroundColor = isValid ? Color.black : Color.black.withAlphaComponent(0.4)
            })
            .disposed(by: disposeBag)
        
        nextButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.navigationController?.pushViewController(NicknameViewController(), animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    func configureLayout() {
        view.addSubview(phoneTextField)
        view.addSubview(nextButton)
         
        phoneTextField.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(200)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        nextButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(phoneTextField.snp.bottom).offset(30)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
    }

}
