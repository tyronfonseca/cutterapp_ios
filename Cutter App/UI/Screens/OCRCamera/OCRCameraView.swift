//
//  OCRCameraView.swift
//  Cutter App
//
//  Created by Tyron on 2/9/26.
//

import SwiftUI
import Vision
import VisionKit

struct OCRCameraView: View {
    @Binding var lastName: String
    @Binding var firstName: String
    
    var selectedTab: Binding<Main.AppTab>? = nil
    
    @Environment(\.dismiss) private var dismiss
    @State private var captureImage: UIImage?
    @State private var showCamera: Bool = false
    @State private var recognizedText: [String] = []
    
    var body: some View {
        VStack(spacing: 20) {
            // Image Preview Area
            if let captureImage = captureImage {
                Image(uiImage: captureImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 250)
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
            } else {
                ContentUnavailableView(
                    "no_image",
                    systemImage: "document.viewfinder",
                    description: Text("tap_to_scan")
                )
                .frame(height: 200)
            }
            
            // Scanned Text Results Card
            VStack {
                if !recognizedText.isEmpty {
                    Text("results_scan_caption")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 4)
                    List {
                        ForEach(recognizedText, id: \.self) { text in
                            Button(action: { selectAndAssignNames(from: text) }) {
                                HStack {
                                    Text(text)
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Image(systemName: "magnifyingglass")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            .listRowBackground(Color.clear)
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .frame(maxHeight: 300)
                } else {
                    ContentUnavailableView(
                        "results_scan",
                        systemImage: "rectangle.and.text.magnifyingglass",
                        description: Text("results_scan_description")
                    )
                    .padding(.vertical, 20)
                }
            }.toCard()
            
            // Action Button
            Button("scan_document", systemImage: "document.viewfinder", action: { showCamera = true })
                .buttonStyle(.glassProminent)
                .controlSize(.large)
        }
        .padding()
        
        .sheet(isPresented: $showCamera) {
            CameraView(selectedImage: $captureImage)
        }
        .onChange(of: captureImage) { _, newImage in
            if let newImage {
                performOCR(on: newImage)
            }
        }
    }
    
    private func selectAndAssignNames(from text: String) {
        let components = text.split(separator: " ").map { String($0).trimmingCharacters(in: .whitespaces) }
        
        guard !components.isEmpty else { return }
        
        if components.count == 1 {
            self.firstName = ""
            self.lastName = components[0]
        } else {
            self.lastName = components.last ?? ""
            self.firstName = components.first ?? ""
        }
        
        if let selectedTab = selectedTab {
            selectedTab.wrappedValue = .home
        }
    }
    
    private func performOCR(on image: UIImage) {
        guard let cgImage = image.cgImage else { return }
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        let request = VNRecognizeTextRequest { request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation], error == nil else {
                DispatchQueue.main.async { self.recognizedText = [] }
                return
            }
            
            let textResults = observations.compactMap { observation in
                observation.topCandidates(1).first?.string
            }
            
            DispatchQueue.main.async {
                self.recognizedText = textResults
            }
        }
        
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try requestHandler.perform([request])
            } catch {
                DispatchQueue.main.async {
                    let msg = String(localized: "failed_extract_text_error", defaultValue: "Failed to extract text.")
                    self.recognizedText = [msg]
                    print(error.localizedDescription)
                }
            }
        }
    }
}

#Preview {
    OCRCameraView(lastName: .constant("Doe"), firstName: .constant("John"))
}
