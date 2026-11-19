/**
 * Date context for the AI, always computed in Asia/Dhaka from the SERVER's
 * clock (a phone with a wrong clock cannot corrupt dates).
 *
 * LLMs are unreliable at calendar arithmetic, so instead of asking the model
 * to compute "next Friday", we give it a ready-made table of the next days
 * and it only has to pick a row.
 */
export const DHAKA_TZ = "Asia/Dhaka";

export interface DhakaCalendar {
  today: string; // YYYY-MM-DD
  weekday: string; // e.g. "Thursday"
  time: string; // HH:mm
  /** Lines like "2026-11-20 Friday (tomorrow / kal)" */
  table: string[];
}

const ymd = new Intl.DateTimeFormat("en-CA", { timeZone: DHAKA_TZ, year: "numeric", month: "2-digit", day: "2-digit" });
const wd = new Intl.DateTimeFormat("en-US", { timeZone: DHAKA_TZ, weekday: "long" });
const hm = new Intl.DateTimeFormat("en-GB", { timeZone: DHAKA_TZ, hour: "2-digit", minute: "2-digit", hourCycle: "h23" });

export function dhakaDate(instant: Date): string {
  return ymd.format(instant);
}

export function buildCalendar(now: Date, days = 14): DhakaCalendar {
  const labels: Record<number, string> = {
    [-2]: "day before yesterday / porshu (past)",
    [-1]: "yesterday / kal (past)",
    0: "TODAY / aaj",
    1: "tomorrow / kal (future)",
    2: "day after tomorrow / porshu (future)",
  };
  const table: string[] = [];
  for (let offset = -2; offset <= days; offset++) {
    // Bangladesh has no DST, so adding 24h always moves one calendar day.
    const d = new Date(now.getTime() + offset * 86_400_000);
    const label = labels[offset] ? ` (${labels[offset]})` : "";
    table.push(`${dhakaDate(d)} ${wd.format(d)}${label}`);
  }
  return { today: dhakaDate(now), weekday: wd.format(now), time: hm.format(now), table };
}

/** "2026-02-30" -> false. Also bounds the year range to ±2 years. */
export function isRealDate(iso: string | null | undefined, now: Date): iso is string {
  if (!iso || !/^\d{4}-\d{2}-\d{2}$/.test(iso)) return false;
  const [y, m, d] = iso.split("-").map(Number);
  const dt = new Date(Date.UTC(y, m - 1, d));
  if (dt.getUTCFullYear() !== y || dt.getUTCMonth() !== m - 1 || dt.getUTCDate() !== d) return false;
  const thisYear = Number(dhakaDate(now).slice(0, 4));
  return y >= thisYear - 2 && y <= thisYear + 2;
}

export function isRealTime(t: string | null | undefined): t is string {
  if (!t) return false;
  const m = /^(\d{2}):(\d{2})$/.exec(t);
  return !!m && Number(m[1]) <= 23 && Number(m[2]) <= 59;
}
