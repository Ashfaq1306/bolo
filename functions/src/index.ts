import { createHash } from "node:crypto";

import Anthropic from "@anthropic-ai/sdk";
import { initializeApp } from "firebase-admin/app";
import { getFirestore } from "firebase-admin/firestore";
import { setGlobalOptions } from "firebase-functions";
import { HttpsError, onCall } from "firebase-functions/https";
import * as logger from "firebase-functions/logger";
import { defineSecret } from "firebase-functions/params";

import { callModel, MODEL } from "./parse/ai";
import { buildCalendar } from "./parse/calendar";
import { mockParse } from "./parse/mock";
import { MAX_TEXT_CHARS, ParseRequestSchema } from "./parse/schema";
import { sanitize, unknownResponse } from "./parse/validate";
import { consumeQuota } from "./quota";

initializeApp();

// Mumbai: closest region to Dhaka, same as Firestore. maxInstances caps cost.
setGlobalOptions({ region: "asia-south1", maxInstances: 10 });

/** Stored in Google Secret Manager: `firebase functions:secrets:set ANTHROPIC_API_KEY`. */
const anthropicKey = defineSecret("ANTHROPIC_API_KEY");

/**
 * Set to true before public launch, once App Check (Play Integrity) is set up
 * in the app (docs/06). Then requests from modified apps/scripts are rejected.
 */
const ENFORCE_APP_CHECK = false;

const hashUid = (uid: string) => createHash("sha256").update(uid).digest("hex").slice(0, 12);

/**
 * parseCommand: text → proposed structured command.
 * It ONLY proposes. It never writes user records; the app saves after the
 * user confirms (docs/04 ADR-4).
 */
export const parseCommand = onCall(
  {
    secrets: [anthropicKey],
    enforceAppCheck: ENFORCE_APP_CHECK,
    memory: "256MiB",
    timeoutSeconds: 20,
  },
  async (request) => {
    const uid = request.auth?.uid;
    if (!uid) throw new HttpsError("unauthenticated", "Sign in first.");

    const parsed = ParseRequestSchema.safeParse(request.data);
    if (!parsed.success) throw new HttpsError("invalid-argument", "Bad request.");
    const text = parsed.data.text.trim().replace(/\s+/g, " ");
    if (text.length === 0 || text.length > MAX_TEXT_CHARS) {
      throw new HttpsError("invalid-argument", `Text must be 1-${MAX_TEXT_CHARS} characters.`);
    }

    const now = new Date();
    const db = getFirestore();
    if (!(await consumeQuota(db, uid, now))) {
      throw new HttpsError("resource-exhausted", "Daily voice-command limit reached.");
    }

    const cal = buildCalendar(now);
    const started = Date.now();

    // Free local testing without an API key (emulator only).
    if (process.env.MOCK_AI === "true" && process.env.FUNCTIONS_EMULATOR === "true") {
      return sanitize(mockParse(text, cal), now);
    }

    try {
      const client = new Anthropic({ apiKey: anthropicKey.value(), maxRetries: 1, timeout: 15_000 });
      const result = await callModel(client, text, cal, parsed.data.locale);
      const response = result.output ? sanitize(result.output, now, text) : unknownResponse();

      // Log usage for cost tracking. NEVER log the user's text (docs/06).
      logger.info("parseCommand", {
        user: hashUid(uid),
        model: MODEL,
        intent: response.intent,
        stopReason: result.stopReason,
        inputTokens: result.inputTokens,
        outputTokens: result.outputTokens,
        cacheReadTokens: result.cacheReadTokens,
        latencyMs: Date.now() - started,
      });
      return response;
    } catch (err) {
      if (err instanceof Anthropic.RateLimitError) {
        logger.warn("AI rate limited", { user: hashUid(uid) });
        throw new HttpsError("unavailable", "Busy, please retry.");
      }
      if (err instanceof Anthropic.AuthenticationError) {
        logger.error("AI authentication failed: check ANTHROPIC_API_KEY secret");
        throw new HttpsError("internal", "Server configuration error.");
      }
      if (err instanceof Anthropic.APIConnectionError) {
        logger.warn("AI connection error", { user: hashUid(uid) });
        throw new HttpsError("unavailable", "AI service unreachable.");
      }
      if (err instanceof Anthropic.APIError) {
        logger.error("AI API error", { status: err.status, user: hashUid(uid) });
        throw new HttpsError("internal", "AI service error.");
      }
      logger.error("parseCommand failed", { user: hashUid(uid), error: String(err) });
      throw new HttpsError("internal", "Unexpected error.");
    }
  },
);
