//
//  Filter.swift
//  Instafilter
//
//  Created by Наташа Спиридонова on 29.08.2025.
//

import Foundation
import CoreImage

struct FilterInfo: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let displayName: String
    let filter: CIFilter
    let category: String
    let parameters: [FilterParameter]
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    
    static func == (lhs:FilterInfo, rhs: FilterInfo) -> Bool {
        lhs.name == rhs.name
    }
}

struct FilterParameter: Identifiable {
    let id = UUID()
    let key: String
    let title: String
    let defaultValue: Double
    let range: ClosedRange<Double>
    let step: Double
    var currentValue: Double
    
    init(key: String, title: String, defaultValue: Double, range: ClosedRange<Double>, step: Double = 0.01) {
        self.key = key
        self.title = title
        self.defaultValue = defaultValue
        self.range = range
        self.step = step
        self.currentValue = defaultValue
    }
}

enum FilterCategory: String, CaseIterable {
    case color = "Цвет"
    case distortion = "Искажения"
    case stylize = "Стилизация"
    case blur = "Размытие"
    case light = "Освещение"
    case other = "Другое"
    
    var icon: String {
        switch self {
        case .color: return "paintpalette"
        case .distortion: return "warp.and.dots"
        case .stylize: return "paintbrush"
        case .blur: return "camera.filters"
        case .light: return "lightbulb"
        case .other: return "ellipsis"
        }
    }
}
