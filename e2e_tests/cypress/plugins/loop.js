const path = require('path');
const fs = require('fs');
const MESSAGE_INDENTATION = '      '

const getLoopEnvConfig = (envName) => {
  const envPath = path.resolve(__dirname, 'environments', `${envName}.json`)
  if (fs.existsSync(envPath)) {
    return JSON.parse(fs.readFileSync(envPath, 'utf8'));
  }
  return {};
};

/// <reference types="cypress" />
// ***********************************************************
// Loop project Cypress plugins configuration
//
// This file configures Cypress for the OnDemand Loop project
// with credential loading, environment setup, and custom tasks
// ***********************************************************

/**
 * @type {Cypress.PluginConfig}
 */
module.exports = (on, config) => {
  // Set up custom tasks for logging and other utilities
  on('task', {
    log(message) {
      console.log(MESSAGE_INDENTATION + message)
      return null
    }
  })

  // Load credentials from multiple sources
  const credentialsPath = path.resolve(process.cwd(), 'credentials.json')
  
  if (fs.existsSync(credentialsPath)) {
    const credentials = JSON.parse(fs.readFileSync(credentialsPath, 'utf8'));
    config.env['ood_username'] = credentials.username
    config.env['ood_password'] = credentials.password
    console.log(`Loop credentials loaded from: ${credentialsPath}`)
  }

  // Environment variables override file-based credentials
  if (process.env['LOOP_USERNAME']) {
    config.env['ood_username'] = process.env['LOOP_USERNAME']
    console.log('Overriding username with $LOOP_USERNAME')
  }
  
  if (process.env['LOOP_PASSWORD']) {
    config.env['ood_password'] = process.env['LOOP_PASSWORD']
    console.log('Overriding password with $LOOP_PASSWORD')
  }

  // Load environment-specific configuration from JSON files
  const loopEnvironment = process.env['LOOP_ENVIRONMENT'] || 'local'
  console.log(`Using Loop environment: ${loopEnvironment}`)
  const customEnv = getLoopEnvConfig(loopEnvironment)
  config.env = { ...config.env, ...customEnv }

  const baseUrl = config.env['baseUrl']
  if (!baseUrl) {
    console.error(`No baseUrl configured for environment: ${loopEnvironment}`)
    return Promise.reject(new Error(`Invalid Loop Environment: ${loopEnvironment}`))
  }

  config.baseUrl = baseUrl

  // Credential validation and logging
  const credentialsCheck = config.env['ood_username'] && config.env['ood_password'] ? 'provided' : 'not provided'
  console.log(`Loop credentials: ${credentialsCheck} - username: ${config.env['ood_username']}`)
  console.log(`Loop baseUrl: ${config.baseUrl}`)

  return config
}