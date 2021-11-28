//
//  MainWindowController.swift
//  SpeakLine
//
//  Created by Juan Pablo Claude on 2/20/15.
//  Copyright (c) 2015 Big Nerd Ranch. All rights reserved.
//

import Cocoa

class MainWindowController: NSWindowController, NSSpeechSynthesizerDelegate, NSWindowDelegate, NSTableViewDataSource, NSTableViewDelegate {

    override var windowNibName: String {
        return "MainWindowController"
    }
    
    
    @IBOutlet weak var textField: NSTextField!
    @IBOutlet weak var speakButton: NSButton!
    @IBOutlet weak var stopButton: NSButton!
    @IBOutlet weak var tableView: NSTableView!
    
    let speechSynth: NSSpeechSynthesizer = NSSpeechSynthesizer()
    
    let voices = NSSpeechSynthesizer.availableVoices
    
    var isStarted: Bool = false {
        didSet {
        updateButtons()
        }
    }
    
    
    override func windowDidLoad() {
        super.windowDidLoad()
        updateButtons()
        speechSynth.delegate = self
        let defaultVoice = NSSpeechSynthesizer.defaultVoice
        if let defaultRow = voices.firstIndex(of: defaultVoice) {
            let indices = IndexSet(integer: defaultRow)
            tableView.selectRowIndexes(indices, byExtendingSelection: false)
            tableView.scrollRowToVisible(defaultRow)
        }
    }
    
    
    // MARK: Action methods
    @IBAction func speakIt(_ sender: NSButton) {
            
        // Get typed-in text as a string
        let string = textField.stringValue
        if string.isEmpty {
            print("string from \(textField!) is empty")
        } else {
            speechSynth.startSpeaking(string)
            isStarted = true
        }
    }
    
    
    @IBAction func stopIt(_ sender: NSButton) {
        speechSynth.stopSpeaking()
        //isStarted = false
    }
    
    
    func updateButtons() {
        if isStarted {
            speakButton.isEnabled = false
            stopButton.isEnabled = true
        } else {
            stopButton.isEnabled = false
            speakButton.isEnabled = true
        }
    }
    
    func voiceNameForIdentifier(identifier: String) -> String? {
        let attributes = NSSpeechSynthesizer.attributes(forVoice: NSSpeechSynthesizer.VoiceName(rawValue: identifier))
        return attributes[NSSpeechSynthesizer.VoiceAttributeKey.name] as? String
    }
    
    
    // MARK: NSSpeechSynthesizerDelegate
    func speechSynthesizer(_ sender: NSSpeechSynthesizer, didFinishSpeaking finishedSpeaking: Bool) {
        isStarted = false
        print("finishedSpeaking=\(finishedSpeaking)")
    }
    
    
    // MARK: NSWindowDelegate
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        return !isStarted
    }
    

    // MARK: NSTableViewDataSource
    func numberOfRows(in tableView: NSTableView) -> Int {
        return voices.count
    }
    
 
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        let voice = voices[row]
        let voiceName = voiceNameForIdentifier(identifier: voice.rawValue)
        return voiceName
    }
    
    
    // MARK: NSTableViewDelegate
    func tableViewSelectionDidChange(_ notification: Notification) {
        let row = tableView.selectedRow
            
        // Set the voice back to the default if the user has deselected all rows
        if row == -1 {
            speechSynth.setVoice(nil)
        return
        }
        let voice = voices[row]
        speechSynth.setVoice(voice)
    }
    
}
