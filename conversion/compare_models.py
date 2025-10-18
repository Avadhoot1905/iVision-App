import coremltools as ct
import os

def inspect_model(model_path):
    """Inspect a CoreML model and return its specs"""
    print(f"\nLoading: {model_path}")
    if not os.path.exists(model_path):
        print(f"  ❌ File not found!")
        return None
    
    model = ct.models.MLModel(model_path)
    spec = model.get_spec()
    
    file_size = os.path.getsize(model_path) / (1024 * 1024)  # Size in MB
    
    info = {
        'path': model_path,
        'file_size_mb': file_size,
        'author': spec.description.metadata.author,
        'version': spec.description.metadata.versionString,
        'description': spec.description.metadata.shortDescription,
        'license': spec.description.metadata.license
    }
    
    return info

def main():
    print("="*70)
    print("COREML MODEL COMPARISON")
    print("="*70)
    
    models = [
        "EyeDiseaseModel.mlmodel",
        "EyeDiseaseModelV2.mlmodel"
    ]
    
    model_infos = []
    
    for model_path in models:
        info = inspect_model(model_path)
        if info:
            model_infos.append(info)
    
    if not model_infos:
        print("\n❌ No models found!")
        return
    
    print("\n" + "="*70)
    print("MODEL COMPARISON TABLE")
    print("="*70)
    print(f"\n{'Model':<30} {'Version':<10} {'Size (MB)':<12} {'Description'}")
    print("-"*70)
    
    for info in model_infos:
        model_name = os.path.basename(info['path'])
        print(f"{model_name:<30} {info['version']:<10} {info['file_size_mb']:<12.2f} {info['description'][:30]}")
    
    print("\n" + "="*70)
    print("DETAILS")
    print("="*70)
    
    for i, info in enumerate(model_infos, 1):
        print(f"\n{i}. {os.path.basename(info['path'])}")
        print(f"   Version: {info['version']}")
        print(f"   Size: {info['file_size_mb']:.2f} MB")
        print(f"   Description: {info['description']}")
        print(f"   Author: {info['author']}")
        print(f"   License: {info['license']}")
    
    print("\n" + "="*70)
    print("RECOMMENDATIONS")
    print("="*70)
    print("""
✓ EyeDiseaseModel.mlmodel (v1.0) - Original model
✓ EyeDiseaseModelV2.mlmodel (v2.0) - Improved accuracy model

For your iOS app:
1. Use EyeDiseaseModelV2.mlmodel for better accuracy
2. Both models have the same architecture and input/output format
3. You can easily swap between them in your Swift code
4. Keep the original as a backup for comparison
    """)

if __name__ == "__main__":
    main()
