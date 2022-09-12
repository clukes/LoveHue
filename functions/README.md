# Cloud Functions

Functions for Google cloud functions.

## nudge_notification
- Listens to a write to a document in firestore with path "nudgeNotifications/{userId}/requested".
- Checks timestamp of last nudge notification to see if request is valid.
- Sends a notification to the requesting users partner.
- Saves completed timestamp to "nudgeNotifications/{userId}/completed".