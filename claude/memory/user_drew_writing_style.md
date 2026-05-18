---
name: Drew Fustini - writing style and voice
description: How Drew writes on lkml/linux-riscv (cover letters, replies, sign-offs); use to match his tone in drafts of emails, commit messages, and cover letters
type: user
originSessionId: 49cba08f-3549-46fe-86fe-0fe3c60829bb
---
Studied from a sample of Drew's lore.kernel.org emails. Index covers 447 emails from `fustini` April 2020 - July 2025; ~75-80% are replies, the rest cover letters / standalone patches / pull requests. Style is remarkably stable across the 5-year span and across employer changes (gmail -> beagleboard -> baylibre -> tenstorrent -> pdp7.com / fustini@kernel.org).

## Tone and persona

- **Humble, low-ego.** Owns mistakes plainly without self-flagellation, even in front of senior maintainers and Linus Torvalds:
  "This is my fault that I did a RESEND after Palmer had already applied the patch... I'm sorry I didn't realize my mistake sooner."
  "I'll keep that in mind for the future." (after a v-numbering miss)
  "I should have stated that I don't know the units."
  "I had changed -ENOTSUPP to -EOPNOTSUPP to silence a checkpatch warning without realizing the implication."
- **Openly admits gaps in knowledge, then frames understanding as a question.** From 2021:
  "I am not familiar with GPIO_REGMAP and REGMAP_IRQ so I will read about it. Is the advantage that it helps to reduce code duplication by using an abstraction?"
  From 2025: "I've not built Linux with Rust before, so I'm going through the quick start [1]... Are you using LLVM?"
- **Asks for what he wants as a question, not a demand.**
  "Would some sort of tunable be acceptable to allow the user to opt out of the v state discard? Maybe a kernel cmdline argument?"
  "Have you tried rootwait instead of the 10 second delay?"
- **Pragmatic.** Prefers what works on real hardware over speculative completeness:
  "The hardware that I have works okay with delay_ctrl of 0, so it seems these new vendor properties are not needed."
- **Empathetic, light human asides slip through.**
  "I imagine an enforced delay would be very annoying."
  "(so we could see the adorable Tux at boot, etc)" (2020 LCD-driver question)
- **Polite but not flowery.** "Thanks for the review." / "Thanks for the patch series. It will be great to have PWM working upstream." Sincere, no padding.
- **Collaborative.** Routinely credits others by name (Emil, Andrew Lunn, Jisheng, Stephen, Palmer); links their replies and branches.

## Structural habits

- **Replies**: quote upstream context generously and precisely, respond inline below the relevant chunk in 1-3 short paragraphs, often a single commitment ("I'll fix in future revision", "I'll remove these custom properties in the next revision"). No top-posting. Preserves the full message-ID quote chain.
- **Cover letters**: open with one or two sentences naming SoC/board and what the series does; list hardware tested; list prereqs; numbered footnote refs; share a `pdp7/linux` GitHub branch URL so reviewers can reproduce. Often includes config gist + boot log gists.
- **Pull requests**: standard `git request-pull` format with brief tag-annotation paragraph: "There are several additions for the T-Head TH1520 SoC: ... These changes have all been tested in linux-next with the corresponding driver patches." Maintainer-formal but still terse.
- **References as bracketed footnotes** at the end ([1] https://...), not inline URLs.
- **Discloses test setup**: kernel version, config gist, boot logs, "tested on lpi4a and beaglev ahead", and exact U-Boot version when debugging.
- **Empirical perf claims come with reproducible artifacts.** Posting null-syscall results, he linked the test program gist, the with-patch branch, and the without-patch branch so anyone could reproduce: "201 ns ... drops to 143 ns."

## Sign-offs

Variable, no single house style. All of these appear regularly:
- `Drew` (most common)
- `-Drew`
- `Thanks,\nDrew`
- `Thank you,\nDrew`

(Drew historically also used lowercase `thanks,\ndrew` on casual replies,
but as of 2026-05-12 he asked drafts to default to capitalized `Drew`.
Do not lowercase the sig in drafts unless he asks for it explicitly.)

No opening greeting in replies most of the time; just dives in below the quoted text. On non-reply community posts (Plumbers, Summit) he opens with `Hello,` or `Hello all,`.

## Email addresses (lore-visible, chronological)

- `pdp7pdp7@gmail.com` (2020-, still used occasionally for personal lkml replies)
- `drew@beagleboard.org` (2021)
- `dfustini@baylibre.com` (2023)
- `dfustini@tenstorrent.com` (Jan 2024 -)
- `drew@pdp7.com` (2024+, MAINTAINERS / pull requests)
- `fustini@kernel.org` (2025+)

## Vocabulary and quirks

- Spells `okay` not `ok`.
- Always `ARM`, never `Arm`.
- Casual short forms for boards: `lpi4a`, `ahead`, `lpi4`.
- Parenthetical asides land warmth: "(my rootfs is a simple buildroot)", "(so we could see the adorable Tux at boot, etc)".
- Doesn't shy from a small typo in flight ("etherenet"); not a perfectionist about prose.
- ASCII hyphens, never em-dashes (consistent with his explicit no-em-dash rule).
- No semicolons in prose. No dashes in prose (ASCII hyphens are fine in code and compound adjectives). Prefer starting a new sentence. Use a comma only when a new sentence really doesn't fit.
- `I'll` / `I've` / `I'm` contractions are normal; doesn't go formal-stiff.
- "thanks," and "Drew" (capitalized or lower) appear together more often than "Best regards" or anything formal.

## How to apply

When drafting an email, cover letter, or reply on his behalf:
- Lead with the concrete (hardware, what works, what was tested), not abstract motivation.
- Keep replies short. Quote, respond in 1-3 sentences inline below the relevant chunk, commit to an action, sign off.
- Acknowledge the reviewer's point directly; if he was wrong, just say so (no defensive hedging).
- When asking for something, frame it as a question: "Would X be acceptable?" / "Have you tried Y?" - never a demand.
- When you don't know something, say so plainly and ask: "I'm not familiar with X - does it help with Y?"
- For empirical claims, link the artifact (gist, branch, dashboard) so the reader can reproduce.
- Use bracketed numeric footnotes for links, not inline URLs in prose.
- Pick `Drew` or `Thanks,\nDrew` as default sign-off. Always capitalized — do not write lowercase `drew` in drafts.
- No em-dashes. No semicolons. No dashes in prose. No hyperbole. No "I hope this finds you well" pleasantries. Light parenthetical warmth is fine and on-brand.
