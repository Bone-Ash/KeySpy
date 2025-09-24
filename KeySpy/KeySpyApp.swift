//
//  KeySpyApp.swift
//  KeySpy
//
//  Created by GH on 9/24/25.
//

import SwiftUI

@main
struct KeySpyApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        MenuBarExtra("键盘监控", systemImage: "keyboard") {
            Button("退出", action: { NSApp.terminate(nil) })
                .keyboardShortcut("q")
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    private let monitor = SpyMonitor()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        monitor.start()
    }
}

final class SpyMonitor {
    private var monitor: Any?
    private var pressedKeys: Set<UInt16> = []
    
    func start() {
        guard AXIsProcessTrusted() else {
            AXIsProcessTrustedWithOptions([kAXTrustedCheckOptionPrompt.takeUnretainedValue(): true] as CFDictionary)
            return
        }
        
        monitor = NSEvent.addGlobalMonitorForEvents(matching: [.keyDown, .keyUp]) { event in
            let keyCode = event.keyCode
            
            if event.type == .keyDown && !self.pressedKeys.contains(keyCode) {
                self.pressedKeys.insert(keyCode)
                print(event.characters ?? "")
            } else if event.type == .keyUp {
                self.pressedKeys.remove(keyCode)
            }
        }
    }
    
    deinit {
        if let monitor {
            NSEvent.removeMonitor(monitor)
        }
    }
}
