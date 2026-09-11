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
                DataScannerRepresentable { scannedValue in
                    self.searchText = scannedValue
                    dismiss()
                }
                .ignoresSafeArea()
            } else {
                ContentUnavailableView(
                    String(localized: "ocrcamera_unavailable_title"),
                    systemImage: "camera.badge.ellipsis",
                    description: Text(String(localized: "ocrcamera_unavailable_message"))
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

// MARK: - VisionKit Live Text & Barcode Camera Wrapper

struct DataScannerRepresentable: UIViewControllerRepresentable {
    var onScannedValue: (String) -> Void

    func makeUIViewController(context: Context) -> DataScannerViewController {
        let scanner = DataScannerViewController(
            recognizedDataTypes: [
                .text(),
                .barcode(symbologies: [.ean13, .ean8])
            ],
            qualityLevel: .balanced,
            recognizesMultipleItems: false,
            isHighFrameRateTrackingEnabled: false,
            isHighlightingEnabled: true
        )
        scanner.delegate = context.coordinator
        try? scanner.startScanning()
        return scanner
    }

    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onScannedValue: onScannedValue)
    }

    class Coordinator: NSObject, DataScannerViewControllerDelegate {
        var onScannedValue: (String) -> Void

        init(onScannedValue: @escaping (String) -> Void) {
            self.onScannedValue = onScannedValue
        }

        func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
            switch item {
            case .text(let text):
                DispatchQueue.main.async {
                    self.onScannedValue(text.transcript)
                }
            case .barcode(let barcode):
                if let payload = barcode.payloadStringValue {
                    DispatchQueue.main.async {
                        self.onScannedValue(payload)
                    }
                }
            @unknown default:
                break
            }
        }
    }
}

#Preview {
    OCRCameraView(searchText: .constant("John Doe"))
}
