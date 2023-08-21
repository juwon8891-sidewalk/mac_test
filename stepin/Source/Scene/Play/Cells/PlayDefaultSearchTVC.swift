//
//  PlayDefaultSearchTVC.swift
//  stepin
//
//  Created by ikbum on 2023/04/02.
//

import UIKit

class PlayDefaultSearchTVC: UITableViewCell {
    static let identifier: String = "PlayDefaultSearchTVC"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    internal func setData(title: String) {
        self.titleLabel.text = title
        self.setLayout()
    }
    
    private func setLayout() {
        self.selectionStyle = .none
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(ScreenUtils.setWidth(value: 16))
            $0.top.bottom.equalToSuperview().inset(ScreenUtils.setWidth(value: 20))
            $0.height.equalTo(ScreenUtils.setWidth(value: 20))
        }
    }
    
    private var titleLabel = UILabel().then {
        $0.font = .suitMediumFont(ofSize: 16)
        $0.textColor = .stepinWhite100
    }
}
