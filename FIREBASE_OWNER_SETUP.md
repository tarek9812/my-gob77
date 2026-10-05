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
