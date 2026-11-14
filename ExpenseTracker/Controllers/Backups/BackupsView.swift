import SwiftData
import SwiftUI
import UniformTypeIdentifiers

struct BackupShareFile: Identifiable {
    let url: URL

    var id: URL { url }
}

struct BackupsView: View {
    @Environment(\.modelContext) private var modelContext

    @Query private var transactions: [Transaction]
    @Query private var categories: [TransactionCategory]

    @State private var isImporting = false
    @State private var isChoosingFormat = false
    @State private var sharedFile: BackupShareFile?
    @State private var pickedFileURL: URL?
    @State private var errorMessage: String?

    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 24) {
                BackupSection(title: L10n.backupsCurrentData) {
                    BackupCountsView(transactions: transactions.count, categories: categories.count)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                }

                BackupSection(title: L10n.backupsExportSection) {
                    MenuRow(title: L10n.backupsShareAction, systemImage: "square.and.arrow.up", action: chooseFormat)
                }
                .confirmationDialog(L10n.backupsFormatTitle, isPresented: $isChoosingFormat, titleVisibility: .visible) {
                    Button(L10n.backupsFormatJson) {
                        share(.json)
                    }
                    Button(L10n.backupsFormatCsv) {
                        share(.csv)
                    }
                    Button(L10n.cancel, role: .cancel) {}
                } message: {
                    Text(L10n.backupsFormatMessage)
                }

                BackupSection(title: L10n.backupsImportSection) {
                    MenuRow(title: L10n.backupsImportAction, systemImage: "square.and.arrow.down", action: startImport)
                }
                .fileImporter(isPresented: $isImporting, allowedContentTypes: [.data], onCompletion: pickFile)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .top)
        }
        .background(.appMain)
        .navigationTitle(L10n.menuBackups)
        .navigationBarTitleDisplayMode(.inline)
        .backupImport(from: $pickedFileURL)
        .sheet(item: $sharedFile) { file in
            ActivityView(items: [file.url])
                .presentationDetents([.medium, .large])
        }
        .alert(L10n.error, isPresented: isErrorPresented) {
            Button(L10n.ok, role: .cancel) {}
        } message: {
            Text(errorMessage ?? "")
        }
    }

    private var isErrorPresented: Binding<Bool> {
        Binding(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })
    }

    private func chooseFormat() {
        FeedbackManager.buttonTapped()
        isChoosingFormat = true
    }

    private func share(_ format: BackupExportFormat) {
        do {
            sharedFile = try BackupShareFile(url: BackupManager.writeExportFile(from: modelContext, format: format))
        } catch {
            show(error)
        }
    }

    private func startImport() {
        FeedbackManager.buttonTapped()
        isImporting = true
    }

    private func pickFile(_ result: Result<URL, Error>) {
        guard case let .success(url) = result else { return }
        pickedFileURL = url
    }

    private func show(_ error: Error) {
        Logger.default.logError("Backup export failed", error: error, category: "BackupsView")
        errorMessage = error.localizedDescription
    }
}

private struct BackupImportModifier: ViewModifier {
    @Binding var fileURL: URL?

    @Environment(\.modelContext) private var modelContext

    @State private var isWorking = false
    @State private var pendingImport: ImportedBackup?
    @State private var errorMessage: String?
    @State private var toastMessage: String?

    func body(content: Content) -> some View {
        content
            .disabled(isWorking)
            .overlay {
                if isWorking {
                    ProgressView()
                        .controlSize(.large)
                        .tint(.appPrimary)
                        .padding(28)
                        .glassSurface(in: RoundedRectangle(cornerRadius: 18, style: .continuous), fallback: .appLabel.opacity(0.2))
                }
            }
            .toast($toastMessage, duration: .seconds(3))
            .sheet(item: $pendingImport) { backup in
                BackupImportSheet(backup: backup, onCancel: cancelImport) { mode in
                    apply(backup, mode: mode)
                }
                .presentationDetents([.medium])
            }
            .alert(L10n.error, isPresented: isErrorPresented) {
                Button(L10n.ok, role: .cancel) {}
            } message: {
                Text(errorMessage ?? "")
            }
            .onChange(of: fileURL) { _, url in
                guard let url else { return }
                fileURL = nil
                read(url)
            }
    }

