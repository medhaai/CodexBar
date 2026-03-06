import AppKit
import CodexBarCore
import SwiftUI

// MARK: - Onboarding step enum

private enum OnboardingStep {
    case welcome
    case providers
    case summary
}

// MARK: - Main onboarding view

@MainActor
struct OnboardingView: View {
    @Bindable var settings: SettingsStore
    @State private var step: OnboardingStep = .welcome

    var body: some View {
        ZStack {
            switch self.step {
            case .welcome:
                WelcomeStepView(
                    onGuide: { withAnimation { self.step = .providers } },
                    onSkip: { withAnimation { self.step = .summary } })
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)))

            case .providers:
                ProvidersStepView(
                    settings: self.settings,
                    onBack: { withAnimation { self.step = .welcome } },
                    onContinue: { withAnimation { self.step = .summary } })
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)))

            case .summary:
                SummaryStepView(
                    settings: self.settings,
                    onDone: {
                        self.settings.hasCompletedOnboarding = true
                        OnboardingWindowController.shared.close()
                    })
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)))
            }
        }
        .animation(.easeInOut(duration: 0.25), value: self.step)
        .frame(width: 560, height: 480)
    }
}

// MARK: - Step 1: Welcome

private struct WelcomeStepView: View {
    let onGuide: () -> Void
    let onSkip: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 16) {
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 52))
                    .foregroundStyle(.tint)

                Text("Welcome to CodexBar")
                    .font(.largeTitle.bold())

                Text("CodexBar shows your AI token usage right in the menu bar — for Claude, Codex, Cursor, Gemini, and more.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 380)
            }

            Spacer()

            VStack(spacing: 12) {
                Button(action: self.onGuide) {
                    Text("Guide me through setup")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .frame(maxWidth: 300)

                Button(action: self.onSkip) {
                    Text("I know what I'm doing  →")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                .frame(maxWidth: 300)
            }
            .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 40)
    }
}

// MARK: - Step 2: Providers

private struct ProvidersStepView: View {
    @Bindable var settings: SettingsStore
    let onBack: () -> Void
    let onContinue: () -> Void

    private var enabledProviders: [UsageProvider] {
        settings.providerOrder.filter { settings.providerEnablement[$0] == true }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 6) {
                Text("Provider Access")
                    .font(.title2.bold())
                Text("Here's what CodexBar reads for each enabled provider.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 32)
            .padding(.horizontal, 32)

            // Provider cards
            ScrollView(.vertical, showsIndicators: true) {
                LazyVStack(spacing: 10) {
                    ForEach(self.enabledProviders, id: \.self) { provider in
                        ProviderOnboardingCard(provider: provider)
                    }
                }
                .padding(.horizontal, 32)
                .padding(.vertical, 16)
            }

            // Navigation
            HStack {
                Button("← Back", action: self.onBack)
                    .buttonStyle(.bordered)
                    .controlSize(.large)

                Spacer()

                Button("Continue →", action: self.onContinue)
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 28)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Provider card

private struct ProviderOnboardingCard: View {
    let provider: UsageProvider

    private var displayName: String {
        ProviderDescriptorRegistry.descriptor(for: self.provider).metadata.displayName
    }

    private var info: OnboardingProviderInfo.Info {
        OnboardingProviderInfo.info(for: self.provider)
    }

    private var icon: NSImage? {
        ProviderBrandIcon.image(for: self.provider)
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Provider icon
            Group {
                if let icon = self.icon {
                    Image(nsImage: icon)
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundStyle(.primary)
                } else {
                    Image(systemName: "cpu")
                        .frame(width: 20, height: 20)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.top, 2)

            VStack(alignment: .leading, spacing: 4) {
                Text(self.displayName)
                    .font(.body.bold())

                Text(self.info.accessSummary)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 8)

            Text(self.info.accessMethod)
                .font(.caption.bold())
                .foregroundStyle(.tint)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(Color.accentColor.opacity(0.12), in: RoundedRectangle(cornerRadius: 5))
        }
        .padding(12)
        .background(.background.opacity(0.6), in: RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(.separator, lineWidth: 0.5))
    }
}

// MARK: - Step 3: Summary

private struct SummaryStepView: View {
    @Bindable var settings: SettingsStore
    let onDone: () -> Void

    private var enabledProviders: [UsageProvider] {
        settings.providerOrder.filter { settings.providerEnablement[$0] == true }
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 16) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 52))
                    .foregroundStyle(.green)

                Text("You're all set!")
                    .font(.largeTitle.bold())

                Text("CodexBar will start tracking usage for the following providers:")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 380)

                VStack(alignment: .leading, spacing: 6) {
                    ForEach(self.enabledProviders, id: \.self) { provider in
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                                .font(.footnote)
                            Text(ProviderDescriptorRegistry.descriptor(for: provider).metadata.displayName)
                                .font(.footnote)
                        }
                    }
                }
                .frame(maxWidth: 300, alignment: .leading)
                .padding(12)
                .background(.background.opacity(0.6), in: RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(.separator, lineWidth: 0.5))
            }

            Spacer()

            Button("Done", action: self.onDone)
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .frame(maxWidth: 200)
                .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 40)
    }
}
