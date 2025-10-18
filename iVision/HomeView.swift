import SwiftUI
import CoreML
import Vision

struct HomeView: View {
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage? = nil
    @State private var navigateToDiagnosis = false

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.lightGreen, Color.deepBlue]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                VStack(spacing: 0) {
                    // Modern Header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("iVision")
                                .font(.system(size: 34, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            Text("Eye Health Assistant")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        Spacer()
                        Button(action: {
                            // Navigate to Profile page
                        }) {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    .padding(.bottom, 10)

                    // Modern Image Upload Card
                    VStack(spacing: 16) {
                        if let image = selectedImage {
                            // Image Preview with modern styling
                            VStack(spacing: 12) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 300)
                                    .frame(maxWidth: .infinity)
                                    .clipped()
                                    .cornerRadius(20)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                    )
                                    .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 4)
                                
                                // Change Image Button
                                Button(action: {
                                    showImagePicker = true
                                }) {
                                    HStack {
                                        Image(systemName: "photo.badge.plus")
                                            .font(.system(size: 16, weight: .semibold))
                                        Text("Change Image")
                                            .font(.system(size: 16, weight: .semibold))
                                    }
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 12)
                                    .background(
                                        Capsule()
                                            .fill(Color.white.opacity(0.25))
                                            .overlay(
                                                Capsule()
                                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                            )
                                    )
                                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                                }
                            }
                        } else {
                            // Upload Placeholder with modern design
                            Button(action: {
                                showImagePicker = true
                            }) {
                                VStack(spacing: 20) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.white.opacity(0.25))
                                            .frame(width: 100, height: 100)
                                            .overlay(
                                                Circle()
                                                    .stroke(Color.white.opacity(0.3), lineWidth: 2)
                                            )
                                        
                                        Image(systemName: "camera.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 45, height: 45)
                                            .foregroundColor(.white)
                                    }
                                    
                                    VStack(spacing: 8) {
                                        Text("Upload Eye Image")
                                            .font(.system(size: 22, weight: .bold))
                                            .foregroundColor(.white)
                                        Text("Tap to select an image from your library")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.white.opacity(0.8))
                                            .multilineTextAlignment(.center)
                                    }
                                }
                                .frame(height: 300)
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color.white.opacity(0.15))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(Color.white.opacity(0.3), lineWidth: 1.5)
                                                .strokeBorder(
                                                    style: StrokeStyle(lineWidth: 2, dash: [8, 8])
                                                )
                                        )
                                )
                                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                    .sheet(isPresented: $showImagePicker) {
                        ImagePicker(image: $selectedImage) { image in
                            showImagePicker = false
                            selectedImage = image
                            if let _ = image {
                                // Navigate immediately after image selection
                                navigateToDiagnosis = true
                            }
                        }
                    }
                    
                    // Previous Entries Section with modern design
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Previous Entries")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(.white)
                                Text("View your diagnosis history")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            Spacer()
                            Image(systemName: "clock.arrow.circlepath")
                                .font(.system(size: 20))
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 24)
                        
                        EntryListView(entries: [
                            "Entry 1 - 27 Sept 2025",
                            "Entry 2 - 20 Sept 2025",
                            "Entry 3 - 10 Sept 2025",
                            "Entry 4 - 5 Sept 2025"
                        ])
                        .padding(.horizontal, 16)
                    }
                    
                    Spacer(minLength: 20)
                }
            }
            .navigationDestination(isPresented: $navigateToDiagnosis) {
                DiagnosisView(image: selectedImage)
            }
        }
    }
}

// ImagePicker for photo library
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    var onPicked: (UIImage?) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        init(_ parent: ImagePicker) { self.parent = parent }
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let img = info[.originalImage] as? UIImage {
                parent.image = img
                parent.onPicked(img)
            } else {
                parent.onPicked(nil)
            }
            picker.dismiss(animated: true)
        }
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.onPicked(nil)
            picker.dismiss(animated: true)
        }
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}

// EntryListView with modern design
struct EntryListView: View {
    let entries: [String]

    var body: some View {
        VStack(spacing: 12) {
            ForEach(entries.indices, id: \.self) { index in
                Button(action: {
                    // Handle entry selection
                }) {
                    HStack {
                        // Icon
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.2))
                                .frame(width: 44, height: 44)
                            Image(systemName: "doc.text.image")
                                .font(.system(size: 18))
                                .foregroundColor(.white)
                        }
                        
                        // Entry Text
                        Text(entries[index])
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        // Chevron
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(0.15))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                    )
                    .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
                }
                .buttonStyle(ScaleButtonStyle())
            }
        }
    }
}

// Custom button style for scale effect
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}
