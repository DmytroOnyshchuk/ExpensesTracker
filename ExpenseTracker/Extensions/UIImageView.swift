//
//  UIImageView.swift
//  OroveraAppClip
//
//  Created by Dmytro Onyshchuk on 08.12.2022.
//  Copyright © 2022 PeaksCircle. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
    func rotate(_ toValue: CGFloat, duration: CFTimeInterval = 0.2) {
        UIView.animate(withDuration: duration, animations: {
            self.transform = CGAffineTransform(rotationAngle: toValue)
        })
    }

    func downloadImageAndSet(from URLString: String, handler: ((_ status: Bool) -> Void)? = nil) {
        guard let url = URL(string: URLString) else {
            DispatchQueue.main.async {
                handler?(false)
            }
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard error == nil else {
                DispatchQueue.main.async {
                    handler?(false)
                }
                return
            }

            guard let httpURLResponse = response as? HTTPURLResponse,
                  httpURLResponse.statusCode == 200,
                  let data
            else {
                DispatchQueue.main.async {
                    handler?(false)
                }
                return
            }

            let image = UIImage(data: data)
            DispatchQueue.main.async {
                self.image = image
                handler?(true)
            }
        }.resume()
    }
}
