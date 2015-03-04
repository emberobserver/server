Category.destroy_all

categories = [
  {name: 'Authentication', description: 'Addons for auth', position: 1},
  {name: 'Styles', description: 'Addons that provide styles, css frameworks, preprocessors', position: 2},
  {name: 'Testing', description: 'Addons related to testing', position: 3},
  {name: 'Components', description: 'Addons that provide a component', position: 4},
  {name: 'Build tools', description: 'Addons related to preprocessing, broccoli plugins and dependencies of ember-cli', position: 5},
  {name: 'Data', description: 'Addons related to ember-data or alternatives to ember-data', position:6},
  {name: 'Library wrappers', description: 'Addons that wrap third party libraries, jQuery plugins and the like', position:7},
  {name: 'Miscellaneous', description: 'The addons that don\'t fit into other categories', position: 8}
]

categories.each do |c|
  Category.create(c)
end
