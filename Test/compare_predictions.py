#!/usr/bin/env python3
"""
Compare two CoreML models on the same test image
"""

import coremltools as ct
import numpy as np
from PIL import Image
import sys

def softmax(x):
    """Apply softmax to convert logits to probabilities"""
    exp_x = np.exp(x - np.max(x))
    return exp_x / exp_x.sum()

def load_image(image_path, target_size=(224, 224)):
    """Load and preprocess an image"""
    img = Image.open(image_path)
    if img.mode != 'RGB':
        img = img.convert('RGB')
    img = img.resize(target_size, Image.Resampling.LANCZOS)
    return img

def predict(model_path, image):
    """Run prediction with a model"""
    model = ct.models.MLModel(model_path)
    prediction = model.predict({'input_image': image})
    output = prediction[list(prediction.keys())[0]]
    output_array = np.array(output).flatten()
    probabilities = softmax(output_array)
    return probabilities, output_array

def main():
    print("="*80)
    print("SIDE-BY-SIDE MODEL COMPARISON")
    print("="*80)
    
    # Paths
    image_path = "conj.jpeg"
    model1_path = "EyeDiseaseModel.mlmodel"
    model2_path = "EyeDiseaseModelV2.mlmodel"
    
    # Disease names
    disease_names = [
        "Normal/Healthy",
        "Cataract",
        "Glaucoma",
        "Diabetic Retinopathy",
        "Age-related Macular Degeneration"
    ]
    
    print(f"\nTest Image: {image_path}")
    print(f"Model 1: {model1_path} (Original)")
    print(f"Model 2: {model2_path} (Improved)")
    
    # Load image
    print("\nLoading and preprocessing image...")
    img = load_image(image_path)
    print(f"✓ Image loaded: {img.size}")
    
    # Run predictions
    print("\nRunning predictions...")
    print("-"*80)
    
    probs1, logits1 = predict(model1_path, img)
    print(f"✓ Model 1 prediction complete")
    
    probs2, logits2 = predict(model2_path, img)
    print(f"✓ Model 2 prediction complete")
    
    # Display comparison
    print("\n" + "="*80)
    print("PREDICTION COMPARISON")
    print("="*80)
    
    print(f"\n{'Disease':<40} {'Model V1':<20} {'Model V2':<20} {'Difference':<15}")
    print("-"*80)
    
    for i, disease in enumerate(disease_names):
        diff = probs2[i] - probs1[i]
        diff_symbol = "↑" if diff > 0 else ("↓" if diff < 0 else "→")
        
        v1_pct = f"{probs1[i]*100:6.2f}%"
        v2_pct = f"{probs2[i]*100:6.2f}%"
        diff_str = f"{diff_symbol} {abs(diff)*100:5.2f}%"
        
        print(f"{disease:<40} {v1_pct:<20} {v2_pct:<20} {diff_str:<15}")
    
    # Top predictions
    print("\n" + "="*80)
    print("TOP PREDICTIONS")
    print("="*80)
    
    top1_idx = np.argmax(probs1)
    top2_idx = np.argmax(probs2)
    
    print(f"\nModel V1 (Original):")
    print(f"  Prediction: {disease_names[top1_idx]}")
    print(f"  Confidence: {probs1[top1_idx]*100:.2f}%")
    
    print(f"\nModel V2 (Improved):")
    print(f"  Prediction: {disease_names[top2_idx]}")
    print(f"  Confidence: {probs2[top2_idx]*100:.2f}%")
    
    # Agreement analysis
    print("\n" + "="*80)
    print("ANALYSIS")
    print("="*80)
    
    if top1_idx == top2_idx:
        print(f"\n✓ Both models agree on the prediction: {disease_names[top1_idx]}")
        confidence_diff = probs2[top2_idx] - probs1[top1_idx]
        if abs(confidence_diff) < 0.01:
            print(f"  Confidence levels are very similar (±{abs(confidence_diff)*100:.2f}%)")
        elif confidence_diff > 0:
            print(f"  Model V2 is more confident by {confidence_diff*100:.2f}%")
        else:
            print(f"  Model V1 is more confident by {abs(confidence_diff)*100:.2f}%")
    else:
        print(f"\n⚠️  Models disagree!")
        print(f"  Model V1 predicts: {disease_names[top1_idx]} ({probs1[top1_idx]*100:.2f}%)")
        print(f"  Model V2 predicts: {disease_names[top2_idx]} ({probs2[top2_idx]*100:.2f}%)")
    
    # Statistical comparison
    print(f"\nStatistical Measures:")
    print(f"  Average difference: {np.mean(np.abs(probs2 - probs1))*100:.2f}%")
    print(f"  Max difference: {np.max(np.abs(probs2 - probs1))*100:.2f}%")
    print(f"  Entropy V1: {-sum(p * np.log(p + 1e-10) for p in probs1):.4f}")
    print(f"  Entropy V2: {-sum(p * np.log(p + 1e-10) for p in probs2):.4f}")
    
    lower_entropy = "V1" if probs1[top1_idx] > probs2[top2_idx] else "V2"
    print(f"\n  → Model {lower_entropy} shows more certainty (lower entropy = higher confidence)")
    
    print("\n" + "="*80)
    print("RECOMMENDATION")
    print("="*80)
    
    if probs2[top2_idx] > probs1[top1_idx]:
        print(f"\n✓ Model V2 shows higher confidence ({probs2[top2_idx]*100:.2f}% vs {probs1[top1_idx]*100:.2f}%)")
        print("  Recommended: Use EyeDiseaseModelV2.mlmodel for production")
    else:
        print(f"\n✓ Model V1 shows higher confidence ({probs1[top1_idx]*100:.2f}% vs {probs2[top2_idx]*100:.2f}%)")
        print("  Note: Test on real eye images to properly evaluate improvement")
    
    print("\n" + "="*80)

if __name__ == "__main__":
    main()
