# Issue #10: Persist Start Date and Implement Savings Logic


## Status
Completed

## Overview
Two screens added in Phase 2 still contain TODOs:
- `OnboardingSetStartDateScreen` does not save the selected start date.
- `UseSavingsScreen` has a placeholder in `_confirm` for integrating with
the calorie savings logic.

## Tasks
- Connect `OnboardingSetStartDateScreen` to a persistence mechanism
  (e.g., Hive or SharedPreferences) so the user's chosen start date is saved.
- Implement the calorie savings deduction and confirmation flow in
  `UseSavingsScreen`.
- Add tests and validation once these features are implemented.
