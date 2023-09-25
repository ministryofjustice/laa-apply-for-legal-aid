const config = {
  verbose: true,
  testEnvironment: 'jest-environment-jsdom-global',
  transformIgnorePatterns: [
    'node_modules/(?!axios/.*)'
  ],
  moduleDirectories: [
    'node_modules'
  ],
  modulePathIgnorePatterns: [
    'vendor'
  ],
  setupFilesAfterEnv: [
    './jest-setup.js'
  ]
}

module.exports = config
