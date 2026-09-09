//
//  EditSearchItemView.swift
//  Cutter App
//
//  Created by Tyron on 5/9/26.
//

import SwiftUI

struct EditSearchItemView: View {
    @Environment(AppSharedData.self) private var sharedData
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @Binding var item: CutterData
    @State private var showingDeleteAlert = false
    
    var onDelete: (() -> Void)? = nil
    var onEdit: ((_ item: CutterData) -> Void)? = nil
    
    var body: some View {
        Form {
            if item.needsReview {
                Section {
                    HStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.yellow)
                            .font(.title3)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Review Required")
                                .font(.subheadline)
                                .bold()
                            Text("Check the author name or surname to generate a valid Cutter number.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Button {
                            withAnimation {
                                item.needsReview = false
                            }
                        } label: {
                            Image(systemName: "xmark")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .padding(6)
                                .contentShape(Circle())
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.vertical, 4)
                }
            }
            
            Section(header: Text("Cutter Number Used")) {
                ReadOnlyField(text: item.cutterUsed.isEmpty ? "No Cutter Code" : item.cutterUsed)
            }
            
            Section(
                header: Text("Author"),
                footer: Text("Verify that the name of the author is correct.")
            ) {
                TextField(
                    item.dontSeparateName ? "Name" : "Surname",
                    text: $item.authorSurname
                )
                if !item.dontSeparateName {
                    TextField(
                        "Name (optional)",
                        text: $item.authorName
                    )
                }
            }
            
            Section(
                footer: Text("If the author is an institution, organization or your system uses the name instead of the surname to get the cutter number set this to ON. If you want this option set to ON by default go to the Settings screen inside the app.")
            ) {
                Toggle(
                    "Author has no surname",
                    isOn: $item.dontSeparateName
                )
                .toggleStyle(.switch)
            }
            
            Section(header: Text("Book"), footer: Text(item.isbn.isEmpty ? "" : "Data taken from OpenLibray.org it may be inaccurate")) {
                TextField("Add or modify the book", text: $item.bookName)
            }
            
            if !item.isbn.isEmpty {
                Section(header: Text("ISBN")) {
                    ReadOnlyField(text: item.isbn)
                }
            }
            
            if !item.ddcs.isEmpty {
                Section(
                    header: Text("Possible DDCs"),
                    footer: Text("Data taken from OpenLibrary.org; it may be inaccurate.")
                ) {
                    Picker("Select DDC", selection: $item.ddcSelected) {
                        ForEach(item.ddcs, id: \.self) { ddc in
                            Text(ddc).tag(ddc)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }
        }
        .navigationTitle("Edit cutter")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: item) { recalculateAndSave() }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(role: .destructive) {
                    showingDeleteAlert = true
                } label: {
                    Label("Delete", systemImage: "trash")
                        .foregroundStyle(.red)
                }
            }
        }
        .alert("Delete Item?", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                onDelete?()
                dismiss()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to delete this entry? This action cannot be undone.")
        }
    }
    
    private func recalculateAndSave() {
        let options = CutterSearchOptions(
            settings: sharedData.settings,
            dontSeparateName: item.dontSeparateName
        )
        
        if let newCutter = sharedData.search(
            name: item.authorName,
            lastName: item.authorSurname,
            options: options
        ) {
            item.code = newCutter.code
            item.name = newCutter.name
            item.needsReview = false
        }
        
        onEdit?(item)
    }
}

#Preview {
    EditSearchItemView(
        item: .constant(
            CutterData(
                name: "Test, prueba",
                code: "251",
                authorName: "Name test",
                authorSurname: "Surname test",
                isbn: "1234567890123",
                bookName: "The King in Yellow",
                ddc: ["881.1", "23.5", "153.5"],
                needsReview: true
            )
        )
    )
    .environment(AppSharedData())
}
