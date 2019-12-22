module.exports = {
  root: true,
  parser: 'babel-eslint',
  parserOptions: {
    ecmaVersion: 2018,
    sourceType: 'module',
    ecmaFeatures: {
      legacyDecorators: true
    }
  },
  plugins: [
    'ember'
  ],
  env: {
    browser: true
  },
  rules: {
    'ember/no-jquery': 'error',
    'ember/no-jquery-integration': 'error',
    'ember/no-observers': 'error'
  },
};
