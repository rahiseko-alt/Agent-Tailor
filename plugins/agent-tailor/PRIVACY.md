# Privacy

Agent Tailor itself collects, stores, and sends no data.

- It reads and writes files only in your working folder.
- It connects to your own Google Drive through Google's official Drive connector (`https://drivemcp.googleapis.com/mcp/v1`) after you sign in from Claude's connector settings. It reads files there to find materials for the agent you are building. It does not share, move, or delete your files. Google's privacy policy applies to that connection: https://policies.google.com/privacy
- It runs the `claude` command on your machine for evaluation and checks, which uses your own Claude account. Anthropic's privacy policy applies: https://www.anthropic.com/legal/privacy
