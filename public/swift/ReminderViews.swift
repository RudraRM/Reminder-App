import SwiftUI

// MARK: - Accessible design tokens
// Semantic fonts scale with Dynamic Type without imposing an upper size cap.
// Dark text on cream/sage surfaces is the default, not an optional afterthought.
enum DaylightStyle {
    static let ink = Color(red: 0.17, green: 0.22, blue: 0.15)
    static let muted = Color(red: 0.34, green: 0.39, blue: 0.30)
    static let cream = Color(red: 0.98, green: 0.98, blue: 0.95)
    static let sage = Color(red: 0.90, green: 0.94, blue: 0.85)
    static let forest = Color(red: 0.23, green: 0.32, blue: 0.20)
    static let peach = Color(red: 0.97, green: 0.92, blue: 0.84)
    static let border = Color(red: 0.65, green: 0.70, blue: 0.59)
}

// MARK: - Motion layer, separate from business state
// Spring interpolation gives a gentle layout-settling effect. Reduce Motion
// switches it off. All changes also have text, labels, and persistent feedback.
enum DaylightMotion {
    static func spring(reduced: Bool) -> Animation? {
        reduced ? nil : .spring(response: 0.42, dampingFraction: 0.86)
    }
    static func transition(reduced: Bool) -> AnyTransition {
        reduced ? .identity : .opacity.combined(with: .move(edge: .top))
    }
}

struct LargeActionStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduced
    var primary = false
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.title3.weight(.semibold))
            .frame(maxWidth: .infinity, minHeight: 64)
            .padding(.horizontal, 16)
            .foregroundStyle(primary ? .white : DaylightStyle.ink)
            .background(primary ? DaylightStyle.forest : DaylightStyle.sage)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(DaylightStyle.border, lineWidth: 1))
            .scaleEffect(configuration.isPressed && !reduced ? 0.98 : 1)
            .animation(DaylightMotion.spring(reduced: reduced), value: configuration.isPressed)
    }
}

// MARK: - Dashboard layout
struct DashboardView: View {
    @EnvironmentObject private var model: ReminderViewModel
    @Environment(\.accessibilityReduceMotion) private var reduced
    @Environment(\.dynamicTypeSize) private var typeSize
    @State private var showAdd = false
    @State private var showSettings = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    greeting
                    if let message = model.confirmation {
                        ConfirmationBanner(message: message) { model.confirmation = nil }
                            .transition(DaylightMotion.transition(reduced: reduced))
                    }
                    progress
                    Button { showAdd = true } label: {
                        Label("Add or speak a reminder", systemImage: "plus.circle.fill")
                            .padding(.vertical, 12)
                    }
                    .buttonStyle(LargeActionStyle(primary: true))
                    .accessibilityHint("Opens a simple form. You can type or speak your reminder.")

