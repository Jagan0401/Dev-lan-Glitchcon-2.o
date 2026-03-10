# MediSync Blank Pages - Debugging Guide

## Current Status
✅ Code compiles without errors
✅ All seed data is defined and properly imported  
✅ All widgets are implemented
✅ Dependencies installed successfully

## Likely Causes & Solutions

### 1. **Device Configuration Issue (Most Likely)**
If pages show blank on-device but work in other conditions:

```bash
# Try clearing app data and reinstalling
flutter clean
flutter pub get
flutter run --release
```

**For Android:**
```bash
# Clear app cache
adb shell pm clear com.medisync.app
flutter run
```

### 2. **Layout Render Issue**
If you see app bar and bottom nav but middle is blank:

- The `ListView` might have zero height
- Content might be off-screen due to padding/margin

**Fix:** Check `Expanded` wrapper in Column - it should fill remaining space.

### 3. **State Not Loading**
If dashboard loads but no data appears:

- AuthBloc might not be emitting `AuthAuthenticatedState` correctly
- MockAuthService might be failing silently

**Debug:** Look at Flutter console for these messages:
```
[DEBUG] DoctorDashboard initState - patients: 5, gaps: 5, results: 5, appointments: 5
[DEBUG] Building tab body for: Dashboard  
[DEBUG] _DashboardTab build - patients: 5
```

### 4. **Theme/Color Issue**
If widgets render but text is invisible:

- Check if text color matches background (both white)
- Unlikely but possible: AppColors not loading

**Verify:** Run in debug mode and check Flutter Inspector

## Quick Verification Steps

### Step 1: Test Mock Auth
```bash
# Ensure mock auth is enabled (it should be by default)
# In lib/core/di/injection.dart, verify: const bool _useMockAuth = true;
```

### Step 2: Test With Sample Credentials
1. Open app
2. Login with:
   - **Email**: `doctor@example.com`
   - **Password**: `doctor123`
   - **Role**: Doctor

If auth works but pages blank, issue is in dashboard rendering.

### Step 3: Check Console Output
Run and watch for `[DEBUG]` messages:
```bash
flutter run 2>&1 | grep DEBUG
```

If you see debug messages, dashboard is initializing. If not, auth might be failing.

### Step 4: Test Other Dashboards
Once logged out, try logging in as:
- Hospital Admin: `admin@hospital.com` / `admin123`
- Lab Tech: `tech@lab.com` / `tech123`

If ALL dashboards show blank, likely a routing/theme issue.
If only Doctor blank, likely specific to doctor dashboard.

## Known Seed Data

All dashboards have test data pre-loaded:

**Doctor Dashboard:**
- 5 Patients (Ravi Kumar, Meena Iyer, Arjun Patel, Neha Sharma, Karthik Rao)
- 5 Care Gaps
- 5 Lab Results
- 5 Appointments
- Activity feed with 5 items
- Caseload chart

If you don't see ANY of this, the dashboard isn't rendering at all.

## Immediate Actions

1. **Clean & Rebuild:**
   ```bash
   flutter clean
   flutter pub get
   flutter run --debug
   ```

2. **Check Device/Emulator:**
   - Try different device if available
   - Update Android/iOS if not latest
   - Try web in Chrome: `flutter run -d chrome`

3. **Check Logs in Flutter DevTools:**
   ```bash
   flutter run -d <device-id>
   # Open http://localhost:xxxxx in browser
   ```

4. **Report Debug Output:**
   When you run the app and see blank pages, share:
   - Console output (especially [DEBUG] lines)
   - Device type (Android/iOS/Web)
   - Screenshot of what you see
   
## File Structure Verification

Key files that must exist for dashboards to work:

```
✓ lib/features/doctor/models/doctor_dashboard_models.dart (has seed data)
✓ lib/features/doctor/screens/doctor_dashboard.dart (imports models)
✓ lib/features/doctor/widgets/activity_feed.dart
✓ lib/features/doctor/widgets/caseload_chart.dart
✓ lib/features/doctor/widgets/metric_card.dart
✓ lib/core/theme/app_theme.dart (AppColors defined)
```

All verified ✓

## Next Steps

1. Run the debug test script: `DEBUG_TEST.ps1`
2. Share console output with [DEBUG] messages
3. Specify which device/platform you're testing on
4. Describe exactly what you see (blank white screen, partial UI, etc.)
