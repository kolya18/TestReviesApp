//
//  ReviewFooterCell.swift
//  Test
//
//  Created by Николай Мартынов on 24.06.2025.
//

import UIKit
// Нижняя ячейка таблицы используемая для отображения количества отзывов (в качестве футера)
final class ReviewFooterCell: UITableViewCell {
    /// Метка для отображения текста в футере
    let label = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        ///Стиль текста
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16)
        label.textColor = .secondaryLabel 
        ///Добавление метки в конкретную область ячейки
        contentView.addSubview(label)
    }
    ///Метод для размещения подвидов внутри ячейки
    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = contentView.bounds
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