                    Text("Today’s tasks").font(.largeTitle.bold())
                        .accessibilityAddTraits(.isHeader)
                    filters
                    ForEach(DayPeriod.allCases) { period in
                        let tasks = model.tasks(in: period)
                        VStack(alignment: .leading, spacing: 16) {
                            // A vertical header at large sizes avoids truncating
                            // familiar time-of-day words to make room for a clock.
                            VStack(alignment: .leading, spacing: 6) {
                                Label(period.rawValue, systemImage: period.symbol)
                                    .font(.title2.bold())
                                Text(period.description).font(.body).foregroundStyle(DaylightStyle.muted)
                            }
                            .accessibilityElement(children: .combine)
                            .accessibilityAddTraits(.isHeader)
                            if tasks.isEmpty {
                                Text(model.filter == .all ? "A little breathing room. Nothing here yet." : "No \(model.filter.rawValue.lowercased()) reminders here.")
                                    .font(.body).foregroundStyle(DaylightStyle.muted)
                                    .padding(20).frame(maxWidth: .infinity, alignment: .leading)
                                    .background(DaylightStyle.sage.opacity(0.5), in: RoundedRectangle(cornerRadius: 16))
                            }
                            ForEach(tasks) { reminder in
                                ReminderCard(reminder: reminder)
                                    .transition(DaylightMotion.transition(reduced: reduced))
                            }
                        }
                    }
                    Text("Your day, at your pace.")
                        .font(.body).foregroundStyle(DaylightStyle.muted)
                        .frame(maxWidth: .infinity).padding(.vertical, 16)
                    Button { showSettings = true } label: {
                        Label("Settings and help", systemImage: "gearshape.fill")
                    }.buttonStyle(LargeActionStyle())
                }
                .padding(20)
                .frame(maxWidth: 720)
                .frame(maxWidth: .infinity)
                .animation(DaylightMotion.spring(reduced: reduced), value: model.reminders)
            }
            .background(DaylightStyle.cream)
            .foregroundStyle(DaylightStyle.ink)
            .navigationTitle("Daylight")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showAdd) { QuickAddView() }
            .sheet(isPresented: $showSettings) { DaylightSettingsView() }
            .alert("A little update", isPresented: Binding(
                get: { model.notificationMessage != nil },
                set: { if !$0 { model.notificationMessage = nil } }
            )) {
                Button("OK") { model.notificationMessage = nil }
            } message: { Text(model.notificationMessage ?? "") }
        }
    }

    private var greeting: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(Date.now, format: .dateTime.weekday(.wide).month(.wide).day())
                .font(.headline).foregroundStyle(DaylightStyle.muted)
            Text("A lovely day ahead.")
                .font(.largeTitle.bold())
                .accessibilityAddTraits(.isHeader)
            Text("Let’s take today one thing at a time.")
                .font(.title3).foregroundStyle(DaylightStyle.muted)
        }
    }

    private var progress: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Small steps. A brighter day.", systemImage: "sun.max.fill")
                .font(.title2.bold())
            Text("\(model.remainingCount) reminders left today.")
                .font(.title3)
            ProgressView(value: Double(model.completedCount), total: Double(max(model.todayTasks.count, 1)))
                .tint(DaylightStyle.forest)
                .scaleEffect(x: 1, y: 2, anchor: .center)
                .padding(.vertical, 6)
                .accessibilityLabel("Today’s progress")
                .accessibilityValue("\(model.completedCount) of \(model.todayTasks.count) reminders complete")
            Text("\(model.completedCount) of \(model.todayTasks.count) completed. Little wins add up.")
                .font(.body).foregroundStyle(DaylightStyle.muted)
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DaylightStyle.peach, in: RoundedRectangle(cornerRadius: 22))
    }

    private var filters: some View {
        // Unlike a compact segmented control, these remain at least 64 points
        // high. At accessibility sizes they stack instead of squeezing labels.
        let layout = typeSize.isAccessibilitySize ? AnyLayout(VStackLayout(spacing: 10)) : AnyLayout(HStackLayout(spacing: 8))
        return layout {
            ForEach(ReminderViewModel.TaskFilter.allCases) { filter in
                Button {
                    withAnimation(DaylightMotion.spring(reduced: reduced)) { model.filter = filter }
                } label: {
                    Text(filter.rawValue)
                        .font(.headline)
                        .frame(maxWidth: .infinity, minHeight: 64)
                        .padding(.horizontal, 8)
                        .foregroundStyle(model.filter == filter ? .white : DaylightStyle.ink)
                        .background(model.filter == filter ? DaylightStyle.forest : DaylightStyle.sage,
                                    in: RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(model.filter == filter ? .isSelected : [])
                .accessibilityHint("Filters the reminders below.")
            }
        }
    }
}

// MARK: - Expandable card (local animation state only)
struct ReminderCard: View {
    @EnvironmentObject private var model: ReminderViewModel
    @Environment(\.accessibilityReduceMotion) private var reduced
    @Environment(\.dynamicTypeSize) private var typeSize
    let reminder: DaylightReminder
    @State private var expanded = false
    @State private var showEdit = false
    @State private var confirmDelete = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            let layout = typeSize.isAccessibilitySize ? AnyLayout(VStackLayout(alignment: .leading, spacing: 8)) : AnyLayout(HStackLayout(alignment: .center, spacing: 8))
            layout {
                Button {
                    withAnimation(DaylightMotion.spring(reduced: reduced)) { model.toggle(reminder) }
                } label: {
                    Image(systemName: reminder.isComplete ? "checkmark.square.fill" : "square")
                        .font(.system(size: 36, weight: .semibold))
                        .foregroundStyle(DaylightStyle.forest)
                        .frame(minWidth: 64, minHeight: 64)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(reminder.isComplete ? "Mark \(reminder.title) as not complete" : "Complete \(reminder.title)")
                .accessibilityValue(reminder.isComplete ? "Completed" : "Not completed")
                .accessibilityHint("Double tap to change completion. You can undo by activating again.")
                Button {
                    withAnimation(DaylightMotion.spring(reduced: reduced)) { expanded.toggle() }
                } label: {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(reminder.title)
                            .font(.title2.weight(.semibold))
                            .strikethrough(reminder.isComplete)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                        Label(reminder.date.formatted(date: .omitted, time: .shortened), systemImage: "clock")
                            .font(.body)
                        if reminder.repeatsDaily {
                            Label("Every day", systemImage: "repeat").font(.body)
                        }
                        if reminder.isComplete {
                            Label("Done", systemImage: "checkmark.circle.fill").font(.headline)
                        }
                        Label(expanded ? "Hide details" : "Show details", systemImage: expanded ? "chevron.up" : "chevron.down")
                            .font(.body.weight(.medium))
                    }
                    .foregroundStyle(DaylightStyle.ink)
                    .frame(maxWidth: .infinity, minHeight: 64, alignment: .leading)
                    .padding(.vertical, 12)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("\(reminder.title), \(reminder.date.formatted(date: .omitted, time: .shortened))")
                .accessibilityValue(expanded ? "Details expanded" : "Details collapsed")
                .accessibilityHint("Double tap to \(expanded ? "hide" : "show") notes and editing actions.")
            }
            if expanded {
                VStack(alignment: .leading, spacing: 16) {
                    Divider().overlay(DaylightStyle.border)
                    Text(reminder.notes.isEmpty ? "No extra details for this reminder." : reminder.notes)
                        .font(.title3).foregroundStyle(DaylightStyle.muted)
                    Button { showEdit = true } label: {
                        Label("Edit reminder", systemImage: "square.and.pencil")
                    }.buttonStyle(LargeActionStyle())
                    Button(role: .destructive) { confirmDelete = true } label: {
                        Label("Delete reminder", systemImage: "trash")
                            .font(.title3.weight(.semibold))
                            .frame(maxWidth: .infinity, minHeight: 64)
                    }
                }
                .padding(.top, 12)
                .transition(DaylightMotion.transition(reduced: reduced))
            }
        }
        .padding(16)
        .background(reminder.isComplete ? DaylightStyle.sage : .white, in: RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(DaylightStyle.border, lineWidth: 1.5))
        .sheet(isPresented: $showEdit) { QuickAddView(existing: reminder) }
        .alert("Delete this reminder?", isPresented: $confirmDelete) {
            Button("Keep reminder", role: .cancel) { }
            Button("Delete reminder", role: .destructive) {
                withAnimation(DaylightMotion.spring(reduced: reduced)) { model.delete(reminder) }
            }
        } message: { Text("\(reminder.title) will be removed. This cannot be undone.") }
    }
}

