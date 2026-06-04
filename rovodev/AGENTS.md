## Socrates (Databricks)

- Host: `socrates-workbench-01.cloud.databricks.com`
- Profile: `DEFAULT`
- Warehouse ID: `af2491cd959ef264`
- Default timeout: `30s` (max `50s`)
- Auth setup: `databricks auth login https://socrates-workbench-01.cloud.databricks.com -p DEFAULT`
- Auth check: `databricks auth describe -p DEFAULT`

### Key tables

| Table                                                               | Description                          |
| ------------------------------------------------------------------- | ------------------------------------ |
| `production.devinfra_productfabric.af_build_metrics_v1_0`           | Build metrics, test counts, pipeline |
| `production.people_apex_analytics.pr_details_table_vnext`           | Employee PR data                     |
| `production.engex_ehd_core_eng_data_model.pull_request_fact`        | PR state, repo info, timestamps      |
| `production.engex_ehd_core_eng_data_model.pull_request_change_fact` | File-level PR changes                |
| `production.analyticsplat.event_ui`                                 | UI interaction events                |
| `production.analyticsplat.event_screen`                             | Screen/page navigation events        |
| `production.analyticsplat.event_track`                              | Completed product actions            |
| `production.analyticsplat.event_operational`                        | Internal system behavior events      |
| `production.pollinator_data_events.pollinator_outage_v1`            | Outage info by checks                |
| `production.pollinator_data_events.pollinator_checks_v1`            | Check metadata                       |
| `production.pollinator_data_events.pollinator_archetypes_v1`        | Check archetype metadata             |
| `inner_loop.metrics`                                                | ALMD metrics (mithril-cli)           |

### Query tips

- Use date filters: `WHERE day >= '2026-01-01'`
- Use `LIMIT` for exploration
- JSON: `JSON_EXTRACT_SCALAR(col, '$.path')` (strings), `JSON_EXTRACT(col, '$.path')` (objects)
- Async: `wait_timeout: "0s"`, poll via `databricks api get /api/2.0/sql/statements/{statement_id} -p DEFAULT`

## Pollinator API Queries

### Base URL

- Commercial Production: `https://pollinator.prod.atl-paas.net/api`
- Commerical Staging: `https://pollinator.staging.atl-paas.net/api`

### Authentication

Use `atlas slauth curl -a pollinator` for authenticated requests. Use `--` before curl args to pass flags properly:

```sh
atlas slauth curl -a pollinator -- -s -X POST -H "Content-Type: application/json" -d '{}' 'https://...'
```

### Build & Deploy Workflow

Both `build` and `deploy` need to know the location of `feature-test.config.yml`. If running from the same directory as the config file, the `-c` flag can be omitted. Otherwise pass `-c {path}`. Always ask the user which project they are working in if not clear from context. Common locations:

| Project | Config path |
|---|---|
| Playground | `/Users/amohanty/dev/atlassian/feature-test-playground/feature-test.config.yml` |
| AFM Jira | `/Users/amohanty/dev/atlassian/atlassian-frontend-monorepo/jira/operations/feature-tests/feature-test.config.yml` |
| Integration tests | `/Users/amohanty/dev/atlassian/atlassian-frontend-monorepo/platform/packages/feature-testing/integration-tests/feature-test.config.yml` |

```sh
# 1. Build (no --test flag, builds all tests in the workspace)
atlas mithril feature-test build -c {path/to/feature-test.config.yml}

# 2. Deploy by suite UUID
atlas mithril feature-test deploy -c {path/to/feature-test.config.yml} --suite-id {suite_uuid} --non-interactive

# 3. Find suite UUID from test config file (suite_uuid field)
cat operations/feature-tests/teams/{team}/{test}/{test}.e2e.config.ts
```

### Querying Checks

The query parameter name is `polliql` (not `query`). Always URL-encode the value. Example:

```sh
POLLIQL='tag = "test_name:my-test" AND tag = "managed-autoprov_target:prod-ic"'
atlas slauth curl -a pollinator \
  "https://pollinator.prod.atl-paas.net/api/v2/checks?polliql=$(python3 -c "import urllib.parse,sys; print(urllib.parse.quote(sys.argv[1]))" "$POLLIQL")&useCache=true"
```

Find check by archetype and target:
`tag = "managed-archetype_uuid:{archetype_uuid}" AND tag = "managed-autoprov_target:{target}"`

Find check by name and target:
`tag = "test_name:{test_name}" AND tag = "managed-autoprov_target:{target}"`

#### Common Tags

• `test_name:<name>` - Test name
• `managed-archetype_uuid:<uuid>` - Archetype UUID
• `managed-autoprov_target:<target>` - Target environment (staging, prod, hello)
• `managed-suite_uuid:<uuid>` - Suite UUID
• `team:<team>`- Team name
• `product:<product>` - Product (jira, confluence, etc.)

### Run-Once (Ad-Hoc Execution)

Trigger an ad-hoc run of a check:

```sh
atlas slauth curl -a pollinator -- -s -X POST \
  -H "Content-Type: application/json" \
  -d '{
    "description": "my test run",
    "type": "synthetic",
    "template_check_uuid": "{check_uuid}",
    "arguments": {},
    "execution_framework": "12JAN2026",
    "hive": "",
    "credentials": {}
  }' \
  'https://pollinator.prod.atl-paas.net/api/v2/adhoc/execute_async'
```

Response contains the execution UUID:
```json
{ "data": { "uuid": "{execution_uuid}" }, "status_code": 200, "errors": [] }
```

Poll for results (returns 404 until complete, then 200):

```sh
atlas slauth curl -a pollinator -- -s \
  'https://pollinator.prod.atl-paas.net/api/v2/adhoc/results/{execution_uuid}'
```

Script output is at `data.result.data.script_output` in the response.

View result in browser:
`https://pollinator.prod.atl-paas.net/checks/{check_uuid}?adhoc_result={execution_uuid}`

### Check Outage Status

Get outages for a check:

```sh
atlas slauth curl -a pollinator \
 'https://pollinator.prod.atl-paas.net/api/v2/outages/{check_uuid}'
```

Determine current status:

• Outages are sorted reverse chronologically (newest first)
• If data[0].end_timestamp is null → check is IN OUTAGE
• Otherwise → check is OK

## Communication Style

Apply this style whenever asked to phrase something — PR review comments, responses to reviewers, Slack messages, ticket descriptions, etc.

### Tone principles

1. **Lead with empathy, not defensiveness** — acknowledge the other person's point is valid before explaining a different view. e.g. "I get where you're coming from, but..."
2. **Be honest about limitations** — call out constraints (broken infra, time pressure, missing tooling) transparently rather than glossing over them. Transparency builds trust.
3. **Name the tradeoff explicitly** — don't just say no; explain *what* would actually be valuable and *why* the suggested approach falls short.
4. **Ground urgency in facts** — if speed matters, say why (e.g. "this is fixing an active HOT issue") so the reviewer has real context.
5. **End with an open question** — keep it collaborative rather than closing the conversation. e.g. "Is that alright?" or "Happy to hear your thoughts!"
6. **Casual but professional** — light use of emoji (e.g. 😅) is fine to soften a pushback without undermining technical substance.
7. **Concise** — avoid over-explaining. Make the point, give the reason, offer a path forward. Don't pad.
