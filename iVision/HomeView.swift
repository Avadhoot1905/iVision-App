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
                VStack {
                    Spacer().frame(height: 15)
                    HStack {
                        Text("iVision")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Spacer().frame(width:195)
                        Button(action: {
                            // Navigate to Profile page
                        }) {
                            Image(systemName: "person.crop.circle")
                                .resizable()
                                .frame(width: 32, height: 32)
                                .foregroundColor(.white)
                        }
                        .padding()
                    }
                    .padding(.top, 10)

                    ZStack {
                        Rectangle()
                            .fill(Color.green.opacity(0.2))
                            .frame(height: 300)
                            .cornerRadius(12)
                            .padding(.horizontal)
                        
                        if let image = selectedImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 280)
                                .cornerRadius(12)
                        } else {
                            VStack {
                                Button(action: {
                                    showImagePicker = true
                                }) {
                                    Image(systemName: "plus")
                                        .resizable()
                                        .frame(width: 50, height: 50)
                                        .foregroundColor(.white)
                                }
                                Text("Upload Image")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .padding(.top)
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
                    Spacer().frame(height: 30)
                    Text("Previous Entries")
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding(.top)
                    EntryListView(entries: [
                        "Entry 1 - 27 Sept 2025",
                        "Entry 2 - 20 Sept 2025",
                        "Entry 3 - 10 Sept 2025",
                        "Entry 4 - 5 Sept 2025"
                    ])
                    Spacer()
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

// EntryListView remains unchanged
struct EntryListView: View {
    let entries: [String]
    @State private var hoveredIndex: Int? = nil

    var body: some View {
        List {
            ForEach(entries.indices, id: \.self) { index in
                Button(action: {
                    // Handle entry selection
                }) {
                    Text(entries[index])
                        .foregroundColor(.black)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(PlainButtonStyle())
                .listRowBackground(Color.green.opacity(0.01))
                .scaleEffect(hoveredIndex == index ? 1.05 : 1.0)
                .animation(.easeInOut(duration: 0.2), value: hoveredIndex == index)
                .onHover { hovering in
                    if hovering {
                        hoveredIndex = index
                    } else if hoveredIndex == index {
                        hoveredIndex = nil
                    }
                }
            }
        }
        .frame(maxHeight: 300)
        .listStyle(PlainListStyle())
    }
}