// MARK: - Quick Add layout and local form state
struct QuickAddView: View {
    @EnvironmentObject private var model: ReminderViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var speech = SpeechService()
    @State private var title: String
    @State private var date: Date
    @State private var notes: String
    @State private var category: ReminderCategory
    @State private var repeatsDaily: Bool
    @State private var validation: String? = nil
    @State private var saving = false
    @FocusState private var titleFocused: Bool
    private let existing: DaylightReminder?

    init(existing: DaylightReminder? = nil) {
        self.existing = existing
        _title = State(initialValue: existing?.title ?? "")
        _date = State(initialValue: existing?.date ?? Date.now.addingTimeInterval(3600))
        _notes = State(initialValue: existing?.notes ?? "")
        _category = State(initialValue: existing?.category ?? .other)
        _repeatsDaily = State(initialValue: existing?.repeatsDaily ?? false)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text(existing == nil ? "What’s on your mind?" : "Edit your reminder")
                        .font(.largeTitle.bold()).accessibilityAddTraits(.isHeader)
                    Text("Type a little reminder, or simply say it.")
                        .font(.title3).foregroundStyle(DaylightStyle.muted)
                    Button {
                        titleFocused = false
                        if speech.isListening { speech.stop() }
                        else { Task { await speech.start() } }
                    } label: {
                        Label(speech.isListening ? "Finish speaking" : "Speak Reminder",
                              systemImage: speech.isListening ? "stop.circle.fill" : "mic.fill")
                            .padding(.vertical, 12)
                    }
                    .buttonStyle(LargeActionStyle(primary: true))
                    .accessibilityHint("Microphone permission is requested only when you start speaking.")
                    Text("Speech uses your device when available; otherwise Apple may process audio. You can always type instead.")
                        .font(.body).foregroundStyle(DaylightStyle.muted)
                    if !speech.message.isEmpty {
                        Text(speech.message).font(.headline)
                            .padding(16).frame(maxWidth: .infinity, alignment: .leading)
                            .background(DaylightStyle.sage, in: RoundedRectangle(cornerRadius: 12))
                    }
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Remind me to").font(.title3.bold())
                        TextField("For example, call Sarah", text: $title, axis: .vertical)
                            .font(.title.weight(.medium))
                            .lineLimit(2...5)
                            .padding(20).frame(minHeight: 96)
                            .background(.white, in: RoundedRectangle(cornerRadius: 16))
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(DaylightStyle.border, lineWidth: 2))
                            .focused($titleFocused)
                            .accessibilityLabel("Reminder title")
                    }
                    if let validation {
                        Label(validation, systemImage: "exclamationmark.circle.fill")
                            .font(.headline).foregroundStyle(Color(red: 0.55, green: 0.19, blue: 0.12))
                    }
                    presets
                    VStack(alignment: .leading, spacing: 14) {
                        Text("When would you like a reminder?").font(.title3.bold())
                        // Wheels keep time selection explicit and large. DatePicker
                        // provides native VoiceOver and localization support.
                        DatePicker("Day", selection: $date, displayedComponents: .date)
                            .datePickerStyle(.graphical)
                            .accessibilityLabel("Reminder date")
                        DatePicker("Time", selection: $date, displayedComponents: .hourAndMinute)
                            .datePickerStyle(.wheel)
                            .accessibilityLabel("Reminder time")
                        Text("\(date.formatted(date: .abbreviated, time: .shortened))")
                            .font(.title3.bold())
                        Text("Speaking fills the reminder title. Please set and check the time here.")
                            .font(.body).foregroundStyle(DaylightStyle.muted)
                    }
                    Toggle(isOn: $repeatsDaily) {
                        Label("Repeat every day", systemImage: "repeat").font(.title3)
                    }
                    .frame(minHeight: 64).tint(DaylightStyle.forest)
                    VStack(alignment: .leading, spacing: 10) {
                        Text("A little detail (optional)").font(.title3.bold())
                        TextField("Anything else to remember?", text: $notes, axis: .vertical)
                            .font(.title3).lineLimit(3...6).padding(18)
                            .frame(minHeight: 100, alignment: .topLeading)
                            .background(.white, in: RoundedRectangle(cornerRadius: 12))
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(DaylightStyle.border))
                            .accessibilityLabel("Optional reminder notes")
                    }
                    Button { save() } label: {
                        Label(saving ? "Saving…" : "Save reminder", systemImage: "checkmark.circle.fill")
                    }
                    .buttonStyle(LargeActionStyle(primary: true))
                    .disabled(saving)
                    Button("Cancel") { speech.stop(); dismiss() }
                        .buttonStyle(LargeActionStyle())
                }
                .padding(22).frame(maxWidth: 680).frame(maxWidth: .infinity)
            }
            .background(DaylightStyle.cream).foregroundStyle(DaylightStyle.ink)
            .navigationTitle(existing == nil ? "New reminder" : "Edit reminder")
            .navigationBarTitleDisplayMode(.inline)
            .interactiveDismissDisabled(saving)
            .onChange(of: speech.transcript) { _, words in if !words.isEmpty { title = words } }
            .onChange(of: scenePhase) { _, phase in if phase != .active { speech.stop() } }
            .onDisappear { speech.stop() }
            .alert("A little update", isPresented: Binding(
                get: { model.notificationMessage != nil },
                set: { if !$0 { model.notificationMessage = nil } }
            )) { Button("OK") { model.notificationMessage = nil } }
            message: { Text(model.notificationMessage ?? "") }
        }
    }

    private var presets: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Or start with something familiar").font(.headline)
            preset("Take Medicine", category: .medicine)
            preset("Call Family", category: .family)
            preset("Doctor Appt", category: .appointment)
        }
    }

    private func preset(_ label: String, category: ReminderCategory) -> some View {
        Button {
            title = label == "Doctor Appt" ? "Doctor appointment" : label
            self.category = category
            validation = nil
        } label: { Label(label, systemImage: category.symbol) }
            .buttonStyle(LargeActionStyle())
            .accessibilityHint("Fills the reminder title. You can edit it before saving.")
    }

    private func save() {
        let cleanTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanTitle.isEmpty else {
            validation = "Please type or speak a reminder first."
            titleFocused = true
            return
        }
        guard repeatsDaily || date > .now || existing != nil else {
            validation = "Please choose a future date and time."
            return
        }
        speech.stop()
        saving = true
        var reminder = existing ?? DaylightReminder(title: cleanTitle, date: date)
        reminder.title = cleanTitle
        reminder.date = date
        reminder.notes = notes
        reminder.category = category
        reminder.repeatsDaily = repeatsDaily
        Task {
            let success = await model.save(reminder)
            saving = false
            if success { dismiss() }
        }
    }
}