    private var isErrorPresented: Binding<Bool> {
        Binding(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })
    }

    private func read(_ url: URL) {
        isWorking = true
        Task {
            defer { isWorking = false }
            do {
                pendingImport = try await Task.detached { try BackupManager.read(from: url) }.value
            } catch {
                show(error)
            }
        }
    }

    private func cancelImport() {
        pendingImport = nil
    }

    private func apply(_ backup: ImportedBackup, mode: BackupImportMode) {
        pendingImport = nil
        isWorking = true
        Task {
            defer { isWorking = false }
            try? await Task.sleep(for: .milliseconds(350))
            do {
                let result = try BackupManager.apply(backup, mode: mode, to: modelContext)
                toastMessage = L10n.backupsImportDone(result.transactions, result.categories)
            } catch {
                modelContext.rollback()
                show(error)
            }
        }
    }

    private func show(_ error: Error) {
        Logger.default.logError("Backup import failed", error: error, category: "BackupImport")
        errorMessage = error.localizedDescription
    }
}

extension View {
    func backupImport(from fileURL: Binding<URL?>) -> some View {
        modifier(BackupImportModifier(fileURL: fileURL))
    }
}

struct BackupSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.appLight(15))
                .foregroundColor(.appLabel)
                .padding(.horizontal, 6)

            VStack(spacing: 0) {
                content
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 6)
            .glassSurface(in: RoundedRectangle(cornerRadius: 18, style: .continuous), fallback: .appLabel.opacity(0.1))
        }
    }
}

struct BackupCountsView: View {
    let transactions: Int
    let categories: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(L10n.backupsTransactionsCount(transactions))
            Text(L10n.backupsCategoriesCount(categories))
        }
        .font(.appLight(17))
        .foregroundColor(.appWhite)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct BackupImportSheet: View {
    let backup: ImportedBackup
    let onCancel: () -> Void
    let onImport: (BackupImportMode) -> Void

    @State private var showReplaceConfirmation = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(L10n.backupsImportPreviewTitle)
                .font(.appRegular(22))
                .foregroundColor(.appWhite)

            VStack(alignment: .leading, spacing: 8) {
                BackupCountsView(
                    transactions: backup.snapshot.transactions.count,
                    categories: backup.snapshot.categories.filter { !$0.isDirectory }.count
                )

                Group {
                    if let period {
                        Text(L10n.backupsImportPeriod(period))
                    }
                    if backup.skippedTransactions > 0 {
                        Text(L10n.backupsImportSkipped(backup.skippedTransactions))
                    }
                }
                .font(.appLight(15))
                .foregroundColor(.appLabel)
            }

            Spacer(minLength: 0)

            VStack(spacing: 12) {
                BackupSheetButton(title: L10n.backupsImportMerge, foreground: .appMain, background: .appPrimary) {
                    onImport(.merge)
                }
                BackupSheetButton(title: L10n.backupsImportReplace, foreground: .appRed, background: .appRed.opacity(0.15)) {
                    showReplaceConfirmation = true
                }
                BackupSheetButton(title: L10n.cancel, foreground: .appWhite, background: .clear, action: onCancel)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(.appMain)
        .confirmationDialog(L10n.backupsImportReplaceWarning, isPresented: $showReplaceConfirmation, titleVisibility: .visible) {
            Button(L10n.backupsImportReplace, role: .destructive) {
                onImport(.replace)
            }
            Button(L10n.cancel, role: .cancel) {}
        }
    }

    private var period: String? {
        guard let range = backup.dateRange else { return nil }
        let start = range.lowerBound.formatted(date: .abbreviated, time: .omitted)
        let end = range.upperBound.formatted(date: .abbreviated, time: .omitted)
        return "\(start) – \(end)"
    }
}

struct BackupSheetButton: View {
    let title: String
    let foreground: Color
    let background: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.appRegular(17))
                .foregroundColor(foreground)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(background)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview("Backups") {
    NavigationStack {
        BackupsView()
    }
    .modelContainer(makePreviewModelContainer())
}

#Preview("Import sheet") {
    let categoryId = UUID()
    let snapshot = BackupSnapshot(
        categories: [
            BackupCategory(uuid: categoryId, name: "Groceries", iconName: "basket.fill", iconColor: "yellow", isDirectory: false, sortIndex: 0),
        ],
        transactions: [
            BackupTransaction(id: UUID(), amount: 12500, date: Date().addingTimeInterval(-86400 * 40), categoryUuid: categoryId),
            BackupTransaction(id: UUID(), amount: 4300, date: Date(), categoryUuid: categoryId),
        ]
    )

    return BackupImportSheet(
        backup: ImportedBackup(snapshot: snapshot, source: .mok, skippedTransactions: 2),
        onCancel: {},
        onImport: { _ in }
    )
}
