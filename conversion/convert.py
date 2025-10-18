import torch
import torchvision
import coremltools as ct
from torchvision import models
import os

def convert_pytorch_to_coreml():
    """
    Convert PyTorch MobileNetV2 model to CoreML format for iOS integration.
    The model evaluates eye images and returns disease predictions.
    """
    
    # Set the model path
    model_path = "mobilenetv2.pth"
    output_path = "EyeDiseaseModel.mlmodel"
    
    print(f"Loading PyTorch model from {model_path}...")
    
    # Load the trained weights first to inspect
    checkpoint = torch.load(model_path, map_location=torch.device('cpu'))
    
    # Determine the number of classes from the checkpoint
    num_classes = None
    state_dict = None
    
    if isinstance(checkpoint, dict):
        if 'model_state_dict' in checkpoint:
            state_dict = checkpoint['model_state_dict']
            num_classes = checkpoint.get('num_classes', None)
        elif 'state_dict' in checkpoint:
            state_dict = checkpoint['state_dict']
            num_classes = checkpoint.get('num_classes', None)
        else:
            state_dict = checkpoint
    else:
        state_dict = checkpoint
    
    # If num_classes not specified, infer from the classifier weight shape
    if num_classes is None and 'classifier.1.weight' in state_dict:
        num_classes = state_dict['classifier.1.weight'].shape[0]
        print(f"Detected {num_classes} output classes from model weights")
    
    # Load the MobileNetV2 architecture with the correct number of classes
    model = models.mobilenet_v2(pretrained=False)
    
    # Adjust the classifier to match the number of classes in the checkpoint
    if num_classes and num_classes != 1000:
        model.classifier[1] = torch.nn.Linear(model.last_channel, num_classes)
    
    # Now load the state dict
    model.load_state_dict(state_dict)
    
    # Set model to evaluation mode
    model.eval()
    
    print("Model loaded successfully!")
    print(f"Model architecture: {model.__class__.__name__}")
    
    # Define input shape for eye images
    # Standard image size for MobileNetV2 is 224x224
    example_input = torch.rand(1, 3, 224, 224)
    
    print("Tracing the model...")
    
    # Trace the model
    traced_model = torch.jit.trace(model, example_input)
    
    print("Converting to CoreML...")
    
    # Convert to CoreML
    # Using neuralnetwork format for better compatibility
    mlmodel = ct.convert(
        traced_model,
        inputs=[ct.ImageType(
            name="input_image",
            shape=example_input.shape,
            scale=1/255.0,  # Normalize pixel values to [0, 1]
            bias=[0, 0, 0],
            color_layout=ct.colorlayout.RGB
        )],
        outputs=[ct.TensorType(name="disease_predictions")],
        convert_to="neuralnetwork"  # Use neuralnetwork format for compatibility
    )
    
    # Add metadata
    mlmodel.author = "iVision Eye Disease Detection"
    mlmodel.license = "MIT"
    mlmodel.short_description = "MobileNetV2 model for eye disease detection"
    mlmodel.version = "1.0"
    
    # Add input/output descriptions
    mlmodel.input_description["input_image"] = "Input eye image (224x224 RGB)"
    mlmodel.output_description["disease_predictions"] = "Disease classification predictions"
    
    # Save the CoreML model
    print(f"Saving CoreML model to {output_path}...")
    mlmodel.save(output_path)
    
    print("Conversion completed successfully!")
    print(f"CoreML model saved to: {output_path}")
    
    # Print model information
    print("\nModel Information:")
    print(f"Input: {mlmodel.input_description}")
    print(f"Output: {mlmodel.output_description}")
    
    return mlmodel

if __name__ == "__main__":
    try:
        print("Starting PyTorch to CoreML conversion...")
        print("=" * 60)
        convert_pytorch_to_coreml()
        print("=" * 60)
        print("Conversion process completed!")
    except Exception as e:
        print(f"Error during conversion: {str(e)}")
        print("\nTroubleshooting tips:")
        print("1. Ensure 'mobilenetv2.pth' exists in the current directory")
        print("2. Install required packages: pip install torch torchvision coremltools")
        print("3. Check that the .pth file is not corrupted")
        raise
