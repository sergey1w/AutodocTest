//
//  ImageStorageProtocol.swift
//  AutodocTest
//
//  Created by sergey on 01.03.2025.
//

import UIKit.UIImage

protocol ImageStorageProtocol {
    func getImage(name: String) async throws -> UIImage?
    func saveImage(image: UIImage, withName name: String) async throws
}
