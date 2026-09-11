//
//  SearchMenuPicker.swift
//  Cutter App
//
//  Created by Tyron on 11/9/26.
//

import SwiftUI

struct SearchMenuPicker<Option: SearchOptionSelectable>: View {
    let iconName: String
    let titleKey: LocalizedStringKey
    let iconAccessibilityID: String
    let pickerAccessibilityID: String
    @Binding var selection: Option

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: iconName)
                .font(.caption)
                .foregroundStyle(.secondary)
                .accessibilityIdentifier(iconAccessibilityID)

            Picker(titleKey, selection: $selection) {
                ForEach(Array(Option.allCases)) { option in
                    optionRow(for: option)
                }
            }
            .accessibilityIdentifier(pickerAccessibilityID)
            .pickerStyle(.menu)
            .buttonStyle(.glass)
            .lineLimit(1)
            .fixedSize(horizontal: true, vertical: false)
        }
    }

    @ViewBuilder
    private func optionRow(for option: Option) -> some View {
        Text(option.localizedName)
            .tag(option)
            .accessibilityIdentifier(option.accessibilityID)
    }
}
