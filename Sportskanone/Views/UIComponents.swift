//
//  UIComponents.swift
//  Sportskanone
//
//  Created by Fabian Pahl on 25/03/2017.
//  Copyright © 2017 21st digital GmbH. All rights reserved.
//

import UIKit

final class BorderButton: UIButton {}
final class HeadlineLabel: UILabel {}
final class TextLabel: UILabel {}

final class TextField: UITextField {
  
  private let borderLayer = CALayer()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    font = UIFont.systemFont(ofSize: 32, weight: UIFontWeightHeavy)
    textColor = UIColor.skBrown
    autocorrectionType = .no
    autocapitalizationType = .words
    returnKeyType = .done
    keyboardType = .alphabet
    
    borderLayer.borderColor = UIColor(white: 0.7, alpha: 0.7).cgColor
    borderLayer.borderWidth = CGFloat(2.0)
    layer.addSublayer(borderLayer)
    layer.masksToBounds = true
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    borderLayer.frame = CGRect(x: 0, y: bounds.size.height - borderLayer.borderWidth, width: bounds.size.width, height: bounds.size.height)
  }
  
}

final class UserTableViewCell: UITableViewCell {
  
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: .value1, reuseIdentifier: reuseIdentifier)
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
}

final class RankingTableViewCell: UITableViewCell {

  private let rankImageView = UIImageView()
  private let horizontalStackView = UIStackView()
  private let leftStackView = UIStackView()
  private let rightStackView = UIStackView()
  private let userLabel = UILabel()
  private let leftDetailLabel = UILabel()
  private let rightDetailLabel = UILabel()
  private let caloriesLabel = UILabel()
  
  var viewModel: RankingCellViewModel? {
    didSet {
      rankImageView.image = viewModel?.rankImage
      userLabel.text = viewModel?.username
      leftDetailLabel.text = viewModel?.updatedAtText
      rightDetailLabel.text = viewModel?.averageCaloriesText
      
      if let calories = viewModel?.activeCalories {
        let calorieAttributes = [NSForegroundColorAttributeName: UIColor.skBrown, NSFontAttributeName: UIFont.systemFont(ofSize: 28, weight: UIFontWeightHeavy)]
        let kiloAttributes = [NSForegroundColorAttributeName: UIColor.skBrown, NSFontAttributeName: UIFont.systemFont(ofSize: 12, weight: UIFontWeightHeavy)]
        let caloriesString = NSMutableAttributedString(string: "\(calories)", attributes: calorieAttributes)
        let kiloString = NSMutableAttributedString(string: " kCal", attributes: kiloAttributes)
        
        let combination = NSMutableAttributedString()
        combination.append(caloriesString)
        combination.append(kiloString)
        
        caloriesLabel.attributedText = combination
      }
      
      if let isCurrentUser = viewModel?.isCurrentUser {
        userLabel.textColor = isCurrentUser ? .skGreen : .skBlack
      }
    }
  }
  
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    contentView.addSubview(rankImageView)
    contentView.addSubview(horizontalStackView)
   
    horizontalStackView.addArrangedSubview(leftStackView)
    horizontalStackView.addArrangedSubview(rightStackView)
    
    leftStackView.addArrangedSubview(userLabel)
    leftStackView.addArrangedSubview(leftDetailLabel)
    rightStackView.addArrangedSubview(caloriesLabel)
    rightStackView.addArrangedSubview(rightDetailLabel)
    
    rankImageView.contentMode = .scaleAspectFit
    
    horizontalStackView.alignment = .center
    horizontalStackView.axis = .horizontal
    horizontalStackView.spacing = 10
    horizontalStackView.distribution = .fillEqually
    
    leftStackView.axis = .vertical
    
    rightStackView.axis = .vertical
    
    userLabel.textFont = UIFont.systemFont(ofSize: 28, weight: UIFontWeightHeavy)
    userLabel.fontColor = .skBlack
    userLabel.adjustsFontSizeToFitWidth = true
    
    leftDetailLabel.textFont = .skDetail
    leftDetailLabel.textColor = .darkGray
    
    caloriesLabel.textFont = UIFont.systemFont(ofSize: 28, weight: UIFontWeightHeavy)
    caloriesLabel.fontColor = .skBrown
    caloriesLabel.adjustsFontSizeToFitWidth = true
    
    rightDetailLabel.textFont = .skDetail
    rightDetailLabel.textColor = .darkGray
    
    setupConstraints()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func setupConstraints() {
    rankImageView.translatesAutoresizingMaskIntoConstraints = false
    rankImageView.widthAnchor.constraint(lessThanOrEqualToConstant: 60).isActive = true
    rankImageView.widthAnchor.constraint(equalTo: rankImageView.heightAnchor).isActive = true
    rankImageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
    rankImageView.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
    rankImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5).isActive = true

    horizontalStackView.translatesAutoresizingMaskIntoConstraints = false
    horizontalStackView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
    horizontalStackView.leftAnchor.constraint(equalTo: rankImageView.rightAnchor, constant: 10).isActive = true
    horizontalStackView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -10).isActive = true
    horizontalStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5).isActive = true
  }
  
}
