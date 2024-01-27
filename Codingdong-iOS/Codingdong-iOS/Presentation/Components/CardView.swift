//
//  CardView.swift
//  Codingdong-iOS
//
//  Created by Joy on 11/7/23.
//

import UIKit
import SnapKit

// MARK: - UIView
final class CardView: UIView {
    
    private var model: CardViewModel?
    
    private let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.gs10.cgColor
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
       let label = UILabel()
        label.font = FontManager.title1()
        label.textColor = .white
        return label
    }()
    
    private let separator: UIView = {
       let view = UIView()
        view.backgroundColor = .gs30
        return view
    }()
    
    private lazy var contentLabel: UILabel = {
       let label = UILabel()
        label.font = FontManager.body()
        label.textColor = .white
        label.numberOfLines = 0
        label.lineBreakMode = .byCharWrapping
        return label
    }()
        
    private lazy var conceptImageView: UIImageView = {
       let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.isAccessibilityElement = false
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
        accessibilityElements = [titleLabel, contentLabel]
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    public func setupView() {
        addSubview(containerView)
        [titleLabel, separator, contentLabel, conceptImageView].forEach { containerView.addSubview($0) }
        
        [containerView, titleLabel, separator, contentLabel, conceptImageView].forEach{ $0.translatesAutoresizingMaskIntoConstraints = false }
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: self.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: Constants.Button.buttonPadding),
            containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -Constants.Button.buttonPadding),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            titleLabel.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: Constants.Card.cardPadding),
            
            separator.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Constants.Card.cardPadding),
            separator.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: Constants.Card.cardPadding),
            separator.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -Constants.Card.cardPadding),
            separator.heightAnchor.constraint(equalToConstant: 1),
            
            contentLabel.topAnchor.constraint(equalTo: separator.bottomAnchor, constant: 20),
            contentLabel.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: Constants.Card.cardPadding),
            contentLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -Constants.Card.cardPadding),
            
            conceptImageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -76),
            conceptImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            conceptImageView.widthAnchor.constraint(equalToConstant: Constants.Card.cardSize),
            conceptImageView.heightAnchor.constraint(equalToConstant: Constants.Card.cardSize)
        ])
    }
}

// MARK: - ViewModel
struct CardViewModel {
    var title: String?
    var content: String?
    var cardImage: String?
    
    public init(title: String?,
                content: String?,
                cardImage: String?) {
        self.title = title
        self.content = content
        self.cardImage = cardImage
    }
}

// MARK: - Extension
extension CardView {
    public func config(model: CardViewModel) {
        self.model = model
        self.titleLabel.text = model.title
        self.contentLabel.text = model.content
        self.conceptImageView.image = UIImage(named: model.cardImage ?? "")
    }
}
