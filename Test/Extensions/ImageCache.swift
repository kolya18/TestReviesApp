//
//  ImageCache.swift
//  Test
//
//  Created by Николай Мартынов on 25.06.2025.
//
import UIKit
///Кэширование на диск
final class ImageCache {
    ///Синглтон для общего доступа к кешу изображений
    static let shared = ImageCache()
    ///NSCache для хранения изображений в оперативной памяти с ключом NSURL
    private let cache = NSCache<NSURL, UIImage>()
    ///FileManager для работы с файловой системой
    private let fileManager = FileManager.default
    /// Приватный конструктор, чтобы избежать создания других экземпляров класса
    private init() {}
    ///Метод возвращает URL файла изображения в директории кэша на устройстве
    private func cachedImageURL(for url: URL) -> URL {
        ///Последний компонент пути URL как имя файла
        let filename = url.lastPathComponent
        ///Путь к системной папке кэша для текущего пользователя
        let caches = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        ///Полный путь к файлу в кэше
        return caches.appendingPathComponent(filename)
    }
    ///Метод для получения изображения по URL с ипользованием кэша
    func image(for url: URL, completion: @escaping (UIImage?) -> Void) {
        ///Получить изображение из оперативной памяти
        if let image = cache.object(forKey: url as NSURL) {
            return completion(image)
        }
        ///Если в памяти нет, пробуем загрузить из файлового кэша
        let cachedURL = cachedImageURL(for: url)
        if let image = UIImage(contentsOfFile: cachedURL.path) {
            ///Если нашли на диске, кладем в память для быстрого доступа в будущем
            cache.setObject(image, forKey: url as NSURL)
            return completion(image)
        }
        ///Если изображения нет ни в памяти, ни на диске тогда загружаем из сети асинхронно
        DispatchQueue.global(qos: .background).async {
            guard let data = try? Data(contentsOf: url),
                  let image = UIImage(data: data) else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            ///Сохраняем загруженные данные в файловый кэш
            try? data.write(to: cachedURL)
            ///Кэшируем изображение в памяти
            self.cache.setObject(image, forKey: url as NSURL)
            ///Возвращаем изображение в главном потоке для обновления UI
            DispatchQueue.main.async {
                completion(image)
            }
        }
    }
}
