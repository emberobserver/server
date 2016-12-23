class API::V2::CategoryResource < JSONAPI::Resource
  attributes :name, :description, :position, :addon_count
  has_many :subcategories, class_name: 'Category'
  has_one :parent, class_name: 'Category'

  has_many :addons

  def addon_count
    @model.addons.count
  end
end
