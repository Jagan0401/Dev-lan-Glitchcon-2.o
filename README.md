# MediSync

MediSync is a healthcare coordination platform designed to streamline communication and workflows between hospitals, doctors, coordinators, and lab technicians.

The project consists of two main components:

* **Web Application (Django Backend + Web Interface)**
* **Mobile Application (Django Backend + Flutter App)**

---

# Product Showcase

| ![](screenshots/8.jpg) |
| ![](screenshots/9.jpg) |
| ![](screenshots/10.jpg) |
| ![](screenshots/1.jpg) |
| ![](screenshots/2.jpg) |
| ![](screenshots/3.jpg) |
| ![](screenshots/4.jpg) |
| ![](screenshots/5.jpg) |
| ![](screenshots/6.jpg) |
| ![](screenshots/7.jpg) |



# 1️⃣ Web Application Setup

## MediSync Backend Setup Guide

Follow the steps below to set up and run the MediSync backend locally.

### Step 1: Navigate to the Project Directory

```bash
cd medisync
cd backend
```

### Step 2: Create a Virtual Environment

```bash
python -m venv .venv
```

### Step 3: Activate the Virtual Environment

**Windows (PowerShell / Command Prompt)**

```bash
.venv\Scripts\activate
```

### Step 4: Install Required Dependencies

```bash
pip install -r requirements.txt
```

### Step 5: Run the Development Server

```bash
python manage.py runserver
```

The backend server should now be running locally.

---

# Sample Login Credentials

Use the following credentials to access different roles in the system.

| Email (Username)                                    | Role           | Hospital / Organization ID |
| --------------------------------------------------- | -------------- | -------------------------- |
| [admin@medisync.ai](mailto:admin@medisync.ai)       | Platform Admin | None (Platform Level)      |
| [meera@apollo.com](mailto:meera@apollo.com)         | Hospital Admin | apollo_chennai             |
| [rahul@fortis.com](mailto:rahul@fortis.com)         | Doctor         | fortis_blr                 |
| [kavya@apollo.com](mailto:kavya@apollo.com)         | Coordinator    | apollo_chennai             |
| [arjun@globalcare.com](mailto:arjun@globalcare.com) | Lab Technician | None                       |

**Password for all users**

```
admin123
```

---

# Running the MediSync Agent

To start the MediSync automation agent, run the following file:

```
start_medisync.bat
```

This launches the background agent required for system automation.

---

# 2️⃣ Flutter Mobile Application Setup

Before running the Flutter app, make sure the **backend server is already running**.

### Step 0: Run Backend

Follow the **Web Application Setup** steps above and start the Django server.

### Step 1: Install Flutter Dependencies

```bash
flutter pub get
```

### Step 2: Run the Flutter Application

```bash
flutter run
```

The Flutter app will connect to the running MediSync backend.

---

# Notes

* Ensure **Python** and **Flutter SDK** are installed before starting.
* Always activate the **Python virtual environment** before running the backend.
* Install dependencies using `requirements.txt` to avoid missing packages.
* The backend must be running before launching the Flutter application.

---

# MediSync Architecture

```
Flutter Mobile App
        │
        ▼
Django Backend API
        │
        ▼
Database / Services / MediSync Agent
```

---

# Contributors

MediSync is developed as part of an innovative healthcare technology project aimed at improving coordination between healthcare providers and patients.
