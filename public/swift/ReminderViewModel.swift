import Foundation
import SwiftUI
import UserNotifications
import UIKit

// MARK: - View model: persistence, task actions, and notification scheduling
// UI expansion and animation state intentionally do not live in this object.
@MainActor
final class ReminderViewModel: ObservableObject {
    @Published private(set) var reminders: [DaylightReminder] = []
    @Published var confirmation: String? = nil
    @Published var notificationMessage: String? = nil
    @Published var selectedDay = Date()
    @Published var filter: TaskFilter = .all

    enum TaskFilter: String, CaseIterable, Identifiable {
        case all = "All tasks", todo = "To do", done = "Done"
        var id: String { rawValue }
    }

    private let defaults: UserDefaults
    private let storageKey = "daylight.native.reminders.v1"
    private let notificationCenter = UNUserNotificationCenter.current()
    // A modest cap avoids silently exceeding iOS's pending-request limit.
    static let reminderLimit = 60

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if let data = defaults.data(forKey: storageKey),
           let saved = try? JSONDecoder().decode([DaylightReminder].self, from: data) {
            reminders = saved
        } else {
            reminders = DaylightReminder.examples()
        }
        refreshDailyRoutines()
        persist()
    }

    var todayTasks: [DaylightReminder] {
        reminders.filter { $0.occurs(on: selectedDay) }
    }
    var completedCount: Int { todayTasks.filter(\.isComplete).count }
    var remainingCount: Int { todayTasks.count - completedCount }

    func tasks(in period: DayPeriod) -> [DaylightReminder] {
        todayTasks.filter { task in
            task.period == period && (filter == .all || (filter == .done ? task.isComplete : !task.isComplete))
        }.sorted {
            let calendar = Calendar.current
            let a = calendar.component(.hour, from: $0.date) * 60 + calendar.component(.minute, from: $0.date)
            let b = calendar.component(.hour, from: $1.date) * 60 + calendar.component(.minute, from: $1.date)
            return a < b
        }
    }

    func save(_ reminder: DaylightReminder) async -> Bool {
        if let index = reminders.firstIndex(where: { $0.id == reminder.id }) {
            reminders[index] = reminder
        } else {
            guard reminders.count < Self.reminderLimit else {
                notificationMessage = "You have 60 reminders. Please remove an old reminder before adding another."
                return false
            }
            reminders.append(reminder)
        }
        persist()
        await schedule(reminder)
        announce("Your reminder is saved.")
        return true
    }

    func toggle(_ reminder: DaylightReminder) {
        guard let index = reminders.firstIndex(where: { $0.id == reminder.id }) else { return }
        reminders[index].completedAt = reminder.isComplete ? nil : .now
        let updated = reminders[index]
        persist()
        // Completion changes are immediately visible; notification scheduling
        // is not allowed to block the user's feedback.
        Task { await schedule(updated) }
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        announce(updated.isComplete ? "Well done! \(updated.title) is complete." : "\(updated.title) is back on your to-do list.")
    }

    func delete(_ reminder: DaylightReminder) {
        reminders.removeAll { $0.id == reminder.id }
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [reminder.id.uuidString])
        notificationCenter.removeDeliveredNotifications(withIdentifiers: [reminder.id.uuidString])
        persist()
        announce("Reminder deleted.")
    }

    func refreshDailyRoutines() {
        for index in reminders.indices where reminders[index].repeatsDaily {
            if let completed = reminders[index].completedAt,
               !Calendar.current.isDateInToday(completed) {
                reminders[index].completedAt = nil
            }
        }
        selectedDay = .now
        persist()
    }

    func announce(_ message: String) {
        // A persistent, dismissible banner avoids a disappearing toast that
        // may not leave enough time for a senior user to read it.
        confirmation = message
        UIAccessibility.post(notification: .announcement, argument: message)
    }

    private func persist() {
        do { defaults.set(try JSONEncoder().encode(reminders), forKey: storageKey) }
        catch { notificationMessage = "Your latest changes could not be saved. Please try again." }
    }

    func enableNotifications() async {
        do {
            let granted = try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
            guard granted else {
                notificationMessage = "Alerts are off. You can still use your list. Enable notifications for Daylight in iPhone Settings whenever you like."
                return
            }
            for reminder in reminders { await schedule(reminder) }
            announce("Reminder alerts are enabled.")
        } catch {
            notificationMessage = "Alerts could not be enabled. Your reminders are still saved."
        }
    }

    private func schedule(_ reminder: DaylightReminder) async {
        let id = reminder.id.uuidString
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [id])
        let settings = await notificationCenter.notificationSettings()
        guard settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional else { return }
        guard reminder.repeatsDaily || !reminder.isComplete else { return }
        guard reminder.repeatsDaily || reminder.date > .now else { return }

        let content = UNMutableNotificationContent()
        content.title = reminder.title
        content.body = reminder.notes.isEmpty ? "A gentle reminder from Daylight." : reminder.notes
        content.sound = .default
        let calendar = Calendar.current
        // Daily triggers have only time components. Completion today therefore
        // does not accidentally cancel tomorrow's medication reminder.
        let components = reminder.repeatsDaily
            ? calendar.dateComponents([.hour, .minute], from: reminder.date)
            : calendar.dateComponents([.year, .month, .day, .hour, .minute], from: reminder.date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: reminder.repeatsDaily)
        do {
            try await notificationCenter.add(UNNotificationRequest(identifier: id, content: content, trigger: trigger))
        } catch {
            notificationMessage = "Your reminder is saved, but its alert could not be scheduled. Please check notification settings."
        }
    }
}
