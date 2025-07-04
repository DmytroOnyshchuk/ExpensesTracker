//
//  UIImageView.swift
//  OroveraAppClip
//
//  Created by Dmytro Onyshchuk on 08.12.2022.
//  Copyright © 2022 PeaksCircle. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

extension UIImageView {
    
    func rotate(_ toValue: CGFloat, duration: CFTimeInterval = 0.2) {
        UIView.animate(withDuration: duration, animations: {
            self.transform = CGAffineTransform(rotationAngle: toValue)
        })
    }
    
    func downloadImageAndSet(from URLString: String, handler: ((_ status: Bool) -> Void)? = nil){
        guard let url = URL(string: URLString) else {
            DispatchQueue.main.async{
                handler?(false)
            }
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard error == nil else {
                DispatchQueue.main.async{
                    handler?(false)
                }
                return
            }
            
            guard let httpURLResponse = response as? HTTPURLResponse,
                  httpURLResponse.statusCode == 200,
                  let data = data else {
                DispatchQueue.main.async{
                    handler?(false)
                }
                return
            }
            
            let image = UIImage(data: data)
            DispatchQueue.main.async{
                self.image = image
                handler?(true)
            }
        }.resume()
    }
    
    func setImageKingfisher(_ url: String?, placeholder: UIImage? = nil, completion: ((UIImage?) -> Void)? = nil) {
        
        let noImage = UIImage(named: "ic_transparent_background_pattern")
        
        if let stringURL = url,
           !stringURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
           let finalURL = stringURL.toURL() {
            kf.indicatorType = .activity
            
            let options: KingfisherOptionsInfo = [
                .cacheOriginalImage,                     // Кэшируем оригинальное изображение
                .loadDiskFileSynchronously,              // Загружаем файл синхронно с диска
                .retryStrategy(DelayRetryStrategy(maxRetryCount: 5,
                                                  retryInterval: .seconds(1))),
                .transition(.fade(0.25))
            ]
            
            kf.setImage(with: finalURL, placeholder: placeholder ?? noImage, options: options) { [weak self] result in
                switch result {
                case .success(let value):
                    self?.image = value.image
                    completion?(value.image)
                case .failure(let error):
                    self?.image = placeholder
                    Logger.default.logMessage("Kingfisher error: \(error.localizedDescription)", category: "Kingfisher")
                    completion?(nil)
                }
            }
        }else{
            image = placeholder ?? noImage
            completion?(nil)
        }
        
    }
    
}
