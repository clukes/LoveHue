import * as functions from "firebase-functions";
import * as https from "https";
import * as admin from "firebase-admin";
import {logger} from "firebase-functions";

/**
 * Steam deck notify.
 */
export const notifyInStock = functions.pubsub
    .schedule("every 5 minutes")
    .onRun((context) => {
      const url =
      "https://store.steampowered.com/reservation/ajaxgetdefaultstate?rgReservationPackageIDs=[595604]&rgDepositPackageIDs=[595601]&cc=GB&l=english";

      https
          .get(url, (response) => {
            let data = "";
            response.on("data", (chunk) => {
              data += chunk;
            });

            response.on("end", async () => {
              if (!isOutOfStock(data)) {
                // Send notification to topic, using the users userId.
                await sendNotification("pe52gYt05icTcXDx2BAeRFwStNx1");
                await sendNotification("jteYcgJebzfaZqRUUYYUXJwXCj23");
              }
            });
          })
          .on("error", (err) => {
            logger.error("Error sending request:", err);
          });

      return null;
    });

/**
 * Send notification.
 * @param {string} topic topic name
 */
async function sendNotification(topic: string) {
  const payload = {
    notification: {
      title: "STEAM DECK",
      body: "Unless this is a mistake, steam deck is in stock",
    },
  };

  const response = await admin
      .messaging()
      .sendToTopic(topic, payload);
  logger.log(
      "Notification sent to topic:",
      topic,
      "with response:",
      response,
      "and with payload:",
      payload
  );
}

/**
 * Check json says in stock.
 * @param {string} data json object
 * @return {boolean} is in stock
 */
function isOutOfStock(data: string): boolean {
  const jsonObject = JSON.parse(data);

  const info = jsonObject["rgReservationPackageInfo"][0];

  if (
    info["strLocalizedShippingMessage"] === "Out of Stock" ||
    info["bOutOfStock"] === true
  ) {
    logger.log("Out of stock");
    return true;
  } else {
    logger.log("In stock");
    return false;
  }
}
