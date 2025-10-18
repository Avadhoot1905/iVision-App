import Foundation
import CoreML
import Vision
import UIKit

class CoreMLService {
    static let shared = CoreMLService()
    private var model: EyeDiseaseModelV2?
    
    private init() {
        loadModel()
    }
    
    private func loadModel() {
        do {
            let configuration = MLModelConfiguration()
            model = try EyeDiseaseModelV2(configuration: configuration)
            print(" CoreML model (EyeDiseaseModelV2) loaded successfully")
            print(" Model version: 2.0")
        } catch {
            print(" Failed to load CoreML model: \(error)")
            print(" Make sure EyeDiseaseModelV2.mlmodel is added to your Xcode project")
            print(" Error details: \(error.localizedDescription)")
        }
    }
    
    func classifyImage(_ image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        print("🔍 Starting image classification...")
        
        guard let model = model else {
            print(" Model not loaded - cannot classify image")
            completion(.failure(CoreMLError.modelNotLoaded))
            return
        }
        
        print("Model is loaded, processing image...")
        
        guard let cgImage = image.cgImage else {
            print("Invalid image format - cannot extract CGImage")
            completion(.failure(CoreMLError.invalidImage))
            return
        }
        
        print("✅ Image is valid, creating Vision request...")
        
        // Create Vision request
        do {
            let visionModel = try VNCoreMLModel(for: model.model)
            
            let request = VNCoreMLRequest(model: visionModel) { request, error in
                if let error = error {
                    print("❌ Vision request failed: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                
                print("📊 Request completed, checking results...")
                print("📊 Results type: \(type(of: request.results))")
                print("📊 Results count: \(request.results?.count ?? 0)")
                
                // Try to get classification observations first
                if let classificationResults = request.results as? [VNClassificationObservation],
                   let topResult = classificationResults.first {
                    print("✅ Got classification observations!")
                    self.handleClassificationResult(topResult, completion: completion)
                    return
                }
                
                // Try to get core ML feature value observations
                if let coreMLResults = request.results as? [VNCoreMLFeatureValueObservation] {
                    print("📊 Got CoreML feature value observations: \(coreMLResults.count)")
                    
                    for (index, result) in coreMLResults.enumerated() {
                        print("📊 Result \(index): \(result.featureName)")
                        
                        if let multiArray = result.featureValue.multiArrayValue {
                            print("📊 MultiArray shape: \(multiArray.shape)")
                            self.handleMultiArrayResult(multiArray, completion: completion)
                            return
                        }
                    }
                }
                
                print("❌ No valid results found")
                print("📊 Available results: \(String(describing: request.results))")
                completion(.failure(CoreMLError.noResults))
            }
            
            // Set image crop and scale option
            request.imageCropAndScaleOption = .centerCrop
            
            // Perform the request
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            print("🚀 Executing Vision request...")
            try handler.perform([request])
            
        } catch {
            print("❌ Failed to create or execute Vision request: \(error.localizedDescription)")
            completion(.failure(error))
        }
    }
    
    private func handleClassificationResult(_ result: VNClassificationObservation, completion: @escaping (Result<String, Error>) -> Void) {
        print("✅ Classification successful!")
        print("📊 Top prediction: \(result.identifier)")
        print("📊 Confidence: \(String(format: "%.2f", result.confidence * 100))%")
        
        let diseaseNames = [
            "0": "Normal/Healthy",
            "1": "Cataract",
            "2": "Glaucoma",
            "3": "Diabetic Retinopathy",
            "4": "Age-related Macular Degeneration"
        ]
        
        let diseaseName = diseaseNames[result.identifier] ?? result.identifier
        let confidence = String(format: "%.2f", result.confidence * 100)
        let resultString = "\(diseaseName) (\(confidence)%)"
        
        print("📋 Final result: \(resultString)")
        completion(.success(resultString))
    }
    
    private func handleMultiArrayResult(_ multiArray: MLMultiArray, completion: @escaping (Result<String, Error>) -> Void) {
        print("✅ Processing multi-array output...")
        
        let diseaseNames = [
            "Normal/Healthy",
            "Cataract",
            "Glaucoma",
            "Diabetic Retinopathy",
            "Age-related Macular Degeneration"
        ]
        
        // Find the index with highest probability
        var maxIndex = 0
        var maxValue: Double = -Double.infinity
        
        let count = multiArray.shape[0].intValue
        print("📊 Number of classes: \(count)")
        
        for i in 0..<min(count, diseaseNames.count) {
            let value = multiArray[i].doubleValue
            print("📊 Class \(i) (\(diseaseNames[i])): \(String(format: "%.4f", value))")
            
            if value > maxValue {
                maxValue = value
                maxIndex = i
            }
        }
        
        // Convert to percentage (assuming softmax output)
        let confidence = maxValue * 100
        let result = "\(diseaseNames[maxIndex]) (\(String(format: "%.2f", confidence))%)"
        
        print("📋 Final result: \(result)")
        completion(.success(result))
    }
}

enum CoreMLError: LocalizedError {
    case modelNotLoaded
    case invalidImage
    case noResults
    
    var errorDescription: String? {
        switch self {
        case .modelNotLoaded:
            return "CoreML model is not loaded"
        case .invalidImage:
            return "Invalid image format"
        case .noResults:
            return "No classification results"
        }
    }
}
