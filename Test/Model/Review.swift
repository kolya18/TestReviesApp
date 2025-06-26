import Foundation

/// Модель отзыва.
struct Review: Decodable {

    /// Текст отзыва.
    let text: String
    /// Время создания отзыва.
    let created: String
    ///Имя
    let firstName: String
    ///Фамилия
    let lastName: String
    ///Рейтинг
    let rating: Int
    ///Аватар
    let avatarURL: URL?
    ///Фотографии
    let photoURLs: [URL]?
    ///Ключи для декодирования из JSON в свойства модели
    enum CodingKeys: String, CodingKey {
            case text
            case created
            case firstName = "first_name"
            case lastName = "last_name"
            case rating
            case avatarURL = "avatar_url"
            case photoURLs = "photo_urls"
        }
}
