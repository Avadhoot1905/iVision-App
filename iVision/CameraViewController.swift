//import SwiftUI
//
//class GooglePlacesService: ObservableObject {
//    @Published var doctors: [Doctor] = []
//    
//    private let apiKey = "REPLACE_WITH_API_KEY" // Replace with your actual API key
//    
//    func fetchDoctors(for query: String) {
//        let queryEncoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
//        let urlString = "https://maps.googleapis.com/maps/api/place/textsearch/json?query=\(queryEncoded)&key=\(apiKey)"
//        
//        guard let url = URL(string: urlString) else { return }
//        
//        URLSession.shared.dataTask(with: url) { data, _, error in
//            guard let data = data, error == nil else { return }
//            do {
//                let response = try JSONDecoder().decode(TextSearchResponse.self, from: data)
//                let placeResults = response.results
//                
//                var fetchedDoctors: [Doctor] = []
//                let group = DispatchGroup()
//                
//                for place in placeResults {
//                    group.enter()
//                    self.fetchPlaceDetails(placeId: place.placeId) { details in
//                        if let details = details {
//                            let doctor = Doctor(
//                                name: place.name,
//                                specialization: details.types.first ?? "Eye Specialist",
//                                address: details.formattedAddress,
//                                phoneNumber: details.formattedPhoneNumber ?? "N/A",
//                                website: details.website ?? ""
//                            )
//                            fetchedDoctors.append(doctor)
//                        }
//                        group.leave()
//                    }
//                }
//                
//                group.notify(queue: .main) {
//                    self.doctors = fetchedDoctors
//                }
//            } catch {
//                print("Failed to decode TextSearchResponse: \(error)")
//            }
//        }.resume()
//    }
//    
//    private func fetchPlaceDetails(placeId: String, completion: @escaping (PlaceDetails?) -> Void) {
//        let urlString = "https://maps.googleapis.com/maps/api/place/details/json?place_id=\(placeId)&fields=name,formatted_address,formatted_phone_number,website,types&key=\(apiKey)"
//        
//        guard let url = URL(string: urlString) else {
//            completion(nil)
//            return
//        }
//        
//        URLSession.shared.dataTask(with: url) { data, _, error in
//            guard let data = data, error == nil else {
//                completion(nil)
//                return
//            }
//            do {
//                let response = try JSONDecoder().decode(PlaceDetailsResponse.self, from: data)
//                completion(response.result)
//            } catch {
//                print("Failed to decode PlaceDetailsResponse: \(error)")
//                completion(nil)
//            }
//        }.resume()
//    }
//}
//
//struct TextSearchResponse: Codable {
//    let results: [PlaceResult]
//}
//
//struct PlaceResult: Codable {
//    let placeId: String
//    let name: String
//    
//    enum CodingKeys: String, CodingKey {
//        case placeId = "place_id"
//        case name
//    }
//}
//
//struct PlaceDetailsResponse: Codable {
//    let result: PlaceDetails?
//}
//
//struct PlaceDetails: Codable {
//    let formattedAddress: String
//    let formattedPhoneNumber: String?
//    let website: String?
//    let types: [String]
//    
//    enum CodingKeys: String, CodingKey {
//        case formattedAddress = "formatted_address"
//        case formattedPhoneNumber = "formatted_phone_number"
//        case website
//        case types
//    }
//}
//
//struct Doctor: Identifiable {
//    let id = UUID()
//    let name: String
//    let specialization: String
//    let address: String
//    let phoneNumber: String
//    let website: String
//}
//
//struct DiagnosisView: View {
//    let diagnosisSummary = "You have been diagnosed with mild myopia. It is recommended to avoid prolonged screen time and ensure proper lighting while reading."
//    
//    let preventionTips = [
//        "Take regular breaks using the 20-20-20 rule: every 20 minutes, look at something 20 feet away for 20 seconds.",
//        "Maintain proper posture and screen distance.",
//        "Ensure adequate lighting while reading or using screens.",
//        "Wear prescribed glasses or contact lenses consistently.",
//        "Schedule regular eye check-ups."
//    ]
//    
//    @StateObject private var placesService = GooglePlacesService()
//    
//    var body: some View {
//        ScrollViewReader { scrollProxy in
//            ScrollView(.vertical, showsIndicators: false) {
//                VStack(spacing: 20) {
//                    // Patient Diagnosis Section
//                    VStack(alignment: .leading, spacing: 10) {
//                        Text("Patient Diagnosis")
//                            .font(.title2)
//                            .fontWeight(.bold)
//                        Text(diagnosisSummary)
//                            .font(.body)
//                            .foregroundColor(.primary)
//                    }
//                    .padding()
//                    .background(
//                        RoundedRectangle(cornerRadius: 15)
//                            .fill(
//                                LinearGradient(
//                                    gradient: Gradient(colors: [Color.lightGreen, Color.deepBlue]),
//                                    startPoint: .topLeading,
//                                    endPoint: .bottomTrailing
//                                )
//                            )
//                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
//                    )
//                    .padding(.horizontal)
//                    
//                    // Advice / Prevention Tips Section
//                    VStack(alignment: .leading, spacing: 10) {
//                        Text("Advice / Prevention Tips")
//                            .font(.title2)
//                            .fontWeight(.bold)
//                        
//                        ForEach(preventionTips, id: \.self) { tip in
//                            HStack(alignment: .top) {
//                                Image(systemName: "checkmark.seal.fill")
//                                    .foregroundColor(.green)
//                                Text(tip)
//                                    .font(.body)
//                                    .foregroundColor(.primary)
//                            }
//                            .padding(.vertical, 4)
//                        }
//                    }
//                    .padding()
//                    .background(
//                        RoundedRectangle(cornerRadius: 15)
//                            .fill(
//                                LinearGradient(
//                                    gradient: Gradient(colors: [Color.lightGreen, Color.deepBlue]),
//                                    startPoint: .topLeading,
//                                    endPoint: .bottomTrailing
//                                )
//                            )
//                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
//                    )
//                    .padding(.horizontal)
//                    
//                    // Contact for Diagnosis Section
//                    VStack(alignment: .leading, spacing: 10) {
//                        Text("Contact for Diagnosis")
//                            .font(.title2)
//                            .fontWeight(.bold)
//                        
//                        if placesService.doctors.isEmpty {
//                            Text("Loading doctors...")
//                                .foregroundColor(.secondary)
//                                .onAppear {
//                                    placesService.fetchDoctors(for: "eye doctors near me")
//                                }
//                        } else {
//                            ForEach(placesService.doctors) { doctor in
//                                if let mapsURL = URL(string: "https://www.google.com/maps/search/?api=1&query=\(doctor.address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") {
//                                    Link(destination: mapsURL) {
//                                        VStack(alignment: .leading, spacing: 5) {
//                                            Text(doctor.name)
//                                                .font(.headline)
//                                            Text(doctor.specialization)
//                                                .font(.subheadline)
//                                                .foregroundColor(.secondary)
//                                            Text(doctor.address)
//                                                .font(.footnote)
//                                                .foregroundColor(.primary)
//                                            
//                                            HStack(spacing: 15) {
//                                                if let phoneURL = URL(string: "tel:\(doctor.phoneNumber.filter { "+0123456789".contains($0) })") {
//                                                    Link(destination: phoneURL) {
//                                                        Label(doctor.phoneNumber, systemImage: "phone.fill")
//                                                            .foregroundColor(.blue)
//                                                    }
//                                                } else {
//                                                    Text(doctor.phoneNumber)
//                                                        .font(.footnote)
//                                                        .foregroundColor(.secondary)
//                                                }
//                                                
//                                                if !doctor.website.isEmpty, let websiteURL = URL(string: doctor.website) {
//                                                    Link(destination: websiteURL) {
//                                                        Label("Website", systemImage: "globe")
//                                                            .foregroundColor(.blue)
//                                                    }
//                                                }
//                                            }
//                                        }
//                                        .padding()
//                                        .background(
//                                            RoundedRectangle(cornerRadius: 12)
//                                                .fill(Color(UIColor.systemBackground))
//                                                .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
//                                        )
//                                    }
//                                }
//                            }
//                        }
//                    }
//                    .padding()
//                    .background(
//                        RoundedRectangle(cornerRadius: 15)
//                            .fill(
//                                LinearGradient(
//                                    gradient: Gradient(colors: [Color.lightGreen, Color.deepBlue]),
//                                    startPoint: .topLeading,
//                                    endPoint: .bottomTrailing
//                                )
//                            )
//                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
//                    )
//                    .padding(.horizontal)
//                    .padding(.bottom, 30)
//                }
//                .padding(.top, 20)
//                // Remove this line to avoid unnecessary animation
//                // .animation(.easeInOut, value: UUID())
//            }
//        }
//        .background(
//            LinearGradient(
//                gradient: Gradient(colors: [Color.lightGreen, Color.deepBlue]),
//                startPoint: .topLeading,
//                endPoint: .bottomTrailing
//            )
//            .edgesIgnoringSafeArea(.all)
//        )
//    }
//}
//
//struct DiagnosisView_Previews: PreviewProvider {
//    static var previews: some View {
//        DiagnosisView()
//    }
//}
