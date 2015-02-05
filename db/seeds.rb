Category.destroy_all

categories = [
  {name: 'Authentication', description: 'Addons for auth', package_ids: [1, 2, 3]},
  {name: 'Components', description: 'Addons that provide a component', package_ids: [1, 2]},
  {name: 'Styles', description: 'Addons that provide styles, css frameworks, preprocessors', package_ids: [3]},
  {name: 'Testing', description: 'Addons related to testing', package_ids: [1, 2, 3]},
  {name: 'Build tools', description: 'Addons related to preprocessing, broccoli plugins and dependencies of ember-cli', package_ids: [1, 2, 3]},
  {name: 'Data', description: 'Addons related to ember-data or alternatives to ember-data', package_ids: []},
  {name: 'Library wrappers', description: 'Addons that wrap third party libraries, jQuery plugins and the like', package_ids: [2]},
  {name: 'Miscellaneous', description: 'The addons that don\'t fit into other categories', package_ids: [1, 2, 3]}
]

categories.each do |c|
  Category.create(c)
end
