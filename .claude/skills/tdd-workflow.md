# TDD Workflow Skill

## Description
A skill to autonomously execute the TDD cycle when a feature or fix is requested.

## Steps
1. **RED**: Create a minimal test case for the requested feature. Run the test to confirm it fails.
2. **GREEN**: Write the minimal implementation code to pass the test. Run the test to confirm it passes.
3. **REFACTOR**: Improve code quality (remove duplication, improve readability) without changing behavior. Verify tests still pass.

## Tools
- `Bash` (for running `flutter test`)
- `Edit` (for modifying code)

## Usage
Trigger this workflow when implementing a new sub-feature or fixing a bug.
