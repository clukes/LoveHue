"use strict";

import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { DataSnapshot } from "@firebase/database-types";
admin.initializeApp();

const baseDocPath = "/nudge/{userId}";
const requestedDocPath = baseDocPath + "/requested";
const completedDocPath = baseDocPath + "/completed";
const minimumMillisecondsBetweenNudges = 10000;

/**
 * Triggers when a nudge notification request is stored.
 *
 * User saves a requested timestamp to `/followers/{followedUid}/{followerUid}`.
 * Users save their device notification tokens to `/users/{followedUid}/notificationTokens/{notificationToken}`.
 */
exports.sendNudgeNotification = functions.firestore
	.document(requestedDocPath)
	.onWrite(async (change, context) => {
		const userId: string = context.params.userId;

		/* If the document is deleted, we exit the function. */
		if (!change.after.exists) {
			return functions.logger.debug(
				"User",
				userId,
				"has had requested doc deleted, at:",
				requestedDocPath
			);
		}

		functions.logger.log("User request nudge notification:", userId);

		const requestedTimestamp = getTimestampFromDoc(
			change.after,
			"requestedTimestamp",
			userId
		);
		if (requestedTimestamp == null) return;

		const lastCompletedTimestampDocRef = admin
			.firestore()
			.doc(completedDocPath);

		const lastCompletedTimestampDoc =
			await lastCompletedTimestampDocRef.get();

		if (lastCompletedTimestampDoc.exists) {
			const validRequest = !isRequestValid(
				lastCompletedTimestampDoc,
				userId,
				requestedTimestamp
			);
			if (!validRequest) return;
		} else {
			functions.logger.debug(
				"LastCompletedTimestampDoc doesn't exist for user:",
				userId
			);
		}

		// Send notification

		// Notification details.
		const payload = {
			notification: {
				title: "You have a new follower!",
				body: `${follower.displayName} is now following you.`,
				icon: follower.photoURL,
			},
		};

		const response = await admin.messaging().sendToTopic(topic, payload);
		functions.logger.log(
			"Notification request by user:",
			userId,
			"sent to topic:",
			topic,
			"with payload:",
			payload
		);

		// Write completed timestamp
		await lastCompletedTimestampDocRef.set({ count: 1 });
		return functions.logger.debug(
			"Notification request by user:",
			userId,
			"sent to topic:",
			topic,
			"with payload:",
			payload
		);
	});

function getTimestampFromDoc(
	doc: admin.firestore.DocumentSnapshot<admin.firestore.DocumentData>,
	docName: string,
	userId: string
) {
	const timestamp = doc.updateTime ?? doc.createTime;
	if (timestamp === undefined) {
		functions.logger.error(
			docName,
			"exists, but timestamp got undefined for user:",
			userId
		);
		return;
	}

	return timestamp;
}

function isRequestValid(
	lastCompletedTimestampDoc: admin.firestore.DocumentSnapshot<admin.firestore.DocumentData>,
	userId: string,
	requestedTimestamp: admin.firestore.Timestamp
) {
	const lastCompletedTimestamp = getTimestampFromDoc(
		lastCompletedTimestampDoc,
		"lastCompletedTimestamp",
		userId
	);
	if (lastCompletedTimestamp == null) return false;

	const millisecondsSinceNudge =
		requestedTimestamp.toMillis() - lastCompletedTimestamp.toMillis();
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
