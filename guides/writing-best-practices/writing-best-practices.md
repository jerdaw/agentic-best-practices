# Writing Best Practices

Guidelines for writing best practices documentation—a meta-guide ensuring this collection remains useful for both AI agents and humans.

> **Scope**: These guidelines apply to writing any best practices, coding standards, or developer guidelines documentation. The goal is content that guides effectively without hindering.

## Contents

| Section |
| --- |
| [Quick Reference](#quick-reference) |
| [Core Principles](#core-principles) |
| [Prescriptive vs Permissive Balance](#prescriptive-vs-permissive-balance) |
| [Structure for Scannability](#structure-for-scannability) |
| [Writing for Dual Audiences](#writing-for-dual-audiences) |
| [Maintainability](#maintainability) |
| [Examples and Illustrations](#examples-and-illustrations) |
| [Common Pitfalls](#common-pitfalls) |
| [Anti-Patterns](#anti-patterns) |
| [Self-Assessment Checklist](#self-assessment-checklist) |

---

## Quick Reference

| Category | Guidance | Rationale |
| --- | --- | --- |
| **Always** | Explain why, not just what | Guides judgment, not just actions |
| **Always** | Use tables and examples over prose | Maximizes scannability and density |
| **Always** | Keep sections self-contained | Improves modularity and AI retrieval |
| **Always** | Prioritize most impactful guidance first | Content survives truncation |
| **Always** | Match audience context constraints | Ensures practical applicability |
| **Never** | Over-prescribe implementation details | Prevents rapid document staleness |
| **Never** | Write walls of text without structure | Reduces cognitive load and token waste |
| **Never** | Create rules without rationale | Rules are ignored without "why" |
| **Never** | Include hypothetical edge cases | Keeps focus on 80% actionable cases |
| **Never** | Let documentation drift from practice | Maintains trust and accuracy |

**Priority order**:

| Rank | Metric | Outcome |
| --- | --- | --- |
| 1 | Actionability | Reader can use this immediately |
| 2 | Scannability | Key info found in <30 seconds |
| 3 | Accuracy | Reflects current actual practice |
| 4 | Maintainability | Can be updated without heroic effort |
| 5 | Completeness | Nice to have, but secondary |

---

## Core Principles

| Principle | Guideline | Rationale |
| --- | --- | --- |
| **Principles over rules** | Guide judgment, not just actions | Readers can adapt to edge cases |
| **Scannable over readable** | Prioritize tables and lists | Faster retrieval for humans and AI |
| **Concise over comprehensive** | focus on essential guidance | Reduces noise and token usage |
| **Current over historical** | Delete outdated rather than archive | Prevents confusion and drift |
| **Flexible over rigid** | Guide decisions, don't mandate | Accommodates varied tech stacks |
| **Tested over theoretical** | Document proven patterns only | Ensures guidance actually works |

---

## Prescriptive vs Permissive Balance

### The Spectrum

| Too Prescriptive | Balanced | Too Permissive |
|------------------|----------|----------------|
| "Always use exactly 3 retries with 1000ms delay" | "Use retries with exponential backoff; 3 attempts is typical" | "Consider retrying failed operations" |
| "Format all dates as YYYY-MM-DD" | "Use ISO 8601 dates; match existing codebase format" | "Use a consistent date format" |
| "Functions must be under 30 lines" | "Prefer functions under 30 lines; prioritize readability" | "Keep functions small" |

### Finding the Right Balance

| Situation | Lean Prescriptive | Lean Permissive |
|-----------|-------------------|-----------------|
| Security requirements | ✓ | |
| Team has inconsistent practices | ✓ | |
| Multiple valid approaches exist | | ✓ |
| Context varies significantly | | ✓ |
| Onboarding new developers | ✓ | |
| Experienced team, clear patterns | | ✓ |

### Language Patterns

| Prescriptive | Balanced | Permissive |
|--------------|----------|------------|
| "Must", "Always", "Never" | "Prefer", "When possible", "Typically" | "Consider", "May", "Could" |
| "Do X" | "Prefer X because Y" | "X is one option" |
| Imperative commands | Guidance with rationale | Open suggestions |

**Use prescriptive language for**:

- Security-critical requirements
- Breaking conventions that cause real harm
- Non-negotiable standards

**Use permissive language for**:

- Style preferences
- Approaches that depend on context
- Emerging patterns not yet proven

---

## Structure for Scannability

### Document Anatomy

Every best practices document should include:

| Section | Purpose | Required? | Effect |
| --- | --- | --- | --- |
| **Title + intro** | What this covers, who it's for | Yes | Sets context immediately |
| **Contents table** | Links to major sections | Yes | Enables direct jump to relevant content |
| **Quick Reference** | Always/Never/Priority at a glance | Yes | Enables <30s navigation |
| **Core Principles** | 5-7 foundational ideas | Yes | Establishes the mental model |
| **Detailed sections** | Deep guidance with examples | Yes | Provides actionable implementation |
| **Anti-Patterns** | What to avoid and why | Yes | Prevents common recurring errors |
| **See Also** | Related guides | Recommended | Promotes deeper exploration |

### Optimize for AI Context Windows

AI agents consume these documents within limited context windows. Structure accordingly:

| Technique | Why It Helps |
| --------- | ------------ |
| Front-load key information | Important content survives truncation |
| Self-contained sections | Each section works independently |
| Tables over prose | Higher information density |
| Concrete examples | Clearer than abstract descriptions |
| Avoid redundancy | More signal per token |

### Contents Tables

Every guide should include a Contents table immediately after the title/intro, linking to major sections:

```markdown
## Contents

| Section |
| --- |
| [Quick Reference](#quick-reference) |
| [Core Principles](#core-principles) |
| [Anti-Patterns](#anti-patterns) |
```

| Guideline | Rationale |
| --------- | --------- |
| Place immediately after intro | First thing AI scans after title |
| Link only to H2/H3 sections | Avoids overwhelming depth |
| Use section names as link text | Self-documenting, no extra prose |
| Optional note column | Only when section name isn't self-explanatory |

### Table Design

Tables are the primary communication tool. Design them well:

| Element | Guideline | Rationale |
|---------|-----------|-----------|
| Column headers | Clear, parallel structure | Enhances scannability |
| Row count | 5-10 rows ideal; split if larger | Prevents cognitive overload |
| Cell content | Brief phrases, not sentences | Increases information density |
| Alignment | Left-align text, right-align numbers | Improves readability |

**Good table**:

| When | Do | Why |
|------|-----|-----|
| Bug fix | Include issue reference | Traceability |
| Security patch | Link CVE | Auditability |

**Avoid**:

| Situations where you might want to consider referencing issues | Recommended practices for those situations | Detailed rationale explaining the reasoning |
|---|---|---|
| When fixing bugs that have been reported... | You should include a reference... | Because this helps with traceability... |

---

## Writing for Dual Audiences

These documents serve both AI agents and human developers.

### AI Agent Considerations

| Consideration | Technique | Rationale |
| --- | --- | --- |
| Token efficiency | Dense formatting, minimize filler | Maximizes info in context window |
| Unambiguous instruction | Explicit statements, avoid pronouns | Prevents hallucination/misinterpretation |
| Actionable guidance | Concrete right/wrong patterns | Enables reliable code generation |
| Structured extraction | Consistent heading hierarchy | Simplifies parsing and indexing |

### Human Reader Considerations

| Consideration | Technique | Rationale |
| --- | --- | --- |
| Quick lookup | Clear headings, scannable tables | Reduces time-to-implementation |
| Understanding "why" | Rationale alongside rules | Builds trust and allows judgment |
| Pattern recognition | Multiple varying examples | Improves conceptual mental model |
| Memorability | Core principles that stick | Ensures long-term adoption |

### Balancing Both

```
// GOOD: Works for both audiences
**Prefer early returns for guard clauses**
- Reduces nesting
- Makes happy path obvious
- Matches common pattern in this codebase

// LESS GOOD: Too verbose, wastes tokens
When you are writing functions that need to validate inputs or check 
preconditions before executing the main logic, you should consider using 
early return statements rather than deeply nested if-else structures...
```

---

## Maintainability

### Living Documentation

| Practice | Implementation | Rationale |
|----------|----------------|-----------|
| Version implicitly | Use present tense, avoid dates in content | Prevents immediate staleness |
| Remove, don't deprecate | Delete outdated sections rather than marking them | Reduces cognitive noise |
| Review triggers | Update when underlying practices change | Ensures accuracy |
| Single source | Don't duplicate guidance across documents | Avoids conflicting rules |

### Avoiding Documentation Drift

| Signal | Action | Rationale |
|--------|--------|-----------|
| Team consistently ignores a guideline | Re-evaluate if guideline is valuable | Rule likely doesn't fit context |
| New patterns emerge in codebase | Document or explain why current pattern preferred | Maintains consistency |
| Tooling enforces the rule | Reduce documentation (tooling is the source of truth) | Eliminates redundancy |
| Frequent exceptions to a rule | Guideline may be too prescriptive | Allows necessary flexibility |

### What to Keep, What to Cut

| Keep | Cut |
|------|-----|
| Actively used patterns | Deprecated approaches |
| Hard-won lessons | Obvious advice |
| Context-setting principles | Exhaustive edge cases |
| Common mistake prevention | Rarely-encountered scenarios |
| Examples that clarify | Redundant examples |

---

## Examples and Illustrations

### Effective Examples

| Quality | Guideline | Rationale |
|---------|-----------|-----------|
| **Minimal** | Shows only what's necessary to illustrate the point | Optimizes for token limits |
| **Realistic** | Uses plausible names, scenarios, data | Promotes correct application |
| **Paired** | Shows both good and bad patterns | Clarifies by contrast |
| **Annotated** | Includes brief comments explaining key aspects | Guides attention |

### Example Patterns

**Good pattern: Paired comparison with brief annotation**

```
// Good: Descriptive, reveals intent
const remainingAttempts = 3

// Avoid: Unclear purpose
const r = 3
```

**Good pattern: Table of options**

| Approach | When to Use | Example |
|----------|-------------|---------|
| Early return | Guard clauses | `if (!user) return null` |
| Nested if | Complex branching logic | `if (a) { if (b) { ... } }` |

### Anti-patterns in Examples

| Problem | Better Approach | Why |
|---------|-----------------|-----|
| Examples too long | Extract to essential lines | Reduces noise |
| Contrived scenarios | Use realistic code | Avoids credibility loss |
| Missing context | Include enough to understand | Ensures clarity |
| Only "good" examples | Show what to avoid too | Prevents ambiguity |

---

## Common Pitfalls

### Scope Creep

| Symptom | Fix | Rationale |
|---------|-----|-----------|
| Document covers too many topics | Split into focused documents | Improves discoverability |
| Every edge case documented | Cover 80% case; let judgment handle rest | Prevents information overload |
| Historical context dominates | Move history to ADRs or changelog | Keeps focus on current state |

### Staleness

| Symptom | Fix | Rationale |
|---------|-----|-----------|
| Guidelines contradict current code | Update guidelines or code | Maintains trust |
| References to deprecated tools | Remove or update references | Prevents errors |
| Examples use old patterns | Refresh examples | Encourages modern practices |

### Over-Engineering Guidelines

| Symptom | Fix | Rationale |
|---------|-----|-----------|
| Process for every situation | Focus on decisions that matter | Saves time |
| Multi-level categorization | Flatten where possible | Simpler navigation |
| Conditional rules with many branches | Simplify to principles | Easier to remember |

---

## Anti-Patterns

| Anti-Pattern | Problem | Fix |
|--------------|---------|-----|
| **Wall of text** | No one reads it; wastes context | Tables, lists, code examples |
| **Rules without rationale** | Followed blindly or ignored | Explain "why" for each rule |
| **Completeness obsession** | Covers edge cases at expense of clarity | Essential guidance only |
| **Implementation mandates** | "Always use library X" becomes outdated | Describe approach, suggest tools |
| **Duplicate guidance** | Conflicting sources of truth | Single authoritative source |
| **Stale content** | Misleads readers | Regular review, remove outdated |
| **Abstract principles only** | Not actionable | Concrete examples required |
| **Rigid rules everywhere** | Hinders appropriate judgment | Prescriptive for safety, permissive for style |

---

## Self-Assessment Checklist

When reviewing a best practices document:

- [ ] Can a reader find what they need in 30 seconds?
- [ ] Does each rule explain "why"?
- [ ] Are examples minimal and realistic?
- [ ] Would this survive context window truncation?
- [ ] Is guidance prescriptive where it matters, permissive elsewhere?
- [ ] Does this reflect current actual practice?
- [ ] Can this be maintained without heroic effort?

---

## See Also

- [Documentation Guidelines](../documentation-guidelines/documentation-guidelines.md) – General documentation practices
- [Context Management](../context-management/context-management.md) – Managing AI context effectively
- [AGENTS.md Guidelines](../agents-md/agents-md-guidelines.md) – Creating effective AI agent configuration