// MARK: - Persistent confirmation (no transient, icon-only success states)
struct ConfirmationBanner: View {
    let message: String
    let dismiss: () -> Void
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label(message, systemImage: "checkmark.circle.fill")
                .font(.title3.bold())
                .accessibilityElement(children: .combine)
            Button("Got it", action: dismiss)
                .buttonStyle(LargeActionStyle())
        }
        .padding(20)
        .foregroundStyle(.white)
        .background(DaylightStyle.forest, in: RoundedRectangle(cornerRadius: 18))
    }
}

// MARK: - Shallow settings and help, one sheet away
struct DaylightSettingsView: View {
    @EnvironmentObject private var model: ReminderViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 26) {
                    Text("Make yourself comfortable.").font(.largeTitle.bold())
                    Label("Clear by default", systemImage: "eye.fill").font(.title2.bold())
                    Text("High-contrast text and large buttons are always on. Daylight follows your iPhone’s text size, Bold Text, VoiceOver, and Reduce Motion preferences.")
                        .font(.title3)
                    Text("To change text size: open iPhone Settings → Accessibility → Display & Text Size. For less animation: Accessibility → Motion → Reduce Motion.")
                        .font(.body).foregroundStyle(DaylightStyle.muted)
                    Button {
                        if let url = URL(string: UIApplication.openSettingsURLString) { openURL(url) }
                    } label: { Label("Open Daylight in Settings", systemImage: "gearshape.fill") }
                        .buttonStyle(LargeActionStyle())
                    Button { Task { await model.enableNotifications() } } label: {
                        Label("Enable reminder alerts", systemImage: "bell.fill")
                    }.buttonStyle(LargeActionStyle(primary: true))
                    Text("Alerts are optional. If you have previously declined, enable Notifications in Daylight’s iPhone Settings. Your list works without alerts.")
                        .font(.body).foregroundStyle(DaylightStyle.muted)
                    Divider()
                    Text("A little help").font(.title2.bold())
                    Text("1. Add a reminder, or speak one aloud. Check the time and save.\n\n2. Tap the large square when you finish. Tap again to undo.\n\n3. Tap Show details to read notes, edit, or delete. No swiping needed.")
                        .font(.title3)
                    Text("Reminders are stored on your device. Medication reminders do not replace advice from your healthcare professional.")
                        .font(.body).foregroundStyle(DaylightStyle.muted)
                    if let confirmation = model.confirmation {
                        ConfirmationBanner(message: confirmation) { model.confirmation = nil }
                    }
                    Button("Done") { dismiss() }.buttonStyle(LargeActionStyle(primary: true))
                }
                .padding(24).frame(maxWidth: 680).frame(maxWidth: .infinity)
            }
            .background(DaylightStyle.cream).foregroundStyle(DaylightStyle.ink)
            .navigationTitle("Settings and help").navigationBarTitleDisplayMode(.inline)
            .alert("A little update", isPresented: Binding(
                get: { model.notificationMessage != nil },
                set: { if !$0 { model.notificationMessage = nil } }
            )) { Button("OK") { model.notificationMessage = nil } }
            message: { Text(model.notificationMessage ?? "") }
        }
    }
}

#Preview {
    DashboardView().environmentObject(ReminderViewModel(defaults: UserDefaults(suiteName: "daylight.preview")!))
}
