- **Balance code clarity and commentary:** Favor **self-documenting code** (clear naming, simple logic, tests) as first resort; use comments/docs only for *non-obvious* context or rationale. In practice, engineers recommend minimal comments except to explain **why** a tricky section exists or to note important invariants. Over-commenting (“what the code does”) should be avoided.

- **Docs-as-code discipline:** Maintain docs in version control, build them automatically in CI, and update them alongside code changes. Google’s style guide notes *“change your documentation in the same CL as the code change”* to keep docs fresh. Routinely prune or delete stale docs (dead docs “misinform” engineers) rather than letting them accumulate.

- **Docstrings for API contracts:** Write docstrings (Python `"""…"""`, JSDoc, JavaDoc, etc.) for every **public** function, method, class or module. These should describe what the interface does (inputs, outputs, exceptions), not restate code logic. Inline comments can elaborate on *why* something happens. As Google notes, any behavior documented should have a test verifying it.

- **Formal docs for higher-level guidance:** Use external docs (e.g. README, MkDocs/Docusaurus sites, architecture diagrams, ADRs, onboarding guides) to cover **project scope, conventions, and workflows**. README.md (and `docs/`) should orient new developers and (now) AI agents to the repo structure, build/test commands, style rules, etc. Write focused guides (e.g. runbooks, tutorials) for complex features, business rules, or deployment steps. Tailor the format to audience: user manuals and tutorials for external users; design docs/ADRs for engineers; runbooks for ops teams.

- **AI/agent-specific instructions:** In AI-assisted workflows, include **repo-level instruction files** (e.g. `AGENTS.md`, `CLAUDE.md`) that explain conventions to the AI. These should cover project layout, “golden commands” (install, test, lint), coding standards, and guardrails. For example, 3L3C’s blog recommends sections like **Project Map**, **Golden Commands**, **PR Rules**, and **Danger Zones** in `AGENTS.md`. Similarly, Claude’s docs advise generating a `CLAUDE.md` (via `/init`) and keeping it concise and up-to-date.

- **Tests and verification:** Equip agents (and humans) with tests or example outputs so they can *verify* changes. Both Google’s docs guide and agentic best-practices stress that documented behavior should be backed by automated tests. Including unit tests, integration tests or even shell commands (“run `npm test`”) in docs/CI helps prevent both code and docs from drifting.

- **Documentation rot prevention:** Bake doc checks into CI (e.g. link checkers, `mkdocs build`, docstring linters). Add PR checklist items (e.g. “Update docs / add doc comment”) and require documentation review just like code review. Regularly audit docs (doc sprints or fixits) and assign owners who enforce updates. Emphasize concise, task-focused docs (focus on *why* and *what*, not *how*) to minimize drift.

- **Context-specific balance:** Adjust the mix by context. **Short-lived prototypes/solo projects** can get away with minimal docs (lean README + code comments as needed). **Teams & long-lived systems** need richer docs: onboarding guides, style guides, design records (ADRs), and thorough API docs. **Libraries/APIs** especially must have clean public docstrings and external API reference (endpoints, parameters) for consumers. **Regulated/safety-critical projects** require comprehensive documentation (detailed design docs, traceability records, tested runbooks) and rigorous processes (doc audits, versioning, strict review) to satisfy audits. Conversely, **casual/internal apps** can skip some formality but should still document core interfaces and invariants.

- **What *not* to document:** Never include secrets (passwords, keys, tokens) or sensitive internal data in docs. Instead, reference a secrets vault or environment variables. Likewise, do **not** publicly document internal threat models or proprietary algorithms beyond necessary descriptions. Classify documentation by sensitivity (Public/Internal/Confidential) and enforce access controls where needed. Runbooks and ops procedures should avoid embedding static credentials—provide steps and vault references instead.

- **Failure modes:** The biggest risk is **stale or incorrect docs**. A misaligned README or docstring can mislead both developers and LLMs. Avoid “documentation debt” by keeping docs small and precise. Another failure mode is **incoherent agent guidance**: overly long or outdated `AGENTS.md`/`CLAUDE.md` can confuse the model. Keep AI prompts and instructions minimal, reviewed, and backed by tests so that agents aren’t flying blind.

