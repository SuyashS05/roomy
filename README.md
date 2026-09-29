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

## User Flow

```mermaid
flowchart TD
   A[Open Roomy] --> B{Verified session exists?}
   B -- Yes --> G[Load stored Firestore role]
   B -- No --> C[Login screen]
   C --> D{Choose action}
   D -- Sign in --> E[Enter email and password]
   E --> F{Email verified?}
   F -- Yes --> G
   F -- No --> H[Resend verification email]
   H --> I[Verify email, then sign in again]
   I --> E
   D -- Sign up --> J[Choose room seeker or room owner]
   J --> K[Create Firebase Auth account]
   K --> L[Send verification email]
   L --> M[Verify email and tap I have verified]
   M --> N[Create Firestore user profile]
   N --> G
   G --> O{Stored role}
   O -- user --> P[Room seeker home]
   O -- roomOwner --> Q[Room owner home]
   O -- admin or master --> R[Admin home]
```

Admin and master accounts are not self-service signup options; provision them through a trusted process and assign the required Firebase Auth admin claim.

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

* Flutter SDK providing Dart 3.7.2 or newer

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

   * Enable the Maps SDK for Android in Google Cloud and restrict its key to this Android package and signing certificate.

   * Set `MAPS_API_KEY` in your shell or CI secret store, or add `MAPS_API_KEY=your-key` to the ignored `android/local.properties` file.

   * For PowerShell, set `$env:MAPS_API_KEY = "your-key"` before running `flutter run`.

   * Maps keys are included in the built app and cannot be kept secret there. Restrict the key to the required API and app identity, and rotate any key that was committed or exposed. Firebase client API keys are also public configuration; protect Firebase data with Security Rules and App Check rather than treating those keys as secrets.

5. Run the app:

   ```bash
   flutter run
   ```

---

## 📸 Screenshots

<div align="center">
<img src="assets/img/2.jpeg" width="180" alt="App screenshot 2" />
<img src="assets/img/3.jpeg" width="180" alt="App screenshot 3" />
<img src="assets/img/5.jpeg" width="180" alt="App screenshot 5" />
<img src="assets/img/6.jpeg" width="180" alt="App screenshot 6" />
<img src="assets/img/7.jpeg" width="180" alt="App screenshot 7" />
<img src="assets/img/9.jpeg" width="180" alt="App screenshot 9" />
<img src="assets/img/10.jpeg" width="180" alt="App screenshot 10" />
<img src="assets/img/11.jpeg" width="180" alt="App screenshot 11" />
<img src="assets/img/12.jpeg" width="180" alt="App screenshot 12" />
<img src="assets/img/13.jpeg" width="180" alt="App screenshot 13" />
<img src="assets/img/14.jpeg" width="180" alt="App screenshot 14" />
<img src="assets/img/15.jpeg" width="180" alt="App screenshot 15" />
<img src="assets/img/16.jpeg" width="180" alt="App screenshot 16" />
<img src="assets/img/18.jpeg" width="180" alt="App screenshot 18" />
<img src="assets/img/19.jpeg" width="180" alt="App screenshot 19" />
<img src="assets/img/20.jpeg" width="180" alt="App screenshot 20" />
<img src="assets/img/21.jpeg" width="180" alt="App screenshot 21" />
<img src="assets/img/22.jpeg" width="180" alt="App screenshot 22" />
<img src="assets/img/24.jpeg" width="180" alt="App screenshot 24" />
</div>


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

* **Suyash S Kotkar** – *Lead Developer*

<!-- * **Suyash Kotkar** – *UI/UX Designer* -->
* **Prathmesh P** – *Lead Developer*

* **Sahil P** – *Lead Developer*

---
