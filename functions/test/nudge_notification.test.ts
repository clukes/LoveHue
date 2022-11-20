"use strict";

import { assert } from "chai";
import * as sinon from "sinon";
import * as admin from "firebase-admin";
import { config as firebaseConfig } from "firebase-functions";
import * as config from "../../assets/configs/notification_configs.json";

import {
    MessagingPayload,
    MessagingOptions,
    MessagingTopicResponse,
} from "firebase-admin/lib/messaging/messaging-api";

const tester = require("firebase-functions-test")();

const userId = "1";
const context = { params: { userId: userId } };

const requestTimestampFieldName = config.columnRequested;
const completeTimestampFieldName = config.columnCompleted;
const minimumMillisecondsBetweenNudges =
    config.minimumMillisecondsBetweenNudges;

describe("Cloud Functions", () => {
    let myFunctions: { sendNudgeNotification: any },
        adminInitStub: sinon.SinonStub<
            [options?: admin.AppOptions | undefined, name?: string | undefined],
            admin.app.App
        >,
        messagingTopicStub: sinon.SinonStub<
            [
                topic: string,
                payload: MessagingPayload,
                options?: MessagingOptions | undefined
            ],
            Promise<MessagingTopicResponse>
        >;

    admin.initializeApp(firebaseConfig().firebase);

    before(() => {
        // [START stubAdminInit]
        // If index.js calls admin.initializeApp at the top of the file,
        // we need to stub it out before requiring index.js. This is because the
        // functions will be executed as a part of the require process.
        // Here we stub admin.initializeApp to be a dummy function that doesn't do anything.
        tester.firestore.exampleDocumentSnapshot();
        adminInitStub = sinon.stub(admin, "initializeApp");
        // Now we can require index.js and save the exports inside a namespace called myFunctions.
        myFunctions = require("../src/index");
        // [END stubAdminInit]
    });

    after(() => {
        adminInitStub.restore();

        tester.cleanup();
    });

    beforeEach(() => {
        messagingTopicStub = sinon.stub(admin.messaging(), "sendToTopic");
    });

    afterEach(() => {
        messagingTopicStub.restore();
    });

    describe("sendNudgeNotification", () => {
        it("is invoked on document write", async () => {
            const { wrapped, snapshotChange, updateStub } = setUpDocumentUpdate(
                myFunctions,
                {},
                {}
            );

            return await assertNotificationNotSent(
                wrapped,
                snapshotChange,
                messagingTopicStub,
                updateStub
            );
        });

        it("doesn't send notification if no change in timestamp", async () => {
            const beforeData = {
                [requestTimestampFieldName]: "1",
            };

            const { wrapped, snapshotChange, updateStub } = setUpDocumentUpdate(
                myFunctions,
                beforeData,
                beforeData
            );

            return await assertNotificationNotSent(
                wrapped,
                snapshotChange,
                messagingTopicStub,
                updateStub
            );
        });

        it("doesn't send notification if document is deleted", async () => {
            const { wrapped, snapshotChange, updateStub } = setUpDocumentUpdate(
                myFunctions,
                {
                    [requestTimestampFieldName]: "1",
                },
                {}
            );

            return await assertNotificationNotSent(
                wrapped,
                snapshotChange,
                messagingTopicStub,
                updateStub
            );
        });

        it("doesn't send notification if after requested timestamp is NaN", async () => {
            const { wrapped, snapshotChange, updateStub } = setUpDocumentUpdate(
                myFunctions,
                {},
                { [requestTimestampFieldName]: "not a number" }
            );

            return await assertNotificationNotSent(
                wrapped,
                snapshotChange,
                messagingTopicStub,
                updateStub
            );
        });

        it("doesn't send notification if after requested timestamp is empty", async () => {
            const { wrapped, snapshotChange, updateStub } = setUpDocumentUpdate(
                myFunctions,
                {},
                { [requestTimestampFieldName]: "" }
            );

            return await assertNotificationNotSent(
                wrapped,
                snapshotChange,
                messagingTopicStub,
                updateStub
            );
        });

        it("doesn't send notification if after completed timestamp is NaN", async () => {
            const { wrapped, snapshotChange, updateStub } = setUpDocumentUpdate(
                myFunctions,
                {},
                {
                    [completeTimestampFieldName]: "not a number",
                    [requestTimestampFieldName]: "1",
                }
            );

            return await assertNotificationNotSent(
                wrapped,
                snapshotChange,
                messagingTopicStub,
                updateStub
            );
        });

        it("doesn't send notification if after completed timestamp is empty", async () => {
            const { wrapped, snapshotChange, updateStub } = setUpDocumentUpdate(
                myFunctions,
                {},
                {
                    [completeTimestampFieldName]: "",
                    [requestTimestampFieldName]: "1",
                }
            );

            return await assertNotificationNotSent(
                wrapped,
                snapshotChange,
                messagingTopicStub,
                updateStub
            );
        });

        it("doesn't send notification if difference between requested and completed timestamp < minimumMillisecondsBetweenNudges", async () => {
            const { wrapped, snapshotChange, updateStub } = setUpDocumentUpdate(
                myFunctions,
                {},
                {
                    [completeTimestampFieldName]: "1",
                    [requestTimestampFieldName]: "2",
                }
            );

            return await assertNotificationNotSent(
                wrapped,
                snapshotChange,
                messagingTopicStub,
                updateStub
            );
        });

        it("sends notification if after completed timestamp is null", async () => {
            const { wrapped, snapshotChange, updateStub } = setUpDocumentUpdate(
                myFunctions,
                {},
                {
                    [completeTimestampFieldName]: null,
                    [requestTimestampFieldName]: "1",
                }
            );

            return await assertNotificationSent(
                wrapped,
                snapshotChange,
                messagingTopicStub,
                updateStub
            );
        });

        it("sends notification if difference between requested and completed timestamp == minimumMillisecondsBetweenNudges", async () => {
            const { wrapped, snapshotChange, updateStub } = setUpDocumentUpdate(
                myFunctions,
                {},
                {
                    [completeTimestampFieldName]: `0`,
                    [requestTimestampFieldName]: `${minimumMillisecondsBetweenNudges}`,
                }
            );

            return await assertNotificationSent(
                wrapped,
                snapshotChange,
                messagingTopicStub,
                updateStub
            );
        });

        it("sends notification if difference between requested and completed timestamp > minimumMillisecondsBetweenNudges", async () => {
            const { wrapped, snapshotChange, updateStub } = setUpDocumentUpdate(
                myFunctions,
                {},
                {
                    [completeTimestampFieldName]: "0",
                    [requestTimestampFieldName]: `${
                        minimumMillisecondsBetweenNudges + 1
                    }`,
                }
            );

            return await assertNotificationSent(
                wrapped,
                snapshotChange,
                messagingTopicStub,
                updateStub
            );
        });

        it("sends notification to correct topic with correct payload", async () => {
            const { wrapped, snapshotChange, updateStub } = setUpDocumentUpdate(
                myFunctions,
                {},
                {
                    [completeTimestampFieldName]: "0",
                    [requestTimestampFieldName]: `${minimumMillisecondsBetweenNudges}`,
                }
            );

            const expectedPayload = {
                notification: {
                    title: "Your partner wants you to update!",
                    body: "Your partner sent you a nudge to update your LoveHue bars.",
                },
            };

            assert.equal(await wrapped(snapshotChange, context), true);
            assert.equal(
                messagingTopicStub.calledOnceWithExactly(
                    userId,
                    expectedPayload
                ),
                true
            );
            return assert.equal(updateStub.calledOnce, true);
        });

        it("sends notification and updates completed timestamp after sending", async () => {
            const requestedTimestamp = `${minimumMillisecondsBetweenNudges}`;
            const { wrapped, snapshotChange, updateStub } = setUpDocumentUpdate(
                myFunctions,
                {},
                {
                    [completeTimestampFieldName]: "0",
                    [requestTimestampFieldName]: requestedTimestamp,
                }
            );

            assert.equal(await wrapped(snapshotChange, context), true);
            assert.equal(messagingTopicStub.calledOnce, true);

            return assert.equal(
                updateStub.calledOnceWithExactly({
                    [completeTimestampFieldName]: requestedTimestamp,
                }),
                true
            );
        });
    });
});

