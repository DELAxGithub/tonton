# Documentation Freshness Report

This report summarizes the last update of key documents in the repository and notes potential discrepancies with the current codebase.

| Document | Last Commit Date | Purpose | Notes on Potential Differences |
|----------|-----------------|---------|--------------------------------|
| README.md | 2025-05-24 | Project overview and setup instructions. | Appears generally up to date. |
| docs/ISSUE_10_COMPLETE_ONBOARDING_AND_SAVINGS_LOGIC.md | 2025-05-24 | Describes remaining TODOs for onboarding and savings features. | The code implements `OnboardingSetStartDateScreen` and `UseSavingsScreen`, so TODOs may be outdated. |
| docs/ISSUE_7_IMAGE_ANALYSIS.md | 2025-05-19 | Explains architecture of AI-based image analysis feature. | Matches current AI service and edge function names. |
| docs/HIVE_DEBUG_GUIDE.md | 2025-05-19 | Guidance for Hive debugging. | No obvious discrepancies. |
| docs/IMAGE_ANALYSIS_CHECKLIST.md | 2025-05-19 | Checklist for production readiness of image analysis. | Several checklist items remain unchecked; verify if they are still pending. |
| docs/ai-config.md | 2025-05-19 (content dated 2024-04-29) | Specification of AI-related environment variables and configuration. | Content shows "Last updated: 2024-04-29" which suggests it might be stale. |
| docs/env_setup_guide.md | 2025-05-24 | Environment variable setup instructions. | Consistent with README. |
| analyze_results.txt | 2025-05-19 | Static analysis output. | Likely outdated; rerun analysis for latest results. |

Additional documents in `docs/*.yaml` provide screen specifications with commit dates around 2025-05-20. These files should be reviewed alongside the corresponding UI code to confirm they reflect current layouts and requirements.

Overall, most documents were last updated in mid to late May 2025. A few contain older dates or TODO items that appear resolved in the code. Running static analysis again and reviewing unchecked checklist items will help confirm current status.
