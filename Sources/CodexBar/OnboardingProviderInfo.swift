import CodexBarCore

/// Static descriptions shown per-provider during the onboarding flow.
enum OnboardingProviderInfo {
    struct Info {
        /// One-sentence description of what CodexBar does for this provider.
        let accessSummary: String
        /// Short badge label (e.g. "OAuth", "API Key", "Browser session").
        let accessMethod: String
    }

    static func info(for provider: UsageProvider) -> Info {
        switch provider {
        case .claude:
            return Info(
                accessSummary: "Reads your session usage via OAuth or browser cookie.",
                accessMethod: "OAuth / Cookie")
        case .codex:
            return Info(
                accessSummary: "Fetches token quota and credits via your OpenAI session.",
                accessMethod: "Browser session")
        case .cursor:
            return Info(
                accessSummary: "Reads request quota from your Cursor account session.",
                accessMethod: "Browser session")
        case .opencode:
            return Info(
                accessSummary: "Reads usage data from your OpenCode session cookie.",
                accessMethod: "Cookie")
        case .factory:
            return Info(
                accessSummary: "Fetches drep session usage from your Factory account.",
                accessMethod: "Cookie")
        case .gemini:
            return Info(
                accessSummary: "Reads Google AI Studio quota via your Google session.",
                accessMethod: "Browser session")
        case .antigravity:
            return Info(
                accessSummary: "Reads usage from your Antigravity Google Workspace session.",
                accessMethod: "Browser session")
        case .copilot:
            return Info(
                accessSummary: "Reads GitHub Copilot quota from your Copilot token.",
                accessMethod: "Token")
        case .zai:
            return Info(
                accessSummary: "Fetches usage from your Zai API key.",
                accessMethod: "API Key")
        case .minimax:
            return Info(
                accessSummary: "Reads MiniMax usage via API key or browser cookie.",
                accessMethod: "API Key / Cookie")
        case .kimi:
            return Info(
                accessSummary: "Fetches Kimi quota from your account token.",
                accessMethod: "Token")
        case .kilo:
            return Info(
                accessSummary: "Reads Kilo Code usage from your account session.",
                accessMethod: "Browser session")
        case .kiro:
            return Info(
                accessSummary: "Fetches Kiro usage quota from your account session.",
                accessMethod: "Browser session")
        case .vertexai:
            return Info(
                accessSummary: "Reads Google Vertex AI quota via OAuth credentials.",
                accessMethod: "OAuth")
        case .augment:
            return Info(
                accessSummary: "Reads Augment Code session usage from your account.",
                accessMethod: "Browser session")
        case .jetbrains:
            return Info(
                accessSummary: "Reads JetBrains AI token usage from local IDE logs.",
                accessMethod: "Local files")
        case .kimik2:
            return Info(
                accessSummary: "Fetches Kimi K2 quota from your account token.",
                accessMethod: "Token")
        case .amp:
            return Info(
                accessSummary: "Reads Amp session usage from your account cookie.",
                accessMethod: "Cookie")
        case .ollama:
            return Info(
                accessSummary: "Connects to your local Ollama instance to read model usage.",
                accessMethod: "Local API")
        case .synthetic:
            return Info(
                accessSummary: "Reads usage from a custom API key you configure.",
                accessMethod: "API Key")
        case .warp:
            return Info(
                accessSummary: "Fetches Warp AI request quota from your account session.",
                accessMethod: "Browser session")
        case .openrouter:
            return Info(
                accessSummary: "Reads OpenRouter credit balance and usage via API key.",
                accessMethod: "API Key")
        }
    }
}
