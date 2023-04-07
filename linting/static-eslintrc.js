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
    'ember',
    'ember-observer'
  ],
  env: {
    browser: true
  },
  rules: {
    'ember/no-jquery': 'error',
    'ember/no-observers': 'error',
    'ember/no-new-mixins': 'error',
    'ember/no-old-shims': 'error',
    'ember/no-classic-classes': 'error',
    'ember/no-classic-components': 'error',
    'ember/no-computed-properties-in-native-classes': 'error',
    'ember/no-get': 'error',
    'ember/no-get-with-default': 'error',
    'ember-observer/no-ember-components': 'error',
    'ember-observer/no-glimmer-components': 'error',
    'ember-observer/no-jquery-integration': 'error',
    'ember-observer/no-tracked': 'error',
    'ember-observer/has-maybe-embroider': 'error',
  },
};
