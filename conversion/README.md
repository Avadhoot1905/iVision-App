# PyTorch to CoreML Conversion

This directory contains the conversion script for converting the MobileNetV2 PyTorch model to CoreML format for use in iOS applications.

## Files

- `mobilenetv2.pth` - Original PyTorch model weights (5 disease classes)
- `convert.py` - Conversion script from PyTorch to CoreML
- `inspect_model.py` - Script to inspect the converted CoreML model
- `EyeDiseaseModel.mlmodel` - Converted CoreML model (ready for iOS)
- `requirements.txt` - Python dependencies

## Model Details

- **Architecture**: MobileNetV2
- **Input**: RGB images, 224x224 pixels
- **Output**: 5 disease classifications
- **Format**: CoreML NeuralNetwork

## Setup and Conversion

### Prerequisites

1. Python 3.11 (recommended for CoreML compatibility)
2. Virtual environment

### Installation

```bash
# Create virtual environment with Python 3.11
python3.11 -m venv venv

# Activate virtual environment
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt
```

### Run Conversion

```bash
# Activate virtual environment
source venv/bin/activate

# Run conversion script
python convert.py
```

The script will:
1. Load the PyTorch model from `mobilenetv2.pth`
2. Detect the number of output classes (5 diseases)
3. Convert to CoreML format
4. Save as `EyeDiseaseModel.mlmodel`

### Inspect Model

```bash
# Activate virtual environment
source venv/bin/activate

# Inspect the converted model
python inspect_model.py
```

## Using the Model in Swift/iOS

### Step 1: Add to Xcode Project

1. Open your Xcode project
2. Drag `EyeDiseaseModel.mlmodel` into your project navigator
3. Xcode will automatically generate Swift classes for the model

### Step 2: Use in Your App

```swift
import Vision
import CoreML
import UIKit

class EyeDiseaseDetector {
    
    private var model: VNCoreMLModel?
    
    init() {
        // Load the CoreML model
        guard let mlModel = try? EyeDiseaseModel(configuration: MLModelConfiguration()).model,
              let visionModel = try? VNCoreMLModel(for: mlModel) else {
            fatalError("Failed to load CoreML model")
        }
        self.model = visionModel
    }
    
    func detectDisease(in image: UIImage, completion: @escaping ([String: Float]) -> Void) {
        guard let cgImage = image.cgImage,
              let model = model else {
            return
        }
        
        // Create the request
        let request = VNCoreMLRequest(model: model) { request, error in
            guard let results = request.results as? [VNCoreMLFeatureValueObservation],
                  let multiArray = results.first?.featureValue.multiArrayValue else {
                return
            }
            
            // Process the output
            var predictions: [String: Float] = [:]
            
            // Convert multiArray to predictions
            // Note: You'll need to map indices to disease names
            let diseaseNames = ["Normal", "Cataract", "Glaucoma", "Diabetic Retinopathy", "Other"]
            
            for i in 0..<min(5, multiArray.count) {
                let confidence = multiArray[i].floatValue
                predictions[diseaseNames[i]] = confidence
            }
            
            completion(predictions)
        }
        
        request.imageCropAndScaleOption = .centerCrop
        
        // Perform the request
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        try? handler.perform([request])
    }
}

// Usage
let detector = EyeDiseaseDetector()
detector.detectDisease(in: eyeImage) { predictions in
    for (disease, confidence) in predictions.sorted(by: { $0.value > $1.value }) {
        print("\(disease): \(String(format: "%.2f%%", confidence * 100))")
    }
}
```

### Step 3: Process Results

The model outputs raw predictions for 5 disease classes. You'll need to:
1. Apply softmax to convert to probabilities (if not already done)
2. Map indices to disease names
3. Sort by confidence to get the top prediction

## Model Specifications

- **Input Name**: `input_image`
- **Input Type**: Image (224x224, RGB)
- **Input Preprocessing**: Automatically normalized (0-1 range)
- **Output Name**: `disease_predictions`
- **Output Type**: MultiArray (FLOAT32, 5 values)
- **Output Values**: Raw predictions for 5 disease classes

## Troubleshooting

### Python Version Issues
If you encounter coremltools compatibility issues, ensure you're using Python 3.11:
```bash
# Check Python version
python --version

# Use Python 3.11 explicitly
python3.11 -m venv venv
```

### Model Loading Issues
If the model doesn't load in Xcode:
1. Clean build folder (Cmd+Shift+K)
2. Rebuild project
3. Check that the .mlmodel file is in the correct target

### Prediction Issues
If predictions seem incorrect:
1. Ensure input images are RGB (not grayscale)
2. Verify images are 224x224 (or will be resized)
3. Check that preprocessing matches training preprocessing

## Notes

- The model was trained on eye images for disease detection
- It classifies into 5 categories
- Images should be properly cropped to show the eye region
- For best results, ensure good lighting and focus in input images
