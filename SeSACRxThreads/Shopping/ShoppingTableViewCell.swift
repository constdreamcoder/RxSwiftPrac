//
//  ShoppingTableViewCell.swift
//  SeSACRxThreads
//
//  Created by SUCHAN CHANG on 4/3/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class ShoppingTableViewCell: UITableViewCell {
    static let identifier = String(describing: ShoppingTableViewCell.self)
    
    let checkmarkButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "checkmark.square")
        button.setImage(image, for: .normal)
        button.tintColor = .black
        return button
    }()
    
    let itemLabel: UILabel = {
        let label = UILabel()
        label.text = "사이다 구매"
        return label
    }()
    
    let favoriteButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "star")
        button.setImage(image, for: .normal)
        button.tintColor = .black
        return button
    }()
    
    var disposeBag = DisposeBag()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configureConstraints()
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        disposeBag = DisposeBag()
    }
}

private extension ShoppingTableViewCell {
    func configureConstraints() {
        [
            checkmarkButton,
            itemLabel,
            favoriteButton
        ].forEach { contentView.addSubview($0) }
        
        checkmarkButton.snp.makeConstraints {
            $0.top.bottom.equalTo(contentView.safeAreaLayoutGuide).inset(16.0)
            $0.leading.equalTo(contentView.safeAreaLayoutGuide).offset(16.0)
        }
        
        checkmarkButton.setContentHuggingPriority(.required, for: .horizontal)
        checkmarkButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        itemLabel.snp.makeConstraints {
            $0.centerY.equalTo(checkmarkButton)
            $0.leading.equalTo(checkmarkButton.snp.trailing).offset(16.0)
            $0.trailing.equalTo(favoriteButton.snp.leading).offset(-8.0)
        }
        
        favoriteButton.snp.makeConstraints {
            $0.centerY.equalTo(checkmarkButton)
            $0.trailing.equalTo(contentView.safeAreaLayoutGuide).inset(16.0)
        }
    }
    
    func configureUI() {
        
    }
}
