# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Metric.destroy_all

Metric.create(
  name: 'Tests',
  description: 'Are tests thorough and robust?'
)

Metric.create(
  name: 'Readme',
  description: 'Is there a complete readme covering topics pertinant to a new user?'
)

Category.destroy_all

Category.create(name: 'authentication')
Category.create(name: 'ui components')