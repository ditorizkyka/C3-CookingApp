//
//  SpeechManager.swift
//  CookingApp
//
//  Created by Brian Anashari on 10/06/26.
//

import Foundation
import AVFoundation
import Speech
import Combine

class SpeechManager: NSObject, ObservableObject, AVSpeechSynthesizerDelegate, @unchecked Sendable {
    // Text-to-Speech
    private let synthesizer = AVSpeechSynthesizer()
    
    // Flag
    private var shouldBeListening = false
    
    // Speech-to-Text
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "id-ID"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    // Timer untuk force-refresh mic agar tidak mabuk karena noise
    private var refreshTimer: Timer?
    
    // State UI
    @Published var isListening: Bool = false
    @Published var isSpeaking: Bool = false
    @Published var recognizedText: String = ""
    @Published var errorMessage: String? = nil
    @Published var audioLevel: Float = 0.0
    @Published var isMuted: Bool = false {
        didSet {
            if isMuted {
                stopSpeaking()
            }
        }
    }
    // Audio Player for loud beep
    private var audioPlayer: AVAudioPlayer?
    
    override init() {
        super.init()
        synthesizer.delegate = self
    }
    
    // Permission
    func requestPermissions() {
        SFSpeechRecognizer.requestAuthorization({authStatus in
            DispatchQueue.main.async {
                switch authStatus {
                case .authorized:
                    print("Izin Speech Recognition diberikan")
                case .denied, .restricted, .notDetermined:
                    self.errorMessage = "Akses mikrofon atau pengenalan suara tidak diizinkan."
                    print("Izin Speech Recognition ditolak")
                @unknown default:
                    break
                }
            }
        })
        
        AVAudioApplication.requestRecordPermission { allowed in
            DispatchQueue.main.async {
                if !allowed {
                    self.errorMessage = "Akses mikrofon ditolak."
                    print("Izin Mikrofon ditolak")
                } else {
                    print("Izin Mikrofon diberikan")
                }
                
            }
            
        }
    }
    
    // Text-to-Speech
    func speak(text: String) {
        guard !isMuted else { return }
        
        // Stop listening right away to prevent overlapping audio issues
        stopListening()
        
        // Mematikan suara
        synthesizer.stopSpeaking(at: .immediate)
        
        // Membuat utterance (ucapan) dari teks yang dikirim
        let utterance = AVSpeechUtterance(string: text)
        
        // Atur bahasa
        utterance.voice = AVSpeechSynthesisVoice(language: "id-ID")
        
        // Atur kecepatan dan nada
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        utterance.pitchMultiplier = 1.0
        
        // Minta bicara
        synthesizer.speak(utterance)
    }
    
    func stopSpeaking() {
        synthesizer.stopSpeaking(at: .immediate)
    }
    
