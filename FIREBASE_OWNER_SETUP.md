# Firebase owner setup

The app uses anonymous Firebase Authentication for the current prototype. To make only the owner able to add room or group members:

1. Run the app on Android or Chrome.
2. Open the contacts screen and copy the displayed Firebase UID.
3. In Firestore, create this document:

`config/app`

with this field:

```text
ownerUid: YOUR_FIREBASE_UID
```

4. Publish `firestore.rules`.

The rules then allow member creation only when the signed-in UID matches `config/app.ownerUid`. They also allow sending in `secret_group` and `shadow_ops` only for the owner or a document in the matching `rooms/{roomId}/members/{uid}` path.

Anonymous UIDs are installation-specific. For a permanent owner account, enable Email/Password or another permanent provider and use that account for the owner instead of relying on an anonymous UID.

## Enable Gemini on the free plan

Shadow Chat uses Firebase AI Logic with the Gemini Developer API directly from
the Flutter app. This does not use a Cloud Function or require a Gemini API key
in the app.

1. In the Firebase console, open **AI Logic** and set up the **Gemini Developer
   API** for this Firebase project.
2. Make sure the app is connected to the same Firebase project and is using the
   current Firebase configuration.
3. Run the app and try Shadow Chat. Gemini Developer API has a free usage tier;
   check the current quotas and model availability in the Firebase console.

For production, configure Firebase App Check to help protect AI requests from
abuse. Firestore Rules control access to Firestore data; they do not authorize
Gemini requests.

The existing `notifyNewMessage` function is separate from Gemini and still
requires Cloud Functions deployment. Cloud Functions deployment requires the
Firebase project to use the Blaze plan.
