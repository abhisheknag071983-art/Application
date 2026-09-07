import SwiftUI
import UIKit

struct SignatureCanvas: View {
    @Binding var strokes: [[CGPoint]]
    @State private var currentStroke: [CGPoint] = []

    var body: some View {
        Canvas { context, _ in
            for stroke in strokes + [currentStroke] {
                guard stroke.count > 1 else { continue }
                var path = Path()
                path.move(to: stroke[0])
                for point in stroke.dropFirst() {
                    path.addLine(to: point)
                }
                context.stroke(
                    path,
                    with: .color(Theme.steel),
                    style: StrokeStyle(lineWidth: 2.2, lineCap: .round, lineJoin: .round)
                )
            }
        }
        .background(Theme.card)
        .overlay(Rectangle().strokeBorder(Theme.rule, style: StrokeStyle(lineWidth: 1, dash: [4])))
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    currentStroke.append(value.location)
                }
                .onEnded { _ in
                    if !currentStroke.isEmpty {
                        strokes.append(currentStroke)
                        currentStroke = []
                    }
                }
        )
    }
}

@MainActor
func renderSignatureImage(strokes: [[CGPoint]], size: CGSize) -> Data? {
    guard size.width > 0, size.height > 0 else { return nil }
    let canvas = SignatureCanvas(strokes: .constant(strokes))
        .frame(width: size.width, height: size.height)
        .background(Color.white)
    let renderer = ImageRenderer(content: canvas)
    renderer.scale = UIScreen.main.scale
    guard let uiImage = renderer.uiImage else { return nil }
    return uiImage.pngData()
}
