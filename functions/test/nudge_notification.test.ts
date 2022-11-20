"use strict";

import {assert} from "chai";
import * as sinon from "sinon";
import * as admin from "firebase-admin";
import {
  config as firebaseConfig,
  HttpsFunction,
  Runnable,
} from "firebase-functions";
import * as config from "../../assets/configs/notification_configs.json";

import {
  MessagingPayload,
  MessagingOptions,
  MessagingTopicResponse,
} from "firebase-admin/lib/messaging/messaging-api";

import * as firebaseFunctionsTest from "firebase-functions-test";
import {WrappedFunction} from "firebase-functions-test/lib/v1";
import {HttpsFunction} from "firebase-functions/v2/https";
const tester = firebaseFunctionsTest();

const userId = "1";
const changeContext = {params: {userId: userId}};

const requestTimestampFieldName = config.columnRequested;
const completeTimestampFieldName = config.columnCompleted;
const minimumMillisecondsBetweenNudges =
  config.minimumMillisecondsBetweenNudges;

describe("Cloud Functions", () => {
  let myFunctions: {sendNudgeNotification: Record<string, unknown>};
  let adminInitStub: sinon.SinonStub<
    [
      options?: admin.AppOptions | undefined,
      name?: string | undefined
    ],
    admin.app.App
  >;
  let messagingTopicStub: sinon.SinonStub<
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
    // Here we stub admin.initializeApp
    // to be a dummy function that doesn't do unknownthing.
    tester.firestore.exampleDocumentSnapshot();
    adminInitStub = sinon.stub(admin, "initializeApp");
    // Now we can require index.js and
    // save the exports inside a namespace called myFunctions.
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
      const {wrapped, snapshotChange, updateStub} =
        setUpDocumentUpdate(myFunctions, {}, {});

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

      const {wrapped, snapshotChange, updateStub} =
        setUpDocumentUpdate(myFunctions, beforeData, beforeData);

      return await assertNotificationNotSent(
          wrapped,
          snapshotChange,
          messagingTopicStub,
          updateStub
      );
    });

    it("doesn't send notification if document is deleted", async () => {
      const {wrapped, snapshotChange, updateStub} =
        setUpDocumentUpdate(
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

    it(
        "doesn't send notification if " +
        "after requested timestamp is NaN",
        async () => {
          const {wrapped, snapshotChange, updateStub} =
          setUpDocumentUpdate(
              myFunctions,
              {},
              {[requestTimestampFieldName]: "not a number"}
          );

          return await assertNotificationNotSent(
              wrapped,
              snapshotChange,
              messagingTopicStub,
              updateStub
          );
        }
    );

    it(
        "doesn't send notification if " +
        "after requested timestamp is empty",
        async () => {
          const {wrapped, snapshotChange, updateStub} =
          setUpDocumentUpdate(
              myFunctions,
              {},
              {[requestTimestampFieldName]: ""}
          );

          return await assertNotificationNotSent(
              wrapped,
              snapshotChange,
              messagingTopicStub,
              updateStub
          );
        }
    );

    it(
        "doesn't send notification if " +
        "after completed timestamp is NaN",
        async () => {
          const {wrapped, snapshotChange, updateStub} =
          setUpDocumentUpdate(
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
        }
    );

    it(
        "doesn't send notification if " +
        "after completed timestamp is empty",
        async () => {
          const {wrapped, snapshotChange, updateStub} =
          setUpDocumentUpdate(
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
        }
    );

    it(
        "doesn't send notification if " +
        "difference between requested and completed " +
        "timestamp < minimumMillisecondsBetweenNudges",
        async () => {
          const {wrapped, snapshotChange, updateStub} =
          setUpDocumentUpdate(
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
        }
    );

    it("sends notification if after completed timestamp is null", async () => {
      const {wrapped, snapshotChange, updateStub} =
        setUpDocumentUpdate(
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

    it(
        "sends notification if " +
        "difference between requested and completed " +
        "timestamp == minimumMillisecondsBetweenNudges",
        async () => {
          const {wrapped, snapshotChange, updateStub} =
          setUpDocumentUpdate(
              myFunctions,
              {},
              {
                [completeTimestampFieldName]: "0",
                [requestTimestampFieldName]:
                minimumMillisecondsBetweenNudges.toString(),
              }
          );

          return await assertNotificationSent(
              wrapped,
              snapshotChange,
              messagingTopicStub,
              updateStub
          );
        }
    );

    it(
        "sends notification if " +
        "difference between requested and completed " +
        "timestamp > minimumMillisecondsBetweenNudges",
        async () => {
          const {wrapped, snapshotChange, updateStub} =
          setUpDocumentUpdate(
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
        }
    );

    it("sends notification to correct topic with correct payload", async () => {
      const {wrapped, snapshotChange, updateStub} =
        setUpDocumentUpdate(
            myFunctions,
            {},
            {
              [completeTimestampFieldName]: "0",
              [requestTimestampFieldName]:
              minimumMillisecondsBetweenNudges.toString(),
            }
        );

      const expectedPayload = {
        notification: {
          title: "Your partner wants you to update!",
          body: "Your partner sent you a nudge to update your LoveHue bars.",
        },
      };

      assert.equal(
          await wrapped(snapshotChange, changeContext),
          true
      );
      assert.equal(
          messagingTopicStub.calledOnceWithExactly(
              userId,
              expectedPayload
          ),
          true
      );
      return assert.equal(updateStub.calledOnce, true);
    });

    it(
        "sends notification and " +
        "updates completed timestamp after sending",
        async () => {
          const requestedTimestamp = `${minimumMillisecondsBetweenNudges}`;
          const {wrapped, snapshotChange, updateStub} =
          setUpDocumentUpdate(
              myFunctions,
              {},
              {
                [completeTimestampFieldName]: "0",
                [requestTimestampFieldName]: requestedTimestamp,
              }
          );

          assert.equal(
              await wrapped(snapshotChange, changeContext),
              true
          );
          assert.equal(messagingTopicStub.calledOnce, true);

          return assert.equal(
              updateStub.calledOnceWithExactly({
                [completeTimestampFieldName]: requestedTimestamp,
              }),
              true
          );
        }
    );
  });
});

/**
 * It creates a Firestore document snapshot,
 * wraps the function, and returns the wrapped function, the
 * snapshot, and a stub for the Firestore update function
 * @param {object} myFunctions:
 * - function to be wrapped
 * @param {object} beforeData:
 * - The data that was in the document before the update.
 * @param {object} afterData:
 * - The data that the document will have after the update.
 * @return {unknown}
An object with the following properties:
 * - wrapped A wrapped function that can be called with a context object.
 * - snapshotChange: A snapshot change object
 *                  that can be passed to the wrapped function.
 * - updateStub: A stub that can be used to verify that the
 *              wrapped function called the update method
 *              on the snapshot.
 */
function setUpDocumentUpdate(
    myFunctions: {
    sendNudgeNotification: HttpsFunction & Runnable<unknown>;
  },
    beforeData: {[x: string]: string},
    afterData: {[x: string]: string | null}
): {
  wrapped: WrappedFunction<
    unknown,
    HttpsFunction & Runnable<unknown>
  >;
  snapshotChange: unknown;
  updateStub: sinon.SinonStub<unknown[], unknown>;
} {
  const snapshotBefore = tester.firestore.makeDocumentSnapshot(
      beforeData,
      "path"
  );
  const snapshotAfter = tester.firestore.makeDocumentSnapshot(
      afterData,
      "path"
  );
  const snapshotChange = tester.makeChange(
      snapshotBefore,
      snapshotAfter
  );
  const updateStub = sinon.stub();
  const wrapped = tester.wrap(myFunctions.sendNudgeNotification);

  snapshotChange.after.ref.update = updateStub;
  updateStub.withArgs(snapshotChange.after.data()).returns(true);
  return {wrapped, snapshotChange, updateStub};
}

/**
 * It asserts that a notification is not sent when the function is called
 * @param {WrappedFunction} wrapped - The wrapped function that we're testing.
 * @param {unknown} snapshotChange - The data that was passed to the function.
 * @param {sinon.SinonStub} messagingTopicStub
 * - a stub for the messaging.topic() function
 * @param {sinon.SinonStub} updateStub
 * - A stub for the Firestore update function.
 * @return {boolean} a boolean value.
 */
async function assertNotificationNotSent(
    wrapped: WrappedFunction<unknown, unknown & Runnable<unknown>>,
    snapshotChange: unknown,
    messagingTopicStub: sinon.SinonStub<
    [
      topic: string,
      payload: MessagingPayload,
      options?: MessagingOptions | undefined
    ],
    Promise<MessagingTopicResponse>
  >,
    updateStub: sinon.SinonStub<unknown[], unknown>
) {
  assert.equal(await wrapped(snapshotChange, changeContext), false);
  assert.equal(messagingTopicStub.called, false);
  return assert.equal(updateStub.calledOnce, false);
}

/**
 * It asserts that a notification is sent when the function is called
 * @param {WrappedFunction} wrapped - The wrapped function that we're testing.
 * @param {unknown} snapshotChange - The data that was passed to the function.
 * @param {sinon.SinonStub} messagingTopicStub
 * - a stub for the messaging.topic() function
 * @param {sinon.SinonStub} updateStub
 * - A stub for the Firestore update function.
 * @return {boolean} a boolean value.
 */
async function assertNotificationSent(
    wrapped: WrappedFunction<unknown, unknown & Runnable<unknown>>,
    snapshotChange: unknown,
    messagingTopicStub: sinon.SinonStub<
    [
      topic: string,
      payload: MessagingPayload,
      options?: MessagingOptions | undefined
    ],
    Promise<MessagingTopicResponse>
  >,
    updateStub: sinon.SinonStub<unknown[], unknown>
) {
  assert.equal(await wrapped(snapshotChange, changeContext), true);
  assert.equal(messagingTopicStub.called, true);
  return assert.equal(updateStub.calledOnce, true);
}
