# App Store Submission Checklist

## Age Rating
- [ ] Info.plist shows 12+ rating (`LSApplicationContentRating`: "12")
- [ ] No 4+ references remain in code

## Privacy Policy
- [ ] Privacy policy link accessible from Settings screen (`https://hiroshikodera.github.io/tonton-privacy/`)
- [ ] Privacy policy link accessible from Signup screen (terms agreement)
- [ ] URL opens correctly in external browser

## Data Deletion
- [ ] Account deletion option in Settings screen
- [ ] Deletion removes all user data (Hive meal records)
- [ ] Account marked as deleted in Supabase
- [ ] User signed out after deletion
- [ ] Cannot login with deleted account
- [ ] Confirmation dialog prevents accidental deletion

## Permission Handling
- [ ] HealthKit denial shows appropriate message ("HealthKit未連携のため、手動入力のみ利用可能です")
- [ ] Camera denial shows appropriate message ("カメラ未許可のため、AI食事解析は利用できません")
- [ ] App remains functional without permissions
- [ ] Permission denied scenarios have fallback UI
- [ ] Settings action available for users to change permissions

## Localization
- [ ] All privacy-related strings are localized (Japanese/English)
- [ ] Privacy policy text is appropriate
- [ ] Account deletion confirmation text is clear
- [ ] Permission denied messages are user-friendly

## Technical Implementation
- [ ] `url_launcher` package properly integrated
- [ ] Auth service includes `deleteAccount()` method
- [ ] Meal data service includes `clearAllData()` method
- [ ] Error handling for account deletion failures
- [ ] Network error handling for privacy policy link

## Final Build
- [ ] Version: 1.0.0
- [ ] Build number: 6 (increment from TestFlight build 5)
- [ ] No debug code remains
- [ ] No console.log statements
- [ ] flutter analyze passes without errors
- [ ] flutter test passes

## App Store Connect Configuration
- [ ] Age rating set to 12+ in App Store Connect
- [ ] Privacy policy URL configured in app metadata
- [ ] Data usage disclosure completed
- [ ] Screenshots updated if UI changed
- [ ] App description mentions privacy features

## Pre-Submission Testing
- [ ] Test privacy policy link opens correctly
- [ ] Test account deletion flow completely
- [ ] Test camera permission denial scenario
- [ ] Test HealthKit permission denial scenario
- [ ] Test signup flow with privacy policy agreement
- [ ] Verify all localized strings display correctly
- [ ] Test on device without HealthKit permissions
- [ ] Test on device with camera access denied

## Documentation
- [ ] Release notes updated for v1.0.0
- [ ] Privacy policy document created and published
- [ ] Internal documentation updated with new features

## Compliance Notes
- **GDPR Compliance**: Account deletion provides complete data removal
- **COPPA Compliance**: 12+ age rating appropriate for health data
- **Apple Review Guidelines**: Privacy policy linked from settings and signup
- **Data Minimization**: Only necessary permissions requested with clear explanations