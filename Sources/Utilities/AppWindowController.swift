import AppKit
import SwiftUI
import TimeTrackerWindowing

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

    static func configureWindowChrome(_ window: NSWindow) {
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.backgroundColor = NSColor(Color.appChrome)
        window.isMovableByWindowBackground = true
        window.isReleasedWhenClosed = false
    }

    static func configureMainWindow(_ window: NSWindow) {
        configureWindowChrome(window)
        applyDefaultFrameIfNeeded(to: window)
    }

    /// Launch size only. Must not run from SwiftUI `updateNSView` on every pass.
    static func applyDefaultFrameIfNeeded(to window: NSWindow) {
        let id = ObjectIdentifier(window)
        guard !windowsWithAppliedDefaultFrame.contains(id) else { return }

        var policy = OnceWindowFramePolicy(
            policy: WindowFramePolicy(
                defaultSize: CGSize(width: defaultSize.width, height: defaultSize.height)
            )
        )
        guard let size = policy.proposedContentSize(forContentLayoutSize: window.contentLayoutRect.size) else {
            windowsWithAppliedDefaultFrame.insert(id)
            return
        }

        window.setContentSize(NSSize(width: size.width, height: size.height))
        window.center()
        windowsWithAppliedDefaultFrame.insert(id)
    }

    private static var windowsWithAppliedDefaultFrame = Set<ObjectIdentifier>()
}
