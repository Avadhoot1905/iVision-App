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
            VStack(spacing: 24) {
                
                // Analyzed Image Section with modern card design
                if let image = image {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "photo.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                            Text("Analyzed Image")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                            Spacer()
                        }
                        
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 280)
                            .frame(maxWidth: .infinity)
                            .clipped()
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                            .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                LinearGradient(colors: [Color.white.opacity(0.2), Color.white.opacity(0.1)],
                                               startPoint: .topLeading,
                                               endPoint: .bottomTrailing)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                    )
                    .padding(.horizontal, 20)
                }
                
                // Diagnosis Section with enhanced modern design
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                        Text("AI Diagnosis")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        if isProcessing {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.9)
                        }
                    }
                    
                    if isProcessing {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 12) {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                Text("Analyzing image...")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            Text("Our AI is examining your image using advanced machine learning algorithms. This may take a few moments.")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(.white.opacity(0.85))
                                .lineSpacing(4)
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.15))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                )
                        )
                    } else {
                        Text(diagnosisSummary)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .lineSpacing(6)
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(0.15))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    )
                            )
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(colors: [Color.green.opacity(0.65), Color.blue.opacity(0.65)],
                                           startPoint: .topLeading,
                                           endPoint: .bottomTrailing)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
                )
                .padding(.horizontal, 20)
                
                // Prevention Tips Section (only show after diagnosis)
                if !isProcessing && !diagnosis.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "heart.text.square.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                            Text("Advice / Prevention Tips")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                            Spacer()
                        }
                        
                        VStack(spacing: 12) {
                            ForEach(preventionTips, id: \.self) { tip in
                                HStack(alignment: .top, spacing: 12) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.white.opacity(0.2))
                                            .frame(width: 28, height: 28)
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(.white)
                                    }
                                    .padding(.top, 2)
                                    
                                    Text(tip)
                                        .font(.system(size: 15, weight: .regular))
                                        .foregroundColor(.white)
                                        .lineSpacing(4)
                                    Spacer()
                                }
                                .padding(14)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white.opacity(0.12))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                        )
                                )
                            }
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                LinearGradient(colors: [Color.green.opacity(0.65), Color.blue.opacity(0.65)],
                                               startPoint: .topLeading,
                                               endPoint: .bottomTrailing)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                            .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
                    )
                    .padding(.horizontal, 20)
                    
                    // Action Buttons with modern styling
                    HStack(spacing: 12) {
                        Button(action: {
                            dismiss()
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 16, weight: .semibold))
                                Text("Retake Photo")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundColor(isProcessing ? .gray.opacity(0.6) : .white)
                            .padding(.vertical, 16)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(
                                        LinearGradient(colors: isProcessing ? 
                                            [Color.gray.opacity(0.3), Color.gray.opacity(0.2)] : 
                                            [Color.blue.opacity(0.8), Color.blue.opacity(0.6)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                    )
                            )
                            .shadow(color: isProcessing ? .clear : .black.opacity(0.15), radius: 8, x: 0, y: 4)
                        }
                        .disabled(isProcessing)
                        
                        Button(action: {
                            // Save diagnosis action
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "square.and.arrow.down.fill")
                                    .font(.system(size: 16, weight: .semibold))
                                Text(isProcessing ? "Processing..." : "Save Report")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundColor(isProcessing ? .gray.opacity(0.6) : .white)
                            .padding(.vertical, 16)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(
                                        LinearGradient(colors: isProcessing ? 
                                            [Color.gray.opacity(0.3), Color.gray.opacity(0.2)] : 
                                            [Color.green.opacity(0.8), Color.green.opacity(0.6)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                    )
                            )
                            .shadow(color: isProcessing ? .clear : .black.opacity(0.15), radius: 8, x: 0, y: 4)
                        }
                        .disabled(isProcessing)
                    }
                    .padding(.horizontal, 20)
                    
                    // Doctors Section with modern card design
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "stethoscope.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                            Text("Contact for Diagnosis")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                            Spacer()
                        }
                        
                        VStack(spacing: 14) {
                            ForEach(doctors) { doctor in
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack {
                                        ZStack {
                                            Circle()
                                                .fill(
                                                    LinearGradient(colors: [Color.blue.opacity(0.3), Color.green.opacity(0.3)],
                                                                   startPoint: .topLeading,
                                                                   endPoint: .bottomTrailing)
                                                )
                                                .frame(width: 50, height: 50)
                                            Image(systemName: "person.fill")
                                                .font(.system(size: 22))
                                                .foregroundColor(.white)
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(doctor.name)
                                                .font(.system(size: 17, weight: .bold))
                                                .foregroundColor(.primary)
                                            Text(doctor.specialization)
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(.secondary)
                                        }
                                        Spacer()
                                    }
                                    
                                    Divider()
                                        .background(Color.gray.opacity(0.3))
                                    
                                    HStack(spacing: 6) {
                                        Image(systemName: "mappin.circle.fill")
                                            .font(.system(size: 14))
                                            .foregroundColor(.blue)
                                        Text(doctor.address)
                                            .font(.system(size: 14, weight: .regular))
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    HStack(spacing: 12) {
                                        if let phoneURL = URL(string: "tel:\(doctor.phoneNumber.filter { "+0123456789".contains($0) })") {
                                            Link(destination: phoneURL) {
                                                HStack(spacing: 6) {
                                                    Image(systemName: "phone.fill")
                                                        .font(.system(size: 13))
                                                    Text("Call")
                                                        .font(.system(size: 14, weight: .semibold))
                                                }
                                                .foregroundColor(.white)
                                                .padding(.horizontal, 16)
                                                .padding(.vertical, 10)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .fill(Color.blue)
                                                )
                                            }
                                        }
                                        
                                        if !doctor.website.isEmpty, let websiteURL = URL(string: doctor.website) {
                                            Link(destination: websiteURL) {
                                                HStack(spacing: 6) {
                                                    Image(systemName: "globe")
                                                        .font(.system(size: 13))
                                                    Text("Website")
                                                        .font(.system(size: 14, weight: .semibold))
                                                }
                                                .foregroundColor(.white)
                                                .padding(.horizontal, 16)
                                                .padding(.vertical, 10)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .fill(Color.green)
                                                )
                                            }
                                        }
                                    }
                                }
                                .padding(18)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color(UIColor.systemBackground))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                        )
                                        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
                                )
                            }
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                LinearGradient(colors: [Color.green.opacity(0.65), Color.blue.opacity(0.65)],
                                               startPoint: .topLeading,
                                               endPoint: .bottomTrailing)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                            .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
                    )
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
            }
            .padding(.top, 20)
        }
        .background(
            LinearGradient(colors: [Color.lightGreen.opacity(0.4), Color.deepBlue.opacity(0.4)],
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .ignoresSafeArea()
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
