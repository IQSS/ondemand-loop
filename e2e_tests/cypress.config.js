const { defineConfig } = require('cypress');

module.exports = defineConfig({
  e2e: {
    chromeWebSecurity: false,
    video: false,
    experimentalModifyObstructiveThirdPartyCode: true,
    defaultCommandTimeout: 5000,
    requestTimeout: 5000,
    responseTimeout: 10000,
    setupNodeEvents(on, config) {
      // Load Loop-specific plugins and configuration
      return require('./cypress/plugins/loop')(on, config)
    },
  },
});
