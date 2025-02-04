# MemoCards

MemoCards is a flashcard app built with SwiftUI and SwiftData. It helps users learn and review information through interactive cards. The app supports intuitive swipe gestures to mark cards and offers a reset feature to restart the game without losing any data.

## Key Features

- **Intuitive Interface:**  
  Use swipe gestures to mark cards as correct or incorrect.

- **SwiftData Persistence:**  
  Replaces UserDefaults with SwiftData for scalable data storage and easier future integration with CloudKit.

- **Card Inactivation Instead of Deletion:**  
  Cards are marked as inactive (rather than being deleted) when swiped right, allowing for a complete reset of the game with the "Start Again" button.

- **Card Editing:**  
  Easily add, delete, and modify cards in the edit mode.

- **Accessibility Support:**  
  Optimized for VoiceOver and other accessibility features for an inclusive user experience.

## Requirements

- **iOS:** 17 or later  
- **Xcode:** 15 or newer  
- **Frameworks:** SwiftUI, SwiftData

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/MemoCards.git
   ```
2. Open the project in Xcode.
3. Build and run the app on your simulator or device.

## Future Improvements

- Integrate CloudKit for data synchronization across devices.
- Add enhanced user progress tracking.
- Improve animations and UI/UX.

## License

This is an open-source project. Please refer to the [LICENSE](LICENSE) file for details.
