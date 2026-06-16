# Legacy

Configuration for tools that are no longer the active choice but are kept for
reference / potential migration.

| Item | Status | Notes |
|------|--------|-------|
| `iterm/` | Retired | Superseded by **cmux** as the terminal/multiplexer going forward. The color schemes and `com.googlecode.iterm2.plist` are kept so their settings can be evaluated for a cmux equivalent later. See `docs/ai-native-plan.md` §5.2.2. |

Nothing in here is wired into `setup.sh` or `bootstrap.sh`. Files are retained
rather than deleted (git history aside) because they capture preference choices
worth porting to their replacements.
