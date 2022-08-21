"use strict";

import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import * as config from "../../configs/notification_configs.json";
admin.initializeApp();

const notificationDocPath = config.notificationCollectionPath + "/{userId}";
const requestTimestampFieldName = config.columnRequested;
const completeTimestampFieldName = config.columnCompleted;
const minimumMillisecondsBetweenNudges =
    config.minimumMillisecondsBetweenNudges;

/**
 * Triggers when a nudge notification request is stored.
 *
 * User saves a requested timestamp to `/nudge/{userId}`.
 */
export const sendNudgeNotification = functions.firestore
    .document(notificationDocPath)
    .onWrite(async (change, context) => {
        const userId: string = context.params.userId;

        // If the request timestamp hasn't been updated, we exit.
        if (
            change.before.get(requestTimestampFieldName) ==
            change.after.get(requestTimestampFieldName)
        ) {
            return functions.logger.debug(
                "User",
                userId,
                "had no change of request timestamp in notification doc, at:",
                notificationDocPath
            );
        }

        // If the document is deleted, we exit the function.
        if (!change.after.exists) {
            return functions.logger.debug(
                "User",
                userId,
                "has had notification doc deleted, at:",
                notificationDocPath
            );
        }

        functions.logger.log("User request nudge notification:", userId);

        // Check if it's been long enough since last request.
        const requestedTimestamp = getTimestampFromDoc(
            change.after,
            requestTimestampFieldName
        );
        if (requestedTimestamp == null) return;

        if (!isRequestValid(change.after, userId, requestedTimestamp)) return;

        // Set notification details.
        const payload = {
            notification: {
                title: "Your partner wants you to update!",
                body: "Your partner sent you a nudge to update your LoveHue bars.",
            },
        };

        // Send notification to topic, using the users userId.
        const topic = userId;
        const response = await admin.messaging().sendToTopic(topic, payload);
        functions.logger.log(
            "Notification request by user:",
            userId,
            "sent to topic:",
            topic,
            "with response:",
            response,
            "and with payload:",
            payload
        );

        // Update completed timestamp
        await change.after.ref.update({
            completeTimestampFieldName: requestedTimestamp,
        });

        return functions.logger.debug(
            "Completed timestamp updated for:",
            userId,
            "with timestamp:",
            requestedTimestamp
        );
    });

/**
 * It takes a Firestore document and a field name,
 * and returns the timestamp in that field
 * @param {admin.firestore.DocumentSnapshot} doc
 *  - The document that we're getting the timestamp from.
 * @param {string} fieldName
 *  - The name of the field in the document that contains the timestamp.
 * @return {number | undefined} A timestamp or undefined if couldn't parse.
 */
function getTimestampFromDoc(
    doc: admin.firestore.DocumentSnapshot,
    fieldName: string
): number | undefined {
    const timestampString = doc.get(fieldName);
    const timestamp: number = parseInt(timestampString);
    if (isNaN(timestamp) || timestamp == undefined) {
        functions.logger.error(
            fieldName,
            "for doc id:",
            doc.id,
            "gave an invalid number:",
            timestampString
        );
        return;
    }

    return timestamp;
}

/**
 * If the user has completed a nudge in the past, check that it's been at least
 * `minimumMillisecondsBetweenNudges` milliseconds since the last nudge
 * @param {admin.firestore.DocumentSnapshot} doc
 *  - this is the document that we're checking to see if
 * @param {string} userId - The user ID of the user who is requesting a nudge.
 * @param {number} requestedTimestamp
 *  - The timestamp of the request to send a nudge.
 * @return {boolean}
 *  True if there is no last completed timestamp
 *  or it has been enough milliseconds.
 */
function isRequestValid(
    doc: admin.firestore.DocumentSnapshot,
    userId: string,
    requestedTimestamp: number
): boolean {
    if (doc.get(completeTimestampFieldName) == null) {
        functions.logger.debug("No completed timestamp user:", userId);
        return true;
    }

    const lastCompletedTimestamp = getTimestampFromDoc(
        doc,
        completeTimestampFieldName
    );
    if (lastCompletedTimestamp == null) return false;

    const millisecondsSinceNudge = requestedTimestamp - lastCompletedTimestamp;
    if (millisecondsSinceNudge < minimumMillisecondsBetweenNudges) {
        functions.logger.warn(
            "Hasn't been long enough since last nudge for user:",
            userId,
            "last timestamp was:",
            lastCompletedTimestamp,
            "requestedTimestamp was:",
            requestedTimestamp,
            "difference in milliseconds was:",
            millisecondsSinceNudge
        );
        return false;
    }

    functions.logger.debug(
        "Has been long enough since last nudge for user:",
        userId,
        "last timestamp was:",
        lastCompletedTimestamp,
        "requestedTimestamp was:",
        requestedTimestamp,
        "difference in milliseconds was:",
        millisecondsSinceNudge
    );

    return true;
}
