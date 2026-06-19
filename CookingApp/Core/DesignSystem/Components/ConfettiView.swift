//
//  ConfettiView.swift
//  CookingApp
//

import SwiftUI
import UIKit

struct ConfettiView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> ConfettiViewController {
        return ConfettiViewController()
    }
    
    func updateUIViewController(_ uiViewController: ConfettiViewController, context: Context) {}
}

class ConfettiViewController: UIViewController {
    private var emitter: CAEmitterLayer!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = false
        
        emitter = CAEmitterLayer()
        emitter.emitterShape = .line
        
        let colors: [UIColor] = [.systemRed, .systemBlue, .systemGreen, .systemYellow, .systemOrange, .systemPurple]
        
        let cells: [CAEmitterCell] = colors.map { color in
            let cell = CAEmitterCell()
            cell.birthRate = 15
            cell.lifetime = 10.0
            cell.velocity = 200
            cell.velocityRange = 100
            cell.yAcceleration = 200
            cell.emissionLongitude = .pi 
            cell.emissionRange = .pi / 4
            cell.spin = 2
            cell.spinRange = 3
            cell.scaleRange = 0.2
            cell.scale = 0.3
            
            let size = CGSize(width: 15, height: 15)
            UIGraphicsBeginImageContext(size)
            let context = UIGraphicsGetCurrentContext()
            context?.setFillColor(color.cgColor)
            context?.fill(CGRect(origin: .zero, size: size))
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            cell.contents = image?.cgImage
            return cell
        }
        
        emitter.emitterCells = cells
        view.layer.addSublayer(emitter)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        emitter.emitterPosition = CGPoint(x: view.bounds.midX, y: -50)
        emitter.emitterSize = CGSize(width: view.bounds.width, height: 1)
    }
}
