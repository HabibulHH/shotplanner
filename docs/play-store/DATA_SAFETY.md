# ShotKit Data safety worksheet

This is a submission aid, not an automatic legal determination. Re-check the final uploaded AAB and every SDK before answering in Play Console.

## Current implementation audit

- Projects, scenes, shots, notes, completion state, settings, and imported reference images are stored locally.
- PDF generation is local; transfer happens only after the user invokes Android sharing.
- No developer backend, account system, analytics SDK, ads SDK, crash SDK, or cloud sync is present.
- Lifetime unlock (from the release after 1.1.0): the `in_app_purchase` plugin uses Google Play Billing. Google Play takes the payment; the app only sees the purchase record on the device (to acknowledge it and remember the unlock) and sends nothing to a developer server. The trial start date and unlock flag are stored locally.
- Declared permissions in the release APK: `INTERNET`, `ACCESS_NETWORK_STATE`, `com.android.vending.BILLING` (from the billing library), and Android's generated dynamic-receiver permission (from the Flutter engine/plugins).
- No broad photo/media permission is declared.
- In-app review (1.1+): the `in_app_review` plugin uses Google Play's In-App Review API. Google Play shows and handles the review card; ShotKit sends no data of its own. The plugin pulls in `url_launcher` transitively (no extra permissions).

## Draft Play Console answers

- Does the app collect or share required user data through a developer-operated service? **No**, based on the current code and the on-device-only content model.
- Is all user data encrypted in transit? **Not applicable to developer-operated collection.**
- Does the app provide account creation? **No.**
- Can users request account deletion? **Not applicable; there is no account.** Users can delete projects/scenes/shots in-app and can clear app data or uninstall.
- Data sharing for user-initiated PDF export: treat as user-initiated transfer; ShotKit does not select or operate the recipient.

## Mandatory verification before submission

- If analytics, crash reporting, cloud backup, login, support upload, or in-app purchases are later added, update this worksheet, the Play declaration, and the privacy policy before release.
- Before submitting 1.1, check Google's SDK data-disclosure guidance for the Play In-App Review library and confirm the merged release manifest adds no new permissions.
- Lifetime unlock: check Google's current Data safety guidance for Google Play Billing. Purchase data never leaves the device through a developer service, so the expected answer stays **no data collected**, but confirm before submitting.
- Play requires a completed Data safety form and public privacy policy even when the answer is that no data is collected.

