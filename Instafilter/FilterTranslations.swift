//
//  FilterTranslations.swift
//  Instafilter
//
//  Created by Наташа Спиридонова on 29.08.2025.
//

import Foundation

/// Класс для управления переводами названий фильтров
final class FilterTranslations {
    
    /// Получает русское название фильтра
    static func getRussianName(for filterName: String) -> String {
        let mapping: [String: String] = [
            // Популярные фильтры
            "CISepiaTone": "Сепия",
            "CIGaussianBlur": "Размытие по Гауссу",
            "CIPixellate": "Пикселизация",
            "CIVignette": "Виньетка",
            "CIUnsharpMask": "Нерезкая маска",
            "CIEdges": "Края",
            "CICrystallize": "Кристаллизация",
            
            // Цветовые фильтры
            "CIColorControls": "Цветовые настройки",
            "CIExposureAdjust": "Коррекция экспозиции",
            "CIHueAdjust": "Коррекция оттенка",
            "CISaturationAdjust": "Коррекция насыщенности",
            "CIVibrance": "Яркость",
            "CIColorMonochrome": "Монохром",
            "CIColorPosterize": "Постеризация",
            "CIColorInvert": "Инверсия цвета",
            "CIGammaAdjust": "Коррекция гаммы",
            
            // Эффекты искажения
            "CIBumpDistortion": "Выпуклость",
            "CITwirlDistortion": "Завихрение",
            "CIPinchDistortion": "Сжатие",
            "CIHoleDistortion": "Дыра",
            "CIGlassDistortion": "Стекло",
            "CITorusLensDistortion": "Тороидальная линза",
            
            // Размытие
            "CIMotionBlur": "Размытие движения",
            "CIZoomBlur": "Размытие зума",
            "CIBokehBlur": "Боке",
            "CIDiscBlur": "Дисковое размытие",
            
            // Стилизация
            "CIPhotoEffectMono": "Монохром",
            "CIPhotoEffectChrome": "Хром",
            "CIPhotoEffectFade": "Выцветание",
            "CIPhotoEffectInstant": "Инстант",
            "CIPhotoEffectNoir": "Нуар",
            "CIPhotoEffectProcess": "Процесс",
            "CIPhotoEffectTonal": "Тональный",
            "CIPhotoEffectTransfer": "Перенос",
            
            // Художественные эффекты
            "CIPointillize": "Пуантилизм",
            "CILineOverlay": "Линии",
            "CIGloom": "Свечение",
            "CIBloom": "Цветение",
            "CIKaleidoscope": "Калейдоскоп",
            "CITriangleKaleidoscope": "Треугольный калейдоскоп",
            
            // Освещение
            "CISpotLight": "Прожектор",
            "CISunbeams": "Солнечные лучи",
            "CILightTunnel": "Световой туннель",
            "CIStarShineGenerator": "Звездный блеск",
            
            // Генераторы текстур
            "CICheckerboardGenerator": "Шахматная доска",
            "CIStripesGenerator": "Полосы",
            "CIRandomGenerator": "Случайная текстура",
            "CIConstantColorGenerator": "Постоянный цвет"
        ]
        
        if let russianName = mapping[filterName] {
            return russianName
        } else {
            return formatFilterName(filterName)
        }
    }
    
    /// Форматирует название фильтра, убирая префикс CI и переводя ключевые слова
    private static func formatFilterName(_ filterName: String) -> String {
        let name = filterName.replacingOccurrences(of: "CI", with: "")
        let words = splitCamelCase(name)
        
        let translations: [String: String] = [
            "Blur": "Размытие",
            "Distortion": "Искажение",
            "Effect": "Эффект",
            "Filter": "Фильтр",
            "Generator": "Генератор",
            "Adjust": "Коррекция",
            "Color": "Цвет",
            "Light": "Свет",
            "Photo": "Фото",
            "Gaussian": "Гауссово",
            "Motion": "Движение",
            "Zoom": "Зум",
            "Disc": "Диск",
            "Bokeh": "Боке"
        ]
        
        let translatedWords = words.map { word in
            translations[word] ?? word
        }
        
        return translatedWords.joined(separator: " ")
    }
    
    /// Разбивает camelCase строку на отдельные слова
    private static func splitCamelCase(_ string: String) -> [String] {
        var words: [String] = []
        var currentWord = ""
        
        for character in string {
            if character.isUppercase && !currentWord.isEmpty {
                words.append(currentWord)
                currentWord = String(character)
            } else {
                currentWord.append(character)
            }
        }
        
        if !currentWord.isEmpty {
            words.append(currentWord)
        }
        
        return words
    }
}
