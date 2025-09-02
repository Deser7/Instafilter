//
//  ContentView.swift
//  Instafilter
//
//  Created by Наташа Спиридонова on 27.08.2025.
//

import CoreImage
import CoreImage.CIFilterBuiltins
import PhotosUI
import StoreKit
import SwiftUI

struct ContentView: View {
    @State private var processedImage: Image?
    @State private var selectedItem: PhotosPickerItem?
    @State private var showingFilters = false
    
    @AppStorage("filterCount") var filterCount = 0
    @Environment(\.requestReview) var requestReview
    
    // Адаптивная система фильтров
    @State private var currentFilter: CIFilter = CIFilter.sepiaTone()
    @State private var currentFilterParameters: [String: Double] = [:]
    let context = CIContext()
    
    private var imageIsEmpty: Bool {
        selectedItem == nil
    }
    
    // Список всех доступных фильтров с их параметрами
    private static let allAvailableFilters: [FilterInfo] = {
        let bestFilters = [
            // Цветовые фильтры
            ("CISepiaTone", FilterCategory.color),
            ("CIColorControls", FilterCategory.color),
            ("CIExposureAdjust", FilterCategory.color),
            ("CIHueAdjust", FilterCategory.color),
            ("CISaturationAdjust", FilterCategory.color),
            ("CIVibrance", FilterCategory.color),
            ("CIColorMonochrome", FilterCategory.color),
            ("CIColorPosterize", FilterCategory.color),
            ("CIColorInvert", FilterCategory.color),
            ("CIGammaAdjust", FilterCategory.color),
            
            // Размытие
            ("CIGaussianBlur", FilterCategory.blur),
            ("CIMotionBlur", FilterCategory.blur),
            ("CIZoomBlur", FilterCategory.blur),
            ("CIBokehBlur", FilterCategory.blur),
            ("CIDiscBlur", FilterCategory.blur),
            
            // Искажения
            ("CIBumpDistortion", FilterCategory.distortion),
            ("CITwirlDistortion", FilterCategory.distortion),
            ("CIPinchDistortion", FilterCategory.distortion),
            ("CIHoleDistortion", FilterCategory.distortion),
            ("CIGlassDistortion", FilterCategory.distortion),
            ("CITorusLensDistortion", FilterCategory.distortion),
            
            // Стилизация
            ("CIPixellate", FilterCategory.stylize),
            ("CICrystallize", FilterCategory.stylize),
            ("CIEdges", FilterCategory.stylize),
            ("CIVignette", FilterCategory.stylize),
            ("CIUnsharpMask", FilterCategory.stylize),
            ("CIPhotoEffectMono", FilterCategory.stylize),
            ("CIPhotoEffectChrome", FilterCategory.stylize),
            ("CIPhotoEffectFade", FilterCategory.stylize),
            ("CIPhotoEffectInstant", FilterCategory.stylize),
            ("CIPhotoEffectNoir", FilterCategory.stylize),
            ("CIPhotoEffectProcess", FilterCategory.stylize),
            ("CIPhotoEffectTonal", FilterCategory.stylize),
            ("CIPhotoEffectTransfer", FilterCategory.stylize),
            
            // Художественные эффекты
            ("CIPointillize", FilterCategory.stylize),
            ("CILineOverlay", FilterCategory.stylize),
            ("CIGloom", FilterCategory.light),
            ("CIKaleidoscope", FilterCategory.stylize),
            ("CITriangleKaleidoscope", FilterCategory.stylize),
            
            // Освещение
            ("CISpotLight", FilterCategory.light),
            ("CISunbeams", FilterCategory.light),
            ("CILightTunnel", FilterCategory.light)
        ]
        
        return bestFilters.compactMap { (name, category) -> FilterInfo? in
            guard let filter = CIFilter(name: name),
                  filter.inputKeys.contains(kCIInputImageKey) else { return nil }
            
            let displayName = FilterTranslations.getRussianName(for: name)
            let parameters = Self.getFilterParameters(filter)
            
            return FilterInfo(
                name: name,
                displayName: displayName,
                filter: filter,
                category: category.rawValue,
                parameters: parameters
            )
        }.sorted { $0.displayName < $1.displayName }
    }()
    
