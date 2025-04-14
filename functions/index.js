const { onRequest } = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");
const { Firestore } = require("@google-cloud/firestore");
const cors = require("cors");
const grpc = require("@grpc/grpc-js");

delete process.env.FIRESTORE_EMULATOR_HOST; // 👈 에뮬레이터 접근 차단

const corsHandler = cors({ origin: true });

const db = new Firestore({
  projectId: 'gilajabi-b182c',
  servicePath: 'asia-northeast3-firestore.googleapis.com',
  port: 443,
  sslCreds: grpc.credentials.createSsl(),
});

exports.saveUserV2 = onRequest(
  { region: "asia-northeast3" },
  (req, res) => {
    corsHandler(req, res, async () => {
      logger.log("🔥 들어왔어!!!!!");

      const { nickname, profileImageUrl } = req.body;
      if (!nickname) {
        logger.error("❌ nickname 없음");
        return res.status(400).send({ error: "Missing nickname" });
      }

      try {
        const result = await db.collection("users").add({
          nickname,
          profileImageUrl,
          createdAt: Firestore.Timestamp.now(),
        });

        logger.log("✅ 저장 완료:", result.id);
        res.status(200).send({ message: "User saved" });
      } catch (err) {
        logger.error("❌ Firestore 저장 실패:", err.message);
        logger.error("🔥 Full error:", JSON.stringify(err, null, 2));
        res.status(500).send({ error: "Failed to save user" });
      }
    });
  }
);
