# Accessibility

OnDemand Loop is built having in mind the [WCAG 2.1 A and AA accessibility criteria](https://www.w3.org/TR/WCAG21/).  
Some tools like [WAVE Evaluation Tool](https://wave.webaim.org/) and reviews assisted with AI have been used to keep the experience inclusive as much as possible.
Nonetheless, despite the efforts, there might be parts of the UI that are not fully compliant. 

---

### Continuous verification

Accessibility is an ongoing effort. New additions to the code should consider it:

- **Manual confirmation** – To keep pursuing accessibility on this application, it is desirable that developers ensure that their code follows the standards. PR reviewers should check accessibility as well.
- **Automated audits** – In the future an automatic evaluation tool can be added to the GitHub workflows so that accessibility is fulfilled on each PR. 

---
### WCAG 2.1 A and AA success criteria partial coverage

Below you can find the criteria taken into account to make the code accessible.

#### Perceivable (Guidelines 1.x)
 
- **1.1.1 Non-text Content (A)** – Decorative and functional icons are rendered through helpers that always provide `alt` text and `aria-label` metadata.
- **1.3.1 Info and Relationships (A)** – Layout uses semantic HTML landmarks (`<nav>`, `<main>`, `<header>`).
- **1.3.2 Meaningful Sequence (A)** – DOM order mirrors visual/logical order.
- **1.3.3 Sensory Characteristics (A)** – Instructions avoid color/position reliance.
- **1.3.5 Identify Input Purpose (AA)** – Inputs use semantic types and labels for autofill and accessibility APIs.
- **1.4.1 Use of Color (A)** – Color never conveys meaning alone; icons/labels supplement.
- **1.4.3 Contrast (Minimum) (AA)** – Text contrast ≥ 4.5:1.
- **1.4.4 Resize Text (AA)** – `rem` units allow zoom up to 200% without layout issues.
- **1.4.5 Images of Text (AA)** – No images of text; text rendered as HTML.
- **1.4.10 Reflow (AA)** – Content reflows without horizontal scroll at 400% zoom.
- **1.4.11 Non-text Contrast (AA)** – UI controls and focus indicators have sufficient contrast.
- **1.4.12 Text Spacing (AA)** – No overrides prevent user text-spacing adjustments.
- **1.4.13 Content on Hover or Focus (AA)** – Hover/focus content is dismissible, persistent, and hover-triggered only when intentional.

---

#### Operable (Guidelines 2.x)

- **2.1.1 Keyboard (A)** – All functionality is operable with keyboard.
- **2.1.2 No Keyboard Trap (A)** – No component traps focus; modals return focus correctly.
- **2.1.4 Character Key Shortcuts (A)** – No single-key shortcuts exist.
- **2.2.1 Timing Adjustable (A)** – No unexpected timeouts; jobs are user-controlled.
- **2.2.2 Pause, Stop, Hide (A)** – Auto-updating regions use polite live regions; users can ignore/dismiss them.
- **2.4.1 Bypass Blocks (A)** – `<main>` landmarks and skip links enable bypass of navigation.
- **2.4.2 Page Titled (A)** – Each page sets a unique, descriptive `<title>`.
- **2.4.3 Focus Order (A)** – Logical, predictable tab order follows DOM.
- **2.4.4 Link Purpose (In Context) (A)** – Links have descriptive text and ARIA labels.
- **2.4.5 Multiple Ways (AA)** – Content reachable via nav, search, breadcrumbs.
- **2.4.6 Headings and Labels (AA)** – Clear headings and form labels aid navigation.
- **2.4.7 Focus Visible (AA)** – Focus indicators are always visible.
- **2.5.1 Pointer Gestures (A)** – No multi-touch gestures required.
- **2.5.2 Pointer Cancellation (A)** – Activation on release, allowing cancellation.
- **2.5.3 Label in Name (A)** – Visible labels match accessible names.

---

#### Understandable (Guidelines 3.x)

- **3.1.1 Language of Page (A)** – `<html lang>` is set dynamically.
- **3.2.1 On Focus (A)** – Focus never triggers context changes.
- **3.2.2 On Input (A)** – Input changes don’t trigger unexpected navigation.
- **3.2.3 Consistent Navigation (AA)** – Navigation menus consistent across pages.
- **3.2.4 Consistent Identification (AA)** – Controls/icons consistent across contexts.
- **3.3.1 Error Identification (A)** – Errors identified next to form fields.
- **3.3.2 Labels or Instructions (A)** – Inputs paired with labels and instructions.
- **3.3.3 Error Suggestion (AA)** – Inline messages suggest corrective action.
- **3.3.4 Error Prevention (Legal, Financial, Data) (AA)** – Confirmations required before destructive actions.

---

#### Robust (Guidelines 4.x)

- **4.1.1 Parsing (A)** – HTML validated; Rails helpers ensure proper markup.
- **4.1.2 Name, Role, Value (A)** – Widgets expose correct ARIA attributes.
- **4.1.3 Status Messages (AA)** – `aria-live="polite"` regions announce status changes without shifting focus.
