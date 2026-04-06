# TornLinux Repo-Ready Baseline (1.3.14 Stable)

This package is the trusted repository starting point.

## What this is
- the 1.3.14 stable baseline
- already includes the proven stable build fixes
- already includes the `features/` folder and `features/index.json`

## What this is NOT
- it is not the salvage pack
- it does not include later feature-line drift work
- it should be committed as the clean baseline before future feature work begins

## Human step after unzip
```bash
cd TornLinux_REPO_READY_BASELINE_1.3.14
git init
git add .
git commit -m "baseline: 1.3.14 stable"
```

Optional remote:
```bash
git remote add origin <your-repo-url>
git branch -M main
git push -u origin main
```
