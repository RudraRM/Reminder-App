import Foundation
import Combine
import Speech
import AVFoundation

// MARK: - Speech service: permissions and resource lifecycle
// No permission is requested until the user explicitly chooses Speak Reminder.
@MainActor
final class SpeechService: ObservableObject {
    @Published private(set) var transcript = ""
    @Published private(set) var isListening = false
    @Published private(set) var message = ""

    private let recognizer = SFSpeechRecognizer(locale: Locale.current)
    private let engine = AVAudioEngine()
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var hasInputTap = false

    func start() async {
        guard !isListening else { stop(); return }
        let speechAllowed: Bool = await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
        guard speechAllowed else {
            message = "Speech recognition is off. You can type your reminder, or enable speech in iPhone Settings."
            return
        }
        let microphoneAllowed: Bool = await withCheckedContinuation { continuation in
            AVAudioApplication.requestRecordPermission { allowed in
                continuation.resume(returning: allowed)
            }
        }
        guard microphoneAllowed else {
            message = "Microphone access is off. You can always type instead."
            return
        }
        guard let recognizer, recognizer.isAvailable else {
            message = "Speech isn’t available right now. Please type your reminder."
            return
        }

        stop()
        transcript = ""
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.record, mode: .measurement, options: .duckOthers)
            try session.setActive(true, options: .notifyOthersOnDeactivation)
            let request = SFSpeechAudioBufferRecognitionRequest()
            request.shouldReportPartialResults = true
            // Prefer local speech processing whenever the device supports it.
            request.requiresOnDeviceRecognition = recognizer.supportsOnDeviceRecognition
            self.request = request
            let input = engine.inputNode
            let format = input.outputFormat(forBus: 0)
            guard format.sampleRate > 0, format.channelCount > 0 else {
                stop()
                message = "No microphone is available. Please type your reminder."
                return
            }
            input.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
                request.append(buffer)
            }
            hasInputTap = true
            recognitionTask = recognizer.recognitionTask(with: request) { [weak self] result, error in
                // Speech callbacks are not guaranteed to arrive on the main queue.
                Task { @MainActor [weak self] in
                    guard let self else { return }
                    if let result { self.transcript = result.bestTranscription.formattedString }
                    if result?.isFinal == true {
                        self.stop()
                        self.message = "Your words are ready. Check the date and time, then save."
                    } else if error != nil && self.isListening {
                        self.stop()
                        self.message = "Listening has stopped. Check your words below, or type your reminder."
                    }
                }
            }
            engine.prepare()
            try engine.start()
            isListening = true
            message = "Listening. Say what you’d like to remember. Tap Finish speaking when you’re done."
        } catch {
            stop()
            message = "We couldn’t start the microphone. Please type your reminder."
        }
    }

    func stop() {
        isListening = false
        if engine.isRunning { engine.stop() }
        if hasInputTap { engine.inputNode.removeTap(onBus: 0); hasInputTap = false }
        request?.endAudio()
        recognitionTask?.cancel()
        recognitionTask = nil
        request = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
}
