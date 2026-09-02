# Project 4: A Fix Loop With a Real Checker

A maker-checker loop: an **implementer** drafts a fix in its own
worktree, a separate **reviewer** grades it and replies PASS/FAIL with
reasons, and a PR is opened **only** on PASS.

**Difficulty:** medium to hard
**Concepts used:** Concept 8 (worktree) · Concept 9 (skill) · Concept 11 (maker-checker)

---

## Files in this project

| File | Role |
|---|---|
| `calculator.py` | source file containing a real bug |
| `test_calculator.py` | the spec — tests that expose the bug |
| `reviewer.py` | the checker — grades a fix and prints PASS/FAIL with reasons |
| `open_pr.py` | opens a PR draft — only ever called after a PASS |
| `apply_good_fix.py` | writes a correct fix (used to demo the PASS path) |
| `apply_bad_fix.py` | writes a deliberately incomplete fix (used to demo the FAIL path) |
| `1_setup.bat` | one-time setup — initializes the git repo |
| `2_run_demo.bat` | runs the full demo automatically (both good and bad fix) |

## The bug

`is_palindrome()` compared a raw string to its reverse, so it broke on
case, spaces, and punctuation — `"A man a plan a canal Panama"` failed
when it should have passed.

## What the reviewer actually checks (not a rubber stamp)

1. **Tests pass** — the primary gate.
2. **Test file untouched** — catches an implementer who "fixes" things
   by weakening the test instead of the bug.
3. **No leftover debug prints.**
4. **Diff is scoped** — not suspiciously large.

A checker that only ran the tests could be fooled by an implementer
editing the test file to force a pass. This one can't be.

## How to run it

1. Put all 8 files in one folder.
2. Double-click `1_setup.bat` once (initializes the git repo).
3. Double-click `2_run_demo.bat` — this does everything automatically:
   - Confirms the bug is real (1 failing test).
   - Creates a worktree, applies the **good** fix, commits it.
   - Runs the reviewer → **PASS** → opens a PR (`PR_DRAFT.md` is created).
   - Creates a second worktree, applies the **bad** fix, commits it.
   - Runs the reviewer → **FAIL** with reasons → no PR is opened.

## Proof — actual results from running it

### Run 1: Good fix → PASS → PR opened
```
=== Reviewer verdict: PASS ===

Checks satisfied:
  [ok] All tests pass.
  [ok] Test file 'test_calculator.py' was not touched (spec left intact).
  [ok] No debug prints left in the diff.
  [ok] Diff is appropriately scoped (2 added lines).

--- PASS: opening PR ---
[open_pr] PR opened for branch 'fix/good'.
[open_pr] Draft written to ..\demo-fix-good\PR_DRAFT.md
```

### Run 2: Deliberately bad fix → FAIL, no PR
```
=== Reviewer verdict: FAIL ===

Checks satisfied:
  [ok] Test file 'test_calculator.py' was not touched (spec left intact).
  [ok] No debug prints left in the diff.
  [ok] Diff is appropriately scoped (2 added lines).

Reasons for FAIL:
  [x] Tests do not pass. pytest output:
      assert is_palindrome("A man a plan a canal Panama") is True
      AssertionError: assert False is True
      1 failed, 2 passed in 0.07s

--- FAIL: no PR opened, as expected ---
```

### Final confirmation
```
Check: ..\demo-fix-good\PR_DRAFT.md should EXIST      -> confirmed present
Check: ..\demo-fix-bad\PR_DRAFT.md should NOT exist    -> confirmed absent
```

## Done-when checklist

- [x] A good fix gets a PASS and a PR.
- [x] A deliberately bad fix gets a FAIL with reasons.
- [x] The checker is not soft — it reports the specific pytest failure,
      not just a blanket rejection.
