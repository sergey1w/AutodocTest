//
//  ImageProviderProtocol.swift
//  AutodocTest
//
//  Created by sergey on 01.03.2025.
//

import UIKit.UIImage

protocol ImageProviderProtocol: AnyObject {
    func getImage(url: URL) async -> UIImage?
}