- **Default recommendation:** Adopt a docs-as-code culture with versioned, living documentation. Use code comments sparingly (for intent) and docstrings for every public interface (per language style). Supplement with a concise README, CONTRIBUTING guide, and an **AI instruction file** (`AGENTS.md` or `CLAUDE.md`). Enforce doc updates in PRs and automate doc builds/tests. Deviate from this baseline only with clear criteria: e.g. skip heavy docs in a throwaway prototype, but add them when project longevity or team size justifies it.

- **Biggest failure modes:** Outdated docs, and “comment rot” are chief concerns. They arise when docs aren’t updated with code changes (violating “docs+code in one CL”). Also, insufficient doc enforcement means LLMs may guess project conventions, leading to merge conflicts or bugs. Guard against this by making docs a first-class CI artifact.

## Decision Matrix: Where to Document What

| **Content / Knowledge**                | **Location**                              | **Audience**             | **Change Frequency** | **Verifiable**           | **Coupling to Code** |
|----------------------------------------|-------------------------------------------|--------------------------|----------------------|-------------------------|----------------------|
| **Public API behavior**                | Docstring / Typedocs + external API docs | Library users / integrators (incl. AI) | Rare (API) / evolving | High (unit tests) | Medium (code-dep.) |
| **Module/class purpose (overview)**    | Docstring header + README snippet | Developers (incl. AI)   | Rare                | Moderate (tests/examples) | Low (description)    |
| **Complex algorithm logic or invariants** | Inline code comments (why) + ADR if architectural | Devs/AI    | Rare to occasional  | Low (hard to test)       | High (implementation) |
| **Business rules / constraints**       | Formal docs (ADRs, design docs) or code comments | Devs/SMEs/AI  | Rare (business change) | High (can write tests)    | Variable            |
| **Code usage examples**                | External docs/tutorials + docstrings     | End-users/Devs/AI        | Occasional         | High (example tests)    | Medium (ref code)    |
| **Onboarding/how-to (setup, build)**   | README, CONTRIBUTING, MkDocs site        | New devs / Ops / AI      | Rare (setup evolves slowly) | Medium (can smoke-test env) | Low              |
| **Coding style & conventions**         | CONTRIBUTING.md / AGENTS.md [8]           | Team / AI               | Rare               | Low (style lint tools)   | N/A                 |
| **Tech stack / repo layout**           | README/CONTRIBUTING + `AGENTS.md` map | Team / AI | Rare | N/A (inert facts) | N/A |
| **Common commands (install/test/lint)** | CONTRIBUTING.md / `AGENTS.md` (golden commands) | Devs/AI | Rare (toolchain stable) | High (CI build) | N/A |
| **ADRs (architectural decisions)**     | `docs/adr/` (or `doc/ADR.md`)            | Devs/Stakeholders       | Rare (once, if needed) | High (justification by design) | Low (doc separate) |
| **Issue/PR references**                | Inline code comments (link to issue)     | Devs    | Occasional (if needed) | Moderate (trace via VCS) | Low                |
| **Versioning/release info**           | Changelog, Release notes                 | Users/Devs             | Every release        | N/A                     | Low                |
| **Incidents/operation runbooks**       | External docs or protected wiki (runbooks) | Ops/SRE/AI assistants  | Low                | Moderate (DR drills)    | Low                 |

- **Stability:** Document in stable (external) docs if things change rarely or have broad impact (e.g. architecture, API contracts). Use inline comments for details that may change with code (logic justification).
- **Audience:** Public-facing info (APIs, user guidance) lives in formal docs + docstrings. Internal “implementation detail” lives closer to code (comments, unit tests).
- **Verifiability:** Anything claimed in docs (especially API behavior or business rules) should be backed by tests or examples.
- **Coupling:** Code-specific notes (side-effects, hacks) are best as comments. Higher-level decisions (why this approach was chosen) go in ADRs or design docs.

## Recommended Baseline Documentation Stack

