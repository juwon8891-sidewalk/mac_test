//
//  DanceRankingHeaderView.swift
//  stepin
//
//  Created by ikbum on 2023/03/12.
//

import UIKit

class DanceRankingHeaderView: UITableViewHeaderFooterView {
    static let identifier: String = "DanceRankingHeaderView"
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
    }
    
    internal func setData(profilePath: [String],
                         userName: [String],
                         userScore: [String],
                          isBlocked: [Bool]) {
        self.firstUserProfile.setData(profilePath: profilePath[0],
                                      userName: userName[0],
                                      userScore: userScore[0],
                                      rank: "1",
                                      isBlocked: isBlocked[0])
        self.secondUserProfile.setData(profilePath: profilePath[1],
                                       userName: userName[1],
                                       userScore: userScore[1],
                                       rank: "2",
                                       isBlocked: isBlocked[1])
        self.thirdUserProfile.setData(profilePath: profilePath[2],
                                      userName: userName[2],
                                      userScore: userScore[2],
                                      rank: "3",
                                      isBlocked: isBlocked[2])
        setLayout()
    }
    
    private func setLayout() {
        self.contentView.backgroundColor = .stepinBlack100
        self.addSubviews([firstUserProfile, secondUserProfile, thirdUserProfile])
        firstUserProfile.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(ScreenUtils.setWidth(value: 20))
            $0.width.equalTo(ScreenUtils.setWidth(value: 110))
            $0.height.equalTo(ScreenUtils.setWidth(value: 219))
        }
        
        secondUserProfile.snp.makeConstraints {
            $0.bottom.equalTo(firstUserProfile.snp.bottom)
            $0.leading.equalToSuperview().offset(ScreenUtils.setWidth(value: 16))
            $0.width.equalTo(ScreenUtils.setWidth(value: 72))
            $0.height.equalTo(ScreenUtils.setWidth(value: 181))
        }
        
        thirdUserProfile.snp.makeConstraints {
            $0.bottom.equalTo(firstUserProfile.snp.bottom)
            $0.trailing.equalToSuperview().inset(ScreenUtils.setWidth(value: 16))
            $0.width.equalTo(ScreenUtils.setWidth(value: 72))
            $0.height.equalTo(ScreenUtils.setWidth(value: 181))
        }
    }
    
    private var firstUserProfile = RankingProfileView(type: .first)
    private var secondUserProfile = RankingProfileView(type: .second)
    private var thirdUserProfile = RankingProfileView(type: .third)
    
}