    // Активные параметры для текущего фильтра
    private var activeFilterParameters: [FilterParameter] {
        guard let currentFilterInfo = Self.allAvailableFilters.first(where: { $0.name == currentFilter.name }) else {
            return []
        }
        
        return currentFilterInfo.parameters.map { parameter in
            var updatedParameter = parameter
            updatedParameter.currentValue = currentFilterParameters[parameter.key] ?? parameter.defaultValue
            return updatedParameter
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                // Выбор изображения
                PhotosPicker(selection: $selectedItem) {
                    if let processedImage {
                        processedImage
                            .resizable()
                            .scaledToFit()
                    } else {
                        ContentUnavailableView(
                            "Нет изображения",
                            systemImage: "photo.badge.plus",
                            description: Text("Нажмите, чтобы выбрать фото")
                        )
                    }
                }
                .buttonStyle(.plain)
                .onChange(of: selectedItem, loadImage)
                
                Spacer()
                
                // Адаптивные слайдеры для параметров фильтра
                if !activeFilterParameters.isEmpty {
                    VStack(spacing: 12) {
                        ForEach(activeFilterParameters) { parameter in
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(parameter.title)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text("\(parameter.currentValue, specifier: "%.2f")")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Slider(
                                    value: Binding(
                                        get: { currentFilterParameters[parameter.key] ?? parameter.defaultValue },
                                        set: { newValue in
                                            currentFilterParameters[parameter.key] = newValue
                                            applyProcessing()
                                        }
                                    ),
                                    in: parameter.range,
                                    step: parameter.step
                                )
                                .disabled(imageIsEmpty)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                // Кнопки управления
                HStack {
                    Button("Изменить фильтр", action: changeFilter)
                        .disabled(imageIsEmpty)
                    
                    Spacer()
                    
                    if let processedImage {
                        ShareLink(
                            item: processedImage,
                            preview: SharePreview("Изображение Instafilter", image: processedImage)
                        )
                    }
                }
            }
            .padding([.horizontal, .bottom])
            .navigationTitle("Instafilter")
            .confirmationDialog("Выберите фильтр", isPresented: $showingFilters) {
                ForEach(Self.allAvailableFilters) { filterInfo in
                    Button(filterInfo.displayName) {
                        setFilter(filterInfo.filter)
                    }
                }
                Button("Отмена", role: .cancel) { }
            }
        }
    }
    
    func changeFilter() {
        showingFilters = true
    }
    
    func loadImage() {
        Task {
            guard let imageData = try await selectedItem?.loadTransferable(type: Data.self) else { return }
            guard let inputImage = UIImage(data: imageData) else { return }
            
            let beginImage = CIImage(image: inputImage)
            currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
            applyProcessing()
        }
    }
    
    func applyProcessing() {
        // Применяем все параметры из currentFilterParameters
        for (key, value) in currentFilterParameters {
            if currentFilter.inputKeys.contains(key) {
                // Специальная обработка для параметра центра
                if key == kCIInputCenterKey {
                    let center = CIVector(x: value, y: value)
                    currentFilter.setValue(center, forKey: key)
                } else {
                    currentFilter.setValue(value, forKey: key)
                }
            }
        }
        
        guard let outputImage = currentFilter.outputImage else { return }
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else { return }
        
        let uiImage = UIImage(cgImage: cgImage)
        processedImage = Image(uiImage: uiImage)
    }
    
    @MainActor
    func setFilter(_ filter: CIFilter) {
        currentFilter = filter
        
        // Сброс параметров и установка значений по умолчанию
        currentFilterParameters.removeAll()
        
        if let filterInfo = Self.allAvailableFilters.first(where: { $0.name == filter.name }) {
            for parameter in filterInfo.parameters {
                currentFilterParameters[parameter.key] = parameter.defaultValue
            }
        }
        
        loadImage()
        
        filterCount += 1
        
        if filterCount > 20 {
            requestReview()
        }
    }
    
    // MARK: - Вспомогательные функции
    
    /// Определяет параметры для фильтра
    private static func getFilterParameters(_ filter: CIFilter) -> [FilterParameter] {
        var parameters: [FilterParameter] = []
        let inputKeys = filter.inputKeys
        
        // Интенсивность
        if inputKeys.contains(kCIInputIntensityKey) {
            parameters.append(FilterParameter(
                key: kCIInputIntensityKey,
                title: "Интенсивность",
                defaultValue: 0.5,
                range: 0.0...1.0,
                step: 0.01
            ))
        }
        
        // Радиус
        if inputKeys.contains(kCIInputRadiusKey) {
            let maxRadius: Double = filter.name.contains("Blur") ? 50.0 : 200.0
            parameters.append(FilterParameter(
                key: kCIInputRadiusKey,
                title: "Радиус",
                defaultValue: 10.0,
                range: 0.0...maxRadius,
                step: 1.0
            ))
        }
        
        // Масштаб
        if inputKeys.contains(kCIInputScaleKey) {
            parameters.append(FilterParameter(
                key: kCIInputScaleKey,
                title: "Масштаб",
                defaultValue: 8.0,
                range: 1.0...100.0,
                step: 1.0
            ))
        }
        
        // Центр (для искажений) - упрощенный подход с одним параметром
        if inputKeys.contains(kCIInputCenterKey) {
            parameters.append(FilterParameter(
                key: kCIInputCenterKey,
                title: "Позиция центра",
                defaultValue: 150.0,
                range: 0.0...300.0,
                step: 1.0
            ))
        }
        
        // Угол
        if inputKeys.contains(kCIInputAngleKey) {
            parameters.append(FilterParameter(
                key: kCIInputAngleKey,
                title: "Угол",
                defaultValue: 0.0,
                range: -Double.pi...Double.pi,
                step: 0.1
            ))
        }
        
        // Яркость
        if inputKeys.contains("inputBrightness") {
            parameters.append(FilterParameter(
                key: "inputBrightness",
                title: "Яркость",
                defaultValue: 0.0,
                range: -1.0...1.0,
                step: 0.01
            ))
        }
        
        // Контраст
        if inputKeys.contains("inputContrast") {
            parameters.append(FilterParameter(
                key: "inputContrast",
                title: "Контраст",
                defaultValue: 1.0,
                range: 0.0...2.0,
                step: 0.01
            ))
        }
        
        // Насыщенность
        if inputKeys.contains("inputSaturation") {
            parameters.append(FilterParameter(
                key: "inputSaturation",
                title: "Насыщенность",
                defaultValue: 1.0,
                range: 0.0...2.0,
                step: 0.01
            ))
        }
        
        // Количество уровней (для постеризации)
        if inputKeys.contains("inputLevels") {
            parameters.append(FilterParameter(
                key: "inputLevels",
                title: "Уровни",
                defaultValue: 6.0,
                range: 2.0...30.0,
                step: 1.0
            ))
        }
        
        // Экспозиция
        if inputKeys.contains("inputEV") {
            parameters.append(FilterParameter(
                key: "inputEV",
                title: "Экспозиция",
                defaultValue: 0.0,
                range: -10.0...10.0,
                step: 0.1
            ))
        }
        
        // Цвет (для монохромных фильтров)
        if inputKeys.contains("inputColor") {
            parameters.append(FilterParameter(
                key: "inputColorIntensity",
                title: "Интенсивность цвета",
                defaultValue: 1.0,
                range: 0.0...1.0,
                step: 0.01
            ))
        }
        
        return parameters
    }
}

#Preview {
    ContentView()
}