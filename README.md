# Roomie App

## 🏠 Overview

Roomie is a comprehensive platform designed to simplify the process of finding roommates and shared accommodations. Whether you're a student, a working professional, or someone relocating to a new city, Roomie connects you with compatible housemates and available rooms, making shared living convenient and stress-free.

---

## 📱 Features

### For Roommates

* **Profile Creation**: Build a detailed profile with personal information, preferences, and lifestyle habits.

* **Matchmaking System**: Utilize a Tinder-style swipe feature to find potential roommates based on shared interests, habits, and preferences.

* **Search Filters**: Apply filters such as location, budget, smoking habits, pet preferences, and more to find the ideal match.

* **Real-Time Chat**: Engage in secure, in-app messaging to communicate with potential roommates.

* **Availability Calendar**: View and manage availability to coordinate move-in dates.

### For Landlords

* **Room Listing**: Easily list available rooms with detailed descriptions, photos, and rental terms.

* **Tenant Matching**: Receive recommendations for potential tenants based on compatibility scores.

* **Application Management**: Review applications, schedule interviews, and finalize agreements through the platform.

* **Payment Integration**: Set up secure payment methods for rent collection and deposits.

---

## 🛠️ Tech Stack

* **Frontend**: Flutter – for building natively compiled applications for mobile, web, and desktop from a single codebase.

* **Backend**: Firebase – for real-time database, authentication, and storage solutions.

* **Maps Integration**: Google Maps API – to display room locations and nearby amenities.

* **Authentication**: Firebase Authentication – for secure sign-in and user management.

* **Storage**: Firebase Storage – to upload and manage images and documents.

* **Push Notifications**: Firebase Cloud Messaging – to send notifications about new matches and messages.

---

## 🚀 Getting Started

### Prerequisites

* Flutter 3.4 or higher

* Firebase account with Firestore and Firebase Storage enabled

* Google Maps API key

### Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/SuyashS05/roomy.git
   cd roomy
   ```

2. Install dependencies:

   ```bash
   flutter pub get
   ```

3. Set up Firebase:

   * Create a Firebase project at [https://console.firebase.google.com/](https://console.firebase.google.com/).

   * Add your app to the Firebase project.

   * Download the `google-services.json` (for Android) or `GoogleService-Info.plist` (for iOS) and place it in the appropriate directory.

4. Configure Google Maps API:

   * Enable the Maps SDK for Android and iOS in your Google Cloud Console.

   * Add your API key to the app's configuration files.

5. Run the app:

   ```bash
   flutter run
   ```

---

## 📸 Screenshots

![Home Screen](assets/screenshots/home.png)

![Room Matching](assets/screenshots/matching.png)

![Chat Interface](assets/screenshots/chat.png)

---

## 📄 License

This project is licensed under the MIT License – see the [LICENSE.md](LICENSE.md) file for details.

---

## 🤝 Contributing

We welcome contributions to enhance the Roomie app. To contribute:

1. Fork the repository.

2. Create a new branch (`git checkout -b feature/your-feature`).

3. Make your changes and commit them (`git commit -am 'Add new feature'`).

4. Push to the branch (`git push origin feature/your-feature`).

5. Create a new Pull Request.

Please ensure your code adheres to the project's coding standards and includes appropriate tests.

---

## 🧑‍💻 Contributors

* **Farah Ait Elahmadi** – *Lead Developer*

* **Rachid Bourigue** – *UI/UX Designer*

---

## 📧 Contact

For inquiries or feedback, please reach out to us at [contact@roomieapp.com](mailto:contact@roomieapp.com).

---

## 🔗 Links

* [Roomie Website](https://www.roomieapp.com)

* [Roomie on GitHub](https://github.com/your-username/roomie-app)

---


## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
