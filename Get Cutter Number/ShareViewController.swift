//
//  ShareViewController.swift
//  Cutter App
//
//  Created by Tyron on 4/9/26.
//

import UIKit

final class ShareViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Task {
            await loadAndOpen()
        }
    }
    
    private func loadAndOpen() async {
        guard let item = extensionContext?.inputItems.first as? NSExtensionItem,
              let itemProvider = item.attachments?.first else {
            close()
            return
        }
        
        let textDataType = "public.plain-text"
        if itemProvider.hasItemConformingToTypeIdentifier(textDataType) {
            do {
                let providedText = try await itemProvider.loadItem(forTypeIdentifier: textDataType, options: nil)
                if let text = providedText as? String {
                    await openApp(with: text)
                } else if let text = providedText as? NSString {
                    await openApp(with: text as String)
                } else {
                    close()
                }
            } catch {
                close()
            }
        } else {
            close()
        }
    }
    
    private func openApp(with query: String) async {
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "cutterapp://search?query=\(encodedQuery)"
        
        guard let url = URL(string: urlString) else {
            close()
            return
        }
                
        // Try extensionContext first
        let opened = await withCheckedContinuation { continuation in
            extensionContext?.open(url) { success in
                continuation.resume(returning: success)
            } ?? continuation.resume(returning: false)
        }
        
        // Fall back to responder chain
        if !opened {
            openViaResponderChain(url)
        }
        
        close()
    }
    
    private func openViaResponderChain(_ url: URL) {
        var responder: UIResponder? = self
        while let current = responder {
            if let application = current as? UIApplication {
                application.open(url, options: [:], completionHandler: nil)
                return
            }
            responder = current.next
        }
    }
    
    private func close() {
        extensionContext?.completeRequest(returningItems: nil)
    }
}
