//
//  ReviewFooterCellConfig.swift
//  Test
//
//  Created by Николай Мартынов on 24.06.2025.
//
import UIKit
//Конфигурация ячейки для отображения футера с количеством отзывов в таблице
//реализует протокол TableCellConfig для настройки и определения высоты ячейки.
struct ReviewFooterCellConfig: TableCellConfig {
    ///Идентификатор повторного использования ячейки, основанный на имени структуры
    static let reuseId = String(describing: ReviewFooterCellConfig.self)
    ///Количество отзывов
    let count: Int
    ///Обновляет содержимое переданной ячейки на основе текущей конфигурации
    func update(cell: UITableViewCell) {
        guard let cell = cell as? ReviewFooterCell else { return }
        cell.label.text = "\(count) отзывов"
    }
    ///Вычисляет высоту ячейки для заданного размера контейнера
    func height(with size: CGSize) -> CGFloat {
        return 60
    }
}
