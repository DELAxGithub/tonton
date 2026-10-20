# Fastlane credentials

Credentials are managed in 1Password. The tracked `.env.default` has been removed; `.env.default.tpl` contains references and empty optional settings. Do not restore plaintext credentials to Git.

From `ios/`, use the registered root and Fastlane configuration with the existing wrapper:

```sh
~/.local/bin/delax-run --env-file ../.env --env-file fastlane/.env.default -- bundle exec fastlane lanes
```

This lists lanes; it does not release the app. Build/upload lanes still require the documented ASC and match credentials. The existing API key file is outside Git. Read `/Users/delaxpro/work/SECRETS.md` before credential maintenance. No build, upload, key revocation or certificate change was performed by this migration.
