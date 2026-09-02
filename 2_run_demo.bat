@echo off
setlocal

echo === Cleaning up any leftover worktrees from before ===
git worktree remove ..\demo-fix-good --force >nul 2>nul
git worktree remove ..\demo-fix-bad --force >nul 2>nul
rmdir /s /q ..\demo-fix-good >nul 2>nul
rmdir /s /q ..\demo-fix-bad >nul 2>nul
git branch -D fix/good >nul 2>nul
git branch -D fix/bad >nul 2>nul
git worktree prune >nul 2>nul

echo.
echo === Confirming the bug is real (should show 1 failed) ===
python -m pytest -q

echo.
echo =====================================================
echo   RUN 1: GOOD FIX
echo =====================================================
git worktree add ..\demo-fix-good -b fix/good
python apply_good_fix.py ..\demo-fix-good\calculator.py

pushd ..\demo-fix-good
git add -A
git commit -m "Fix is_palindrome: normalize case and strip punctuation"
popd

echo.
echo --- Reviewer grading the GOOD fix ---
python reviewer.py main ..\demo-fix-good test_calculator.py
if %errorlevel%==0 (
    echo.
    echo --- PASS: opening PR ---
    python open_pr.py fix/good ..\demo-fix-good "Fix is_palindrome bug" "Normalized case and punctuation before comparing. All tests pass."
) else (
    echo.
    echo --- FAIL: no PR opened ---
)

echo.
echo =====================================================
echo   RUN 2: DELIBERATELY BAD FIX
echo =====================================================
git worktree add ..\demo-fix-bad -b fix/bad
python apply_bad_fix.py ..\demo-fix-bad\calculator.py

pushd ..\demo-fix-bad
git add -A
git commit -m "Fix is_palindrome (incomplete fix)"
popd

echo.
echo --- Reviewer grading the BAD fix ---
python reviewer.py main ..\demo-fix-bad test_calculator.py
if %errorlevel%==0 (
    echo.
    echo --- PASS: opening PR ---
    python open_pr.py fix/bad ..\demo-fix-bad "Fix is_palindrome bug" "..."
) else (
    echo.
    echo --- FAIL: no PR opened, as expected ---
)

echo.
echo =====================================================
echo   DEMO COMPLETE
echo   Check: ..\demo-fix-good\PR_DRAFT.md should EXIST
echo   Check: ..\demo-fix-bad\PR_DRAFT.md should NOT exist
echo =====================================================
pause
