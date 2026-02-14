# Human-AI Collaboration in Coding

A reference for deciding when and how to use AI assistance—knowing when to delegate, pair, or work independently for optimal results.

> **Scope**: These patterns help you make effective use of AI assistance while maintaining your skills and producing quality work. AI is a tool; knowing when to use it matters as much as how.

## Contents

| Section |
| --- |
| [Quick Reference](#quick-reference) |
| [Core Principles](#core-principles) |
| [The Delegation Spectrum](#the-delegation-spectrum) |
| [Task Suitability Matrix](#task-suitability-matrix) |
| [Knowing When to Switch](#knowing-when-to-switch) |
| [Pairing Patterns](#pairing-patterns) |
| [Handoff Patterns](#handoff-patterns) |
| [Complexity Thresholds](#complexity-thresholds) |
| [Diminishing Returns](#diminishing-returns) |
| [Skill Development Considerations](#skill-development-considerations) |
| [Team Considerations](#team-considerations) |
| [Decision Framework](#decision-framework) |
| [Anti-Patterns](#anti-patterns) |

---

## Quick Reference

### Strengths Comparison

| Capability | AI Excels | Humans Excel | Rationale |
| --- | --- | --- | --- |
| **Ambiguity** | Poor | **Excellent** | AI needs clear specs; humans handle fuzziness. |
| **Repetition** | **Excellent** | Poor | AI never gets bored; humans fatigue. |
| **Context** | Limited | **Deep** | Humans hold the full system mental model. |
| **Safety** | Poor | **Critical** | AI lacks accountability; humans own risk. |
| **Syntax** | **Excellent** | Variable | AI has infinite "cheat sheet" memory. |

### Decision Heuristic

> **Tip**: If you can precisely describe what you want in a prompt, AI can likely help. If you need to figure out what you want, do that part yourself first.

---

## Core Principles

| Principle | Rationale |
| --- | --- |
| **Fit to Task** | Use a hammer for nails, not screws. Don't force AI. |
| **Human Loop** | You are the pilot; AI is the autopilot. Monitor constantly. |
| **Fail Fast** | If AI struggles 3x, switch to manual. Don't spiral. |
| **Skill Maint** | Don't let your coding muscles atrophy; practice manually. |
| **Quality** | Fast garbage is still garbage. Verify output relentlessly. |

---

## The Delegation Spectrum

### Modes of Working

| Mode | Description | When to Use | Rationale |
| --- | --- | --- | --- |
| **Delegate** | AI does the work, you review | Clear, well-defined tasks | Maximizes speed; treats AI as an intern. |
| **Pair** | Interactive back-and-forth | Exploration, complex problems | Combines AI knowledge with human judgment. |
| **Consult** | Ask AI questions, you implement | Need info, prefer control | Keeps human in driver's seat for critical logic. |
| **Independent** | Work without AI | Novel problems, sensitive code | Prevents hallucination risks and skill atrophy. |

### Delegation Decision Flow

| Logic Step | Condition | Action | Rationale |
| --- | --- | --- | --- |
| **1. Clarity** | Is task well-defined? | **No**: Consult/Independent | AI hallucinates effectively on vague prompts. |
| **2. Type** | Is it boilerplate? | **Yes**: Delegate | AI is a pattern-matching machine. |
| **3. Risk** | Is it high risk/complexity? | **Yes**: Pair/Independent | Safety requires human accountability. |
| **4. Default** | (Fail-through) | **Action**: Delegate | If it's clear, safe, and new, let AI try. |

---

## Task Suitability Matrix

### High AI Suitability

| Task | Why AI Fits | Approach | Rationale |
| --- | --- | --- | --- |
| **Boilerplate** | Repetitive patterns | Delegate | Zero creativity required; high accuracy. |
| **CRUD** | Standard architecture | Delegate | Established patterns are training data gold. |
| **Conversions** | Mechanical logic | Delegate | Low risk of "creative" logic errors. |
| **Tests** | Pattern-based | Delegate | AI covers edge cases humans miss due to fatigue. |
| **Explaining** | Summarization strength | Consult | AI reads faster than humans. |
| **Syntax** | Knowledge retrieval | Consult | Faster than Googling/StackOverflow. |
| **Regex** | Pattern matching | Delegate | Write-only languages are AI's forte. |
| **Transforms** | Input->Output clear | Delegate | Easy to verify the result. |

### Medium AI Suitability

| Task | Considerations | Approach | Rationale |
| --- | --- | --- | --- |
| **Bug fix** | Complexity varies | **Varies** | Syntactic bugs = Delegate; Logic bugs = Pair. |
| **Refactor** | Scope risk | **Varies** | Rename = Delegate; Architect = Pair. |
| **Feature** | Spec clarity | **Varies** | Clear spec = Delegate; Fuzzy spec = Pair. |
| **Optimize** | Profiling needed | **Pair** | AI guesses bottlenecks; humans measure them. |
| **Integrate** | Multi-system context | **Pair** | AI lacks full environmental context. |

### Low AI Suitability

| Task | Why AI Struggles | Approach | Rationale |
| --- | --- | --- | --- |
| **Design** | Context & Trade-offs | **Independent** | AI optimizes local maximums, not global architecture. |
| **Security** | Threat Modeling | **Independent** | AI training data contains vulnerable patterns. |
| **Novelty** | Creativity required | **Independent** | AI cannot predict what it hasn't seen. |
| **Ambiguity** | Needs clarification | **Clarify** | "Do what I mean" is not a reliable prompt strategy. |
| **Heisenbug** | Observation needed | **Manual** | Debugging requires state inspection AI can't do. |
| **Incident** | Time sensitivity | **Manual** | During outages, speed and certainty > experiments. |

---

## Knowing When to Switch

### Signs AI Assistance Is Working

| Signal | Meaning | Rationale |
| --- | --- | --- | --- |
| **First Try** | Output is close | Validates prompt clarity and model capability. |
| **Tweaks** | Minor edits needed | Interactive loop is tightening; good signal. |
| **Understanding** | You grasp the logic | Maintainability is preserved. |
| **Speed** | Faster than manual | ROI is positive. |

### Signs to Switch Approach

| Signal | Meaning | Action | Rationale |
| --- | --- | --- | --- |
| **3+ Fails** | Task mismatch | **Manual** | Definition of insanity: doing same thing expecting diff results. |
| **Loops** | AI confusion | **Gather Info** | AI is guessing; feed it more context. |
| **Confusion** | Unmaintainable | **Simplify** | If you can't read it, you can't own it. |
| **Explanation** | High overhead | **Manual** | "Faster to do it myself" is a valid metric. |
| **Regression** | Limit hit | **Workaround** | Model context window or logic cap reached. |

### When to Abandon AI for a Task

| Attempt | Action | Rationale |
| --- | --- | --- |
| **0** | Draft Prompt (Clear constraints) | Start with best effort input. |
| **1** | Review Output -> Refine Context | Give AI a chance to correct based on feedback. |
| **2** | Try Different Approach | Reboot the strategy (e.g., smaller chunk). |
| **3** | **Abandon -> Manual** | Stop bleeding time; 4th try rarely works. |

---

## Pairing Patterns

### Interactive Problem-Solving

1. **Human**: Define problem, constraints.
2. **AI**: Suggests approach.
3. **Human**: Evaluates, asks questions or requests changes.
4. **AI**: Refines based on feedback.
5. **Human**: Implements or asks for implementation.
6. **AI**: Writes code.
7. **Human**: Reviews, tests, integrates.

### Effective Pairing Prompts

**Starting exploration**:

```text
I need to [goal]. The constraints are [constraints].
What approaches would you consider? Don't write code yet.
```

**Narrowing down**:

```text
I like approach 2. What are the trade-offs?
What edge cases should I consider?
```

**Implementation**:

```text
Let's go with approach 2. Here's the context:
[relevant code]

Please implement [specific part].
```

**Review**:

```text
Here's my implementation:
[code]

Does this handle [specific concern]? What am I missing?
```

---

## Handoff Patterns

### Human → AI Handoff

| Situation | How to Hand Off | Rationale |
| --- | --- | --- |
| **Clear** | Describe task + constraints | Perfect for "intern" mode. |
| **Context** | Share code + requirements | Anchors AI to existing patterns. |
| **Explore** | Goal -> Options -> Impl | Prevents premature optimization. |

**Good handoff**:

```text
Add pagination to this API endpoint:
[endpoint code]

Requirements:
- Limit and offset query params
- Default 20 items, max 100
- Return total count in response
- Follow the pattern in /api/products

Don't change the response format for existing fields.
```

### AI → Human Handoff

When AI work needs human completion:

| Scenario | What Human Does | Rationale |
| --- | --- | --- |
| **Code Gen** | Review, test, refine | Trust but verify. |
| **Limitation** | Take over execution | AI is the booster; you are the orbiter. |
| **Judgment** | Make the call | AI can't own consequences. |
| **Security** | Implement critical path | Too risky to delegate completely. |

---

## Complexity Thresholds

### When Complexity Increases Risk

| Complexity Level | AI Approach | Human Involvement | Rationale |
| --- | --- | --- | --- |
| **Low** | Delegate fully | Review output | Low stakes, easy to verify. |
| **Medium** | Pair/Delegate pieces | Guide and verify | Logic nuances need human steering. |
| **High** | Consult | Human drives decisions | Too many interdependent variables for LLMs. |
| **Very High** | Research only | Don't delegate | Hallucination risk at max; need expert control. |

### Complexity Indicators

| Indicator | Suggests | Rationale |
| --- | --- | --- | --- |
| **"It depends"** | Judgment needed | AI struggles with subjective context. |
| **Politics** | Multiple stakeholders | AI can't read the room or org chart. |
| **Long-term** | Architectural impact | AI optimizes for next token, not next year. |
| **Security** | Compliance risk | Liability requires human signature. |
| **Ambiguity** | Clarification needed | Garbage in, garbage out. |

---

## Diminishing Returns

### Signs of Diminishing Returns

| Signal | Meaning | Rationale |
| --- | --- | --- |
| **Prompt++** | More prompting than coding | Inefficient; tool fighting. |
| **Review++** | Reviewing > Writing | Cognitive load is higher than generation gain. |
| **Yo-Yo** | Many cycles | Task is likely ill-defined or out of bounds. |
| **Rework** | Heavy editing | Starting from scratch might have been cleaner. |

### Time Investment Guide

| Time Spent | Action | Rationale |
| --- | --- | --- |
| **< 2 min** | Good use | High velocity gain. |
| **2-5 min** | Acceptable | Break-even point for complex tasks. |
| **5-10 min** | Evaluate | Sunk cost fallacy risk. |
| **> 10 min** | **Manual** | You could have written it twice by now. |

### When Manual Is Actually Faster

| Scenario | Why Manual Wins | Rationale |
| --- | --- | --- |
| **Deep Knowledge** | Typing > Prompting | Muscle memory flows faster than chat. |
| **Context Switch** | Overhead | Staying in flow state beats context shifting. |
| **Fuzzy** | Exploration needed | Thinking through typing is a valid process. |
| **Fail Loop** | AI blocked | Don't fight the tool; just code. |

---

## Skill Development Considerations

### Maintaining Core Skills

| Skill | Risk | Mitigation | Rationale |
| --- | --- | --- | --- |
| **Algorithms** | Medium | Manual practice | Don't lose ability to problem solve. |
| **Debugging** | Medium | Debug first | Observational skills atrophy quickly. |
| **Reading** | Low | Review AI | Reviewing IS reading; skill is exercised. |
| **Quality** | Medium | Reject bad code | Develop taste by critiquing. |
| **Design** | High | Design manually | AI mimics, it doesn't invent architectures. |

### Learning New Skills

| Approach | When to Use | Rationale |
| --- | --- | --- |
| **Explain** | Learning concepts | Low friction way to get unblocked. |
| **Try/Correct** | Building muscle memory | "Do it yourself" reinforces retention. |
| **Reverse** | Pattern recognition | Seeing good code builds mental models. |
| **Pair** | Unfamiliar domain | Interactive guide shortens learning curve. |

### Deliberate Practice

Set aside time for unassisted coding to maintain skills:

| Activity | Purpose | Rationale |
| --- | --- | --- |
| **Manual Algo** | Problem solving | Keep the "logical core" sharp. |
| **Manual Feat** | Implementation | Retain syntax mastery. |
| **Solo Debug** | Observation | Don't outsource the "detective" work. |
| **Code Review** | Quality sense | Critique allows you to judge AI later. |

---

## Team Considerations

### When Working with Others

| Situation | AI Approach | Rationale |
| --- | --- | --- |
| **Review** | Note AI assistance | Reviewers need to know risk profile. |
| **Pairing** | Discuss usage first | Don't alienate your human partner. |
| **Mentoring** | Show manual process | Juniors need to learn the "how", not just get results. |
| **Sharing** | Explain the "why" | Don't just paste code; teach the concept. |

### Team Guidelines

```markdown
## AI Usage Guidelines

### Transparency
- Note significant AI assistance in PR descriptions
- Share effective prompts that worked well

### Quality
- All AI code needs the same review as human code
- Security-sensitive code needs manual review regardless

### Learning
- New team members should understand code before using AI for it
- Rotate who does manual vs AI-assisted work for skill maintenance
```

---

## Decision Framework

### Quick Decision Tree

| Step | Question | Action | Rationale |
| --- | --- | --- | --- |
| 1. | Can I clearly describe what I want? | **No** → Figure that out first (manually or with AI brainstorming) | AI needs clear input; ambiguity leads to poor output. |
| 2. | Is this security-critical or novel? | **Yes** → Work independently; use AI only for review | High-risk areas require human expertise and accountability. |
| 3. | Is this boilerplate or well-defined? | **Yes** → Delegate to AI | AI excels at repetitive tasks and known patterns. |
| 4. | Am I learning this for the first time? | **Yes** → Pair with AI for understanding | AI can explain concepts and provide examples, accelerating learning. |
| 5. | Default | Try AI, switch if not working after 2-3 attempts | Leverage AI's speed; if it struggles, human intervention is more efficient. |

### Mode Selection Matrix

| Task Clarity | Risk Level | Recommended Mode | Rationale |
| --- | --- | --- | --- |
| **High** | **Low** | Delegate | Ideal conditions for automation. |
| **High** | **High** | Pair or Independent | Risk requires human oversight. |
| **Low** | **Low** | Pair to clarify | Use AI to explore/clarify. |
| **Low** | **High** | Independent first | Define the problem before solving it. |

---

## Anti-Patterns

| Anti-Pattern | Problem | Fix | Rationale |
| --- | --- | --- | --- |
| **AI for everything** | Skill atrophy | Match tool | Right tool for the job. |
| **Never using AI** | Inefficiency | Try it | Don't be a Luddite; be a skeptic. |
| **Blind Acceptance** | Security/Qual | Review | Trust but verify. |
| **Quitting Early** | Missed gain | Refine prompt | Prompt engineering is a skill. |
| **Sunk Cost** | Wasted time | Switch | Know when to fold 'em. |
| **Hidden AI** | Trust issues | Note in PR | Transparency builds confidence. |
| **No Learning** | Unmaintainable | Understand | You can't maintain what you don't know. |

---

## Red Flags

| Signal | Action | Rationale |
| --- | --- | --- |
| Accepting AI output without reading it | Read every line before committing | Blind acceptance ships bugs and security holes |
| Using AI for security-critical code without manual review | Add manual expert review | AI training data contains vulnerable patterns |
| Spending 10+ minutes prompting for a 5-minute task | Do it manually | The tool is slowing you down, not helping |
| Unable to explain AI-generated code in your PR | Understand it first or rewrite | You can't maintain what you don't understand |
| Team member skills degrading from over-delegation | Schedule manual practice time | Skill atrophy makes the team dependent on AI |

---

## See Also

- [Prompting Patterns](../prompting-patterns/prompting-patterns.md) – Effective prompts for AI
- [Git Workflows with AI](../git-workflows-ai/git-workflows-ai.md) – Attribution and PR practices
