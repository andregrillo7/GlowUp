import SwiftUI
import SwiftData
import PhotosUI

struct PhotosView: View {
    @Query(sort: \ProgressPhoto.date, order: .reverse) private var photos: [ProgressPhoto]
    @Environment(\.modelContext) private var context
    @State private var selectedType: PhotoType = .face
    @State private var photosPickerItem: PhotosPickerItem?
    @State private var showCamera = false

    private var filteredPhotos: [ProgressPhoto] {
        photos.filter { $0.type == selectedType }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                typePicker
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)

                ScrollView {
                    VStack(spacing: 16) {
                        addPhotoSection
                        photoGrid
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Progress")
        }
    }

    private var typePicker: some View {
        HStack(spacing: 0) {
            ForEach(PhotoType.allCases, id: \.self) { type in
                Button {
                    selectedType = type
                } label: {
                    Text(type.rawValue)
                        .font(.subheadline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(selectedType == type ? Color(.systemGray4) : Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .foregroundStyle(.primary)
            }
        }
        .padding(4)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var addPhotoSection: some View {
        VStack(spacing: 8) {
            Text(selectedType.prompt)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                PhotosPicker(selection: $photosPickerItem, matching: .images) {
                    Label("Library", systemImage: "photo")
                        .font(.subheadline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .foregroundStyle(.primary)
                .onChange(of: photosPickerItem) { _, item in
                    Task { await loadPhoto(from: item) }
                }

                Button {
                    showCamera = true
                } label: {
                    Label("Camera", systemImage: "camera")
                        .font(.subheadline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .foregroundStyle(.primary)
            }
        }
    }

    private var photoGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 4) {
            ForEach(filteredPhotos) { photo in
                ThumbnailImage(data: photo.imageData, key: photo.id.uuidString)
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .aspectRatio(1, contentMode: .fill)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(alignment: .bottomLeading) {
                        Text(photo.date.formatted(date: .abbreviated, time: .omitted))
                            .font(.caption2)
                            .padding(4)
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                            .padding(4)
                    }
            }
        }
    }

    private func loadPhoto(from item: PhotosPickerItem?) async {
        guard let item,
              let data = try? await item.loadTransferable(type: Data.self) else { return }
        // Compress large photos before storing to keep the database lean.
        let storedData = compress(data) ?? data
        let photo = ProgressPhoto(type: selectedType, imageData: storedData)
        context.insert(photo)
        try? context.save()
        photosPickerItem = nil
    }

    /// Downsizes to a reasonable max dimension and re-encodes as JPEG.
    private func compress(data: Data, maxDimension: CGFloat = 1500, quality: CGFloat = 0.8) -> Data? {
        guard let image = UIImage(data: data) else { return nil }
        let size = image.size
        let scale = min(1, maxDimension / max(size.width, size.height))
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)

        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: newSize, format: format)
        let resized = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
        return resized.jpegData(compressionQuality: quality)
    }
}
