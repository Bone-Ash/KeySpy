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
        monitor.checkAccessibilityPermission()
    }
}

final class SpyMonitor {
    private var monitor: Any?
    private var pressedKeys: Set<UInt16> = []
    
    func checkAccessibilityPermission() {
        if AXIsProcessTrusted() {
            start()
        } else {
            AXIsProcessTrustedWithOptions([kAXTrustedCheckOptionPrompt.takeUnretainedValue(): true] as CFDictionary)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.showPermissionAlert()
            }
        }
    }
    
    private func showPermissionAlert() {
        let alert = NSAlert()
        alert.messageText = "需要辅助功能权限"
        alert.informativeText = "请在系统设置 > 隐私与安全性 > 辅助功能中添加此应用"
        alert.addButton(withTitle: "打开设置")
        alert.addButton(withTitle: "取消")
        
        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
        } else {
            NSApp.terminate(nil)
        }
    }
    
    func start() {
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
