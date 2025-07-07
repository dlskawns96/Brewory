//
//  FileManager+Extension.swift
//  Brewory
//
//  Created by Nam Jun Lee on 5/18/25.
//

import Foundation

extension FileManager {
    static var documentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
}
