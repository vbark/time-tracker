import AppKit
import SwiftUI

extension Notification.Name {
    static let requestOpenMainWindow = Notification.Name("TimeTracker.requestOpenMainWindow")
}

enum AppWindowID {
    static let main = "main"
}

@MainActor
enum AppWindowController {
    /// Default launch size (780×560 content, ~30% shorter than prior 800pt height).
    static let defaultSize = NSSize(width: 780, height: 560)

    static func openMainWindow() {
        NSApp.activate(ignoringOtherApps: true)
        if NSApp.isHidden {
            NSApp.unhide(nil)
        }

        if let window = findMainWindow() {
            if window.isMiniaturized {
                window.deminiaturize(nil)
            }
            window.makeKeyAndOrderFront(nil)
            return
        }

        NotificationCenter.default.post(name: .requestOpenMainWindow, object: nil)
    }

    static func findMainWindow() -> NSWindow? {
        NSApp.windows.first { isMainContentWindow($0) }
    }

    static func isMainContentWindow(_ window: NSWindow) -> Bool {
        guard !window.isSheet else { return false }
        if window is NSPanel { return false }
        if window.className.localizedCaseInsensitiveContains("StatusBar") { return false }
        if window.frame.width <= 300 { return false }
        return window.canBecomeKey
    }

    static func configureMainWindow(_ window: NSWindow) {
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.backgroundColor = NSColor(Color.appChrome)
        window.isMovableByWindowBackground = true
        window.isReleasedWhenClosed = false
        applyDefaultFrameIfNeeded(to: window)
    }

    static func applyDefaultFrameIfNeeded(to window: NSWindow) {
        let size = defaultSize
        let current = window.contentLayoutRect.size

        if current.width < size.width - 20 || current.height < size.height - 20 {
            window.setContentSize(size)
            window.center()
            return
        }

        if current.height > size.height + 40 {
            window.setContentSize(NSSize(width: max(current.width, size.width), height: size.height))
            window.center()
        }
    }
}
