import SwiftUI
import PhotosUI
import UIKit

struct PhotoBlockView: View {
    @Binding var job: Job
    @State private var selectedItems: [PhotosPickerItem] = []

    var body: some View {
        BlockContainer(label: "Photos", isComplete: job.photosComplete) {
            VStack(spacing: 12) {
                ForEach(Array(job.photos.enumerated()), id: \.element.id) { index, photo in
                    HStack(alignment: .top, spacing: 12) {
                        if let uiImage = UIImage(data: photo.imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 84, height: 84)
                                .clipped()
                                .overlay(Rectangle().stroke(Theme.rule, lineWidth: 1))
                        }
                        VStack(alignment: .leading, spacing: 6) {
                            TextField(
                                index == 0 ? "Before — describe what this shows" : "Describe what this shows",
                                text: captionBinding(for: photo.id)
                            )
                            .font(.system(size: 14))
                            .padding(10)
                            .background(Theme.card)
                            .overlay(Rectangle().stroke(Theme.rule, lineWidth: 1))

                            LinkButtonView(title: "Remove") {
                                job.photos.removeAll { $0.id == photo.id }
                            }
                        }
                    }
                }

                PhotosPicker(selection: $selectedItems, matching: .images) {
                    Text(job.photos.isEmpty ? "Add photos" : "Add another photo")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Theme.steel)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                        .background(Theme.card)
                        .overlay(Rectangle().stroke(Theme.steel, lineWidth: 1))
                }
                .onChange(of: selectedItems) { newItems in
                    Task { await loadPhotos(newItems) }
                }

                Text("Captioned photos are what stop a dispute three months later.")
                    .font(.system(size: 13))
                    .foregroundColor(Theme.muted)
            }
        }
    }

    private func captionBinding(for id: UUID) -> Binding<String> {
        Binding(
            get: { job.photos.first(where: { $0.id == id })?.caption ?? "" },
            set: { newValue in
                if let idx = job.photos.firstIndex(where: { $0.id == id }) {
                    job.photos[idx].caption = newValue
                }
            }
        )
    }

    private func loadPhotos(_ items: [PhotosPickerItem]) async {
        for item in items {
            if let data = try? await item.loadTransferable(type: Data.self) {
                job.photos.append(JobPhoto(imageData: data))
            }
        }
        selectedItems = []
    }
}
