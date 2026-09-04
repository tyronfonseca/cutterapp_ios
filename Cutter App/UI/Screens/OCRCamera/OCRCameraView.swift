//
//  OCRCameraView.swift
//  Cutter App
//
//  Created by Tyron on 2/9/26.
//

import SwiftUI
import VisionKit

struct OCRCameraView: View {
    @Binding var searchText: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack(alignment: .topTrailing) {
            if DataScannerViewController.isSupported && DataScannerViewController.isAvailable {
                DataScannerRepresentable { recognizedText in
                    self.searchText = recognizedText
                    dismiss()
                }
                .ignoresSafeArea()
            } else {
                ContentUnavailableView(
                    "Camera Unavailable",
                    systemImage: "camera.badge.ellipsis",
                    description: Text("Data scanning is not supported or camera permission is restricted on this device.")
                )
            }

            // Close Button
            Button(action: { dismiss() }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title)
                    .foregroundStyle(.white, .black.opacity(0.6))
                    .padding()
            }
        }
    }
}

// MARK: - VisionKit Live Text Camera Wrapper

struct DataScannerRepresentable: UIViewControllerRepresentable {
    var onTextSelected: (String) -> Void

    func makeUIViewController(context: Context) -> DataScannerViewController {
        let scanner = DataScannerViewController(
            recognizedDataTypes: [.text()],
            qualityLevel: .balanced,
            recognizesMultipleItems: true,
            isHighFrameRateTrackingEnabled: true,
            isHighlightingEnabled: true
        )
        scanner.delegate = context.coordinator
        try? scanner.startScanning()
        return scanner
    }

    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onTextSelected: onTextSelected)
    }

    class Coordinator: NSObject, DataScannerViewControllerDelegate {
        var onTextSelected: (String) -> Void

        init(onTextSelected: @escaping (String) -> Void) {
            self.onTextSelected = onTextSelected
        }

        func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
            switch item {
            case .text(let text):
                DispatchQueue.main.async {
                    self.onTextSelected(text.transcript)
                }
            default:
                break
            }
        }
    }
}

#Preview {
    OCRCameraView(searchText: .constant("John Doe"))
}
