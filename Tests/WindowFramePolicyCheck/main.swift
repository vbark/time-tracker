import Foundation
import TimeTrackerWindowing

@main
enum WindowFramePolicyCheck {
    static func main() {
        let defaultSize = CGSize(width: 780, height: 560)
        let policy = WindowFramePolicy(defaultSize: defaultSize)

        let afterUnifiedTitlebar = CGSize(width: 780, height: 508)
        precondition(
            policy.proposedContentSize(forContentLayoutSize: afterUnifiedTitlebar) == defaultSize,
            "unified titlebar layout rect must still look 'too small' to a naive policy"
        )

        let settingsLayout = CGSize(width: 680, height: 420)
        precondition(
            policy.proposedContentSize(forContentLayoutSize: settingsLayout) == defaultSize,
            "settings-sized windows must not use the main-window grow policy"
        )

        var once = OnceWindowFramePolicy(policy: policy)
        let first = once.proposedContentSize(forContentLayoutSize: afterUnifiedTitlebar)
        let second = once.proposedContentSize(forContentLayoutSize: afterUnifiedTitlebar)
        let third = once.proposedContentSize(forContentLayoutSize: afterUnifiedTitlebar)
        precondition(first == defaultSize, "first pass may resize")
        precondition(second == nil, "second pass must not resize (this is the layout-loop fix)")
        precondition(third == nil, "later passes must not resize")
        precondition(once.hasApplied)

        var alreadySized = OnceWindowFramePolicy(policy: policy)
        precondition(alreadySized.proposedContentSize(forContentLayoutSize: defaultSize) == nil)
        precondition(
            alreadySized.proposedContentSize(forContentLayoutSize: afterUnifiedTitlebar) == nil,
            "after a correct first pass, a shorter layout rect must not start a loop"
        )

        fputs("WindowFramePolicyCheck passed\n", stdout)
    }
}
