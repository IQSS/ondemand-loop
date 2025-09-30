# Accessibility Guidelines

### Why Accessibility Matters
Accessibility ensures that people of all abilities can use OnDemand Loop effectively.
Accessible features often improve the overall usability of the product, reduce friction for everyone, and demonstrate respect for our diverse user base.  
Building with accessibility in mind also reduces long-term maintenance costs by avoiding retrofits.

### Current State of Accessibility
We have implemented several accessibility-conscious practices across the application, such as:

- Using semantic HTML where possible
- Applying ARIA labels to clarify the purpose of interactive components for assistive technologies
- Providing keyboard navigation for primary workflows so users are not blocked by pointer-only interactions
- Improving color contrast between text and backgrounds in core UI areas

These measures improve the experience, but the application is **not fully compliant with accessibility standards** (e.g., WCAG, Section 508).
While we strive to follow best practices, the current state should not be interpreted as certification or full accessibility compliance.

### Developer Responsibility
Every change to the application is an opportunity to improve accessibility. When developing new features or modifying existing ones, you should:

- Favor semantic HTML elements and landmarks to convey structure and meaning (avoid relying only on `<div>` and `<span>`)
- Ensure all interactive elements (buttons, links, inputs) are accessible via keyboard
- Provide clear and descriptive labels for inputs and form controls (visible label, `aria-label`, or equivalent association)
- Check that color contrast meets at least minimum accessibility requirements
- Apply ARIA attributes only where necessary and ensure they remain in sync with component state
- Test new functionality with keyboard navigation and screen reader tools when possible

### Limitations
At this stage, the application does not guarantee compliance with any accessibility standard.

Our goal is **incremental improvement**—making the application more accessible over time without giving a false impression of full accessibility.

### Quick Checklist for Developers
Before submitting your changes, review the following:

- [ ] Did I use semantic HTML tags and landmarks appropriately?
- [ ] Can I navigate my feature entirely with a keyboard?
- [ ] Do all inputs and interactive elements have clear, accessible labels or names?
- [ ] Is the color contrast sufficient for text and essential UI elements?
- [ ] Did I avoid unnecessary or incorrect ARIA attributes, and keep them in sync with UI state?
- [ ] Did I test the main user paths with keyboard navigation or assistive tools?


---

By keeping accessibility in mind with every change, we ensure steady progress toward a more inclusive application. Even small improvements add up over time.

!!! info "Testing Tools and Resources"

    **Accessibility Testing Tools:**

    - [WAVE Web Accessibility Evaluation Tool](https://wave.webaim.org/) — Browser extension for identifying accessibility issues
    - [axe DevTools](https://www.deque.com/axe/devtools/) — Browser extension for automated accessibility testing
    - [Lighthouse Accessibility Audit](https://developers.google.com/web/tools/lighthouse) — Built into Chrome DevTools
    - [NVDA Screen Reader](https://www.nvaccess.org/) — Free screen reader for testing (Windows)
    - [VoiceOver](https://www.apple.com/accessibility/vision/) — Built-in screen reader for macOS

    **Standards Reference:**

    - [WCAG 2.1 Guidelines](https://www.w3.org/TR/WCAG21/) — Web Content Accessibility Guidelines (A and AA levels)
    - [WebAIM Resources](https://webaim.org/) — Practical accessibility guidance and tutorials
