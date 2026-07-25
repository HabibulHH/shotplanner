# ShotKit Data safety worksheet

This is a submission aid, not an automatic legal determination. Re-check the final uploaded AAB and every SDK before answering in Play Console.

## Current implementation audit

- Projects, scenes, shots, notes, completion state, settings, and imported reference images are stored locally.
- PDF generation is local; transfer happens only after the user invokes Android sharing.
- No developer backend, account system, analytics SDK, ads SDK, crash SDK, or cloud sync is present.
- The app is completely free: no in-app purchases and no Google Play Billing dependency.
- Declared permissions in the release APK: `INTERNET`, `ACCESS_NETWORK_STATE`, and Android's generated dynamic-receiver permission (from the Flutter engine/plugins).
- No broad photo/media permission is declared.

## Draft Play Console answers

- Does the app collect or share required user data through a developer-operated service? **No**, based on the current code and the on-device-only content model.
- Is all user data encrypted in transit? **Not applicable to developer-operated collection.**
- Does the app provide account creation? **No.**
- Can users request account deletion? **Not applicable; there is no account.** Users can delete projects/scenes/shots in-app and can clear app data or uninstall.
- Data sharing for user-initiated PDF export: treat as user-initiated transfer; ShotKit does not select or operate the recipient.

## Mandatory verification before submission

- If analytics, crash reporting, cloud backup, login, support upload, or in-app purchases are later added, update this worksheet, the Play declaration, and the privacy policy before release.
- Play requires a completed Data safety form and public privacy policy even when the answer is that no data is collected.

