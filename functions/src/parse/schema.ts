import { z } from "zod";

/**
 * The JSON shape the AI must return. This schema is sent to the Claude API as
 * a structured-output format, so the response is constrained to it.
 * Keep it simple (enums + nullable fields); range checks happen afterwards in
 * validate.ts because not every JSON-Schema constraint is supported for
 * structured outputs.
 */
export const INTENTS = [
  "create_reminder",
  "create_task",
  "add_expense",
  "add_receivable",
  "add_payable",
  "settle_ledger",
  "query_summary",
  "call_contact",
  "play_media",
  "open_app",
  "unknown",
] as const;

export const CATEGORIES = [
  "food",
  "transport",
  "bills",
  "shopping",
  "health",
  "education",
  "mobile_recharge",
  "family",
  "other",
] as const;

export const AMBIGUITIES = ["none", "am_pm", "relative_day", "relative_week", "missing_date"] as const;

export const AiCommandSchema = z.object({
  intent: z.enum(INTENTS),
  confidence: z.number().describe("0 to 1: how sure you are about intent and fields"),
  title: z.string().nullable().describe("Short description in the user's own language/script"),
  amount: z.number().nullable().describe("Amount in taka (BDT) as a plain number"),
  person: z.string().nullable(),
  category: z.enum(CATEGORIES).nullable(),
  date: z.string().nullable().describe("YYYY-MM-DD, a Dhaka calendar date"),
  time: z.string().nullable().describe("HH:mm, 24-hour Dhaka wall-clock time"),
  ambiguity: z.enum(AMBIGUITIES),
  alternatives: z
    .array(z.object({ date: z.string(), time: z.string().nullable() }))
    .describe("Other plausible date/time readings when ambiguous, at most 3"),
  reminderOffsetMinutes: z.number().nullable().describe("For tasks: remind this many minutes before the deadline"),
  repeat: z.enum(["none", "daily", "weekly"]).nullable(),
  clarification: z.string().nullable().describe("One short question for the user, in their language, if something is unclear"),
  language: z.enum(["bn", "en", "mixed"]),
});

export type AiCommand = z.infer<typeof AiCommandSchema>;

/** What the function returns to the app (same fields, validated). */
export type ParseResponse = Omit<AiCommand, "language"> & { language: AiCommand["language"] };

/** The callable's input. */
export const ParseRequestSchema = z.object({
  text: z.string(),
  locale: z.enum(["bn", "en"]).default("bn"),
  clientNow: z.string().optional(),
});

export const MAX_TEXT_CHARS = 500;
