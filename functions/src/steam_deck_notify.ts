import * as functions from "firebase-functions";
import * as https from "https";
import * as admin from "firebase-admin";
import {logger} from "firebase-functions";

const sixtyfourgbpos = 0;
const twofivesixgbpos = 1;

/**
 * Steam deck notify.
 */
export const notifyInStock = functions.pubsub
    .schedule("every 5 minutes")
    .onRun((_) => {
      const url =
      "https://store.steampowered.com/reservation/ajaxgetdefaultstate?rgReservationPackageIDs=[595603,595604]&rgDepositPackageIDs=[595598,595601]&cc=GB&l=english";

      https
          .get(url, (response) => {
            let data = "";
            response.on("data", (chunk) => {
              data += chunk;
            });

            response.on("end", async () => {
              const inStockDecks = [];
              if (!isOutOfStock(data, sixtyfourgbpos)) {
                // Send notification to topic, using the users userId.
                inStockDecks.push("64GB");
              }
              if (!isOutOfStock(data, twofivesixgbpos)) {
                // Send notification to topic, using the users userId.
                inStockDecks.push("256GB");
              }
              await sendNotificationToUsers(inStockDecks.join(" and "));
            });
          })
          .on("error", (err) => {
            logger.error("Error sending request:", err);
          });

      return null;
    });

/**
 * Send notification to users.
 * @param {string} name name to put in message
 */
async function sendNotificationToUsers(name: string) {
  await sendNotification("pe52gYt05icTcXDx2BAeRFwStNx1", name);
  await sendNotification("jteYcgJebzfaZqRUUYYUXJwXCj23", name);
}

/**
 * Send notification.
 * @param {string} topic topic name
 * @param {string} name name to put in message
 */
async function sendNotification(topic: string, name: string) {
  const payload = {
    notification: {
      title: "STEAM DECK",
      body: `Unless this is a mistake, ${name} steam deck in stock`,
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
 * @param {number} pos position of relevant item in array
 * @return {boolean} is in stock
 */
function isOutOfStock(data: string, pos: number): boolean {
  const jsonObject = JSON.parse(data);

  const info = jsonObject["rgReservationPackageInfo"][pos];

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
