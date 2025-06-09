# Contributing to OnDemand Loop
Thank you for your interest in contributing! This document outlines the guidelines for contributing to this project. We use GitHub Issues to track all contributions including feature requests, bugs, documentation improvements, translations, and code.

## 📌 Ideas and Feature Requests
If you have an idea to improve the app or want to suggest a new feature:

- First, check [existing issues](../../issues) to avoid duplicates.
- If your idea is new, [open an issue](../../issues/new?template=feature_request.md) and clearly describe:
    - What the feature should do
    - Why it’s useful
    - Any relevant context or examples
- Keep the scope focused and be open to feedback.

## 🐞 Bug Reports
To report a bug:

- Search existing [bug reports](../../issues?q=is%3Aissue+label%3Abug) to see if it's already known.
- If not, [open a new issue](../../issues/new?template=bug_report.md) and include:
    - A clear description of the problem
    - Steps to reproduce
    - Expected vs. actual behavior
    - Environment (OS, browser if relevant, Ruby version, etc.)
    - Any logs or error messages, if available

Well-documented bug reports help us resolve issues faster.

## 📚 Documentation
We welcome improvements to any part of the documentation:

- Typos, grammar, structure, or clarity fixes are all valuable.
- If you're unsure where to place new documentation, suggest it in an issue first.
- Keep style consistent and prefer concise, direct language.
- Use Markdown formatting.

## 🌍 Translations
If you'd like to help translate the app:

- Check for existing translation issues or create one for your language.
- We use [insert your i18n approach if applicable, e.g. Rails I18n YAML files].
- Follow the existing format and structure of locale files.
- Include your locale code in the file name (e.g., `fr.yml` for French).

Please test your translations in context where possible.

## 🧑‍💻 Code
Before submitting code changes:

1. **Open an issue** to discuss the problem or feature.
2. **Fork the repository** and create a new branch with a meaningful name.
3. Follow the style conventions of the project:
    - Ruby 3.1.5+, Rails 7.2.2.1
    - Bootstrap 5.3, Stimulus
    - Use single quotes in Ruby whenever possible
4. Add **tests using Minitest with Mocha**.
5. Run tests locally and ensure they all pass:
   ```bash
   make test
    ```
## ✅ Pull Requests
After completing your changes, open a Pull Request (PR):
- Link it to the relevant issue.
- Describe what your change does and why.
- Request a review once tests pass and you're ready.