A **starter kit** for a new AI-assisted repo should include:
- **README.md:** High-level project overview. Include quickstart steps (clone, dependencies, build/test commands), repository structure hints (e.g. “`src/` has logic, `docs/` has docs, `web/` is UI”). Summarize project goal and major components. Briefly mention where to find more info (e.g. `docs/`).
- **CONTRIBUTING.md:** Onboarding guide. Cover coding standards (lint/format commands), testing commands, branch/PR workflow, and any repo-specific tooling. List required checks (e.g. “run `npm test`” or “`cargo test`”) and style rules. This also can include guidance for AI agents (e.g. test commands).
- **AGENTS.md (or CLAUDE.md/GEMINI.md):** A brief agent instructions file at repo root. Sections may include:
  - *Project Map:* “Key directories: `api/`, `ui/`, etc.”.
  - *Golden Commands:* “Install: `pip install -r requirements.txt`; Test: `pytest`; Lint: `flake8`”.
  - *Coding Style:* “Follow PEP8 and Google Python docstring style (see CONTRIBUTING).”
  - *PR Rules:* Checklist like “add tests for bug fixes; update CHANGELOG”.
  - *Danger Zones:* “Do not change migration scripts without review” or similar warnings.
  These guide the AI’s behavior in context.
- **docs/** directory (if the project demands): Host formal documentation (MkDocs/Sphinx/Docusaurus). For example:
  - `docs/index.md`: Landing page with overview.
  - `docs/architecture.md` or `docs/overview.md`: System design and high-level diagrams.
  - `docs/onboarding.md`: Developer setup and onboarding exercises.
  - `docs/api/`: Generated API reference (from docstrings via Sphinx, TypeDoc, etc).
  - `docs/design/`: ADRs or RFCs explaining major decisions.
- **ADRs/** or **design_docs/**: Place long-lived decision records (Architecture Decision Records). Each ADR (e.g. `adr-001-use-cqrs.md`) details a choice, alternatives, and reason. Tools like [adr-tools] can help maintain these.
- **Docstring convention:** Establish one style (Google-style, NumPy-style, etc) via references. For Python, mention PEP257 or Google style guides in CONTRIBUTING. Include a note in CONTRIBUTING that all public functions/classes require docstrings.
- **Documentation CI:** A pipeline (GitHub Actions/GitLab CI) that builds the docs site and lints docsyntax (links, markdown style). Enforce "build docs" passing and broken-link checks on PRs.
- **Testing/Verification:** Ensure code examples in docs or READMEs are tested (e.g. with doctest or unit tests). This prevents code-blocks from rotting.
- **Linking:** In comments or markdown, link to issues/PRs and ADRs when explaining rationale. Use consistent URLs (or relative paths in repo). For example: `# TODO (see Issue #123 for details)`.
- **Ownership:** Assign doc “owners” (e.g. via CODEOWNERS or team convention) responsible for keeping docs up-to-date as features change.

## Commenting & Docstring Guidelines

- **Code Comments (//, #):** Use only for *clarification*. Mandatory when code does something non-intuitive or implements a non-obvious requirement. Focus on *why* the code exists, or note important side-effects/invariants. Example:
  ```python
  # Use a deque to achieve O(1) pops from left, to limit memory spike
  window = collections.deque(maxlen=N)
  ```

* **What to comment:** Explain workarounds, performance choices, or reference external constraints (e.g. “// must do X due to bug in library Y”). Also mark **TODO** and **FIXME** with specific context (“# TODO: handle X when migrating to Python3; see issue #456”).

* **What *not* to comment:** Do *not* restate code (avoid “i++ increments i”). Don’t comment obvious logic or language syntax. Never annotate internal implementation; that should be refactored or expressed through clearer code instead.

* **Docstrings ("""...""" or /**...*/):** Required for every **public-facing** API element. They should have at least:

  * A one-line summary of *purpose/behavior*.
  * A description of parameters (names and types) and return value (and exceptions/errors raised).
  * *Optional:* usage examples, context notes, or references to related functions.
  * Follow language conventions (PEP257, Google or Numpy style for Python; JSDoc for JS/TS; Rustdoc for Rust).
  * **Content:** Docstrings describe *what* the function/class does and its contract. Do *not* detail algorithmic “how” except if it affects usage. If some internal detail *must* be known (for performance or legacy reasons), mention it briefly.
  * **Example (Python):**

    ```python
    def compute_score(data: List[int]) -> float:
        """
        Compute the weighted score of a data series.

        Args:
            data: List of integer measurements.
        Returns:
            Weighted average as a float.
        Raises:
            ValueError: if `data` is empty.
        """
        ...
    ```
  * Include types and exceptions (if language supports). For TypeScript/JSDoc, annotate types similarly. Demonstrate examples especially for complex APIs.

