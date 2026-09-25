## Git & PR workflow

- Rebase, don't merge, when updating a branch (`pull.rebase=true`,
  `rebase.autoStash=true`). Keep history linear.
- Small, focused commits with clear messages. Imperative mood
  ("Add X", not "Added X"). Explain *why* in the body when it's not obvious.
- Use the [Conventional Commits](https://www.conventionalcommits.org/) format
  (`type(scope): subject`) for commit messages.
- **Jira ticket prefix (Atlassian work repos only).** When the repo lives under
  `~/dev/atlassian/` or `~/atlassian-frontend-monorepo/`, prefix the commit
  with the Jira ticket parsed from the current branch name. The ticket goes at
  the very front:

  ```
  <JIRA-TICKET> <type>(<scope>): <subject>
  ```

  Example — on branch `feature/PROJ-123-add-login`:

  ```
  PROJ-123 feat(auth): add login form
  ```

  Parse the ticket as the uppercase `ABC-123` pattern in the branch name. If
  the repo is outside those Atlassian paths, or the branch has no Jira ticket,
  omit the prefix and use a plain conventional commit.
- When creating branches, unless otherwise specified, prefix with my initials
  `am/`. The format depends on the workflow:
  - **Normal branches:** `am/JIRA-123-short-description`
  - **Stacked diffs** (Atlassian Git `ag`): `stack/am-JIRA-123-short-description`

  Use `JIRA-123` as the relevant Jira ticket, and a short kebab-case
  description. Omit the ticket segment if there isn't one.
- Don't perform git write operations (commit, push, merge, stash) unless I
  explicitly ask. Read operations are fine anytime.
- Clean up merged branches rather than letting them pile up.

## Review

- When reviewing or responding to reviewers, see the communication style below.
- Call out tradeoffs and risks explicitly rather than silently picking one.
