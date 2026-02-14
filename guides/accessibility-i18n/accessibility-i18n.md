# Accessibility & Internationalization

Guidelines for building software that works for everyone, regardless of ability or language.

> **Scope**: Applies to user-facing applications—web, mobile, desktop. Agents must build accessible, localizable interfaces by default.

## Contents

| Section |
| --- |
| [Quick Reference](#quick-reference) |
| [Core Principles](#core-principles) |
| [Accessibility (a11y)](#accessibility-a11y) |
| [Internationalization (i18n)](#internationalization-i18n) |
| [Testing](#testing) |
| [Anti-Patterns](#anti-patterns) |

---

## Quick Reference

| Category | Guidance | Rationale |
| --- | --- | --- |
| **Always** | Use semantic HTML | Screen readers depend on it |
| **Always** | Externalize strings | Enables translation |
| **Always** | Provide alt text for images | Blind users need description |
| **Always** | Ensure keyboard navigation | Motor impairments |
| **Prefer** | Native elements over custom | Built-in a11y support |
| **Prefer** | Relative units over absolute | Respects user preferences |
| **Never** | Hardcode strings in UI code | Blocks localization |
| **Never** | Rely on color alone | Colorblind users excluded |
| **Never** | Disable zoom on mobile | Visually impaired need it |

---

## Core Principles

| Principle | Guideline | Rationale |
| --- | --- | --- |
| **Perceivable** | Content available to all senses | WCAG Principle 1 |
| **Operable** | All functions via keyboard/input | WCAG Principle 2 |
| **Understandable** | Clear, predictable interface | WCAG Principle 3 |
| **Robust** | Works with assistive tech | WCAG Principle 4 |
| **Localizable** | Designed for translation | Global reach |

---

## Accessibility (a11y)

### Semantic HTML

| Element | Use For | Avoid |
| --- | --- | --- |
| `<button>` | Clickable actions | `<div onclick>` |
| `<a>` | Navigation | `<span onclick>` |
| `<nav>` | Navigation menus | `<div class="nav">` |
| `<main>` | Primary content | `<div id="main">` |
| `<h1>`-`<h6>` | Heading hierarchy | `<div class="title">` |
| `<label>` | Form field labels | Placeholder only |

```html
<!-- Good: Semantic button -->
<button type="submit">Save Changes</button>

<!-- Bad: Div pretending to be button -->
<div class="button" onclick="save()">Save Changes</div>
```

### ARIA When Needed

| Pattern | ARIA Attribute | Purpose |
| --- | --- | --- |
| Dynamic content | `aria-live="polite"` | Announce updates |
| Custom controls | `role="button"` | Define purpose |
| Expanded state | `aria-expanded="true"` | Menu state |
| Error messages | `aria-describedby` | Link error to field |
| Required fields | `aria-required="true"` | Mark required |

```html
<!-- Good: Accessible dropdown -->
<button aria-expanded="false" aria-haspopup="menu">
  Options
</button>
<ul role="menu" hidden>
  <li role="menuitem">Edit</li>
  <li role="menuitem">Delete</li>
</ul>
```

### Color and Contrast

| Requirement | Minimum Ratio | Applies To |
| --- | --- | --- |
| Normal text | 4.5:1 | Body copy |
| Large text | 3:1 | 18pt+ or 14pt bold |
| UI components | 3:1 | Buttons, borders |

```css
/* Good: Sufficient contrast */
.button {
  background: #1a73e8;
  color: #ffffff; /* 4.6:1 ratio */
}

/* Bad: Low contrast */
.button {
  background: #cccccc;
  color: #999999; /* 1.5:1 ratio - fails */
}
```

### Keyboard Navigation

| Requirement | Implementation |
| --- | --- |
| Focus visible | `:focus` styling, never `outline: none` |
| Tab order | Logical flow, use `tabindex` sparingly |
| Skip links | "Skip to main content" at page top |
| Focus trapping | Modal dialogs trap focus until closed |

```css
/* Good: Clear focus indicator */
:focus {
  outline: 2px solid #1a73e8;
  outline-offset: 2px;
}

/* Bad: Removing focus entirely */
:focus {
  outline: none;
}
```

---

## Internationalization (i18n)

### String Externalization

```javascript
// Good: Externalized strings
import { t } from './i18n';

function WelcomeMessage({ user }) {
  return <h1>{t('welcome.greeting', { name: user.name })}</h1>;
}

// en.json
{
  "welcome.greeting": "Hello, {name}!"
}

// es.json
{
  "welcome.greeting": "¡Hola, {name}!"
}
```

```javascript
// Bad: Hardcoded strings
function WelcomeMessage({ user }) {
  return <h1>Hello, {user.name}!</h1>;
}
```

### Formatting Patterns

| Data Type | Use | Avoid |
| --- | --- | --- |
| Dates | `Intl.DateTimeFormat` | Manual formatting |
| Numbers | `Intl.NumberFormat` | String concatenation |
| Currency | `Intl.NumberFormat` | Symbol + number |
| Plurals | ICU/CLDR plural rules | If/else on count |

```javascript
// Good: Locale-aware formatting
const formatter = new Intl.DateTimeFormat(locale, {
  dateStyle: 'long'
});
return formatter.format(date);
// "February 2, 2024" (en-US)
// "2 de febrero de 2024" (es-ES)

// Bad: Hardcoded format
return `${month}/${day}/${year}`; // US-only format
```

### Text Considerations

| Issue | Solution |
| --- | --- |
| Text expansion | Allow 30-50% extra space |
| Text direction | Support RTL with `dir="rtl"` |
| Character encoding | UTF-8 everywhere |
| Concatenation | Use templates, not glued strings |

```javascript
// Bad: Concatenated strings (breaks in many languages)
const message = `There are ${count} items in your ${location}`;

// Good: Complete sentences with placeholders
const message = t('cart.summary', { count, location });
// "Your {location} contains {count} items" - translatable as unit
```

---

## Testing

### Automated Checks

| Tool | Checks | Integration |
| --- | --- | --- |
| axe-core | WCAG violations | CI, browser |
| Lighthouse | a11y audit | Chrome, CI |
| eslint-plugin-jsx-a11y | React a11y | ESLint |
| i18n linters | Missing translations | Build time |

```javascript
// Automated a11y test
import { axe, toHaveNoViolations } from 'jest-axe';

expect.extend(toHaveNoViolations);

test('form is accessible', async () => {
  const { container } = render(<LoginForm />);
  const results = await axe(container);
  expect(results).toHaveNoViolations();
});
```

### Manual Checks

| Check | Method |
| --- | --- |
| Keyboard-only navigation | Tab through entire page |
| Screen reader | Test with NVDA/VoiceOver/JAWS |
| Color blindness | Sim Daltonism, colorblind filters |
| Zoom | 200% zoom, verify no breakage |
| Translations | Human review of machine translations |

---

## Anti-Patterns

| Anti-Pattern | Problem | Fix |
| --- | --- | --- |
| **Non-semantic HTML** | Screen readers can't parse | Use semantic elements |
| **Color-only indicators** | Colorblind users miss info | Add icons or patterns |
| **Mouse-only interactions** | Keyboard users excluded | Add keyboard handlers |
| **No alt text** | Images invisible to blind | Always provide alt |
| **Hardcoded strings** | Can't translate | Externalize all strings |
| **Glued strings** | Grammar breaks across languages | Use complete phrases |
| **Date/number formats** | Wrong for locale | Use Intl APIs |
| **Fixed-width layouts** | Breaks with text expansion | Use flexible layouts |

---

## Red Flags

| Signal | Action | Rationale |
| --- | --- | --- |
| Images with no `alt` attribute or `alt=""` on informational images | Add descriptive alt text | Screen reader users get no information from untagged images |
| `outline: none` on focusable elements with no replacement | Provide a visible focus indicator | Keyboard users can't navigate without visible focus state |
| UI strings hardcoded directly in component code | Externalize to translation files | Hardcoded strings make localization impossible without code changes |
| Color used as the only indicator of state (e.g., red = error) | Add icons, text, or patterns alongside color | Colorblind users miss color-only indicators entirely |
| Date or currency formatted with string concatenation | Use `Intl.DateTimeFormat` / `Intl.NumberFormat` | Manual formatting breaks for non-US locales |

---

## See Also

- [Coding Guidelines](../coding-guidelines/coding-guidelines.md) – General code standards
- [Testing Strategy](../testing-strategy/testing-strategy.md) – Testing approaches
- [Error Handling](../error-handling/error-handling.md) – Accessible error messages
