import CoreGraphics

/// One-shot launch-size policy for the main window.
///
/// SwiftUI sizes content-sized windows via `HeightReportingHostingView`. Comparing
/// `contentLayoutRect` to `setContentSize` every layout pass is unstable: the unified
/// titlebar makes the layout rect shorter than the content size, so a naive "grow if
/// smaller than default" check resizes forever. That loop also forces Core Animation
/// to rebuild backdrop blur (WindowServer convolution) on every frame.
public struct WindowFramePolicy: Equatable, Sendable {
    public var defaultSize: CGSize
    public var growThreshold: CGFloat
    public var shrinkHeightSlack: CGFloat

    public init(
        defaultSize: CGSize,
        growThreshold: CGFloat = 20,
        shrinkHeightSlack: CGFloat = 40
    ) {
        self.defaultSize = defaultSize
        self.growThreshold = growThreshold
        self.shrinkHeightSlack = shrinkHeightSlack
    }

    public func proposedContentSize(forContentLayoutSize current: CGSize) -> CGSize? {
        if current.width < defaultSize.width - growThreshold
            || current.height < defaultSize.height - growThreshold {
            return defaultSize
        }
        if current.height > defaultSize.height + shrinkHeightSlack {
            return CGSize(
                width: max(current.width, defaultSize.width),
                height: defaultSize.height
            )
        }
        return nil
    }
}

/// Applies `WindowFramePolicy` at most once so a still-small layout rect cannot loop.
public struct OnceWindowFramePolicy: Equatable, Sendable {
    public private(set) var hasApplied: Bool
    public var policy: WindowFramePolicy

    public init(policy: WindowFramePolicy, hasApplied: Bool = false) {
        self.policy = policy
        self.hasApplied = hasApplied
    }

    public mutating func proposedContentSize(forContentLayoutSize current: CGSize) -> CGSize? {
        guard !hasApplied else { return nil }
        hasApplied = true
        return policy.proposedContentSize(forContentLayoutSize: current)
    }
}
