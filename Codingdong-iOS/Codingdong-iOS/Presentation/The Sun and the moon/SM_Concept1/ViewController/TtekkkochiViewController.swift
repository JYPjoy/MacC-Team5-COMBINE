//
//  TtekkkochiViewController.swift
//  Codingdong-iOS
//
//  Created by Joy on 10/20/23.
//

import UIKit
import Combine
import Log
import CoreMotion

final class TtekkkochiViewController: UIViewController, ConfigUI {
    var viewModel = TtekkkochiViewModel()
    private var cancellable = Set<AnyCancellable>()
    private var blockIndex: Int = 0
    private var hapticManager: HapticManager?
    private let motionManager = CMMotionManager()
    private var motionCount: Int = 0
    
    // MARK: - Components
    private let naviLine: UIView = {
        let view = UIView()
        view.backgroundColor = .white.withAlphaComponent(0.15)
        return view
    }()
    
    private let navigationTitle: UILabel = {
        let label = UILabel()
        label.text = "호랑이를 마주친 엄마"
        label.font = FontManager.navigationtitle()
        label.textColor = .gs20
        return label
    }()
    
    private lazy var leftBarButtonItem: UIBarButtonItem = {
        let leftBarButton = UIBarButtonItem(
            image: UIImage(systemName: "books.vertical"),
            style: .plain,
            target: self,
            action: #selector(popThisView)
        )
        return leftBarButton
    }()
    
    private let titleLabel: UILabel = {
       let label = UILabel()
        label.text = """
        화면 중앙에 다섯 개의 떡들로 이루어진 떡꼬치가 있어.
        
        핸드폰 화면이 하늘을 바라보도록 아주 사알짝 딱 한 번만 뒤로 젖혀볼까?
        """
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = FontManager.body()
        label.textColor = .gs10
        label.numberOfLines = 0
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private let stickView: UIView = {
       let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 5
        return view
    }()
    
    private lazy var ttekkkochiCollectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        view.register(TtekkkochiCollectionViewCell.self, forCellWithReuseIdentifier: TtekkkochiCollectionViewCell.identifier)
        view.isAccessibilityElement = false
        view.backgroundColor = .clear
        //view.backgroundColor = .systemRed
        view.dataSource = self
        view.delegate = self
        return view
    }()
    
    private let nextButton = CommonButton()
    private lazy var settingButtonViewModel = CommonbuttonModel(title: "꼬치를 준다", font: FontManager.textbutton(), titleColor: .primary1, backgroundColor: .primary2) {[weak self] in
       self?.viewModel.selectItem()
    }

    private let ttekkkochiCollectionViewElement: UIAccessibilityElement = {
        let element = UIAccessibilityElement(accessibilityContainer: TtekkkochiViewController.self)
        return element
    }()
    
