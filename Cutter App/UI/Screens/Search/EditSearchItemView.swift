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
                        Image(systemName: "exclamationmark.circle.fill")
                            .foregroundStyle(.orange)
                            .font(.title3)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(String(localized: "edit_review_required"))
                                .font(.subheadline)
                                .bold()
                            Text(String(localized: "edit_review_required_message"))
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
            
            Section(header: Text(String(localized: "edit_cutter_number_used"))) {
                ReadOnlyField(text: item.cutterUsed.isEmpty ? String(localized: "edit_no_cutter_code") : item.cutterUsed)
            }
            
            Section(
                header: Text(String(localized: "author")),
                footer: Text(String(localized: "edit_verify_author_name"))
            ) {
                TextField(
                    item.dontSeparateName ? String(localized: "name") : String(localized: "surname"),
                    text: $item.authorSurname
                )
                if !item.dontSeparateName {
                    TextField(
                        String(localized: "edit_name_optional"),
                        text: $item.authorName
                    )
                }
            }
            
            Section(
                footer: Text(String(localized: "edit_toggle_footer"))
            ) {
                Toggle(
                    String(localized: "edit_author_has_no_surname"),
                    isOn: $item.dontSeparateName
                )
                .toggleStyle(.switch)
            }
            
            Section(header: Text(String(localized: "book")), footer: Text(item.isbn.isEmpty ? "" : String(localized: "edit_data_warning"))) {
                TextField(String(localized: "edit_add_or_modify_book"), text: $item.bookName)
            }
            
            if !item.ddcs.isEmpty {
                Section(
                    header: Text(String(localized: "edit_possible_ddc")),
                    footer: Text(String(localized: "edit_data_warning"))
                ) {
                    Picker(String(localized: "selected"), selection: $item.ddcSelected) {
                        ForEach(item.ddcs, id: \.self) { ddc in
                            Text(ddc).tag(ddc)
                        }
                    }
                    .pickerStyle(.menu)
                    .onAppear {
                        if item.ddcSelected.isEmpty, let firstDDC = item.ddcs.first {
                            item.ddcSelected = firstDDC
                        }
                    }
                }
            }
            
            if !item.isbn.isEmpty {
                Section(header: Text("isbn")) {
                    ReadOnlyField(text: item.isbn)
                }
            }
            
        }
        .navigationTitle(String(localized: "edit_edit_cutter"))
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: item) { recalculateAndSave() }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(role: .destructive) {
                    showingDeleteAlert = true
                } label: {
                    Label(String(localized: "delete"), systemImage: "trash")
                        .foregroundStyle(.red)
                }
            }
        }
        .alert(String(localized: "edit_delete_item_title"), isPresented: $showingDeleteAlert) {
            Button(String(localized: "delete"), role: .destructive) {
                onDelete?()
                dismiss()
            }
            Button(String(localized: "cancel"), role: .cancel) { }
        } message: {
            Text(String(localized: "edit_delete_item_message"))
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
