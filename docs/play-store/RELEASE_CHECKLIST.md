# ShotKit — Google Play release checklist

Last reviewed: 18 July 2026

## Already prepared in the repository

- Android application ID: `com.appmachine.shotkit`
- App name: `ShotKit`
- Version: `1.0.0` (`versionCode 1`)
- Minimum Android: API 24
- Target Android: API 36
- Android App Bundle release task configured
- Separate upload-key signing; debug signing is blocked for release builds
- Adaptive, round, legacy, and Android 12 splash icons
- Play Store icon: `assets/play-store/app-icon-512.png`
- Feature graphic: `assets/play-store/feature-graphic-1024x500.png`
- Store copy, privacy draft, data-safety worksheet, and tester guide
- Permission audit: Internet, Network State, and Android's generated receiver permission only
- No broad storage, photos, camera, microphone, contacts, or location permission

## Decisions required before the first Play upload

- [ ] Confirm `com.appmachine.shotkit` is the permanent package ID. It cannot be changed for the same Play listing after the first artifact is uploaded.
- [ ] Replace every bracketed placeholder in `PRIVACY_POLICY.md`, especially legal developer name, contact email, and public privacy-policy URL.
- [ ] Back up `android/keystore/shotkit-upload.jks` and `android/key.properties` in a secure password manager or encrypted vault. Neither file is committed to Git.
- [ ] Confirm whether the Play developer account is Personal or Organization and complete current developer verification.

## Play Console setup

1. Create the app in Play Console with default language `English (United States)`, app type **App**, and pricing **Free**. (The download stays free; the lifetime unlock is an in-app product — see below.)
2. Enroll in **Play App Signing** and use the generated ShotKit key as the upload key.
3. Complete the Main store listing using `STORE_LISTING.md` and the assets in `assets/play-store/`.
4. Host the final privacy policy on a public HTTPS URL and enter that URL in App content and the store listing.
5. Complete App content:
   - Ads: **No**
   - App access: **All functionality is available without login**
   - Target audience: professional/general filmmaking users; do not select child-directed groups unless the product strategy changes
   - Content rating: complete IARC accurately; the current app itself contains no violent, sexual, gambling, or user-generated content
   - Data safety: use `DATA_SAFETY.md`, then re-check it against the exact uploaded bundle
6. Add testers, upload the signed AAB to Internal testing, and verify install, reinstall, and offline flows.
8. Add at least two real phone screenshots. Capture the project slate, guided shot builder, visual preview, on-set mode, and PDF export. Do not use mock UI that differs from the shipped app.
9. Run a pre-launch report and fix crashes, ANRs, accessibility warnings, and device-compatibility issues.
10. If this is a Personal developer account created after 13 November 2023, run a closed test with at least 12 continuously opted-in testers for 14 days before applying for production access.
11. Upload production release notes, select countries/regions, review warnings, and submit for review.

## Lifetime unlock (one-time in-app product)

The app gives new installs a 10-day trial, then goes read-only until the user buys the
`shotkit_lifetime` one-time product. Installs from 1.0/1.1 are early supporters and stay free.

1. **Payments profile:** Play Console → Settings → Payments profile. Create a merchant account
   (Bangladesh is supported; payouts are in USD to your bank account). Add tax info if asked.
2. **Upload a build first:** Play only lets you create in-app products after a bundle with the
   `com.android.vending.BILLING` permission is uploaded. Upload the new AAB to **Internal testing**.
3. **Create the product:** Monetize with Play → Products → In-app products (one-time products) →
   Create. Product ID **`shotkit_lifetime`** (must match `UnlockService.productId`; it can never be
   reused or renamed). Name `ShotKit Lifetime`, price **USD 2.99**, let Play set local prices, then
   **Activate**.
4. **Test purchases:** Settings → License testing → add your Gmail and testers' Gmails. Install the
   app from the Internal testing link (not `flutter run`), buy with the test card, then check:
   unlocks at once, survives reinstall (Restore purchase), and "Payment pending" for the slow test card.
5. **Test the trial:** a fresh install shows "Free trial · 10 days left"; an update over 1.1 shows
   "Early supporter" in Kit.
6. Update the listing text (see `STORE_LISTING.md`), the privacy policy page (`docs/index.html`,
   push so GitHub Pages updates), and Data safety, then promote the release to Production.

## Every future release

- Increase the build number in `pubspec.yaml` (`1.0.1+2`, for example).
- Re-run analyzer and tests.
- Build a signed AAB: `flutter build appbundle --release`.
- Inspect the bundle in Play Console and run the pre-launch report.
- Review Data safety and privacy copy whenever dependencies or network behavior change.

## Current-policy references

- Target API requirements: https://support.google.com/googleplay/android-developer/answer/11926878
- New Personal-account testing: https://support.google.com/googleplay/android-developer/answer/14151465
- Upload and Play App Signing: https://developer.android.com/studio/publish/upload-bundle
- Store listing fields: https://support.google.com/googleplay/android-developer/answer/9859152
- Data safety: https://support.google.com/googleplay/android-developer/answer/10787469

