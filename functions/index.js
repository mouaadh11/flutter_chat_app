/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const {initializeApp} = require("firebase-admin/app");
const {getFirestore} = require("firebase-admin/firestore");
const {getMessaging} = require("firebase-admin/messaging");
const {setGlobalOptions} = require("firebase-functions");
const {onDocumentCreated} = require("firebase-functions/v2/firestore");
const logger = require("firebase-functions/logger");

// For cost control, you can set the maximum number of containers that can be
// running at the same time. This helps mitigate the impact of unexpected
// traffic spikes by instead downgrading performance. This limit is a
// per-function limit. You can override the limit for each function using the
// `maxInstances` option in the function's options, e.g.
// `onRequest({ maxInstances: 5 }, (req, res) => { ... })`.
// NOTE: setGlobalOptions does not apply to functions using the v1 API. V1
// functions should each use functions.runWith({ maxInstances: 10 }) instead.
// In the v1 API, each function can only serve one request per container, so
// this will be the maximum concurrent request count.
setGlobalOptions({maxInstances: 10});

initializeApp();

exports.sendChatNotification = onDocumentCreated(
    "chats/{chatId}/messages/{messageId}",
    async (event) => {
      const message = event.data && event.data.data();
      if (!message) {
        logger.warn("Missing message data", event.params);
        return;
      }

      const text = message.text;
      const senderId = message.senderId;
      const receiverId = message.receiverId;
      const senderEmail = message.senderEmail;

      if (!text || !senderId || !receiverId || senderId === receiverId) {
        logger.warn("Ignoring invalid chat message", {
          chatId: event.params.chatId,
          messageId: event.params.messageId,
        });
        return;
      }

      const db = getFirestore();
      const receiverTokens = await db
          .collection("users")
          .doc(receiverId)
          .collection("fcmTokens")
          .get();

      if (receiverTokens.empty) {
        logger.info("Receiver has no FCM tokens", {receiverId});
        return;
      }

      let title = senderEmail || "New Message";
      const senderDoc = await db.collection("users").doc(senderId).get();
      if (senderDoc.exists) {
        const sender = senderDoc.data();
        title = sender.username || sender.email || title;
      }

      const tokens = receiverTokens.docs.map((doc) => doc.id);
      const response = await getMessaging().sendEachForMulticast({
        tokens,
        notification: {
          title,
          body: text,
        },
        android: {
          priority: "high",
          notification: {
            channelId: "messages",
          },
        },
        data: {
          chatId: event.params.chatId,
          messageId: event.params.messageId,
          senderId,
          receiverId,
        },
      });

      const invalidCodes = new Set([
        "messaging/invalid-registration-token",
        "messaging/registration-token-not-registered",
      ]);

      const deleteInvalidTokens = response.responses
          .map((sendResponse, index) => {
            if (sendResponse.success) return null;

            const code = sendResponse.error && sendResponse.error.code;
            if (!invalidCodes.has(code)) {
              logger.warn("Failed to send chat notification", {
                code,
                token: tokens[index],
              });
              return null;
            }

            return receiverTokens.docs[index].ref.delete();
          })
          .filter(Boolean);

      await Promise.all(deleteInvalidTokens);

      logger.info("Sent chat notification", {
        chatId: event.params.chatId,
        messageId: event.params.messageId,
        successCount: response.successCount,
        failureCount: response.failureCount,
      });
    },
);

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
