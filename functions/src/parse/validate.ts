import { isRealDate, isRealTime } from "./calendar";
import type { AiCommand, ParseResponse } from "./schema";

/** ৳1,000,000,000: anything above is treated as a recognition error. */
export const MAX_AMOUNT_TAKA = 1_000_000_000;

const clip = (s: string | null | undefined, max: number): string | null => {
  if (s == null) return null;
  const t = s.trim().replace(/\s+/g, " ");
  return t.length === 0 ? null : t.slice(0, max);
};

/**
 * Deterministic cross-check: if the utterance contains digits, the AI's amount
 * must be one of those numbers (optionally × thousand / lakh / crore, e.g.
 * "2k", "3 lakh"). If not, the AI probably misread it. Returns true when
 * consistent or when there are no digits to check (amount said in words).
 */
export function amountMatchesText(text: string, amount: number | null): boolean {
  if (amount == null) return true;
  const ascii = text.replace(/[০-৯]/g, (d) => String("০১২৩৪৫৬৭৮৯".indexOf(d))).replace(/(\d),(?=\d)/g, "$1");
  const numbers = (ascii.match(/\d+(?:\.\d+)?/g) ?? []).map(Number);
  if (numbers.length === 0) return true;
  const multipliers = [1, 1_000, 100_000, 10_000_000];
  return numbers.some((n) => multipliers.some((m) => Math.abs(n * m - amount) < 0.005));
}

/**
 * Second line of defence after the schema: the AI output is checked for
 * real dates, sane amounts and lengths. Invalid parts are dropped (null),
 * never "fixed" by guessing. The app validates again and the user confirms.
 */
export function sanitize(ai: AiCommand, now: Date, text?: string): ParseResponse {
  const date = isRealDate(ai.date, now) ? ai.date : null;
  const time = isRealTime(ai.time) ? ai.time : null;

  const isAction = ai.intent === "call_contact" || ai.intent === "play_media" || ai.intent === "open_app";
  const amount =
    !isAction &&
    typeof ai.amount === "number" && Number.isFinite(ai.amount) && ai.amount > 0 && ai.amount <= MAX_AMOUNT_TAKA
      ? Math.round(ai.amount * 100) / 100
      : null;

  const alternatives = (ai.alternatives ?? [])
    .filter((a) => isRealDate(a.date, now))
    .map((a) => ({ date: a.date, time: isRealTime(a.time) ? a.time : null }))
    .slice(0, 3);

  const offset =
    typeof ai.reminderOffsetMinutes === "number" && ai.reminderOffsetMinutes > 0 && ai.reminderOffsetMinutes <= 60 * 24 * 30
      ? Math.round(ai.reminderOffsetMinutes)
      : null;

  let ambiguity = ai.ambiguity;
  // A reminder without a usable date is always "missing_date".
  if (ai.intent === "create_reminder" && (date === null || time === null) && ambiguity === "none") {
    ambiguity = "missing_date";
  }

  let confidence = Number.isFinite(ai.confidence) ? Math.min(1, Math.max(0, ai.confidence)) : 0;
  // Amount disagrees with the digits the user actually said: make the app
  // show the card in "please check" mode instead of trusting it.
  if (text !== undefined && !amountMatchesText(text, amount)) confidence = Math.min(confidence, 0.5);

  return {
    intent: ai.intent,
    confidence,
    title: clip(ai.title, 200),
    amount,
    person: clip(ai.person, 80),
    category: ai.category ?? null,
    date,
    time,
    ambiguity,
    alternatives,
    reminderOffsetMinutes: offset,
    repeat: ai.repeat ?? "none",
    clarification: clip(ai.clarification, 200),
    language: ai.language,
  };
}

/** What we return when the model refused, was cut off, or produced junk. */
export function unknownResponse(): ParseResponse {
  return {
    intent: "unknown",
    confidence: 0,
    title: null,
    amount: null,
    person: null,
    category: null,
    date: null,
    time: null,
    ambiguity: "none",
    alternatives: [],
    reminderOffsetMinutes: null,
    repeat: "none",
    clarification: null,
    language: "mixed",
  };
}
