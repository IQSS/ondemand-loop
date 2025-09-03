// ***********************************************************
// Stimulus Framework Support for Cypress Tests
//
// This file provides custom Cypress commands to handle timing issues
// with Stimulus controllers that need time to initialize after page load.
// 
// Commands:
// - waitClick: Adds a delay before clicking to ensure Stimulus controllers
//   are fully loaded and responsive. Waits up to 500ms from every page load.
//
// Why this was added:
// Rails 7 applications using Stimulus often have race conditions where
// DOM elements are clickable before their Stimulus controllers are ready.
// This leads to flaky tests where clicks don't trigger expected behavior.
// ***********************************************************

Cypress.on('window:load', () => {
    // page finished loading
    Cypress.env('pageLoadTimestampMs', Date.now());
});

// Wraps .click() and waits up to 500ms since the test started
Cypress.Commands.add('waitClick', { prevSubject: 'element' }, (subject, options = {}) => {
    const MAX_WAIT = 500;
    const start = Cypress.env('pageLoadTimestampMs') || Date.now();
    const elapsed = Date.now() - start;
    const remaining = Math.max(0, MAX_WAIT - elapsed);

    if (remaining > 0) {
        console.log(`waitClick: waiting ${remaining}ms before click`);
        return cy.wait(remaining, { log: false }).wrap(subject).click(options);
    }

    return cy.wrap(subject).click(options);
});
