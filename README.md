# TrollPro Max

A fun Flutter application with troll sounds and effects.

## Features

- **Electric Gun**: Make electric buzz sounds
- **Mosquito**: Play annoying mosquito buzzing
- **Hair Trimmer**: Hair clipper/tensioner sound
- **Fart**: Classic fart sound
- **Alarm**: Loud alarm sound
- **Fake System Error**: Create a fake virus alert
- **Unclickable Button**: A button that runs away when you try to press it

## Architecture

This app follows the MVVM (Model-View-ViewModel) architecture pattern:

- **Models**: Data classes
- **Views**: UI screens
- **ViewModels**: Logic and state management
- **Services**: Handle business logic for sound, flashlight, etc.

## Requirements

- Flutter SDK 3.7.0 or higher
- Android SDK 21+ (Android 5.0 or higher)
- iOS 12.0 or higher (optional)

## Getting Started

1. Make sure you have Flutter installed on your machine
2. Clone this repository
3. Run `flutter pub get` to install dependencies
4. Connect a device or start an emulator
5. Run `flutter run` to start the app

## Permissions

The app needs the following permissions:
- Camera (for flashlight)
- Vibration
- Audio

## Technologies Used

- Flutter
- Provider for state management
- AudioPlayers for sound playback
- Torch Light for flashlight control
- Vibration for haptic feedback
- Flutter Animate for animations

## License

This project is for educational purposes only.

## Acknowledgements

- Sound files from various sources
- Inspired by various troll apps
