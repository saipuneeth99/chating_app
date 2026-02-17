# Chat App

A beautiful and real-time chat application built with Flutter and Supabase. Connect with other users, send messages, and manage your conversations seamlessly.

## Features

- **User Authentication**: Sign up and login with email and password
- **Real-time Messaging**: Send and receive messages instantly
- **User Discovery**: Search and find users to start new conversations
- **Conversation Management**: View all your active conversations in one place
- **User Profiles**: See usernames and full names of other users
- **Timestamps**: Track when messages were sent with relative time display
- **Dark Mode Support**: Full dark and light theme support
- **Responsive Design**: Works seamlessly on all device sizes

## Tech Stack

### Frontend
- **Flutter** - Cross-platform mobile framework
- **Provider** - State management solution
- **Material 3** - Modern Material Design UI components

### Backend & Services
- **Supabase** - Backend-as-a-Service (PostgreSQL, Authentication, Real-time)
- **Dart** - Programming language

### Key Dependencies
- `supabase_flutter: ^2.12.0` - Supabase integration
- `provider: ^6.1.5+1` - State management
- `cached_network_image: ^3.4.1` - Image caching
- `intl: ^0.20.2` - Internationalization
- `uuid: ^4.5.2` - UUID generation
- `shared_preferences: ^2.5.3` - Local storage
- `timeago: ^3.7.1` - Relative time formatting

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── cofig/
│   └── supabase_config.dart  # Supabase configuration
├── models/
│   ├── user_model.dart       # User data model
│   ├── conversation_model.dart # Conversation data model
│   └── message_model.dart    # Message data model
├── providers/
│   ├── auth_provider.dart    # Authentication state management
│   └── chat_provider.dart    # Chat state management
└── screens/
    ├── splash_screen.dart    # App splash screen
    ├── signup_screen.dart    # User registration
    ├── login_screen.dart     # User login
    ├── home_screen.dart      # Conversations list
    ├── chat_screen.dart      # Individual chat interface
    └── new_chat_screen.dart  # Start new conversation
```

## Screenshots

### Welcome Flow
<div align="center">
  
| Splash Screen | Sign Up |
|---|---|
| ![Splash Screen](assets/screenshots/splash.png) | ![Sign Up](assets/screenshots/signup.png) |

| Login | Messages List |
|---|---|
| ![Login](assets/screenshots/login.png) | ![Messages List](assets/screenshots/messages_list.png) |

| Chat Screen | New Chat |
|---|---|
| ![Chat Screen](assets/screenshots/chat_screen.png) | ![New Chat](assets/screenshots/new_chat.png) |

</div>

## Getting Started

### Prerequisites
- Flutter SDK (version 3.8.1 or higher)
- Dart SDK
- Supabase account and project

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd chat_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Supabase**
   - Create a Supabase project at [https://supabase.com](https://supabase.com)
   - Update `lib/cofig/supabase_config.dart` with your Supabase URL and anonymous key:
   ```dart
   class SupabaseConfig {
     static const String supabaseUrl = 'YOUR_SUPABASE_URL';
     static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
   }
   ```

4. **Run the application**
   ```bash
   flutter run
   ```

## Usage

### Creating an Account
1. Launch the app
2. Tap the "Sign Up" link on the login screen
3. Enter your email, username, full name (optional), and password
4. Tap "Sign Up" to create your account

### Starting a Conversation
1. Authenticate with your credentials
2. Tap the "+" button on the home screen
3. Search for a user by username
4. Select the user to start a new conversation

### Sending Messages
1. Open a conversation from the messages list
2. Type your message in the text field at the bottom
3. Tap the send button to send the message
4. Messages will appear in real-time for both users

## Architecture

This app uses the **Provider pattern** for state management:

- **AuthProvider**: Manages user authentication state, login, signup, and logout operations
- **ChatProvider**: Manages chat state, conversations, messages, and real-time updates from Supabase

The app follows the MVC pattern with clear separation between:
- **Models**: Data structures and business logic
- **Providers**: State management and business logic
- **Screens**: UI presentation and user interaction

## Database Schema

The app requires the following Supabase tables:

### Users Table
```sql
CREATE TABLE users (
  id UUID PRIMARY KEY,
  email TEXT UNIQUE,
  username TEXT UNIQUE,
  full_name TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Conversations Table
```sql
CREATE TABLE conversations (
  id UUID PRIMARY KEY,
  user_id_1 UUID REFERENCES users(id),
  user_id_2 UUID REFERENCES users(id),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Messages Table
```sql
CREATE TABLE messages (
  id UUID PRIMARY KEY,
  conversation_id UUID REFERENCES conversations(id),
  sender_id UUID REFERENCES users(id),
  content TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## Features in Development

- Message notifications
- User presence indicators
- Message read receipts
- Image sharing
- Voice messages
- Group conversations
- User blocking functionality

## Known Issues

- Refer to `sql_fix.sql`, `sql_fix_v2.sql`, and `sql_fix_v3.sql` for database migration notes

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support, email support@chatapp.com or create an issue in the repository.

## Acknowledgments

- Built with [Flutter](https://flutter.dev/)
- Backend powered by [Supabase](https://supabase.com/)
- State management with [Provider](https://pub.dev/packages/provider)
