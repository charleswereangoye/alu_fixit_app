# ALU FixIt - Campus Incident Reporting Mobile Application

## Overview

ALU FixIt (branded as FIXIT) is a cross-platform mobile application developed using Flutter and Firebase for the African Leadership University (ALU) campus community at Kigali Innovation City, Rwanda.

The application serves as a centralized incident reporting and facility tracking system. It enables students to easily report campus maintenance and safety issues, including water shortages, electrical faults, damaged furniture, sanitation problems, and security hazards. Campus staff can review incoming reports, filter issues by campus buildings or blocks, and update the resolution status in real time.

---

## Key Features

### 1. Authentication and Role-Based Access
- Secure account registration and sign-in backed by Firebase Authentication.
- Institutional domain restriction ensuring all accounts use valid @alueducation.com email addresses.
- Support for two distinct user roles:
  - Student: Submit incident reports, attach photos, track report progression, and manage personal submissions.
  - Campus Staff: Access the Staff Resolution Hub, review student reports across campus hubs, and update issue statuses.

### 2. Incident Reporting
- Report creation form capturing incident title, detailed description, issue category, campus location, and optional photo attachment.
- Five predefined incident categories: Facilities, Water, Electricity, Safety, and Sanitation.
- Authentic campus locations mapped to ALU Kigali Innovation City hubs, including Leadership Center learning labs, Social Commons, Enterprise Commons, Soul Hostels, and sports facilities.
- Photo attachment support with gallery selection and camera capture.

### 3. Status Progression and Tracking
- Three-stage lifecycle tracking for each incident: Submitted, In Progress, and Resolved.
- Visual status stepper showing exact timestamps for submission, technician assignment, and final resolution.
- Staff members can add resolution notes to document actions taken by maintenance teams.

### 4. Search and Campus Block Filtering
- Real-time search bar to find reports by incident title, description, student name, or location.
- Campus block filter chips to view issues by specific buildings:
  - Leadership Center
  - Social Commons
  - Enterprise Commons
  - Soul Hostels
  - Grounds and Security
- Status filter tabs to isolate reports that are Submitted, In Progress, or Resolved.

### 5. Profile and Avatar Management
- User profile dashboard displaying account details, institutional email, degree program or staff department, and campus location.
- Custom profile picture upload from device gallery or camera, stored securely in Firebase Storage.
- Seamless role switching option on the profile screen for testing and evaluation purposes.

---

## Technical Architecture

The application follows the Model-View-ViewModel (MVVM) design pattern using the Provider state management package. This architecture cleanly separates user interface components from business logic and database interactions.

```
lib/
├── main.dart                      # Application entry point and global MultiProvider setup
├── models/
│   ├── user_model.dart            # User data model with serialization and role getters
│   └── incident_model.dart        # Incident data model, block detection, and routing logic
├── providers/
│   ├── auth_provider.dart         # Authentication state, login, signup, and profile updates
│   └── incident_provider.dart     # Firestore CRUD, live stream listeners, and search filters
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart      # User login with institutional validation
│   │   └── signup_screen.dart     # Registration with role and department selection
│   ├── home/
│   │   └── home_screen.dart       # Student home feed and Staff Resolution Hub
│   ├── report/
│   │   └── report_incident_screen.dart # Incident submission form with photo upload
│   ├── details/
│   │   └── incident_details_screen.dart# Full report details, status timeline, and staff actions
│   ├── reports/
│   │   └── my_reports_screen.dart # Student report tracker and Campus Incident Queue
│   ├── profile/
│   │   └── profile_screen.dart    # User profile, avatar management, and role toggle
│   └── main_navigation_screen.dart# Bottom navigation bar with role-tailored tabs
├── widgets/
│   ├── incident_card.dart         # Reusable incident card with responsive layout
│   └── status_badge.dart          # Status badge indicator widget
└── utils/
    └── app_theme.dart             # Centralized design tokens, colors, and typography
```

---

## Technology Stack

- Framework: Flutter (Dart SDK 3.x)
- State Management: Provider package
- Backend Services:
  - Firebase Authentication: Email and password authentication with domain validation
  - Cloud Firestore: NoSQL real-time document database with collection streams
  - Firebase Storage: Cloud media storage for incident and profile images
- Local Assets: Image picker, intl (date formatting)

---

## Database Structure

### Users Collection (`users/{userId}`)
- `uid`: Unique Firebase Authentication user ID
- `name`: Full name of the user
- `email`: Institutional email address (@alueducation.com)
- `role`: Role identifier ("student" or "staff")
- `department`: Degree program for students or operational department for staff
- `campus`: Campus name ("Kigali, Rwanda")
- `profileImage`: Download URL for uploaded avatar image
- `createdAt`: Account creation date timestamp

### Incidents Collection (`incidents/{incidentId}`)
- `id`: Document identifier
- `title`: Short title of the reported incident
- `description`: Detailed explanation of the issue
- `category`: Category string (Facilities, Water, Electricity, Safety, Sanitation)
- `location`: Specific campus location string
- `imageUrl`: Download URL for attached photo
- `status`: Incident status (Submitted, In Progress, Resolved)
- `reportedByUid`: User ID of the reporting student
- `reportedByName`: Name of the reporting student
- `reportedByEmail`: Email of the reporting student
- `createdAt`: Submission date timestamp
- `inProgressAt`: Date timestamp when work commenced
- `resolvedAt`: Date timestamp when issue was marked resolved
- `resolutionNotes`: Optional technician notes describing the fix
- `assignedStaffName`: Name of the staff member managing the resolution

---

## Getting Started

### Prerequisites
- Flutter SDK (version 3.19 or later) installed and configured on your system
- Android Studio with an Android Emulator or a connected physical Android device
- Git installed on your machine

### Installation Steps

1. Clone the repository:
   ```bash
   git clone https://github.com/charleswereangoye/alu_fixit_app.git
   cd alu_fixit_app
   ```

2. Install all required dependencies:
   ```bash
   flutter pub get
   ```

3. Ensure Firebase configuration files are in place:
   - Android configuration: `android/app/google-services.json`

4. Launch the application on a running emulator or physical device:
   ```bash
   flutter run
   ```

---

## Running Tests and Code Quality

To execute the automated unit tests:
```bash
flutter test
```

To run static analysis and verify zero warnings or lint errors:
```bash
flutter analyze
```

---

## License

This project was developed for educational purposes as part of the individual coursework at the African Leadership University.
