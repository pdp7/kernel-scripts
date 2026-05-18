---
name: v4 candidate Reinette-perspective review
description: Pre-send self-review of Ssqosid/CBQRI v4. All cheap-fix items landed before v4 send (HEAD `f3ba981889e6` for v5 prep); remaining items are design-level "wait for Reinette" or low.
type: project
originSessionId: ba1ccd3f-177b-4a45-9f4c-c919afd9fc63
---
Self-review file: `~/dev/linux/reinette-perspective-review-20260430.md`.

Built by reading Reinette's v1/v2 CBQRI review, her v3/v4 MPAM review
patterns (Ben Horgan series), and her ongoing fs/resctrl quality series,
then comparing to the v4 candidate.

**Why:** v3 sent 2026-04-14, no Reinette review yet. v4 sent 2026-05-10
to preempt high-probability pushback. v5 prep continues on the same
branch with sashiko-driven fixes folded in.

**Cheap-fix items landed by v4 send:** (1) alloc_capable/mon_capable
set last; (2) monitor-only L3 TODO removed, pr_warn_once +
resctrl.rst doc; (5) sum-overflow pr_err to pr_err_ratelimited;
(8a) `i.e.\ when` polished; (10) TODO removed; (11)
lockdep_assert_held(&ctrl->lock) added at all 5 sites.

**Held (correctly, per "don't preempt"):** (3) bool default_at_min;
(4) arch-set r->name; (7) error-path comment; (9) resctrl_is_membw
schema_fmt keying.

**Walk-back on prior claim:** I originally said rdt_last_cmd_printf()
was callable from arch drivers, citing arch/x86. That was wrong.
Verified: the proto is in fs/resctrl/internal.h (private to fs/resctrl);
no arch backend uses it. The applied pr_err_ratelimited + comment is
correct for v4.

**Status at HEAD `f3ba981889e6` (v5 prep):** v4 sent, sashiko replied,
fixes folded. No further Reinette-driven cheap fixes outstanding.
Held items remain design-level and properly wait for Reinette's
actual review.
