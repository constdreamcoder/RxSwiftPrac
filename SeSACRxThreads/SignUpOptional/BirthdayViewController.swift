//
//  BirthdayViewController.swift
//  SeSACRxThreads
//
//  Created by jack on 2023/10/30.
//
 
import UIKit
import SnapKit
import RxSwift
import RxCocoa

enum InfoLabelText: String {
    case availableAge = "가입 가능한 나이입니다"
    case unavailableAge = "만 17세 이상만 가입 가능합니다"
}

class BirthdayViewController: UIViewController {
    
    let birthDayPicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .wheels
        picker.locale = Locale(identifier: "ko-KR")
        picker.maximumDate = Date()
        return picker
    }()
    
    let infoLabel: UILabel = {
       let label = UILabel()
        label.textColor = Color.black
        label.text = "만 17세 이상만 가입 가능합니다."
        return label
    }()
    
    let containerStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        stack.spacing = 10 
        return stack
    }()
    
    let yearLabel: UILabel = {
       let label = UILabel()
        label.text = "2023년"
        label.textColor = Color.black
        label.snp.makeConstraints {
            $0.width.equalTo(100)
        }
        return label
    }()
    
    let monthLabel: UILabel = {
       let label = UILabel()
        label.text = "33월"
        label.textColor = Color.black
        label.snp.makeConstraints {
            $0.width.equalTo(100)
        }
        return label
    }()
    
    let dayLabel: UILabel = {
       let label = UILabel()
        label.text = "99일"
        label.textColor = Color.black
        label.snp.makeConstraints {
            $0.width.equalTo(100)
        }
        return label
    }()
  
    let nextButton = PointButton(title: "가입하기")
    
    let year = PublishSubject<Int>()
    let month = PublishSubject<Int>()
    let day = PublishSubject<Int>()
    let info = PublishSubject<String>()
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Color.white
        
        configureLayout()
        
        bind()
    }
    
    func bind() {
        nextButton.rx.tap
            .bind(with: self) { owner, _ in
                let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
                let sceneDelegate = windowScene?.delegate as? SceneDelegate
                
                let sampleVC = SampleViewController()
                
                sceneDelegate?.window?.rootViewController = sampleVC
                sceneDelegate?.window?.makeKeyAndVisible()
            }
            .disposed(by: disposeBag)
        
        info
            .bind(with: self, onNext: { owner, infoString in
                owner.infoLabel.text = infoString

                if infoString == InfoLabelText.availableAge.rawValue {
                    owner.infoLabel.textColor = .blue
                    owner.nextButton.backgroundColor = .blue
                    owner.nextButton.isEnabled = true
                } else if infoString == InfoLabelText.unavailableAge.rawValue {
                    owner.infoLabel.textColor = .red
                    owner.nextButton.backgroundColor = .lightGray
                    owner.nextButton.isEnabled = false
                }
            })
            .disposed(by: disposeBag)
        
        year
            .map { "\($0)년"}
            .bind(to: yearLabel.rx.text)
            .disposed(by: disposeBag)
        
        month
            .map { "\($0)월"}
            .bind(to: monthLabel.rx.text)
            .disposed(by: disposeBag)
        
        day
            .map { "\($0)일"}
            .bind(to: dayLabel.rx.text)
            .disposed(by: disposeBag)
        
        birthDayPicker.rx.date
            .subscribe(with: self) { owner, date in
                let components = Calendar.current.dateComponents([.year, .month, .day], from: date)
                
                owner.year.onNext(components.year!)
                owner.month.onNext(components.month!)
                owner.day.onNext(components.day!)
                
                let today = Date()
                
                let todayComponents = Calendar.current.dateComponents([.year, .month, .day], from: today)
                
                if todayComponents.year! - components.year! > 17 {
                    owner.info.onNext(InfoLabelText.availableAge.rawValue)
                } else if todayComponents.year! - components.year! == 17 {
                    if todayComponents.month! > components.month! {
                        owner.info.onNext(InfoLabelText.availableAge.rawValue)
                    } else if todayComponents.month! == components.month! {
                        if todayComponents.day! >= components.day! {
                            owner.info.onNext(InfoLabelText.availableAge.rawValue)
                        } else {
                            owner.info.onNext(InfoLabelText.unavailableAge.rawValue)
                        }
                    } else {
                        owner.info.onNext(InfoLabelText.unavailableAge.rawValue)
                    }
                } else {
                    owner.info.onNext(InfoLabelText.unavailableAge.rawValue)
                }
            }
            .disposed(by: disposeBag)
    }
    
    func configureLayout() {
        view.addSubview(infoLabel)
        view.addSubview(containerStackView)
        view.addSubview(birthDayPicker)
        view.addSubview(nextButton)
 
        infoLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(150)
            $0.centerX.equalToSuperview()
        }
        
        containerStackView.snp.makeConstraints {
            $0.top.equalTo(infoLabel.snp.bottom).offset(30)
            $0.centerX.equalToSuperview()
        }
        
        [yearLabel, monthLabel, dayLabel].forEach {
            containerStackView.addArrangedSubview($0)
        }
        
        birthDayPicker.snp.makeConstraints {
            $0.top.equalTo(containerStackView.snp.bottom)
            $0.centerX.equalToSuperview()
        }
   
        nextButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(birthDayPicker.snp.bottom).offset(30)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
    }

}
