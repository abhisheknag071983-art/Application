import SwiftUI
import UIKit

enum PDFGenerator {
    static func generate(for job: Job, dateString: String) -> Data {
        let pageWidth: CGFloat = 612
        let pageHeight: CGFloat = 792
        let margin: CGFloat = 48
        let contentWidth = pageWidth - margin * 2

        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight))

        return renderer.pdfData { context in
            context.beginPage()
            var y: CGFloat = margin

            func draw(_ text: String, font: UIFont, color: UIColor = .black, spacingAfter: CGFloat = 4) {
                let attrs: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: color]
                let bounding = (text as NSString).boundingRect(
                    with: CGSize(width: contentWidth, height: .greatestFiniteMagnitude),
                    options: .usesLineFragmentOrigin,
                    attributes: attrs,
                    context: nil
                )
                (text as NSString).draw(
                    in: CGRect(x: margin, y: y, width: contentWidth, height: bounding.height),
                    withAttributes: attrs
                )
                y += bounding.height + spacingAfter
            }

            func rule(_ height: CGFloat = 1, gap: CGFloat = 10) {
                context.cgContext.setFillColor(UIColor(white: 0.84, alpha: 1).cgColor)
                context.cgContext.fill(CGRect(x: margin, y: y, width: contentWidth, height: height))
                y += height + gap
            }

            draw("Ridgeway Electrical", font: .boldSystemFont(ofSize: 18))
            draw("NICEIC 84102 · 07700 900000", font: .systemFont(ofSize: 11), color: .darkGray, spacingAfter: 10)
            rule(2)

            draw("Job: \(job.id)", font: .systemFont(ofSize: 12))
            draw("Customer: \(job.customer)", font: .systemFont(ofSize: 12))
            draw("Site: \(job.address)", font: .systemFont(ofSize: 12))
            draw("Attended: From \(job.arrived ?? "--:--"), \(dateString)", font: .systemFont(ofSize: 12))
            draw("Work: \(job.type)", font: .systemFont(ofSize: 12), spacingAfter: 14)

            draw("Work carried out", font: .boldSystemFont(ofSize: 13), spacingAfter: 6)
            draw(job.notes.isEmpty ? "—" : job.notes, font: .systemFont(ofSize: 12), spacingAfter: 14)

            draw("Safety checks completed", font: .boldSystemFont(ofSize: 13), spacingAfter: 6)
            for item in checklistItems {
                let ok = job.checks[item] == true
                draw(
                    (ok ? "✓ " : "✕ ") + item,
                    font: .systemFont(ofSize: 12),
                    color: ok ? UIColor(Theme.green) : UIColor(Theme.red),
                    spacingAfter: 3
                )
            }
            y += 10

            if !job.parts.isEmpty {
                draw("Parts and materials", font: .boldSystemFont(ofSize: 13), spacingAfter: 6)
                for part in job.parts {
                    draw(
                        "\(part.qty) × \(part.desc) — £\(String(format: "%.2f", part.lineTotal))",
                        font: .systemFont(ofSize: 12),
                        spacingAfter: 3
                    )
                }
                draw("Total: £\(String(format: "%.2f", job.partsTotal))", font: .boldSystemFont(ofSize: 12), spacingAfter: 14)
            }

            if !job.photos.isEmpty {
                draw("Photographs", font: .boldSystemFont(ofSize: 13), spacingAfter: 6)
                let thumbSize: CGFloat = 110
                let gap: CGFloat = 10
                var x = margin
                let rowStartY = y
                var rowMaxY = y
                for photo in job.photos {
                    if x + thumbSize > margin + contentWidth {
                        x = margin
                        y = rowMaxY + 18
                    }
                    if let image = UIImage(data: photo.imageData) {
                        image.draw(in: CGRect(x: x, y: y, width: thumbSize, height: thumbSize))
                    }
                    let caption = photo.caption.isEmpty ? "No caption" : photo.caption
                    (caption as NSString).draw(
                        in: CGRect(x: x, y: y + thumbSize + 2, width: thumbSize, height: 14),
                        withAttributes: [.font: UIFont.systemFont(ofSize: 9), .foregroundColor: UIColor.darkGray]
                    )
                    rowMaxY = max(rowMaxY, y + thumbSize + 16)
                    x += thumbSize + gap
                }
                _ = rowStartY
                y = rowMaxY + 8
            }

            draw("Signed on completion", font: .boldSystemFont(ofSize: 13), spacingAfter: 6)
            if case .captured(let imgData) = job.signature, let image = UIImage(data: imgData) {
                let sigHeight: CGFloat = 60
                let sigWidth: CGFloat = min(contentWidth, 200)
                image.draw(in: CGRect(x: margin, y: y, width: sigWidth, height: sigHeight))
                y += sigHeight + 6
            }
            draw(
                "\(job.signedBy.isEmpty ? job.customer : job.signedBy) · \(dateString)",
                font: .systemFont(ofSize: 11)
            )
        }
    }
}
