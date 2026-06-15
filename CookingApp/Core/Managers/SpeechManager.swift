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
    
    // State UI
    @Published var isListening: Bool = false
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
        }
    }
    
    // Dipanggil otomatis saat TTS selesai berbicara
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
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
        if shouldBeListening {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                if !self.synthesizer.isSpeaking {
                    self.startListening()
                }
            }
        }
    }
    
    // Speech-to-Text
    func startListening() {
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
            }
            
        } catch {
            self.errorMessage = "Gagal menyalakan mikrofon: \(error.localizedDescription)"
            stopListening()
        }
    }
    
    // stop permanent = saat user meninggalkan halaman
    func stopListening(permanent: Bool = false) {
        if permanent { shouldBeListening = false }
        
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
}