* **Formatting:** Keep docstrings/ comments concise (wrap ~72–100 chars). Use imperative tone (“Compute the score” instead of “Computes…”). Check style with linters (e.g. pylint/flake8 docstring checkers, Doxygen tools).

* **“Why” over “What”:** As 67Bricks recommends, embed in comments the reasoning behind decisions. If an algorithm has a subtle step (e.g. half-open interval choice), comment *why* that step is needed. This aids both humans and LLMs in understanding intent.

* **AI-friendly patterns:** Avoid slang or culturally specific references in comments or examples. Use clear, neutral language. Include references or docs in comments when linking to external specs or requirements.

## Agentic/AI-Specific Practices

* **AGENTS.md/CLAUDE.md:** Create a top-level `AGENTS.md` file (or `CLAUDE.md` if using Anthropic’s Claude) with concise instructions for AI. Include sections for:

  * **Project map:** Brief directory overview (“`/api` = backend, `/web` = frontend”).
  * **Commands:** Key one-liners: build, test, lint, format commands (the “golden commands”).
  * **Coding standards:** Summarize style (tabs vs spaces, naming conventions, doc guidelines).
  * **PR Checklist:** Agent-goals (e.g. “ensure tests, update docs”).
  * **Forbidden zones:** Warnings (“Do not modify migration scripts without approval.”).
  * Keep it focused: as Claude’s docs warn, *every* line should serve a purpose – prune anything non-essential.

* **Agent inputs/outputs:** When using AI (Copilot, Codex, Claude Code, etc.), embed test cases or expected outputs in prompts so the agent can self-verify. For example, an AI instruction might include “After changes, run `pytest` and ensure tests pass. Attach test results.”. This yields more reliable patches.

* **Repository map & specs:** Maintain a doc (or diagram) of the overall system architecture (e.g. in `docs/architecture.md`). Tools like **Agent SOPs** (AWS Strands) use these as background knowledge. AI agents can read a summary of codebase structure to orient their decisions.

* **Decision logs:** Require the agent to keep a record of its “thinking.” For example, prompt: “After each change, write a line in `fyi.md` explaining what you did and why.” This is an **Automated Decision Log (ADL)**. It helps humans audit AI-generated changes and assists future onboarding. (See *Addy Osmani*’s recommendation for an `ai_decisions.log` file with bullet notes.)

* **Prompt templates:** Store canonical prompt formats (for bug fixing, refactoring, etc.) as text files or comments (but without sensitive content). These templates shouldn’t contain private chain-of-thought, just instructions or examples. For instance, a `prompts/bugfix.md` might outline a typical prompt structure.

* **“Safe mode” instructions:** If an AI is deployed in a workspace, define boundaries (e.g. “Don’t push changes to `main` without review”). Such guardrails belong in `AGENTS.md` or the agent instructions of your platform (GitHub Copilot allows repository instructions).

* **Test-driven tasks:** Encourage agentic development by defining tasks that end in verifiable artifacts (fixed bug + test, new feature + spec and tests, updated docs + smoke tests). Initially use small, well-scoped tasks to build trust (e.g. “Write one test for function X” or “Fix this failing unit test”).

* **Versioning AI guidance:** Treat `AGENTS.md` and prompt files as code – put them under version control and review them like code. These files “compound in value” over time, so team contributions and reviews matter.

## Anti-Rot Mechanisms

* **CI/CD checks:** Automate documentation validation. Examples:

  * **Build docs:** CI step to compile site (e.g. `mkdocs build`) and fail on broken Markdown or link errors.
  * **Doc linter:** Spell-check or style-check (e.g. codespell, Vale for prose).
  * **Docstring lint:** Tools like `pydocstyle` or ESLint JSDoc rules enforce format.
  * **Doctest/example tests:** If docs contain code samples, use tools (Sphinx `doctest`, reST examples) to run them in CI, catching outdated snippets.
  * **Broken link scan:** A link-checker for markdown, to detect outdated references.
