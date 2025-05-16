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

# Troll Sounds App - Tối ưu hóa

## Tóm tắt các tối ưu hóa đã thực hiện

### 1. Loại bỏ debug prints không cần thiết
- Đã xóa toàn bộ debug prints dư thừa trong các file:
  - `lib/services/myinstants_service.dart` 
  - `lib/services/sound_service.dart`
  - `lib/screens/myinstants_screen.dart`
  - `lib/screens/home_screen.dart`
  - `lib/main.dart`

### 2. Cải thiện pubspec.yaml
- Loại bỏ các assets không tồn tại, sửa lỗi:
  ```
  Error: unable to find directory entry in pubspec.yaml: /Users/dohieu/Desktop/troll/assets/sounds/
  ```
- Làm sạch định dạng file để dễ đọc và bảo trì

### 3. Tối ưu code trong nhiều file
- Loại bỏ các comment không cần thiết
- Làm sạch code, đảm bảo giữ nguyên chức năng chính
- Giảm kích thước và độ phức tạp của code

### 4. Giữ nguyên chức năng chính
- Đảm bảo tính năng phát âm thanh từ MyInstants hoạt động như trước
- Giữ nguyên các tính năng của ứng dụng
- Sửa lỗi và warning khi thực hiện tối ưu

## Các cải tiến khác
- Thay thế giải pháp phân tích HTML phức tạp bằng danh sách âm thanh cố định đáng tin cậy
- Đơn giản hóa luồng code trong các dịch vụ chính
- Tối ưu quá trình xử lý URL và MIME type

## Lưu ý
Ứng dụng vẫn còn một số cảnh báo linter như:
- Unused imports
- Unused variables
- withOpacity deprecated

Các cảnh báo này không ảnh hưởng đến chức năng của ứng dụng và có thể được xử lý trong các lần tối ưu hóa tiếp theo.

# Sound App Optimization

## Cải Thiện UI/UX 

Ứng dụng đã được cải thiện đáng kể về mặt thiết kế giao diện và trải nghiệm người dùng, tập trung vào các thành phần sau:

### 1. Hiệu Ứng Skeleton Loading
- Đã thêm hiệu ứng shimmer loading khi tải dữ liệu
- Hiển thị UI skeleton trong khi đợi API trả về kết quả
- Cải thiện cảm giác ứng dụng phản hồi nhanh

### 2. Thanh Danh Mục (Category Bar)
- Thiết kế lại với gradient và hiệu ứng bóng đổ
- Cải thiện hiển thị mục đang chọn với kiểu chữ và màu sắc nổi bật
- Tối ưu hóa kích thước và khoảng cách giữa các mục

### 3. Nút Âm Thanh (Sound Button)
- Thiết kế hiện đại với gradient và bóng đổ tinh tế
- Thêm hiệu ứng sóng âm khi phát âm thanh
- Cải thiện bố cục nút với biểu tượng phát và nút tải xuống
- Tối ưu hiệu ứng khi chạm và nhấn giữ

### 4. Màn Hình Âm Thanh Online
- Thiết kế lại dạng lưới với 2 cột thay vì 3 cột để hiển thị rõ hơn
- Thêm thông báo khi không tìm thấy âm thanh
- Thêm hiệu ứng animation khi hiển thị danh sách âm thanh
- Cải thiện thông báo lỗi và thành công

### 5. Bản Địa Hóa
- Chuyển toàn bộ giao diện sang tiếng Việt
- Điều chỉnh tên các danh mục phù hợp với người dùng Việt Nam
- Hiển thị thông báo lỗi và thành công bằng tiếng Việt

### 6. Thanh Điều Hướng (Navigation Bar)
- Thiết kế lại thanh navigation với bo góc và bóng đổ
- Thêm hiệu ứng khi chuyển đổi giữa các tab
- Cập nhật tên các tab sang tiếng Việt

### 7. Các Cải Tiến Khác
- Tối ưu hóa hiệu suất khi tải và phát âm thanh
- Cải thiện phản hồi khi tải xuống âm thanh
- Thiết kế thông báo (toast/snackbar) hiện đại và rõ ràng hơn

## Công Nghệ Sử Dụng
- Flutter Animate: Thêm hiệu ứng animation mượt mà
- Shimmer Package: Tạo hiệu ứng loading skeleton
- Gradient và Shadow: Tạo giao diện hiện đại

## Lưu ý
Thiết kế mới đảm bảo tương thích với cả theme sáng và tối, đồng thời giữ nguyên tất cả chức năng của ứng dụng.

# Troll Sound Effects App - Enhancement Project

## Project Overview
This application provides a collection of sound effects that users can play, organize, and download. It includes sounds from the local app assets as well as from online sources like MyInstants.

## Recent Enhancements

### 1. Home Screen Redesign with Horizontal Category Bar
- Replaced dropdown category selector with a horizontally scrollable category bar
- Added visual icons for each category to improve recognition
- Implemented active category highlighting
- Added smooth animations for category switching

### 2. Sound Item UI/UX Optimization
- Redesigned sound cards with a modern, clean layout
- Added play, download, and favorite buttons
- Improved visual feedback with animations for currently playing sounds
- Enhanced card layout for better information hierarchy

### 3. My Instants Tab Enhancement
- Implemented matching design pattern from Home screen
- Added better error handling and loading states
- Improved category filtering consistent with Home screen
- Added download functionality for online sounds

### 4. API Integration Improvements
- Added proper caching to prevent duplicate requests
- Improved error handling and user feedback
- Enhanced sound metadata extraction from MyInstants
- Implemented timeout handling for network requests

### 5. Sound Download Functionality
- Added download progress indicators
- Improved error handling for downloads
- Added functionality to manage downloaded sounds
- Enhanced download button UI/UX

### 6. UX Improvements
- Added animations throughout the app
- Implemented proper loading and empty states
- Enhanced search functionality
- Improved error messages in both English and Vietnamese

## Development Setup

### Prerequisites
- Flutter SDK (version 3.0.0 or higher)
- Dart SDK (version 2.17.0 or higher)
- Android Studio / VSCode with Flutter extensions

### Installation
1. Clone this repository
2. Run `flutter pub get` to install dependencies
3. Run `flutter run` to start the app

## Feature List

- Browse sound effects by category
- Play sound effects with one tap
- Add sounds to favorites
- Download sounds from MyInstants
- Search for specific sounds
- Browse online sound libraries

## Technical Architecture
The app follows a clean architecture approach with:
- Models: Data classes representing sounds and categories
- Services: Business logic for sound playback, downloads, etc.
- Screens: UI components organized by functionality
- Widgets: Reusable UI components
- Utils: Helper functions and constants
