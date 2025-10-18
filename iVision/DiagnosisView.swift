import SwiftUI

// Doctor model
struct Doctor: Identifiable{
    let id = UUID() 
    let name: String
    let specialization: String
    let address: String
    let phoneNumber: String
    let website: String
}

struct DiagnosisView: View {
    // Input parameters
    let image: UIImage?
    
    @Environment(\.dismiss) private var dismiss
    
    // ML Processing state
    @State private var diagnosis: String = ""
    @State private var isProcessing = false
    @State private var processingError: String? = nil
    private let coreMLService = CoreMLService.shared
    
    // Diagnosis text
    var diagnosisSummary: String {
        if isProcessing {
            return "Analyzing your image using advanced AI technology..."
        } else if let error = processingError {
            return "Analysis failed: \(error)"
        } else if diagnosis.isEmpty {
            return "Starting image analysis..."
        } else {
            return diagnosis
        }
    }
    
    // Prevention tips
    let preventionTips = [
        "Take regular breaks using the 20-20-20 rule: every 20 minutes, look at something 20 feet away for 20 seconds.",
        "Maintain proper posture and screen distance.",
        "Ensure adequate lighting while reading or using screens.",
        "Wear prescribed glasses or contact lenses consistently.",
        "Schedule regular eye check-ups."
    ]
    
    // Dummy doctors
    let doctors: [Doctor] = [
        Doctor(name: "Dr. A. Sharma", specialization: "Ophthalmologist", address: "123 Main St, Mumbai", phoneNumber: "+912345678901", website: "https://example.com"),
        Doctor(name: "Dr. R. Patel", specialization: "Eye Specialist", address: "456 Park Ave, Pune", phoneNumber: "+912345678902", website: ""),
        Doctor(name: "Dr. S. Iyer", specialization: "Optometrist", address: "789 Central Rd, Bangalore", phoneNumber: "+912345678903", website: "https://example.org")
    ]
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                
                // Analyzed Image Section
                if let image = image {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Analyzed Image")
                            .font(.title2)
                            .bold()
                        
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 300)
                            .cornerRadius(15)
                            .shadow(radius: 5)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.gray.opacity(0.1))
                    )
                }
                
                // Diagnosis Section
                VStack(alignment: .leading, spacing: 15) {
                    HStack {
                        Text("AI Diagnosis")
                            .font(.title2)
                            .bold()
                        
                        if isProcessing {
                            Spacer()
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        }
                    }
                    
                    if isProcessing {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                Text("Analyzing image...")
                                    .font(.headline)
                                Spacer()
                            }
                            Text("Our AI is examining your image using advanced machine learning algorithms. This may take a few moments.")
                                .font(.caption)
                                .opacity(0.8)
                        }
                    } else {
                        Text(diagnosisSummary)
                            .font(.body)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(
                            LinearGradient(colors: [Color.green.opacity(0.6), Color.blue.opacity(0.6)],
                                           startPoint: .topLeading,
                                           endPoint: .bottomTrailing)
                        )
                        .shadow(radius: 5)
                )
                .padding(.horizontal)
                
                // Prevention Tips Section (only show after diagnosis)
                if !isProcessing && !diagnosis.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Advice / Prevention Tips")
                            .font(.title2)
                            .bold()
                        
                        ForEach(preventionTips, id: \.self) { tip in
                            HStack(alignment: .top) {
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundColor(.green)
                                Text(tip)
                            }
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(
                                LinearGradient(colors: [Color.green.opacity(0.6), Color.blue.opacity(0.6)],
                                               startPoint: .topLeading,
                                               endPoint: .bottomTrailing)
                            )
                            .shadow(radius: 5)
                    )
                    .padding(.horizontal)
                    
                    // Action Buttons
                    HStack(spacing: 15) {
                        Button(action: {
                            dismiss()
                        }) {
                            HStack {
                                Image(systemName: "camera.fill")
                                Text("Retake Photo")
                            }
                            .font(.headline)
                            .foregroundColor(isProcessing ? .gray : .white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                LinearGradient(colors: isProcessing ? [Color.gray, Color.gray.opacity(0.7)] : [Color.blue, Color.blue.opacity(0.7)],
                                               startPoint: .leading,
                                               endPoint: .trailing)
                            )
                            .cornerRadius(12)
                        }
                        .disabled(isProcessing)
                        
                        Button(action: {
                            // Save diagnosis action
                        }) {
                            HStack {
                                Image(systemName: "square.and.arrow.down")
                                Text(isProcessing ? "Processing..." : "Save Report")
                            }
                            .font(.headline)
                            .foregroundColor(isProcessing ? .gray : .white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                LinearGradient(colors: isProcessing ? [Color.gray, Color.gray.opacity(0.7)] : [Color.green, Color.green.opacity(0.7)],
                                               startPoint: .leading,
                                               endPoint: .trailing)
                            )
                            .cornerRadius(12)
                        }
                        .disabled(isProcessing)
                    }
                    .padding(.horizontal)
                    
                    // Doctors Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Contact for Diagnosis")
                            .font(.title2)
                            .bold()
                        
                        ForEach(doctors) { doctor in
                            VStack(alignment: .leading, spacing: 5) {
                                Text(doctor.name)
                                    .font(.headline)
                                Text(doctor.specialization)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text(doctor.address)
                                    .font(.footnote)
                                
                                HStack(spacing: 15) {
                                    if let phoneURL = URL(string: "tel:\(doctor.phoneNumber.filter { "+0123456789".contains($0) })") {
                                        Link(destination: phoneURL) {
                                            Label(doctor.phoneNumber, systemImage: "phone.fill")
                                                .foregroundColor(.blue)
                                        }
                                    }
                                    if !doctor.website.isEmpty, let websiteURL = URL(string: doctor.website) {
                                        Link(destination: websiteURL) {
                                            Label("Website", systemImage: "globe")
                                                .foregroundColor(.blue)
                                        }
                                    }
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(UIColor.systemBackground))
                                    .shadow(radius: 3)
                            )
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(
                                LinearGradient(colors: [Color.green.opacity(0.6), Color.blue.opacity(0.6)],
                                               startPoint: .topLeading,
                                               endPoint: .bottomTrailing)
                            )
                            .shadow(radius: 5)
                    )
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
            }
            .padding(.top, 20)
        }
        .background(
            LinearGradient(colors: [Color.green.opacity(0.3), Color.blue.opacity(0.3)],
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
        )
        .navigationTitle("Diagnosis Results")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            startDiagnosis()
        }
    }
    
    private func startDiagnosis() {
        print("📸 DiagnosisView: Starting diagnosis...")
        
        guard let image = image else {
            print("❌ DiagnosisView: No image provided")
            processingError = "No image provided"
            return
        }
        
        print("✅ DiagnosisView: Image received, size: \(image.size)")
        isProcessing = true
        processingError = nil
        diagnosis = ""
        
        print("🔄 DiagnosisView: Calling CoreML service...")
        coreMLService.classifyImage(image) { result in
            DispatchQueue.main.async {
                self.isProcessing = false
                switch result {
                case .success(let prediction):
                    print("✅ DiagnosisView: Received prediction: \(prediction)")
                    self.diagnosis = prediction
                case .failure(let error):
                    print("❌ DiagnosisView: Classification failed: \(error.localizedDescription)")
                    self.processingError = error.localizedDescription
                }
            }
        }
    }
    }