function setUpDocumentUpdate(
    myFunctions: { sendNudgeNotification: any },
    beforeData: { [x: string]: string },
    afterData: { [x: string]: string | null }
) {
    const snapshotBefore = tester.firestore.makeDocumentSnapshot(beforeData);
    const snapshotAfter = tester.firestore.makeDocumentSnapshot(afterData);
    const snapshotChange = tester.makeChange(snapshotBefore, snapshotAfter);
    const updateStub = sinon.stub();
    const wrapped = tester.wrap(myFunctions.sendNudgeNotification);

    snapshotChange.after.ref.update = updateStub;
    updateStub.withArgs(snapshotChange.after.data()).returns(true);
    return { wrapped, snapshotChange, updateStub };
}

async function assertNotificationNotSent(
    wrapped: (arg0: any, arg1: { params: { userId: string } }) => any,
    snapshotChange: any,
    messagingTopicStub: sinon.SinonStub<
        [
            topic: string,
            payload: MessagingPayload,
            options?: MessagingOptions | undefined
        ],
        Promise<MessagingTopicResponse>
    >,
    updateStub: sinon.SinonStub<any[], any>
) {
    assert.equal(await wrapped(snapshotChange, context), false);
    assert.equal(messagingTopicStub.called, false);
    return assert.equal(updateStub.calledOnce, false);
}

async function assertNotificationSent(
    wrapped: (arg0: any, arg1: { params: { userId: string } }) => any,
    snapshotChange: any,
    messagingTopicStub: sinon.SinonStub<
        [
            topic: string,
            payload: MessagingPayload,
            options?: MessagingOptions | undefined
        ],
        Promise<MessagingTopicResponse>
    >,
    updateStub: sinon.SinonStub<any[], any>
) {
    assert.equal(await wrapped(snapshotChange, context), true);
    assert.equal(messagingTopicStub.called, true);
    return assert.equal(updateStub.calledOnce, true);
}
