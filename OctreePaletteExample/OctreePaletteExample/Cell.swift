//
//  Cell.swift
//  OctreePaletteExample
//
//  Created by Victor Ragojos on 11/16/20.
//

import UIKit
import OctreePalette

class Cell: UICollectionViewCell {
    // MARK: - Internal Properties
    private lazy var bgView: UIView = {
        let bgView: UIView = UIView()
        bgView.backgroundColor = .systemBackground
        bgView.translatesAutoresizingMaskIntoConstraints = false
        return bgView
    }()
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 4
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // MARK: - Life Cycles
    override init(frame: CGRect) {
        super.init(frame: .zero)
        self.contentView.addSubview(bgView)
        self.contentView.addSubview(imageView)
        self.contentView.addSubview(stackView)
        self.setupAnchors()
    }
    
    func configure(image: UIImage) {
        OctreePalette().getColorTheme(from: image) { (theme) in
            DispatchQueue.main.async {
                
                UIView.animate(withDuration: 0.25) {
                    self.imageView.image = image
                    self.setupColors(theme: theme)
                }
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Helper Functions
extension Cell {
    private func setupAnchors() {
        let bgViewConstraints: [NSLayoutConstraint] = [
            bgView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor),
            bgView.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor),
            bgView.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor),
            bgView.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor)
        ]
        NSLayoutConstraint.activate(bgViewConstraints)
        
        let imageViewConstraints: [NSLayoutConstraint] = [
            imageView.trailingAnchor.constraint(equalTo: bgView.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: bgView.topAnchor, constant: 20),
            imageView.bottomAnchor.constraint(equalTo: bgView.bottomAnchor, constant: -20),
            imageView.leadingAnchor.constraint(equalTo: bgView.leadingAnchor, constant: 20)
        ]
        NSLayoutConstraint.activate(imageViewConstraints)
        
        let stackViewConstraints: [NSLayoutConstraint] = [
            stackView.widthAnchor.constraint(equalToConstant: 30),
            stackView.topAnchor.constraint(equalTo: imageView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: imageView.trailingAnchor)
        ]
        NSLayoutConstraint.activate(stackViewConstraints)
    }
    
    private func setupColors(theme: ColorTheme) {
        UIView.animate(withDuration: 0.25) {
            self.bgView.backgroundColor = theme.background.uiColor
            self.contentView.backgroundColor = theme.background.uiColor
        }
        
        for i in 0 ... 3 {
            let colorView: UIView
            switch i {
            case 0:
                colorView = createColorSquare(with: theme.background, textColor: theme.primary.uiColor)
                break
            case 1:
                colorView = createColorSquare(with: theme.primary, textColor: theme.primary.uiColor)
                break
            case 2:
                colorView = createColorSquare(with: theme.secondary, textColor: theme.primary.uiColor)
                break
            default:
                colorView = createColorSquare(with: theme.tertiary, textColor: theme.primary.uiColor)
                break
            }
            self.stackView.addArrangedSubview(colorView)
            let colorViewConstraints: [NSLayoutConstraint] = [
                colorView.heightAnchor.constraint(equalTo: self.stackView.heightAnchor, multiplier: 0.25)
            ]
            NSLayoutConstraint.activate(colorViewConstraints)
        }
    }
    
    private func createColorSquare(with color: OctreeColor, textColor: UIColor) -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let colorView = UIView()
        colorView.backgroundColor = color.uiColor
        colorView.translatesAutoresizingMaskIntoConstraints = false
        
        let labelView = UILabel()
        labelView.text = color.HexCode
        labelView.textColor = textColor
        labelView.translatesAutoresizingMaskIntoConstraints = false
        labelView.font = UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: 14, weight: .bold))
        
        view.addSubview(colorView)
        view.addSubview(labelView)
        
        NSLayoutConstraint.activate([
            colorView.topAnchor.constraint(equalTo: view.topAnchor),
            colorView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            colorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            colorView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            labelView.centerYAnchor.constraint(equalTo: colorView.centerYAnchor),
            labelView.leadingAnchor.constraint(equalTo: colorView.trailingAnchor, constant: 5)
        ])
        
        return view
    }
}
