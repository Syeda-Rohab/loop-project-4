# Project 4: A Fix Loop With a Real Checker

A maker-checker loop: an **implementer** drafts a fix in its own
worktree, a separate **reviewer** grades it and replies PASS/FAIL with
reasons, and a PR is opened **only** on PASS.

- **Difficulty:** medium to hard
- **Concepts used:** Concept 8 (worktree), Concept 9 (skill), Concept 11 (maker-checker)

## Files in this project

| File | What it does |
|---|---|
| `1_setup.bat` | One-time setup — initializes the git repo and makes the first commit |
| `2_run_demo.bat` | Runs the entire demo automatically: good fix, review, PR; bad fix, review, no PR |
| `calculator.py` | The source file containing a real bug |
| `test_calculator.py` | The tests — the spec the fix must satisfy |
| `apply_good_fix.py` | Writes a correct, complete fix into a worktree's `calculator.py` |
| `apply_bad_fix.py` | Writes a deliberately incomplete fix, to prove the checker isn't soft |
| `reviewer.py` | The checker — grades a worktree's diff, prints PASS/FAIL with reasons |
| `open_pr.py` | Only ever called after `reviewer.py` returns PASS — opens (simulates) a PR |

Running `2_run_demo.bat` also creates two throwaway worktree folders next
to this one: `demo-fix-good` and `demo-fix-bad`.

## The bug

`is_palindrome()` in `calculator.py` compared a raw string to its
reverse, so it broke on case, spaces, and punctuation —
`"A man a plan a canal Panama"` failed when it should have passed.

## The skill (Concept 9)

The implementer follows a short, repeatable procedure: run the tests
first, fix only the source file (never the test), write the smallest
fix that corrects the actual behavior (not one that special-cases the
test string), leave no debug prints, and re-run the full suite before
handing off.

## What the reviewer actually checks (Concept 11 — not a rubber stamp)

1. **Tests pass** — the primary gate.
2. **Test file untouched** — catches an implementer who "fixes" things
   by weakening the test instead of the bug.
3. **No leftover debug prints.**
4. **Diff is scoped** — not suspiciously large.

A checker that only ran pytest could be tricked by an implementer who
edits the test to force a pass. This one can't — check #2 exists
specifically to catch that.

## Proof — two runs, two different verdicts

### Run 1: Good fix → PASS → PR opened
Implementer normalized the string (lowercase + strip non-alphanumeric)
before comparing.
```
=== Reviewer verdict: PASS ===
Checks satisfied:
  [ok] All tests pass.
  [ok] Test file 'test_calculator.py' was not touched (spec left intact).
  [ok] No debug prints left in the diff.
  [ok] Diff is appropriately scoped (2 added lines).

--- PASS: opening PR ---
[open_pr] PR opened for branch 'fix/good'.
[open_pr] Draft written to ..\demo-fix-good/PR_DRAFT.md
```

### Run 2: Deliberately bad fix → FAIL, no PR
Implementer only lowercased the string and forgot to strip spaces —
the palindrome test still fails.
```
=== Reviewer verdict: FAIL ===
Reasons for FAIL:
  [x] Tests do not pass. pytest output:
      AssertionError: assert False is True
      1 failed, 2 passed in 0.07s

--- FAIL: no PR opened, as expected ---
```

### Confirmed
```
Check: ..\demo-fix-good\PR_DRAFT.md  -> EXISTS
Check: ..\demo-fix-bad\PR_DRAFT.md   -> does NOT exist
```

This satisfies the "done when" condition: a good fix gets a PASS and a
PR, a deliberately planted bad fix gets a FAIL with reasons, and the
checker did not approve everything.

## Running it yourself (Windows)

1. Put all 8 files in one folder.
2. Double-click `1_setup.bat` once.
3. Double-click `2_run_demo.bat`. It will:
   - Confirm the bug is real (1 failing test)
   - Create a worktree, apply the good fix, commit, run the reviewer -> PASS -> open a PR
   - Create a second worktree, apply the bad fix, commit, run the reviewer -> FAIL with reasons -> no PR

## Making PRs real

Right now `open_pr.py` simulates opening a PR by writing `PR_DRAFT.md`,
since this demo has no GitHub remote. To make it a real PR once you
have a GitHub repo + the GitHub CLI set up (`gh auth login`), swap the
body of `open_pr()` for:
```
gh pr create --title "<title>" --body "<body>" --base main --head <branch>
```

## Cleaning up worktrees
```
git worktree remove ..\demo-fix-good --force
git worktree remove ..\demo-fix-bad --force
```
