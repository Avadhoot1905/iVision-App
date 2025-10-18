#!/usr/bin/env python3
"""
Test script for the EyeDiseaseModel CoreML model
This script loads an image and runs inference to test the model.
"""

import coremltools as ct
import numpy as np
from PIL import Image
import sys
import os

def load_and_preprocess_image(image_path, target_size=(224, 224)):
    """
    Load and preprocess an image for the model
    
    Args:
        image_path: Path to the image file
        target_size: Target size for the image (width, height)
    
    Returns:
        PIL Image ready for inference
    """
    print(f"Loading image from: {image_path}")
    
    # Load image
    img = Image.open(image_path)
    print(f"Original image size: {img.size}")
    print(f"Original image mode: {img.mode}")
    
    # Convert to RGB if necessary
    if img.mode != 'RGB':
        print(f"Converting image from {img.mode} to RGB")
        img = img.convert('RGB')
    
    # Resize to target size
    img = img.resize(target_size, Image.Resampling.LANCZOS)
    print(f"Resized image to: {img.size}")
    
    return img

def softmax(x):
    """Apply softmax to convert logits to probabilities"""
    exp_x = np.exp(x - np.max(x))
    return exp_x / exp_x.sum()

def run_inference(model_path, image_path):
    """
    Run inference on an image using the CoreML model
    
    Args:
        model_path: Path to the .mlmodel file
        image_path: Path to the input image
    """
    print("="*70)
    print("COREML MODEL INFERENCE TEST")
    print("="*70)
    
    # Load the CoreML model
    print(f"\nLoading CoreML model from: {model_path}")
    model = ct.models.MLModel(model_path)
    
    # Get model spec
    spec = model.get_spec()
    print(f"Model loaded successfully!")
    print(f"Model: {spec.description.metadata.shortDescription}")
    
    # Load and preprocess image
    print("\n" + "-"*70)
    img = load_and_preprocess_image(image_path)
    
    # Run prediction
    print("\n" + "-"*70)
    print("Running inference...")
    
    try:
        # Make prediction
        prediction = model.predict({'input_image': img})
        
        print("✓ Inference completed successfully!")
        
        # Get the output
        output_key = list(prediction.keys())[0]
        output = prediction[output_key]
        
        print(f"\nOutput key: {output_key}")
        print(f"Output type: {type(output)}")
        print(f"Output shape: {output.shape if hasattr(output, 'shape') else 'N/A'}")
        
        # Convert to numpy array if needed
        if hasattr(output, '__array__'):
            output_array = np.array(output).flatten()
        else:
            output_array = np.array(output).flatten()
        
        print(f"Output values (raw logits): {output_array}")
        
        # Apply softmax to get probabilities
        probabilities = softmax(output_array)
        
        print("\n" + "="*70)
        print("PREDICTION RESULTS")
        print("="*70)
        
        # Disease class names (you may need to adjust these based on your training)
        # Common eye diseases - adjust these to match your actual training labels
        disease_names = [
            "Normal/Healthy",
            "Cataract",
            "Glaucoma",
            "Diabetic Retinopathy",
            "Age-related Macular Degeneration"
        ]
        
        # If we have fewer or more classes than names, adjust
        if len(probabilities) != len(disease_names):
            disease_names = [f"Class {i}" for i in range(len(probabilities))]
        
        # Create results
        results = []
        for i, (disease, prob) in enumerate(zip(disease_names, probabilities)):
            results.append({
                'class_index': i,
                'disease': disease,
                'probability': prob,
                'percentage': prob * 100,
                'raw_logit': output_array[i]
            })
        
        # Sort by probability (highest first)
        results.sort(key=lambda x: x['probability'], reverse=True)
        
        # Print results
        print(f"\n{'Rank':<6}{'Disease':<40}{'Confidence':<15}{'Raw Logit':<15}")
        print("-"*70)
        
        for rank, result in enumerate(results, 1):
            confidence_bar = "█" * int(result['percentage'] / 2)
            print(f"{rank:<6}{result['disease']:<40}{result['percentage']:>6.2f}%  {confidence_bar}")
        
        print("\n" + "="*70)
        print("TOP PREDICTION")
        print("="*70)
        top_result = results[0]
        print(f"Predicted Disease: {top_result['disease']}")
        print(f"Confidence: {top_result['percentage']:.2f}%")
        print(f"Class Index: {top_result['class_index']}")
        
        # Print detailed statistics
        print("\n" + "="*70)
        print("DETAILED STATISTICS")
        print("="*70)
        print(f"Total classes: {len(probabilities)}")
        print(f"Sum of probabilities: {sum(probabilities):.6f} (should be ~1.0)")
        print(f"Max probability: {max(probabilities):.6f}")
        print(f"Min probability: {min(probabilities):.6f}")
        print(f"Entropy: {-sum(p * np.log(p + 1e-10) for p in probabilities):.4f}")
        
        # Confidence assessment
        print("\n" + "="*70)
        print("CONFIDENCE ASSESSMENT")
        print("="*70)
        
        if top_result['percentage'] > 80:
            confidence_level = "Very High"
            assessment = "The model is very confident in this prediction."
        elif top_result['percentage'] > 60:
            confidence_level = "High"
            assessment = "The model is confident in this prediction."
        elif top_result['percentage'] > 40:
            confidence_level = "Moderate"
            assessment = "The model has moderate confidence. Consider reviewing the image quality."
        else:
            confidence_level = "Low"
            assessment = "The model has low confidence. The image may not be suitable or might be unclear."
        
        print(f"Confidence Level: {confidence_level}")
        print(f"Assessment: {assessment}")
        
        # Check if prediction seems uncertain (similar probabilities)
        if results[0]['percentage'] - results[1]['percentage'] < 10:
            print("\n⚠️  Warning: Top predictions are very close. The model is uncertain.")
            print(f"   Difference between top 2: {results[0]['percentage'] - results[1]['percentage']:.2f}%")
        
        print("\n" + "="*70)
        
        return results
        
    except Exception as e:
        print(f"\n❌ Error during inference: {str(e)}")
        import traceback
        traceback.print_exc()
        return None

def main():
    # Paths
    model_path = "EyeDiseaseModel.mlmodel"
    image_path = "conj.jpeg"
    
    # Check if files exist
    if not os.path.exists(model_path):
        print(f"❌ Error: Model file not found: {model_path}")
        sys.exit(1)
    
    if not os.path.exists(image_path):
        print(f"❌ Error: Image file not found: {image_path}")
        sys.exit(1)
    
    # Run inference
    results = run_inference(model_path, image_path)
    
    if results:
        print("\n✓ Test completed successfully!")
    else:
        print("\n❌ Test failed!")
        sys.exit(1)

if __name__ == "__main__":
    main()
