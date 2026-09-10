// DAYLIGHT — Accessible reminders for iOS 17+
//
// SETUP
// 1. Create an iOS App project in Xcode using SwiftUI (Swift 5 language mode).
// 2. Remove the generated App and ContentView files. Add this downloaded file,
//    or split it at the named file boundaries into the five supplied files.
// 3. Set the deployment target to iOS 17.0 or later.
// 4. Add these Info.plist privacy keys using Target > Info:
//    NSSpeechRecognitionUsageDescription = "Turn your words into a reminder."
//    NSMicrophoneUsageDescription = "Listen when you choose Speak Reminder."
// 5. Run on a real device to test microphone input and local notifications.
//    Notifications and speech remain optional; typing always works.
//
// DESIGN REFERENCES
// Apple HIG, Accessibility:
// https://developer.apple.com/design/human-interface-guidelines/accessibility
// Apple Speech documentation:
// https://developer.apple.com/documentation/speech/recognizing-speech-in-live-audio
// Task-first senior care inspiration:
// https://dribbble.com/shots/23202341-Senior-Care-Management-Mobile-App-Dashboard-Design
//
// Intent: clear hierarchy, warm neutrals, high-contrast text, familiar labeled
// actions, 64-point minimum controls, no swipe-only functionality, and optional
// spring motion. Portfolio aesthetics never override accessibility.
//
// PERSISTENCE / PRIVACY
// Reminders are saved in this app's local UserDefaults container. Do not store
// sensitive medical records here. Medication reminders are not dosage advice.
// Speech may be processed by Apple's service when on-device recognition is
// unavailable. The UI explains this before requesting microphone permission.
//
// TEST CHECKLIST
// VoiceOver, Voice Control, Bold Text, all accessibility Dynamic Type sizes,
// Reduce Motion, dark system appearance, permission denial, empty lists,
// notification delivery on device, date changes, and daily repeat behavior.
// This source is provided for Xcode integration; the browser build does not
// compile or execute Swift. Audit on physical devices before production use.

import SwiftUI

@main
struct DaylightApp: App {
    @StateObject private var reminders = ReminderViewModel()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            DashboardView()
                .environmentObject(reminders)
                // Deliberate light, high-contrast palette instead of relying on
                // automatic appearance to reinterpret the color hierarchy.
                .preferredColorScheme(.light)
                .onChange(of: scenePhase) { _, phase in
                    if phase == .active { reminders.refreshDailyRoutines() }
                }
        }
    }
}
