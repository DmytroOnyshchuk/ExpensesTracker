import SwiftData
import SwiftUI
import UniformTypeIdentifiers

struct BackupShareFile: Identifiable {
    let url: URL

    var id: URL { url }
}

struct BackupsView: View {
    @Environment(\.modelContext) private var modelContext
    @Inject private var userManager: UserManager
    
    @Query private var storedTransactions: [Transaction]
    @Query private var storedCategories: [TransactionCategory]

    private var transactions: [Transaction] { storedTransactions.notDeleted }

    private var categories: [TransactionCategory] { storedCategories.notDeleted }

    @State private var isImporting = false
    @State private var isChoosingFormat = false
    @State private var sharedFile: BackupShareFile?
    @State private var pickedFileURL: URL?
    @State private var errorMessage: String?
    @State private var showResetConfirmation = false

    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 24) {
                BackupSection(title: L10n.backupsCurrentData) {
                    BackupCountsView(transactions: transactions.count, categories: categories.count)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                }

                BackupSection(title: L10n.backupsExportSection) {
                    MenuRow(title: L10n.backupsShareAction, systemImage: "square.and.arrow.up", action: chooseFormat)
                }

                BackupSection(title: L10n.backupsImportSection) {
                    MenuRow(title: L10n.backupsImportAction, systemImage: "square.and.arrow.down", action: startImport)
                }
                .fileImporter(isPresented: $isImporting, allowedContentTypes: [.data], onCompletion: pickFile)

                Button {
                    showResetConfirmation = true
                } label: {
                    Text(L10n.backupsResetAction)
                        .font(.appLight(14))
                        .foregroundColor(.appRed)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .top)
        }
        .appBackground()
        .navigationTitle(L10n.menuBackups)
        .navigationBarTitleDisplayMode(.inline)
        .backupImport(from: $pickedFileURL)
        .overlay {
            if isChoosingFormat {
                BackupFormatPopup(onCancel: closeFormatPopup) { format in
                    closeFormatPopup()
                    share(format)
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isChoosingFormat)
        .sheet(item: $sharedFile) { file in
            ActivityView(items: [file.url])
                .presentationDetents([.medium, .large])
        }
        .alert(L10n.error, isPresented: isErrorPresented) {
            Button(L10n.ok, role: .cancel) {}
        } message: {
            Text(errorMessage ?? "")
        }
        .alert(L10n.backupsResetAction, isPresented: $showResetConfirmation) {
            Button(L10n.cancel, role: .cancel) {}
            Button(L10n.delete, role: .destructive, action: clear)
        } message: {
            Text(L10n.backupsResetWarning)
        }
    }

    private var isErrorPresented: Binding<Bool> {
        Binding(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })
    }

    private func clear() {
        do {
            try userManager.logout(context: modelContext)
        } catch {
            modelContext.rollback()
            Logger.default.logError("Clear failed", error: error, category: "BackupsView")
            errorMessage = error.localizedDescription
        }
    }

    private func chooseFormat() {
        FeedbackManager.shared.buttonTapped()
        isChoosingFormat = true
    }

    private func closeFormatPopup() {
        isChoosingFormat = false
    }

    private func share(_ format: BackupExportFormat) {
        do {
            sharedFile = try BackupShareFile(url: BackupManager.writeExportFile(from: modelContext, format: format))
        } catch {
            show(error)
        }
    }

    private func startImport() {
        FeedbackManager.shared.buttonTapped()
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
            .toast($toastMessage, icon: .success, duration: .seconds(3))
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
                _ = try BackupManager.apply(backup, mode: mode, to: modelContext)
                toastMessage = L10n.done
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

struct BackupFormatPopup: View {
    let onCancel: () -> Void
    let onConfirm: (BackupExportFormat) -> Void

    @State private var selection = BackupExportFormat.json

    var body: some View {
        TransactionEditPopup(onCancel: onCancel, onConfirm: { onConfirm(selection) }) {
            VStack(spacing: 12) {
                Text(L10n.backupsFormatTitle)
                    .font(.appMedium(16))
                    .foregroundColor(.appLabel)

                ForEach(BackupExportFormat.allCases) { format in
                    BackupFormatRow(format: format, isSelected: format == selection) {
                        select(format)
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private func select(_ format: BackupExportFormat) {
        guard format != selection else { return }
        FeedbackManager.shared.selectionChanged()
        selection = format
    }
}

struct BackupFormatRow: View {
    let format: BackupExportFormat
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(format.title)
                        .font(.appRegular(18))
                        .foregroundColor(.appWhite)

                    Text(format.summary)
                        .font(.appLight(14))
                        .foregroundColor(.appLabel)
                        .multilineTextAlignment(.leading)
                }

                Spacer(minLength: 8)

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .appPrimary : .appLabel.opacity(0.6))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.appMain.opacity(LiquidGlass.isAvailable ? 0.5 : 1))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.appPrimary, lineWidth: isSelected ? 1.5 : 0)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

struct BackupSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            MenuSectionHeader(title: title)

            VStack(spacing: 0) {
                content
            }
            .frame(maxWidth: .infinity, alignment: .leading)
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
        .font(.appLight(16))
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
        .appBackground()
        .alert(L10n.backupsImportReplace, isPresented: $showReplaceConfirmation) {
            Button(L10n.backupsImportReplace, role: .destructive) {
                onImport(.replace)
            }
            Button(L10n.cancel, role: .cancel) {}
        } message: {
            Text(L10n.backupsImportReplaceWarning)
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

#Preview("Format popup") {
    BackupFormatPopup(onCancel: {}, onConfirm: { _ in })
        .background(.appMain)
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
