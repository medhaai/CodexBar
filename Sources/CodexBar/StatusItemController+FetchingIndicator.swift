import AppKit
import CodexBarCore
import QuartzCore

extension StatusItemController {
    private static let dotSize: CGFloat = 5
    private static let dotFPS: Double = 12
    private static let dotPhaseStep: Double = 0.15

    // MARK: - Public entry point

    /// Called whenever `store.refreshingProviders` may have changed.
    func updateFetchingIndicators() {
        guard self.settings.fetchingIndicatorEnabled else {
            self.removeAllFetchingDots()
            return
        }

        if self.shouldMergeIcons {
            self.updateMergedFetchingDot()
        } else {
            for provider in UsageProvider.allCases {
                if self.store.refreshingProviders.contains(provider), self.isVisible(provider) {
                    self.showFetchingDot(for: provider)
                } else {
                    self.hideFetchingDot(for: provider)
                }
            }
        }

        self.updateDotAnimation()
    }

    // MARK: - Merged icon mode

    private func updateMergedFetchingDot() {
        let anyRefreshing = UsageProvider.allCases.contains {
            self.store.refreshingProviders.contains($0) && self.isEnabled($0)
        }
        if anyRefreshing {
            // Use a sentinel provider key (.codex) to represent the merged dot.
            self.showFetchingDot(for: .codex)
        } else {
            self.hideFetchingDot(for: .codex)
            // Also clean up any per-provider dots that might exist from a previous mode.
            for provider in UsageProvider.allCases where provider != .codex {
                self.hideFetchingDot(for: provider)
            }
        }
    }

    // MARK: - Per-provider dot management

    private func showFetchingDot(for provider: UsageProvider) {
        guard self.fetchingDotItems[provider] == nil else { return }
        let item = NSStatusBar.system.statusItem(withLength: Self.dotSize + 6)
        item.button?.imageScaling = .scaleNone
        item.button?.image = self.makeDotImage(alpha: 1.0)
        item.isVisible = true
        self.fetchingDotItems[provider] = item
    }

    private func hideFetchingDot(for provider: UsageProvider) {
        guard let item = self.fetchingDotItems.removeValue(forKey: provider) else { return }
        NSStatusBar.system.removeStatusItem(item)
    }

    private func removeAllFetchingDots() {
        let items = self.fetchingDotItems.values
        for item in items {
            NSStatusBar.system.removeStatusItem(item)
        }
        self.fetchingDotItems.removeAll()
        self.stopDotAnimation()
    }

    // MARK: - Dot animation

    private func updateDotAnimation() {
        if self.fetchingDotItems.isEmpty {
            self.stopDotAnimation()
        } else if self.dotAnimationDriver == nil {
            self.dotAnimationPhase = 0
            let driver = DisplayLinkDriver(onTick: { [weak self] in
                self?.tickDotAnimation()
            })
            self.dotAnimationDriver = driver
            driver.start(fps: Self.dotFPS)
        }
    }

    private func stopDotAnimation() {
        self.dotAnimationDriver?.stop()
        self.dotAnimationDriver = nil
        self.dotAnimationPhase = 0
    }

    private func tickDotAnimation() {
        self.dotAnimationPhase += Self.dotPhaseStep
        let alpha = 0.4 + 0.6 * (sin(self.dotAnimationPhase) * 0.5 + 0.5)
        let image = self.makeDotImage(alpha: alpha)
        for item in self.fetchingDotItems.values {
            item.button?.image = image
        }
    }

    // MARK: - Dot image rendering

    private func makeDotImage(alpha: Double) -> NSImage {
        let d = Self.dotSize
        let padding: CGFloat = 2
        let totalSize = CGSize(width: d + padding * 2, height: d + padding * 2)
        let image = NSImage(size: totalSize)
        image.lockFocus()
        NSColor.labelColor.withAlphaComponent(CGFloat(alpha)).setFill()
        let rect = CGRect(x: padding, y: padding, width: d, height: d)
        NSBezierPath(ovalIn: rect).fill()
        image.unlockFocus()
        image.isTemplate = false
        return image
    }
}
