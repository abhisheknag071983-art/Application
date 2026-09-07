import SwiftUI
import UIKit

struct SignBlockView: View {
    @Binding var job: Job
    @State private var strokes: [[CGPoint]] = []
    @State private var canvasSize: CGSize = CGSize(width: 300, height: 130)

    var body: some View {
        BlockContainer(label: "Customer signature", isComplete: job.signComplete, isRequired: true) {
            VStack(alignment: .leading, spacing: 10) {
                TextField("Name of person signing", text: $job.signedBy)
                    .padding(13)
                    .background(Theme.card)
                    .overlay(Rectangle().stroke(Theme.rule, lineWidth: 1))

                signatureArea
            }
        }
    }

    @ViewBuilder
    private var signatureArea: some View {
        switch job.signature {
        case .captured(let data):
            if let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 130)
                    .frame(maxWidth: .infinity)
                    .background(Theme.card)
                    .overlay(Rectangle().stroke(Theme.green, lineWidth: 1))
            }
            LinkButtonView(title: "Sign again") {
                strokes = []
                job.signature = .none
            }
        case .seed, .none:
            SignatureCanvas(strokes: $strokes)
                .frame(height: 130)
                .background(
                    GeometryReader { proxy in
                        Color.clear.onAppear { canvasSize = proxy.size }
                    }
                )

            HStack(spacing: 8) {
                SecondaryButton(title: "Save signature", action: saveSignature)
                SecondaryButton(title: "Clear", action: clearSignature)
            }

            Text("Hand the phone over and let them sign with a finger.")
                .font(.system(size: 13))
                .foregroundColor(Theme.muted)
        }
    }

    private func saveSignature() {
        guard !strokes.isEmpty, let data = renderSignatureImage(strokes: strokes, size: canvasSize) else { return }
        job.signature = .captured(data)
    }

    private func clearSignature() {
        strokes = []
        job.signature = .none
    }
}
