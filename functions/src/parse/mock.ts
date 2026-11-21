import type { DhakaCalendar } from "./calendar";
import type { AiCommand } from "./schema";

/**
 * A tiny rule-based stand-in for the AI, used ONLY when MOCK_AI=true (local
 * emulator / demos without an API key). It understands a few patterns so the
 * whole app flow can be tested for free. It is NOT a production parser.
 */
export function mockParse(raw: string, cal: DhakaCalendar): AiCommand {
  const text = raw.replace(/[০-৯]/g, (d) => String("০১২৩৪৫৬৭৮৯".indexOf(d))).toLowerCase();
  const amountMatch = /(\d+(?:\.\d+)?)\s*(?:k\b)?/.exec(text);
  const amount = amountMatch ? Number(amountMatch[1]) * (/\d\s*k\b/.test(text) ? 1000 : 1) : null;
  const tomorrow = cal.table.find((l) => l.includes("tomorrow"))!.slice(0, 10);
  const date = /\b(kal|tomorrow)\b|কাল/.test(text) ? tomorrow : cal.today;
  const timeMatch = /(\d{1,2})\s*(?:ta|tay|টা|টায়|am|pm)/.exec(text);
  let time: string | null = null;
  if (timeMatch) {
    let h = Number(timeMatch[1]);
    if (/pm|bikal|বিকাল|rat|রাত|shondha|সন্ধ্যা/.test(text) && h < 12) h += 12;
    time = `${String(h).padStart(2, "0")}:00`;
  }
  const base: AiCommand = {
    intent: "unknown",
    confidence: 0.7,
    title: raw.slice(0, 60),
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
    language: /[ঀ-৿]/.test(raw) ? "bn" : "mixed",
  };
  if (/remind|mone kor|মনে করি/.test(text)) {
    return { ...base, intent: "create_reminder", date, time: time ?? "09:00" };
  }
  const callee = /([a-z]+) (?:ke )?(?:call|phone|fon) (?:koro|dao|kor)/.exec(text) ?? /\bcall ([a-z]+)/.exec(text);
  if (callee) return { ...base, intent: "call_contact", person: callee[1][0].toUpperCase() + callee[1].slice(1) };
  if (/(gaan|gan|song|গান).*(bajao|chalao|play|বাজাও)|\bplay\s/.test(text)) {
    const what = text.replace(/\b(gaan|gan|song|bajao|chalao|play|er|ekta)\b/g, " ").replace(/\s+/g, " ").trim();
    return { ...base, intent: "play_media", title: what };
  }
  if (/\b(kholo|open)\b/.test(text)) {
    return { ...base, intent: "open_app", title: text.replace(/\b(kholo|open|app)\b/g, " ").trim() };
  }
  if (/khoroch|spent|খরচ|kinlam/.test(text) && amount) {
    return { ...base, intent: "add_expense", amount, category: /lunch|khabar|খাবার|dinner/.test(text) ? "food" : "other", date: cal.today };
  }
  if (/dite hobe|দিতে হবে|owe/.test(text) && amount) {
    return { ...base, intent: "add_payable", amount, date };
  }
  if (/pabo|পাব|amar kache|owes me/.test(text) && amount) {
    return { ...base, intent: "add_receivable", amount };
  }
  if (/korte hobe|করতে হবে|submit|deadline/.test(text)) {
    return { ...base, intent: "create_task", date };
  }
  return { ...base, confidence: 0.3 };
}
