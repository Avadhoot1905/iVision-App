import coremltools as ct

def inspect_coreml_model(model_path):
    """
    Inspect the CoreML model to display its specifications
    """
    print(f"Loading CoreML model from {model_path}...")
    model = ct.models.MLModel(model_path)
    
    spec = model.get_spec()
    
    print("\n" + "="*60)
    print("MODEL INFORMATION")
    print("="*60)
    
    print(f"\nAuthor: {spec.description.metadata.author}")
    print(f"Version: {spec.description.metadata.versionString}")
    print(f"Description: {spec.description.metadata.shortDescription}")
    print(f"License: {spec.description.metadata.license}")
    
    print("\n" + "="*60)
    print("INPUT SPECIFICATIONS")
    print("="*60)
    for input_feature in spec.description.input:
        print(f"\nName: {input_feature.name}")
        print(f"Type: {input_feature.type}")
        if input_feature.type.HasField('imageType'):
            img_type = input_feature.type.imageType
            print(f"Image Type: {img_type}")
    
    print("\n" + "="*60)
    print("OUTPUT SPECIFICATIONS")
    print("="*60)
    for output_feature in spec.description.output:
        print(f"\nName: {output_feature.name}")
        print(f"Type: {output_feature.type}")
        if output_feature.type.HasField('multiArrayType'):
            arr_type = output_feature.type.multiArrayType
            print(f"Shape: {list(arr_type.shape)}")
            print(f"Data Type: {arr_type.dataType}")
    
    print("\n" + "="*60)
    print("USAGE IN SWIFT")
    print("="*60)
    print("""
To use this model in your Swift app:

1. Drag the .mlmodel file into your Xcode project
2. Xcode will automatically generate a Swift class

Example usage:
```swift
import Vision
import CoreML

// Load the model
guard let model = try? VNCoreMLModel(for: EyeDiseaseModel().model) else {
    fatalError("Failed to load model")
}

// Create a request
let request = VNCoreMLRequest(model: model) { request, error in
    guard let results = request.results as? [VNClassificationObservation] else {
        return
    }
    
    // Process results - top predictions
    for result in results.prefix(5) {
        print("\\(result.identifier): \\(result.confidence)")
    }
}

// Use with an image
let handler = VNImageRequestHandler(cgImage: cgImage)
try? handler.perform([request])
```

The model outputs 5 disease classifications.
    """)

if __name__ == "__main__":
    inspect_coreml_model("EyeDiseaseModel.mlmodel")
