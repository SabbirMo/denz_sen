# 🗺️ Google Maps Not Working - Solution

## ❌ Error Found:
```
E Google Maps Android API: Error requesting API token. 
StatusCode=INVALID_ARGUMENT
```

## 🔧 Solutions (Try in order):

### ✅ Solution 1: Enable APIs and Remove Restrictions

1. **Go to Google Cloud Console:**
   - [https://console.cloud.google.com/](https://console.cloud.google.com/)

2. **Enable Maps SDK:**
   - **APIs & Services** → **Library**
   - Search: **"Maps SDK for Android"**
   - Click and **ENABLE**

3. **Remove API Key Restrictions (for testing):**
   - **APIs & Services** → **Credentials**
   - Click your API key
   - **Application restrictions:** Select **"None"**
   - **API restrictions:** Select **"Don't restrict key"**
   - Click **SAVE**
   - ⏰ Wait 5 minutes for changes to propagate

4. **Enable Billing (REQUIRED!):**
   - **Billing** → **Link a billing account**
   - Add payment method
   - Google gives $200 free credit/month
   - Without billing, Maps will NOT work!

5. **Clean rebuild app:**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

---

### ✅ Solution 2: Create New API Key

1. **Google Cloud Console → Credentials**
2. **+ CREATE CREDENTIALS → API key**
3. Copy the new API key
4. Update in `android/app/src/main/AndroidManifest.xml`:
   ```xml
   <meta-data android:name="com.google.android.geo.API_KEY"
          android:value="YOUR_NEW_API_KEY_HERE"/>
   ```

5. Clean rebuild:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

---

### ✅ Solution 3: Add Package Name Restriction

1. **Get your package name:**
   - Open `android/app/build.gradle.kts`
   - Find: `namespace = "com.example.denz_sen"`

2. **Get SHA-1 fingerprint:**
   ```bash
   cd android
   ./gradlew signingReport
   ```
   
   Or:
   ```bash
   keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
   ```

3. **Add to API key restrictions:**
   - Google Cloud Console → Credentials → Your API key
   - **Application restrictions:** Android apps
   - Click **+ ADD AN ITEM**
   - Package name: `com.example.denz_sen`
   - SHA-1: (paste from step 2)
   - **SAVE**

---

### ✅ Solution 4: Check Required APIs

Make sure these are **ENABLED**:

- ✅ Maps SDK for Android
- ✅ Maps JavaScript API
- ✅ Places API
- ✅ Geocoding API
- ✅ Geolocation API

Go to: [APIs Library](https://console.cloud.google.com/apis/library)

---

## 🧪 Test Commands:

### 1. Check if API key is valid:
```bash
curl "https://maps.googleapis.com/maps/api/staticmap?center=40.714728,-73.998672&zoom=12&size=400x400&key=YOUR_API_KEY"
```

### 2. Check Maps SDK status:
```bash
adb logcat | Select-String "Google Maps"
```

### 3. Clean rebuild:
```bash
flutter clean
cd android
./gradlew clean
cd ..
flutter pub get
flutter run
```

---

## 📋 Checklist:

- [ ] Maps SDK for Android **ENABLED**
- [ ] Billing **ENABLED** (REQUIRED!)
- [ ] API restrictions **REMOVED** (for testing)
- [ ] Application restrictions **NONE** (for testing)
- [ ] Waited 5 minutes after changes
- [ ] `flutter clean` and rebuild
- [ ] API key in AndroidManifest.xml is correct

---

## 🔍 Current API Key:
```
AIzaSyBpD1p4hQ3su-aayuiQ226ZDXQRqK1cIok
```

**Location in project:**
```
android/app/src/main/AndroidManifest.xml (line 46)
```

---

## ⚠️ Common Issues:

### Issue 1: "This API project is not authorized to use this API"
**Solution:** Enable "Maps SDK for Android" in API Library

### Issue 2: "API keys with referer restrictions cannot be used"
**Solution:** Use "Android apps" restriction instead of "HTTP referrers"

### Issue 3: "INVALID_ARGUMENT"
**Solution:** 
1. Enable billing
2. Remove all restrictions (testing)
3. Wait 5 minutes
4. Clean rebuild

### Issue 4: Gray screen with "For development purposes only"
**Solution:** Billing not enabled - add payment method

---

## ✅ Expected Result:

After fixing, you should see:
- ✅ Map loads properly
- ✅ No gray screen
- ✅ No "For development purposes only" watermark
- ✅ Current location marker shows
- ✅ Console log: "Google Maps loaded successfully"

---

## 📱 Quick Test:

1. Go to: https://console.cloud.google.com/google/maps-apis/credentials
2. Remove ALL restrictions
3. Enable billing
4. Wait 5 minutes
5. `flutter clean && flutter run`

If map still doesn't work, create a NEW API key and replace it!