* **PR Review Checklist:** Include a “Documentation” section in PR templates. Items such as “I updated relevant docs/README” or “Docstrings updated for changed APIs”. This social force keeps docs aligned.
* **Ownership & schedule:** Assign doc ownership (e.g. rotate among team, or designate a tech writer). Plan periodic documentation sprints or “fix-its” to tackle accumulated stale docs.
* **Executable docs:** Where feasible, make docs executable. For instance, tutorials can be Dockerized or have scripts. This blurs docs and tests, ensuring at least the environment is validated.
* **Docs-as-code tools:** Use version tagging or semver for docs releases (David Nevin’s approach). Link each published doc version to code version.
* **Monitoring & metrics:** Optionally track doc coverage (e.g. percentage of functions with docstrings) and issue tickets for gaps. Spot surges in “docs questions” via chat channels as early warning (DocuWriter warns of support tickets as red flags).

## Templates (Examples)

> **AGENTS.md (Repository Instructions)**
>
> ```
> # AGENTS Instructions
>
> ## Project Map
> - `/src/`: Main backend logic. Public API endpoints in `controllers/`.
> - `/web/`: Front-end React app.
> - `/scripts/`: Utility scripts (data migrations, etc.).
>
> ## Golden Commands
> - **Setup:** `python3 -m venv venv && source venv/bin/activate && pip install -r requirements.txt`
> - **Tests:** `pytest --maxfail=1 --disable-warnings -q`
> - **Lint:** `flake8 src/`
>
> ## PR Rules
> - Add a unit test for every bug fix or new feature.
> - Update README or docs for any public API change.
> - “Minor” formatting PRs still require passing CI (tests + lint).
>
> ## Danger Zones
> - Do **not** modify `schema/migrations/` files directly (use Alembic commands).
> - This repo uses Python 3.10; avoid introducing syntax from later versions.
> ```
>
> *Cited from 3L3C blog: AGENTS.md with project map, golden commands, PR rules, danger zones.*

> **ADR Template (`docs/adr/001-sample.md`):**
>
> ```
> # ADR 001: [Short Title]
> Date: YYYY-MM-DD
> **Status:** [Proposed | Accepted | Deprecated]
>
> ## Context and Problem Statement
> [Describe the context and why a decision is needed.]
>
> ## Decision Drivers
> - [Driver 1 (e.g. performance)]
> - [Driver 2 (e.g. ease of use)]
>
> ## Considered Options
> 1. **Option A:** [Brief description of option A]. Pros/cons.
> 2. **Option B:** [Same for option B].
>
> ## Decision Outcome
> Chosen option: **Option X**. Rationale: [why this was chosen].
>
> ## Consequences
> - Positive: [benefits of choice]
> - Negative: [trade-offs or risks]
> ```
>
> *Based on canonical ADR structure (inspired by Google and Michael Nygard).*

> **Python Module Docstring:**
>
> ````python
> """
> This module provides utilities for data transformation.
>
> Functions:
> - `normalize(data)`: Scale numeric data to [0,1].
> - `transform(record)`: Apply feature engineering steps.
>
> Example:
>     >>> normalize([0, 5, 10])
>     [0.0, 0.5, 1.0]
> """
>
> import numpy as np
>
> def normalize(data: List[float]) -> List[float]:
>     """
>     Normalize a list of numbers to the range [0, 1].
>
>     Args:
>         data: List of floats.
>     Returns:
>         New list with values scaled to [0,1].
>     Raises:
>         ValueError: If `data` is empty.
>     """
>     ```
> *Shows a concise module docstring with summary, function list, and example, and a function docstring with Args/Returns/Errors.*
> ````

> **Inline Comment Example:**
>
> ```python
> # Use reversed list because API expects last-in-first-out behavior.
> stack.append(item)
> ```
>
> *Emphasizes **why** we append to stack, not **what** append does (StackOverflow advice).*

> **PR Template (snippet):**
>
> ```
> ### Documentation
> - [ ] Changes include documentation updates (docstrings, README, or ADR as needed).
> - [ ] Any new public APIs are documented in the code or external docs.
> - [ ] If sensitive data is involved, documentation is appropriately secured (no secrets).
> ```
>
> *E.g. an item prompting the reviewer to verify docs were updated.*

Each element of this stack is justified by best practices: versioned docs (docs-as-code), targeted inline comments, and agent-specific guides. By following these conventions, teams can leverage AI assistants effectively while keeping the codebase maintainable.

**Sources:** Google Style/Docs Guides; Python PEP8 Recommendations; community experts (Jeff Atwood); developer blogs and books; AI tooling docs (Copilot, Claude); and technical best-practice posts.

```
