// Footer: pi's built-in footer (cwd/branch/session line, token + context
// usage/model line, MCP + extension status line) with the hostname merged
// into the first line, right-aligned. Reuses the real FooterComponent via a
// session shim, so nothing about the built-in rendering is duplicated.
//
// Colors: match the terminal prompt on this machine — the hostname-hash
// darkreader theme in .terminal/.bashrc (__ps1_host_colors) renders periwinkle
// #99a5ff block text and battery green #87d787 (xterm 114) for this hostname.
// ponytail: colors hardcoded for THIS host; port the cksum/hue derivation from
// __ps1_host_colors if this extension is ever copied to another machine.
// Applied by swapping the theme's dim gray (38;2;102;102;102) per line; if the
// theme changes, swaps become no-ops and the footer falls back to its default.
//
// Thinking level gets a cool→hot heat ramp (mango hues): minimal steel
// blue → low blue → medium purple → high pink → xhigh red → max blazing red.
// "off" stays untinted.
//
// Limitations of the shim (all acceptable here): "(sub)" cost marker is
// never shown (isUsingSubscription → false, only affects kimi-coding-style
// providers), and model/thinking-level freshness relies on ctx being stable
// across events (same pattern as pi's own custom-footer example).
import os from "node:os";
import { truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";
import { FooterComponent } from "@earendil-works/pi-coding-agent";
import type { AgentSession, ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function (pi: ExtensionAPI) {
	pi.on("session_start", async (_event, ctx) => {
		if (!ctx.hasUI) return;
		ctx.ui.setFooter((tui, theme, footerData) => {
			// No AgentSession handle exists for extensions; feed the component
			// from what the extension context exposes instead.
			const session = {
				get state() {
					return { model: ctx.model, thinkingLevel: ctx.thinkingLevel };
				},
				getContextUsage: () => ctx.getContextUsage(),
				sessionManager: ctx.sessionManager,
				modelRuntime: { isUsingSubscription: () => false },
			} as unknown as AgentSession;
			const builtin = new FooterComponent(session, footerData);
			const unsub = footerData.onBranchChange(() => tui.requestRender());
			return {
				dispose: () => {
					unsub();
					builtin.dispose();
				},
				invalidate() {
					builtin.invalidate();
				},
				render(width: number): string[] {
					const lines = builtin.render(width);
					const DIM = "38;2;102;102;102"; // theme dim gray #666666
					const purple = "38;2;153;165;255"; // host-theme block text #99a5ff
					const green = "38;2;135;215;135"; // host-theme battery green #87d787
					// thinking-level heat ramp, cool → hot (mango hues)
					const HEAT: Record<string, string> = {
						minimal: "95;135;175", // steel blue
						low: "95;175;223", // mango blue #5fafdf
						medium: "175;135;255", // mango purple #af87ff
						high: "255;95;175", // mango pink #ff5faf
						xhigh: "255;95;95", // mango red #ff5f5f
						max: "255;0;0", // mango light-mode red #ff0000
					};
					// cwd line purple, stats/model line green, MCP/status line untouched
					const tinted = lines.map((line, i) =>
						i === 0
							? line.replaceAll(DIM, purple)
							: i === 1
								? line.replaceAll(DIM, green)
								: line,
					);
					// recolor the trailing "• <level>" segment with the heat color
					const tail = tinted[1]?.match(
						/(• (?:thinking )?(off|minimal|low|medium|xhigh|high|max))((?:\x1b\[[0-9;]*m)*)$/,
					);
					if (tinted[1] && tail && HEAT[tail[2]]) {
						tinted[1] =
							tinted[1].slice(0, tail.index) +
							`\x1b[38;2;${HEAT[tail[2]]}m${tail[1]}\x1b[39m${tail[3]}`;
					}
					const host = `\x1b[${green}m${os.hostname()}\x1b[39m`;
					const first = tinted[0] ?? "";
					const pad = " ".repeat(
						Math.max(1, width - visibleWidth(first) - visibleWidth(host)),
					);
					tinted[0] = truncateToWidth(first + pad + host, width);
					return tinted;
				},
			};
		});
	});
}
