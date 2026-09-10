import Foundation

// MARK: - Domain models (no view or animation state)

enum DayPeriod: String, CaseIterable, Identifiable, Codable {
    case morning = "Morning", afternoon = "Afternoon", evening = "Evening"
    var id: String { rawValue }
    var symbol: String {
        switch self {
        case .morning: "sunrise.fill"
        case .afternoon: "sun.max.fill"
        case .evening: "moon.fill"
        }
    }
    var description: String {
        switch self {
        case .morning: "Before noon"
        case .afternoon: "Noon to 5 PM"
        case .evening: "After 5 PM"
        }
    }
}

enum ReminderCategory: String, Codable, CaseIterable {
    case medicine, family, appointment, water, walk, other
    var symbol: String {
        switch self {
        case .medicine: "pills.fill"
        case .family: "phone.fill"
        case .appointment: "calendar"
        case .water: "drop.fill"
        case .walk: "figure.walk"
        case .other: "bell.fill"
        }
    }
}

struct DaylightReminder: Identifiable, Codable, Equatable {
    var id = UUID()
    var title: String
    var date: Date
    var notes = ""
    var category: ReminderCategory = .other
    var repeatsDaily = false
    var completedAt: Date? = nil

    var isComplete: Bool { completedAt != nil }
    var period: DayPeriod {
        let hour = Calendar.current.component(.hour, from: date)
        return hour < 12 ? .morning : hour < 17 ? .afternoon : .evening
    }

    // Daily routines are shown every day; one-off tasks are tied to their date.
    func occurs(on day: Date) -> Bool {
        repeatsDaily || Calendar.current.isDate(date, inSameDayAs: day)
    }

    static func examples(now: Date = .now) -> [Self] {
        let calendar = Calendar.current
        func at(_ hour: Int, _ minute: Int = 0) -> Date {
            calendar.date(bySettingHour: hour, minute: minute, second: 0, of: now) ?? now
        }
        return [
            .init(title: "Take morning medicine", date: at(8), notes: "After breakfast. Follow your prescribed dosage.", category: .medicine, repeatsDaily: true),
            .init(title: "Drink a glass of water", date: at(9), category: .water, repeatsDaily: true),
            .init(title: "Call Sarah", date: at(13), notes: "A little catch-up with family.", category: .family),
            .init(title: "Go for a little walk", date: at(15, 30), notes: "A little fresh air, at your own pace.", category: .walk),
            .init(title: "Take evening medicine", date: at(19), notes: "Follow your prescribed dosage.", category: .medicine, repeatsDaily: true)
        ]
    }
}
