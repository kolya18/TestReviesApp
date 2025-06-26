//
//  CustomLoadingIndicator.swift
//  Test
//
//  Created by Николай Мартынов on 25.06.2025.
//
///Кастомный индикатоор загрузки
import UIKit

final class CustomLoadingIndicator: UIView {
    // MARK: - Свойства
    private let spinnerLayer = CAShapeLayer()
    private let animationKey = "rotationAnimation"
    
    // MARK: - Инициализация
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayer()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayer()
    }
    // MARK: - Настройка графики
    private func setupLayer() {
        let radius = min(bounds.width, bounds.height) / 2 * 0.8
        let centerPoint = CGPoint(x: bounds.midX, y: bounds.midY)

        let circlePath = UIBezierPath(
            arcCenter: centerPoint,
            radius: radius,
            startAngle: 0,
            endAngle: CGFloat.pi * 1.5, //270 градусов
            clockwise: true
        )

        spinnerLayer.path = circlePath.cgPath
        spinnerLayer.strokeColor = UIColor.systemBlue.cgColor
        spinnerLayer.fillColor = UIColor.clear.cgColor
        spinnerLayer.lineWidth = 4
        spinnerLayer.lineCap = .round

        layer.addSublayer(spinnerLayer)
    }
    
    // MARK: - Управление анимацией
    func startAnimating() {
        if spinnerLayer.animation(forKey: animationKey) != nil { return }

        let rotation = CABasicAnimation(keyPath: "transform.rotation")
        rotation.fromValue = 0
        rotation.toValue = CGFloat.pi * 2
        rotation.duration = 1
        rotation.repeatCount = .infinity

        spinnerLayer.add(rotation, forKey: animationKey)
        isHidden = false
    }

    func stopAnimating() {
        spinnerLayer.removeAnimation(forKey: animationKey)
        isHidden = true
    }
}
