# MediSync Test Users Guide

## Testing Mode Status
✅ **Mock Auth Enabled** - The app is currently using mock authentication with test users.

To switch to real API, edit `lib/core/di/injection.dart`:
```dart
const bool _useMockAuth = false;  // ← Change to false
```

---

## Test Credentials

All test users use the same password: `test@123`

### 1. **Doctor**
- **Email:** `dr.singh@apollo.com`
- **Role:** Doctor
- **Hospital:** apollo_delhi
- **Full Name:** Dr. Rajesh Singh
- **Access:** Doctor Dashboard with patient management, care gaps, lab results, appointments

### 2. **Care Coordinator**
- **Email:** `kavya.patel@apollo.com`
- **Role:** Care Coordinator
- **Hospital:** apollo_delhi
- **Full Name:** Kavya Patel
- **Access:** Coordinator Dashboard (Coming Soon)

### 3. **Hospital Admin**
- **Email:** `admin@apollo.com`
- **Role:** Hospital Admin
- **Hospital:** apollo_delhi
- **Full Name:** Meera Iyer
- **Access:** Hospital Admin Dashboard with facility management

### 4. **Lab Technician**
- **Email:** `arjun.kumar@apollo.com`
- **Role:** Lab Technician
- **Hospital:** apollo_delhi
- **Full Name:** Arjun Kumar
- **Access:** Lab Technician Dashboard with sample collection & tracking

### 5. **Platform Admin (Super Admin)**
- **Email:** `admin@medisync.ai`
- **Role:** Platform Admin
- **Hospital:** medisync
- **Full Name:** Platform Admin
- **Access:** Platform Admin Dashboard with system monitoring

---

## How to Test

1. **Run the app:**
   ```bash
   flutter run
   ```

2. **Login page will appear** - Select a role and enter credentials

3. **Each user has different dashboard** - Try all 5 roles to verify:
   - Doctor Dashboard (fully implemented)
   - Hospital Admin Dashboard (fully implemented)
   - Lab Technician Dashboard (fully implemented)
   - Platform Admin Dashboard (fully implemented)
   - Coordinator Dashboard (placeholder)

4. **Test features:**
   - Role-based navigation ✅
   - Patient data display ✅
   - Care gap tracking ✅
   - Lab results ✅
   - Logout functionality ✅

---

## Test Data Locations

- **Test Users:** `lib/core/constants/test_data.dart`
- **Mock Auth Service:** `lib/core/services/mock_auth_service.dart`
- **Dependency Injection:** `lib/core/di/injection.dart`

---

## Switching Between Test & Production

Edit `lib/core/di/injection.dart` line 12:

```dart
// For TESTING (mock auth with sample users)
const bool _useMockAuth = true;

// For PRODUCTION (real API)
const bool _useMockAuth = false;
```

Then run: `flutter pub get && flutter run`