    // MARK: - View init
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .gs90
        setupNavigationBar()
        addComponents()
        setConstraints()
        nextButton.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        binding()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupAccessibility()
    }
    
    func setupNavigationBar() {
        view.addSubview(naviLine)
        naviLine.snp.makeConstraints {
            $0.top.equalToSuperview().offset(106)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(0.33)
        }
        self.navigationController?.navigationBar.tintColor = .gs20
        self.navigationItem.titleView = self.navigationTitle
        self.navigationItem.leftBarButtonItem = self.leftBarButtonItem
        navigationController?.navigationBar.accessibilityElementsHidden = true
    }
    
    func addComponents() {
        [titleLabel, ttekkkochiCollectionView, nextButton, stickView].forEach { view.addSubview($0) }
    }
    
    func setConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(naviLine.snp.bottom).offset(16)
            $0.left.right.equalToSuperview().inset(16)
        }
        
        ttekkkochiCollectionView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(40)
            $0.left.right.equalToSuperview().inset(95)
            $0.bottom.equalToSuperview().offset(-100)
        }
        
        stickView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(28)
            $0.left.right.equalToSuperview().inset(191)
            $0.bottom.equalToSuperview().offset(-90)
        }
        
        self.view.sendSubviewToBack(stickView)
        
        nextButton.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(Constants.Button.buttonPadding)
            $0.bottom.equalToSuperview().inset(Constants.Button.buttonPadding * 2)
            $0.height.equalTo(72)
        }
    }
    
    func setupAccessibility() {
        let leftBarButtonElement = setupLeftBackButtonItemAccessibility(label: "내 책장")
        ttekkkochiCollectionViewElement.accessibilityFrameInContainerSpace = ttekkkochiCollectionView.frame
        view.accessibilityElements = [titleLabel, ttekkkochiCollectionViewElement, nextButton, leftBarButtonElement]
    }
    
    func binding() {
        initializeView()
        self.viewModel.route
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] nextView in
                self?.navigationController?.pushViewController(nextView, animated: false)
            })
            .store(in: &cancellable)
            
        startRecordingDeviceMotion() // 조건 걸어서 1번만 실행되도록 해야 함
    }
    
    func initializeView() {
        (0...4).forEach {
            answerBlocks[$0].isShowing = false
            selectBlocks[$0].isAccessible = true
            selectBlocks[$0].isShowing = true
            ttekkkochiCollectionView.reloadData()
        }
    }
    
    @objc
    func popThisView() {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { self.ttekkkochiCollectionView.reloadData()
        }
        
        self.navigationController?.pushViewController(CustomAlert(), animated: false)
    }
}

// MARK: - Extension
extension TtekkkochiViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return answerBlocks.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TtekkkochiCollectionViewCell.identifier, for: indexPath) as? TtekkkochiCollectionViewCell else { fatalError() }
        cell.block = answerBlocks[indexPath.row]
        return cell
    }
}

extension TtekkkochiViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = collectionView.frame.size.width
        return CGSize(width: cellWidth, height: cellWidth/3.2)
    }
}

extension TtekkkochiViewController {
    func startRecordingDeviceMotion() {
        // Device motion을 수집 가능한지 확인
        guard motionManager.isDeviceMotionAvailable else {
            Log.e("Device motion data is not available")
            return
        }
        
        // 모션 갱신 주기 설정 (10Hz)
        motionManager.deviceMotionUpdateInterval = 0.1
        // Device motion 업데이트 받기 시작
        motionManager.startDeviceMotionUpdates(to: .main) { (deviceMotion: CMDeviceMotion?, error: Error?) in
            guard let data = deviceMotion, error == nil else {
                print("Failed to get device motion data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            // 필요한 센서값 불러오기
            let acceleration = data.userAcceleration
            let shakeThreshold = 0.5  // 흔들기 인식 강도
            if acceleration.x >= shakeThreshold || acceleration.y >= shakeThreshold || acceleration.z >= shakeThreshold {
                
                if acceleration.y > 1 && acceleration.z < 0 {
                    (0...2).forEach { answerBlocks[$0].isShowing = true }
                    DispatchQueue.global().async { SoundManager.shared.playSound(sound: .bell) }
                    self.ttekkkochiCollectionView.reloadData()
                    
                    self.titleLabel.text = """
                       잘했어! 이번에는 아니면을 채우기 위해 화면을 좌우로 흔들어봐!
                       """
                    self.ttekkkochiCollectionViewElement.accessibilityLabel = "만약에\n떡 하나 주면\n안 잡아먹는다\n!"
//                    
//                    if acceleration.x > 0 || acceleration.x < 0 {
//                        (3...4).forEach { answerBlocks[$0].isShowing = true }
//                        DispatchQueue.global().async { SoundManager.shared.playSound(sound: .bell) }
//                        self.ttekkkochiCollectionView.reloadData()
//                        self.ttekkkochiCollectionViewElement.accessibilityLabel = "만약에\n떡 하나 주면\n안 잡아먹는다\n아니면\n잡아먹는다\n잘 만들었는데? 이제 호랑이에게 주자!"
//                    }
                }

            }
            self.motionManager.stopAccelerometerUpdates()
        }
    }
    
    func stopRecordingDeviceMotion() {
        motionManager.stopDeviceMotionUpdates()
    }
}
