//
//  UIHelpers.swift
//  MarvelComic
//
//  Created by Mitchell Clay on 3/11/22.
//

import Foundation

enum PreviewHelper {
    static func isPreviewMode() -> Bool {
        return ProcessInfo
            .processInfo
            .environment["XCODE_RUNNING_FOR_PREVIEWS"] ?? "0" == "1" ? true : false
    }
}