    // Dipanggil otomatis saat TTS mulai berbicara
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        stopListening()
        DispatchQueue.main.async {
            self.audioLevel = 0.0
            self.isSpeaking = true
        }
    }
    
    // Dipanggil otomatis saat TTS selesai berbicara
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        DispatchQueue.main.async { self.isSpeaking = false }
        if shouldBeListening {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                if !self.synthesizer.isSpeaking {
                    self.startListening()
                }
            }
        }
    }
    
    // Dipanggil otomatis saat TTS dibatalkan
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        DispatchQueue.main.async { self.isSpeaking = false }
        if shouldBeListening {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                if !self.synthesizer.isSpeaking {
                    self.startListening()
                }
            }
        }
    }
    
    // Speech-to-Text
    func startListening(playBeep: Bool = true) {
        shouldBeListening = true
        
        if audioEngine.isRunning || synthesizer.isSpeaking {
            return
        }
        
        do {
            // Minta izin microphone dan pastikan bisa play suara (TTS)
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.duckOthers, .defaultToSpeaker])
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            
            // Buat wadah penampung suara
            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            guard let recognitionRequest = recognitionRequest else {
                return
            }
            
            // Biar hasilnya keluar satu-satu ga nunggu selesai ngomong
            recognitionRequest.shouldReportPartialResults = true
            
            // memaksa pemrosesan di dalam HP (tanpa internet) supaya kebal terhadap putus koneksi karena bising
            recognitionRequest.requiresOnDeviceRecognition = true
            
            // Prepare Mic
            let inputNode = audioEngine.inputNode
            
            // Mulai menebak kata
            guard let recognizer = speechRecognizer, recognizer.isAvailable else {
                self.errorMessage = "Speech recognizer tidak tersedia."
                return
            }
            
            recognitionTask = recognizer.recognitionTask(with: recognitionRequest) { result, error in
                if let result = result {
                    // Update teks yang kedeteksi ke UI
                    DispatchQueue.main.async {
                        // Ambil string terakhir yang didengar, ubah ke huruf kecil biar gampang dicocokkan
                        self.recognizedText = result.bestTranscription.formattedString.lowercased()
                    }
                }
                
                if error != nil || (result?.isFinal ?? false) {
                    self.stopListening()
                    
                    if self.shouldBeListening && !self.synthesizer.isSpeaking {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            if self.shouldBeListening && !self.synthesizer.isSpeaking {
                                self.startListening(playBeep: false) // Silent auto-restart
                            }
                        }
                    }
                }
            }
            
            // Sambung mic ke wadah penampung (recognition request) & hitung audio level
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
                self.recognitionRequest?.append(buffer)
                
                // Menghitung audio level
                guard let channelData = buffer.floatChannelData?[0] else { return }
                let frames = Int(buffer.frameLength)
                var sumSquares: Float = 0.0
                for i in 0..<frames {
                    let sample = channelData[i]
                    sumSquares += sample * sample
                }
                let rms = sqrt(sumSquares / Float(frames))
                let level = min(max(rms * 8.0, 0.0), 1.0)
                
                DispatchQueue.main.async {
                    self.audioLevel = level
                }
            }
            
            // Nyalain engine
            audioEngine.prepare()
            try audioEngine.start()
            
            DispatchQueue.main.async {
                self.isListening = true
                self.errorMessage = nil
                
                // Bunyikan beep HANYA jika playBeep = true (bukan dari auto-refresh)
                if playBeep {
                    self.playBeepSound()
                }
            }
            
            scheduleRefreshTimer()
            
        } catch {
            self.errorMessage = "Gagal menyalakan mikrofon: \(error.localizedDescription)"
            stopListening()
        }
    }
    
    // stop permanent = saat user meninggalkan halaman
    func stopListening(permanent: Bool = false) {
        if permanent { shouldBeListening = false }
        
        refreshTimer?.invalidate()
        refreshTimer = nil
        
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        
        recognitionTask?.cancel()
        recognitionTask = nil
        
        DispatchQueue.main.async {
            self.isListening = false
        }
    }
    
    // Play loud beep sound
    func playBeepSound() {
        let soundURL = URL(fileURLWithPath: "/System/Library/Audio/UISounds/begin_record.caf")
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.volume = 1.0
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("Gagal memutar beep: \(error)")
        }
    }
    
    private func scheduleRefreshTimer() {
        refreshTimer?.invalidate() 
        
        // Tiap 15 detik, restart paksa mic-nya
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 15.0, repeats: false) { [weak self] _ in
            guard let self = self, self.shouldBeListening, !self.synthesizer.isSpeaking else { return }
            
            print("🔄 Force refreshing speech recognizer (mencuci telinga dari noise)...")
            self.stopListening()
            
            // Kasih jeda sekian milidetik biar engine beneran mati, lalu nyalain lagi
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                if self.shouldBeListening && !self.synthesizer.isSpeaking {
                    self.startListening(playBeep: false) // Silent force refresh
                }
            }
        }
    }
}
