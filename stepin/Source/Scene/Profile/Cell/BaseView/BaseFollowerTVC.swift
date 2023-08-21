//
//  BaseFollowerTVC.swift
//  stepin
//
//  Created by ikbum on 2023/02/16.
//

import UIKit

class BaseFollowerTVC: UITableViewCell {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    internal func setLayout() {
        self.selectionStyle = .none
        self.backgroundColor = .stepinBlack100
        self.contentView.addSubviews([profileImageView, userNameLabel, generalButton])
        profileImageView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(ScreenUtils.setWidth(value: 10))
            $0.width.height.equalTo(ScreenUtils.setWidth(value: 40))
            $0.leading.equalToSuperview().offset(ScreenUtils.setWidth(value: 16))
        }
        profileImageView.layer.cornerRadius = ScreenUtils.setWidth(value: 40) / 2
        profileImageView.clipsToBounds = true
        
        userNameLabel.snp.makeConstraints {
            $0.centerY.equalTo(profileImageView)
            $0.height.equalTo(ScreenUtils.setWidth(value: 20))
            $0.leading.equalTo(profileImageView.snp.trailing).offset(ScreenUtils.setWidth(value: 12))
        }
        
        generalButton.snp.makeConstraints {
            $0.centerY.equalTo(profileImageView)
            $0.height.equalTo(ScreenUtils.setWidth(value: 30))
            $0.trailing.equalToSuperview().inset(ScreenUtils.setWidth(value: 16))
            $0.width.equalTo(ScreenUtils.setWidth(value: 72))
        }
        generalButton.layer.cornerRadius = ScreenUtils.setWidth(value: 15)
    }
    
    internal var profileImageView = UIImageView()
    internal var userNameLabel = UILabel().then {
        $0.font = .suitMediumFont(ofSize: 16)
        $0.textColor = .stepinWhite100
    }
    internal var generalButton = UIButton().then {
        $0.backgroundColor = .stepinWhite100
        $0.setTitle(" ", for: .normal)
        $0.setTitleColor(.stepinBlack100, for: .normal)
        $0.titleLabel?.font = .suitRegularFont(ofSize: 12)
    }
    
}
