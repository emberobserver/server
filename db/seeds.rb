Category.destroy_all

categories = [
  {name: 'Authentication', description: 'Addons for auth'},
  {name: 'Components', description: 'Addons that provide a component'},
  {name: 'Styles', description: 'Addons that provide styles, css frameworks, preprocessors'},
  {name: 'Testing', description: 'Addons related to testing'},
  {name: 'Build tools', description: 'Addons related to preprocessing, broccoli plugins and dependencies of ember-cli'},
  {name: 'Data', description: 'Addons related to ember-data or alternatives to ember-data'},
  {name: 'Library wrappers', description: 'Addons that wrap third party libraries, jQuery plugins and the like'},
  {name: 'Miscellaneous', description: 'The addons that don\'t fit into other categories'}
]

categories.each do |c|
  Category.create(c)
end
