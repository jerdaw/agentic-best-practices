# Git Workflows with AI Assistants

A reference for version control practices when using AI coding assistants—commits, PRs, attribution, and review workflows.

> **Scope**: These patterns apply to any git-based workflow with AI assistance. Adapt conventions to your team's standards while maintaining the core principles.

## Contents

| Section |
| --- |
| [Quick Reference](#quick-reference) |
| [Core Principles](#core-principles) |
| [Commit Message Conventions](#commit-message-conventions) |
| [Attribution Practices](#attribution-practices) |
| [Branch Naming](#branch-naming) |
| [Pull Request Practices](#pull-request-practices) |
| [Squashing and History](#squashing-and-history) |
| [Review Requirements](#review-requirements) |
| [Workflow Patterns](#workflow-patterns) |
| [Handling AI Mistakes in Git](#handling-ai-mistakes-in-git) |
| [CI/CD Integration](#cicd-integration) |
| [Feature Flags for AI Behavior Changes](#feature-flags-for-ai-behavior-changes) |
| [Anti-Patterns](#anti-patterns) |
| [Team Guidelines Template](#team-guidelines-template) |

---

## Quick Reference

### Conventions Summary

| Category | Guideline | Rationale |
| --- | --- | --- |
| **Commits** | **Atomic** | One logical change ensures reversibility and clarity. |
| **Commits** | **Human Author** | Humans are accountable; AI is a tool, not a legal entity. |
| **PRs** | **Transparent** | Reviewers need to know if code was machine-generated. |
| **PRs** | **Verified** | "I tested it" > "It looks right". Prove it works. |
| **Review** | **Mandatory** | AI writes bugs confidently; humans must catch them. |

### Review Standards

| Type | Requirement | Rationale |
| --- | --- | --- |
| **Generality** | **Line-by-Line** | Do not rubber-stamp; read every line AI wrote. |
| **Security** | **Deep Dive** | AI ignores OWASP; you must not. |
| **Tests** | **Passing** | Code is not done until it proves itself. |

---

## Core Principles

| Principle | Rationale |
| --- | --- |
| **Accountability** | You push it, you own it. "The AI did it" is not an excuse. |
| **Transparency** | Hiding AI use breeds distrust; transparency enables proper review. |
| **Atomicity** | Huge AI dumps are unreviewable; break them down. |
| **Scrutiny** | Machine code requires *more* review than human code, not less. |
| **Clean History** | Squash the "asking AI" churn; keep the "solution" commit. |

---

## Commit Message Conventions

### Message Structure

```text
<type>: <concise description>

[Optional body explaining why, not what]

[Optional footer with references]
```

### Commit Types

| Type | When to Use | Rationale |
| --- | --- | --- |
| `feat` | New functionality | SemVer MAJOR/MINOR trigger. |
| `fix` | Bug fixes | SemVer PATCH trigger. |
| `refactor` | Code changes (no behavior) | Maintenance debt repayment (no SemVer impact). |
| `test` | Adding/modifying tests | Quality assurance (no production code change). |
| `docs` | Documentation changes | Knowledge sharing (no code change). |
| `chore` | Maintenance (deps, config) | Project structure hygiene (no user impact). |

### Good vs Bad Messages

| Quality | Subject | Body | Rationale |
| --- | --- | --- | --- |
| **Good** | `feat: add retry logic to API` | "Handle 5xx w/ exp backoff" | Explains *why* (resilience) and *what* (backoff). |
| **Bad** | `update api` | "ai helped" | "Update" means nothing; AI attribution belongs in footer/PR. |
| **Bad** | `fix bug` | (empty) | Which bug? Fixed how? Searchable history broken. |
| **Bad** | `use while loop` | (empty) | Implementation detail in subject; should be in diff or body. |

### AI-Assisted Commit Practices

| Scenario | Recommendation | Rationale |
| --- | --- | --- |
| **Refinement** | **Commit** | You reviewed and edited it; you own it. |
| **Fix** | **Commit** | You verified the fix works; the insight was yours. |
| **Iteration** | **Squash** | "Try 1", "Try 2" logs are noise; keep the solution. |
| **Dead End** | **Discard** | Failed experiments belong in `/tmp`, not `master`. |

---

## Attribution Practices

### Who is the Author?

The human who reviews and accepts responsibility is the author.

```bash
# The human is always the author
git commit -m "feat: add user validation"

# AI assistance can be noted in message body or PR, not author
```

### What NOT to Do

```bash
# WRONG: AI as author
git commit --author="Claude <claude@anthropic.com>" -m "..."

# WRONG: AI as co-author in commit
git commit -m "feat: add feature

Co-Authored-By: AI Assistant <ai@example.com>"
```

### Transparency Without Co-Authorship

| Location | Visibility | Usage | Rationale |
| --- | --- | --- | --- |
| **PR Desc** | **High** | "AI drafted initial logic" | Best for reviewers context & risk assessment. |
| **Msg Body** | **Medium** | "Refactoring aided by AI" | Permanent record in git log for future auditors. |
| **Msg Footer** | **Low** | `AI-Tools: Claude-3.5` | Machine-readable metadata for analysis. |

```markdown
## PR Description

Adds retry logic to API client.

### Notes
- Initial implementation drafted with AI assistance
- Manually verified retry behavior with integration tests
- Added edge case handling for timeout scenarios
```

---

## Branch Naming

### Convention

```
<type>/<short-description>
```

### Examples

| Branch | Purpose | Rationale |
| --- | --- | --- |
| `feat/auth` | New Feature | Groups all auth work; easy to grep/filter. |
| `fix/login` | Bug Fix | specific; indicates a patch is coming. |
| `refactor/api` | Cleanup | Signals high line-count, low behavior-change. |
| `chore/deps` | Maintenance | Low-risk dependency bumps (often auto-merged). |

### AI-Specific Considerations

| Situation | Branch Strategy | Rationale |
| --- | --- | --- |
| **Quick Fix** | **Feature Branch** | Simple, linear history for small changes. |
| **Prototyping** | **Exp Branch** | Isolate noise; squash clean result to main later. |
| **Refactor** | **Multi-Branch** | Break massive AI rewrites into reviewable chunks. |

---

## Pull Request Practices

### PR Size Guidelines

| Size | Lines | Review Approach | Rationale |
| --- | --- | --- | --- |
| **Small** | < 100 | Single reviewer | Quick verify; low cognitive load. |
| **Medium** | 100-300 | Standard review | Requires understanding context; normal flow. |
| **Large** | 300-500 | Consider splitting | Risk of "LGTM" fatigue; hard to rollback. |
| **Huge** | > 500 | **Split it** | Unreviewable by humans; bugs *will* slip through. |

AI can generate large changes quickly. Resist the urge to submit them all at once.

### PR Description Template

```markdown
## Summary

[One paragraph: what this PR does and why]

## Changes

- [Bullet points of key changes]
- [Focus on what's important for reviewers]

## Testing

- [ ] Unit tests added/updated
- [ ] Integration tests pass
- [ ] Manually tested [specific scenarios]

## Review Notes

[Areas needing extra attention, questions for reviewers]

### AI Assistance

[Optional: Note if AI was used significantly]
- AI helped with: [specific parts]
- I verified: [what you checked manually]
```

### Example PR Description

```markdown
## Summary

Adds exponential backoff retry logic to the API client for handling
transient server errors. This improves reliability when the backend
experiences momentary issues.

## Changes

- Added `withRetry` wrapper function in `src/utils/retry.ts`
- Updated `ApiClient.fetch` to use retry for 5xx errors
- Added configuration for max retries and backoff multiplier

## Testing

- [x] Unit tests for retry logic
- [x] Integration tests pass
- [x] Manually tested by killing backend during requests

## Review Notes

The retry delay calculation on line 45 might look unusual—it uses
jitter to prevent thundering herd. Please verify this is correct.

### AI Assistance

Initial retry implementation drafted with AI. I added:
- Jitter logic (AI version had fixed delays)
- Timeout handling (AI missed this)
- Test cases for concurrent retries
```

---

## Squashing and History

### When to Squash

| Scenario | Action | Rationale |
| --- | --- | --- |
| **Iterations** | **Squash** | "Fix 1", "Fix 2" clutter history; end state matters. |
| **Dead End** | **Drop** | Failed paths are distraction; keep history clean. |
| **Distinct** | **Keep** | Independent fixes deserve independent reverts. |
| **WIP** | **Squash** | "Save work" commits are not semantic history. |

### How to Squash

```bash
# Interactive rebase to squash last N commits
git rebase -i HEAD~N

# In editor, change 'pick' to 'squash' for commits to combine
# First commit stays 'pick', rest become 'squash' or 's'
```

### Preserving Meaningful History

**Good history**:
```text
abc1234 feat: add user validation
def5678 feat: add validation error messages
ghi9012 test: add validation edge case tests
```

**Bad history** (AI iteration noise):
```text
abc1234 add validation
def5678 fix validation
ghi9012 fix validation again
jkl3456 actually fix validation
mno7890 final fix
```

---

## Review Requirements

### All AI Code

| Check | Required | Rationale |
| --- | --- | --- |
| **Compiles** | **Yes** | AI acts as a stochastic parrot; verify basic syntax. |
| **Tests** | **Yes** | If it's not tested, it doesn't work. |
| **Read Every Line** | **Yes** | You are the author. You own the CVEs. |
| **Reviewer** | **Yes** | Four eyes are better than two (machine eyes don't count). |

### Security-Sensitive Code

| Check | Required | Rationale |
| --- | --- | --- |
| **Standard** | **Yes** | Baseline quality checks (lint, typecheck). |
| **Security** | **Yes** | AI can hallucinate vulnerabilities; check OWASP. |
| **Scenarios** | **Yes** | Test abuse cases, not just happy paths. |
| **Team Review** | **Recommended** | Specialized knowledge beats general review. |

### High-Risk Changes

For authentication, authorization, payments, or data handling:

```markdown
### High-Risk Checklist

| Check | Rationale |
| --- | --- |
| **Input Validation** | AI often assumes happy-path inputs; prevent injections. |
| **No Injections** | Verify SQL/XSS safety explicitly; AI is notoriously bad here. |
| **Error Handling** | Ensure no stack traces or secrets bubble up to UI. |
| **AuthZ** | Did AI add the check? Verify permissions logic manually. |
| **Logging** | Ensure passwords/tokens are redacted (AI might log `req.body`). |
| **Security Tests** | Add specific tests for the vulnerabilities AI might miss. |
```

---

## Workflow Patterns

### Solo Development with AI

```text
1. Create feature branch
2. Use AI to draft implementation
3. Review and refine code
4. Run tests
5. Commit with clear message
6. Self-review the diff
7. Merge (or PR for documentation)
```

### Team Development with AI

```text
1. Create feature branch
2. Use AI to draft implementation
3. Review and refine code
4. Run tests locally
5. Commit with clear message
6. Push and create PR
7. Note AI usage in PR description
8. Team review
9. Address feedback
10. Squash if needed, merge
```

### Large Changes with AI

```text
1. Plan the change (what files, what order)
2. Create tracking issue
3. Break into multiple PRs:
   - PR 1: Foundation/types
   - PR 2: Core implementation
   - PR 3: Integration
   - PR 4: Tests and polish
4. Each PR is reviewable size (< 300 lines)
5. Merge sequentially, validate between merges
```

---

## Handling AI Mistakes in Git

### Fixing Bad Commits

```bash
# Amend last commit (hasn't been pushed)
git commit --amend

# Fix earlier commit (hasn't been pushed)
git rebase -i HEAD~N
# Mark commit as 'edit', make changes, continue

# Revert pushed commit
git revert <commit-hash>
```

### Recovering from AI Errors

| Situation | Solution | Rationale |
| --- | --- | --- |
| **Wrong Branch** | **Cherry-pick** | Move the good bits; reset the bad state. |
| **Breaking** | **Revert** | `git revert` is safer than manual undo; preserves history. |
| **Secrets** | **Rotate** | Reverting logic doesn't hide the secret; rotate keys immediately. |
| **Spam** | **Interactive** | `git rebase -i` to clean up the "chat log" style commits. |

### Secrets in History

If AI accidentally committed secrets:

```bash
# 1. Immediately rotate the exposed secrets

# 2. Remove from history
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch path/to/.env" \
  --prune-empty --tag-name-filter cat -- --all

# 3. Force push (coordinate with team)
git push origin --force --all

# 4. Consider the secrets permanently compromised
```

---

## CI/CD Integration

### Pre-Commit Checks

```yaml
# .pre-commit-config.yaml
repos:
  - repo: local
    hooks:
      - id: no-secrets
        name: Check for secrets
        entry: detect-secrets-hook
        language: system

      - id: lint
        name: Lint code
        entry: npm run lint
        language: system

      - id: typecheck
        name: Type check
        entry: npm run typecheck
        language: system
```

### PR Checks

Required before merge:
- All tests pass
- Linting passes
- Type checking passes
- Security scan passes
- Code coverage meets threshold
- At least one approval

---

## Feature Flags for AI Behavior Changes

When AI-generated code introduces behavior changes, use feature flags for safe rollout.

### When to Use Feature Flags

| Change Type | Flag? | Rationale |
| --- | --- | --- |
| **Bug fix** | **No** | Immediate benefit; fix it and ship it. |
| **Behavior** | **Yes** | Risks breaking workflows; allow quick disable. |
| **Feature** | **Yes** | Standard practice for incremental rollout. |
| **Optimization** | **Optional** | If logic changes significantly, flag it for safety. |
| **Breaking** | **Yes** | Essential for controlled migration timing. |

### Feature Flag Pattern

```typescript
// Feature flag for AI-generated behavior change
if (featureFlags.isEnabled('new-validation-logic')) {
  // New AI-generated validation
  return validateWithNewRules(input)
} else {
  // Original validation
  return validateLegacy(input)
}
```

### Rollout Strategy

```text
1. Merge with flag disabled (default: false)
2. Enable for internal testing
3. Enable for subset of users (canary)
4. Monitor for issues
5. Gradually increase rollout
6. Remove flag once stable
```

### Flag Naming Convention

| Pattern | Example | Rationale |
| --- | --- | --- |
| **New Feature** | `enable-ai-suggestions` | Toggles entire functionality groups. |
| **Behavior** | `use-v2-validation` | Switches specific logic paths (A/B safe). |
| **Migration** | `migrate-async-proc` | Temporary flag for infrastructure shifts. |

### Cleanup Requirement

Track flags in PR description:

```markdown
## Feature Flags

- Added: `new-payment-validation` (default: off)
- Cleanup target: 2 weeks after full rollout
```

---

## Anti-Patterns

| Anti-Pattern | Problem | Rationale |
| --- | --- | --- |
| **Blind Commit** | **Bugs** | You are committing code you don't understand. Dangerous. |
| **AI Author** | **Accountability** | Humans go to jail/get fired; AIs do not. You are the author. |
| **Mega PR** | **Unreviewable** | 1000 lines of AI code is a black box. Split it up. |
| **Vague Msg** | **Useless History** | "Update" tells future you nothing. Be descriptive. |
| **Hidden AI** | **Distrust** | Teams need to know risk profiles. Be honest. |
| **Exploration** | **Noise** | Don't merge your scratchpad. Clean it up first. |
| **No Tests** | **Risk** | AI code is not perfect. Test it like a junior dev wrote it. |
| **No Flags** | **Rigidity** | AI logic changes can be subtle; flags allow instant rollback. |

---

## Team Guidelines Template

Add to your AGENTS.md or CONTRIBUTING.md:

```markdown
## Git Conventions for AI-Assisted Development

### Commits
- Human is always the author
- Clear messages describing what and why
- Atomic commits (one logical change each)
- Squash AI exploration before merging

### Pull Requests
- Note significant AI assistance in PR description
- Include what you manually verified
- Flag areas needing extra review attention
- Keep PRs under 300 lines when possible

### Review
- All AI-generated code requires human review
- Security-sensitive code needs additional scrutiny
- All tests must pass before merge

### Attribution
- Don't list AI as author or co-author
- Note AI assistance in PR description if significant
- Human takes full responsibility for committed code
```

---

## See Also

- [Human-AI Collaboration](../human-ai-collaboration/human-ai-collaboration.md) – When to use AI vs work manually
