# FoundationModelsChat

A modern, local **AI chat application** built with **SwiftUI**, **Swift Concurrency**, and **The Composable Architecture (TCA)**, leveraging **Apple Foundation Models** for efficient local LLM interactions on **macOS** and **iOS**.

[👉 View on GitHub](https://github.com/Anderson-Hyl/FoundationModelsChat)

---

## 🚀 Features

✅ **Local LLM Chat** using Apple Foundation Models  
✅ **Streaming responses** with smooth TCA-based state management  
✅ **Adaptive, Apple Intelligence-inspired UI** with dynamic gradients and glass effects  
✅ **Structured local database** with `sharing-grdb` for chat history  
✅ **Cross-platform macOS and iOS support** with efficient window management  
✅ **Minimal, clear architecture optimized for extension and experimentation**  

---

## 🧩 Architecture

The project utilizes **The Composable Architecture (TCA)** for clear, testable, and modular state management. The following diagram illustrates the current reducer structure:

```mermaid
%%{ init : { "theme" : "default", "flowchart" : { "curve" : "monotoneY" }}}%%
graph LR
    AppReducer ---> AppDelegateReducer
    AppReducer ---> OnboardingReducer
    HomeReducer ---> DialogsListReducer
    HomeReducer -- optional --> MessageListReducer
    MessageListReducer ---> MessageListInputReducer

    AppDelegateReducer(AppDelegateReducer: 1)
    DialogsListReducer(DialogsListReducer: 1)
    MessageListInputReducer(MessageListInputReducer: 1)
    MessageListReducer(MessageListReducer: 1)
    OnboardingReducer(OnboardingReducer: 1)


⸻

📦 Structure
	•	AppReducer:
	•	Entry point reducer for app lifecycle and routing.
	•	AppDelegateReducer:
	•	Handles app delegate interactions, window management, and onboarding checks.
	•	OnboardingReducer:
	•	Handles onboarding flow.
	•	HomeReducer:
	•	Manages home navigation, displaying dialogs and optionally message lists.
	•	DialogsListReducer:
	•	Displays a list of chat dialogs.
	•	MessageListReducer:
	•	Displays message lists within a dialog, supports streaming updates.
	•	MessageListInputReducer:
	•	Manages input state, send actions, and streaming triggers.

⸻

📚 Dependencies
	•	SwiftUI
	•	The Composable Architecture (TCA)
	•	Apple Foundation Models
	•	sharing-grdb
	•	Mermaid (for visual diagrams in documentation)

⸻

🚀 Getting Started
	1.	Clone the repository:

git clone https://github.com/Anderson-Hyl/FoundationModelsChat.git
cd FoundationModelsChat

	2.	Open in Xcode:

xed .

	3.	Run on your Mac or iOS Simulator.

⸻

🌈 Screenshots

[video](Screenshots/recording.mov)

⸻

✨ Future Plans
  • Bugfix
	•	Integration with Foundation Models audio and image modalities.
	•	Support for local prompt customization.
	•	Flexible plugin system for retrieval-augmented generation (RAG).
	•	CloudKit or iCloud sync (optional).

⸻

🤝 Contributing

Contributions are welcome! Please open issues or submit PRs for improvements.

⸻

📜 License

MIT License. See LICENSE for details.

⸻

👤 Author

Maintained by Anderson Huang.

⸻

FoundationModelsChat is designed as a practical and elegant base to build, iterate, and learn on top of local AI capabilities using Apple Foundation Models, TCA, and SwiftUI.
