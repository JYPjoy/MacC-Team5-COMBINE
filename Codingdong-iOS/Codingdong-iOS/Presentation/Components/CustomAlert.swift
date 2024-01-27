//
//  CustomAlert.swift
//  Codingdong-iOS
//
//  Created by BAE on 2023/11/28.
//

import UIKit
import Log

final class CustomAlert:UIViewController, ConfigUI {
    
    private let alertContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .gs80
        view.layer.cornerRadius = 14
        return view
    }()
    
    private let alertTitle: UILabel = {
        let label = UILabel()
        label.font = FontManager.callout()
        label.textColor = .white
        label.text = "메인 화면으로"
        label.textAlignment = .center
        return label
    }()
    
    private let alertContent: UILabel = {
        let label = UILabel()
        label.font = FontManager.caption2()
        label.textColor = .white
        label.text = "동화를 나가시면 다시 처음부터 시작해요!"
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        return label
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("남기", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = FontManager.caption2()
        button.backgroundColor = .clear
        return button
    }()
    
    private lazy var cancelLabel: UILabel = {
        let label = UILabel()
        label.isUserInteractionEnabled = true
        label.font = FontManager.caption2()
        label.textColor = .white
        label.textAlignment = .center
        label.text = "남기"
        label.tag = AlertButtonType.stay.rawValue
        let labelTap = UITapGestureRecognizer(target: self, action: #selector(buttonTapped))
        label.addGestureRecognizer(labelTap)
        return label
    }()
    
    private lazy var applyLabel: UILabel = {
        let label = UILabel()
        label.isUserInteractionEnabled = true
        label.font = FontManager.caption2()
        label.textColor = .secondary1
        label.textAlignment = .center
        label.text = "돌아가기"
        label.tag = AlertButtonType.leave.rawValue
        let labelTap = UITapGestureRecognizer(target: self, action: #selector(buttonTapped))
        label.addGestureRecognizer(labelTap)
        return label
    }()
    
    private let horizontalLine: UIView = {
        let view = UIView()
        view.backgroundColor = .white.withAlphaComponent(0.15)
        return view
    }()
    
    private let verticalLine: UIView = {
        let view = UIView()
        view.backgroundColor = .white.withAlphaComponent(0.15)
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupAccessibility()
        addComponents()
        setConstraints()
        setupNavigationBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    func setConstraints() {
        [alertContainer, alertTitle, alertContent, horizontalLine, verticalLine, cancelLabel, applyLabel].forEach{ $0.translatesAutoresizingMaskIntoConstraints = false }
        
        NSLayoutConstraint.activate([
            alertContainer.topAnchor.constraint(equalTo: view.topAnchor, constant: 340),
            alertContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -340),
            alertContainer.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 62),
            alertContainer.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -62),
            
            alertTitle.topAnchor.constraint(equalTo: alertContainer.topAnchor, constant: 20),
            alertTitle.leftAnchor.constraint(equalTo: alertContainer.leftAnchor, constant: 16),
            alertTitle.rightAnchor.constraint(equalTo: alertContainer.rightAnchor, constant: -16),
            
            alertContent.topAnchor.constraint(equalTo: alertContainer.topAnchor),
            alertContent.bottomAnchor.constraint(equalTo: alertContainer.bottomAnchor, constant: -16),
            alertContent.leftAnchor.constraint(equalTo: alertContainer.leftAnchor, constant: 16),
            alertContent.rightAnchor.constraint(equalTo: alertContainer.rightAnchor, constant: -16),

            horizontalLine.bottomAnchor.constraint(equalTo:  alertContainer.bottomAnchor, constant: -44),
            horizontalLine.heightAnchor.constraint(equalToConstant: 0.33),
            horizontalLine.leftAnchor.constraint(equalTo: alertContainer.leftAnchor),
            horizontalLine.rightAnchor.constraint(equalTo:  alertContainer.rightAnchor),
            
            verticalLine.topAnchor.constraint(equalTo: horizontalLine.bottomAnchor),
            verticalLine.widthAnchor.constraint(equalToConstant: 0.33),
            verticalLine.centerXAnchor.constraint(equalTo: alertContainer.centerXAnchor),
            verticalLine.bottomAnchor.constraint(equalTo: alertContainer.bottomAnchor),
            
            cancelLabel.topAnchor.constraint(equalTo: horizontalLine.bottomAnchor, constant: 10),
            cancelLabel.leftAnchor.constraint(equalTo: alertContainer.leftAnchor, constant: 49),
            
            applyLabel.topAnchor.constraint(equalTo: horizontalLine.bottomAnchor, constant: 10),
            applyLabel.rightAnchor.constraint(equalTo: alertContainer.rightAnchor, constant: -33)
        ])
    }
    
    func setupAccessibility() {
        
    }
    
    func addComponents() {
        view.addSubview(alertContainer)
        [alertTitle, alertContent, horizontalLine, verticalLine, cancelLabel, applyLabel].forEach { alertContainer.addSubview($0) }
    }
    
    func setupNavigationBar() {
        navigationController?.isNavigationBarHidden = true
    }
}

extension CustomAlert {
    enum AlertButtonType: Int {
        case stay = 0
        case leave = 1
    }
    
    @objc
    func buttonTapped(_ sender: UITapGestureRecognizer) {
        if let type = AlertButtonType(rawValue: sender.view?.tag ?? 0) {
            switch type {
            case .stay:
                self.navigationController?.popViewController(animated: false)
            case .leave:
                self.navigationController?.popToRootViewController(animated: false)
            }
        }
    }
}

