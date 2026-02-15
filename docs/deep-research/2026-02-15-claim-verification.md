# Claim Verification Sample (2026-02-15)

Sample verification of high-impact claims against primary/high-signal sources.

## Verification Table

| Claim | Report(s) | Verification result | Confidence | Evidence |
| --- | --- | --- | --- | --- |
| Docstrings should describe API semantics and usage, not implementation details | ChatGPT, Gemini | Verified | High | Google Python Style Guide (docstrings describe syntax/semantics, not implementation details) |
| Public modules/functions/classes should have docstrings | ChatGPT, Gemini | Verified | High | PEP 257: modules and exported functions/classes should have docstrings |
| Update docs in same change/PR as code | ChatGPT | Verified | High | Google Documentation Best Practices: "Change your documentation in the same CL as the code change" |
| Docs-as-code should use code workflows (VCS, code review, automated tests) | ChatGPT, Gemini | Verified | High | Write the Docs "Docs as Code" guidance |
| Agent instruction files should include specific commands and boundaries | ChatGPT, Gemini | Verified | Medium-High | GitHub Blog (Nov 2025): analysis of 2,500+ `agents.md` files; successful files include exact commands and clear boundaries |
| Keep `CLAUDE.md` concise and regularly pruned | ChatGPT, Gemini | Verified | High | Claude Code docs: keep concise, prune regularly, treat as code |
| LLM prompt injection is a real risk and should be mitigated | Gemini | Verified | High | OWASP Top 10 for LLMs: LLM01 Prompt Injection |
| Every file must have a top-level docstring for repo maps | Gemini | Not verified as universal rule | Low | No authoritative source found establishing this as a universal requirement |
| Teams must publish `llms.txt` for internal libraries | Gemini | Not verified as universal rule | Low | `llms.txt` exists as emerging practice, not an established must-do standard |
| Agents should log their "thinking" in decision logs | ChatGPT, Gemini | Partially verified | Low-Medium | Decision logs are useful, but storing chain-of-thought is not a recommended default security/privacy pattern |

## Verified Source Notes

| Source | Why used |
| --- | --- |
| Google Python Style Guide | Primary source for comments/docstrings behavior |
| PEP 257 | Canonical Python docstring convention |
| Google Documentation Best Practices | Primary source for docs-updated-with-code principle |
| Write the Docs (Docs as Code) | Established docs-as-code workflow reference |
| GitHub Blog (agents.md analysis) | High-signal 2025 guidance for repo-level agent instructions |
| Claude Code Best Practices | Primary source for `CLAUDE.md` lifecycle guidance |
| OWASP Top 10 for LLM Applications | Primary source for LLM-specific security risks |

## References

| Reference | Publisher | Date |
| --- | --- | --- |
| [Google Developer Documentation Style Guide - Documentation Best Practices](https://developers.google.com/style/documentation-best-practices) | Google Developers | Accessed 2026-02-15 |
| [Google Python Style Guide - Comments and Docstrings](https://google.github.io/styleguide/pyguide.html#38-comments-and-docstrings) | Google | Accessed 2026-02-15 |
| [PEP 257 - Docstring Conventions](https://peps.python.org/pep-0257/) | Python Software Foundation | 2001 (current) |
| [Docs as Code](https://www.writethedocs.org/guide/docs-as-code/) | Write the Docs | Accessed 2026-02-15 |
| [How to Write a Great AGENTS.md: Lessons from over 2,500 repositories](https://github.blog/ai-and-ml/github-copilot/how-to-write-a-great-agents-md-lessons-from-over-2500-repositories/) | GitHub Blog | 2025-11-03 |
| [Claude Code - Best Practices](https://docs.anthropic.com/en/docs/claude-code/common-workflows) | Anthropic | Accessed 2026-02-15 |
| [OWASP Top 10 for LLM Applications](https://owasp.org/www-project-top-10-for-large-language-model-applications/) | OWASP | 2025 |

## Practical Screening Rule

| Recommendation type | Adoption rule |
| --- | --- |
| Strong normative claim ("must/always") | Require at least one `T1` source |
| Emerging pattern (agent workflows) | Require one `T1/T2` + explicit "emerging" label |
| Tool-specific advice | Keep tool-scoped; do not generalize to all repos |
