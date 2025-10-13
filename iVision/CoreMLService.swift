import Foundation
import CoreML
import Vision
import UIKit

class CoreMLService {
    static let shared = CoreMLService()
    private var model: MyModel?
    
    private init() {
        loadModel()
    }
    
    private func loadModel() {
        do {
            model = try MyModel()
            print("CoreML model loaded successfully")
        } catch {
            print("Failed to load CoreML model: \(error)")
        }
    }
    
    func classifyImage(_ image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        guard let model = model else {
            completion(.failure(CoreMLError.modelNotLoaded))
            return
        }
        
        guard let cgImage = image.cgImage else {
            completion(.failure(CoreMLError.invalidImage))
            return
        }
        
        // Create Vision request
        let request = VNCoreMLRequest(model: try! VNCoreMLModel(for: model.model)) { request, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let results = request.results as? [VNClassificationObservation],
                  let topResult = results.first else {
                completion(.failure(CoreMLError.noResults))
                return
            }
            
            let confidence = String(format: "%.2f", topResult.confidence * 100)
            let result = "\(topResult.identifier) (\(confidence)%)"
            completion(.success(result))
        }
        
        // Perform the request
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try handler.perform([request])
        } catch {
            completion(.failure(error))
        }
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
