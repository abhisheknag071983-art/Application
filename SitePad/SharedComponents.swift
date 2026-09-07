import SwiftUI
import UIKit

struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var enabled: Bool = true

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(Theme.surface)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(enabled ? Theme.steel : Theme.disabled)
        }
        .disabled(!enabled)
    }
}

struct SecondaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(Theme.steel)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 13)
                .background(Theme.card)
                .overlay(Rectangle().stroke(Theme.steel, lineWidth: 1))
        }
    }
}

struct LinkButtonView: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13))
                .foregroundColor(Theme.muted)
                .underline()
        }
        .padding(.top, 6)
    }
}

struct LabeledField: View {
    let label: String
    @Binding var text: String
    var placeholder: String = ""
    var keyboard: UIKeyboardType = .default

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Theme.muted)
            TextField(placeholder, text: $text)
                .keyboardType(keyboard)
                .font(.system(size: 16))
                .padding(13)
                .background(Theme.card)
                .overlay(Rectangle().stroke(Theme.rule, lineWidth: 1))
        }
    }
}

struct BarHeader: View {
    let title: String
    var subtitle: String?
    let onBack: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Button(action: onBack) {
                Text("‹ Back")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Theme.amber)
            }
            Text(title)
                .font(.system(size: 21, weight: .bold))
                .foregroundColor(Theme.surface)
            if let subtitle {
                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundColor(Theme.dimText)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(EdgeInsets(top: 16, leading: 20, bottom: 16, trailing: 20))
        .background(Theme.steel)
    }
}

struct BlockContainer<Content: View>: View {
    let label: String
    var isComplete: Bool = false
    var isRequired: Bool = false
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Text(label).font(.system(size: 15, weight: .bold))
                if isRequired && !isComplete {
                    Text("Needed")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Theme.red)
                }
                if isComplete {
                    Text("✓")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(Theme.green)
                }
                Spacer()
            }
            content
        }
        .foregroundColor(Theme.steel)
        .padding(18)
        .overlay(Rectangle().frame(height: 1).foregroundColor(Theme.rule), alignment: .bottom)
    }
}
