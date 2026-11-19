import Anthropic from "@anthropic-ai/sdk";
import { zodOutputFormat } from "@anthropic-ai/sdk/helpers/zod";

import type { DhakaCalendar } from "./calendar";
import { buildUserMessage, SYSTEM_PROMPT } from "./prompt";
import { AiCommandSchema, type AiCommand } from "./schema";

/**
 * The ONE place that talks to the AI provider. To compare or switch models,
 * change MODEL and re-run the eval set (docs/09 § 9.4).
 */
export const MODEL = "claude-haiku-5-5";

export interface ModelResult {
  output: AiCommand | null;
  stopReason: string | null;
  inputTokens: number;
  outputTokens: number;
  cacheReadTokens: number;
}

export async function callModel(client: Anthropic, text: string, cal: DhakaCalendar, locale: string): Promise<ModelResult> {
  const response = await client.messages.parse({
    model: MODEL,
    // Short extraction task: low effort keeps reasoning (billed as output) small.
    max_tokens: 1024,
    output_config: { effort: "low", format: zodOutputFormat(AiCommandSchema) },
    system: SYSTEM_PROMPT,
    // Caches the stable system prompt when it is long enough for the model's
    // minimum cacheable length; check cacheReadTokens in the logs.
    cache_control: { type: "ephemeral" },
    messages: [{ role: "user", content: buildUserMessage(text, cal, locale) }],
  });

  // A refusal or a cut-off answer is not a usable command.
  const usable = response.stop_reason === "end_turn" && response.parsed_output != null;
  return {
    output: usable ? response.parsed_output : null,
    stopReason: response.stop_reason ?? null,
    inputTokens: response.usage.input_tokens,
    outputTokens: response.usage.output_tokens,
    cacheReadTokens: response.usage.cache_read_input_tokens ?? 0,
  };
}
