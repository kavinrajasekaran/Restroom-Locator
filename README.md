# 🏰 Restroom Locator

A **SwiftUI-based iOS application** that helps users locate the nearest public restrooms. The app utilizes **MapKit**, **SwiftData**, and **CoreLocation** to fetch and display bathroom locations, allowing users to contribute comments and access restroom codes.

---

## 🚀 Features

- **📌 Locate Restrooms**: Uses **MapKit** and **SwiftData** to find restrooms near the user.
- **🗺 Interactive Map**: Users can view restroom locations on a map with markers.
- **📝 User Contributions**: Users can add **comments** and **codes** to bathrooms.
- **🔑 Bathroom Codes**: Provides the most upvoted bathroom codes.
- **🔒 User Authentication**: Allows users to sign up and log in.
- **📊 SwiftData Integration**: Stores and retrieves user data, comments, and codes.
- **🌍 Offline Storage**: Uses local storage to cache restroom data.

---

## 🛠 Tech Stack


SwiftUI, MapKit, SwiftData, CoreLocation


---

## 📂 Project Structure

```
📺 Restroom Locator
┣ 📚 Views
┃ ┣ 📄 ContentView.swift      # Main app layout with TabView
┃ ┣ 📄 MapTabView.swift       # Map screen with restroom markers
┃ ┣ 📄 NearestRestroomView.swift # Displays the closest restroom
┃ ┣ 📄 BathroomDetailView.swift # Shows restroom details, comments, and codes
┃ ┣ 📄 AuthViews.swift        # Login & Sign-Up UI
┃ ┗ 📄 MapView.swift          # Custom MapKit implementation
┣ 📚 Models
┃ ┣ 📄 Models.swift           # User, Bathroom, Comment, Code, and Vote models
┃ ┗ 📄 Item.swift             # Example model for SwiftData
┣ 📚 Managers
┃ ┣ 📄 LocationManager.swift  # Handles location services
┃ ┗ 📄 BathroomFetcher.swift  # Fetches restrooms from MapKit & SwiftData
┣ 📄 RestroomLocatorApp.swift # App entry point
┣ 📄 README.md                # Project documentation
┗ 📄 Package.swift            # Swift package dependencies
```

---



## 📦 Installation

1. **Clone the Repository**:
   ```sh
   git clone https://github.com/yourrepo/restroom-locator.git
   cd restroom-locator
   ```

2. **Open in Xcode**:
   - Open `RestroomLocator.xcodeproj` or `RestroomLocator.xcworkspace` in **Xcode**.

3. **Run on a Simulator or Device**:
   - Select an iPhone Simulator and press **Cmd + R**.

---

## 🔥 Key Components

### **1️⃣ Map & Annotations**
- `MapTabView.swift` integrates `MapView.swift` to display restrooms.
- Uses **MapKit** to place **MKPointAnnotation** for restroom locations.

### **2️⃣ Bathroom Details & Comments**
- `BathroomDetailView.swift` displays **restroom info, comments, and codes**.
- Users can **log in** to contribute and **upvote/downvote codes**.

### **3️⃣ Authentication System**
- `AuthViews.swift` provides a **Login & Signup UI**.
- `Models.swift` includes **User authentication** with hashed passwords.

### **4️⃣ Location Manager**
- `LocationManager.swift` fetches **user’s current location**.
- Used to **find nearest restrooms** in `NearestRestroomView.swift`.

### **5️⃣ SwiftData Persistence**
- `Models.swift` defines **Bathroom, Comment, and Code** models.
- `BathroomFetcher.swift` fetches and stores data locally.

---

## 🤝 Contributing

Contributions are welcome! If you’d like to contribute:
1. **Fork the repo**
2. **Create a new branch** (`git checkout -b feature-newFeature`)
3. **Commit changes** (`git commit -m "Added new feature"`)
4. **Push to GitHub** (`git push origin feature-newFeature`)
5. **Submit a Pull Request**

---

## 📜 License

**MIT License** - Feel free to modify and distribute the project.

---

## 💎 Contact

For any questions or feedback, reach out at:  
📧 **kavin.krajasekaran@gmail.com**

