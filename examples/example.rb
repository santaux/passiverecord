lib = File.expand_path('../../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'passive_record'

# Initialize database adapter and create tables:
@adapter = PassiveRecord::Adapter.connect({adapter: "sqlite", database: "test.sqlite3", explain: true})
@adapter.create_table({
  items: {
    name: "VARCHAR(255)",
    category_id: "INTEGER"
  }
})
@adapter.create_table({
  subitems: {
    name: "VARCHAR(255)",
    item_id: "INTEGER"
  }
})
@adapter.create_table({
  categories: {
    name: "VARCHAR(255)",
    description: "VARCHAR(255)"
  }
})

# Write models:
class Item < PassiveRecord::Base
  has_one :subitem
  belongs_to :category

  validate :presence, :name
  validate :unique, :name
end

class Subitem < PassiveRecord::Base
  belongs_to :item
end

class Category < PassiveRecord::Base
  has_many :items
end

# Create some items and categories:
category = Category.create(name: "Base Category", description: "Just an example of category")
item     = Item.create(name: "Item1", category_id: category.id)
subitem  = Subitem.create(name: "Subitem1", item_id: item.id)

# Fetch all items:
Item.all

# Fetch category with current id:
Category.find(1)

# Queries chaining:
query = Item.where(category_id: 1).where(name: "Item1")
query.load

# or
Item.where(category_id: 1).where(name: "Item1").load # => Array of Items

# ActiveRecord like validating, save and update:
new_item = Item.new
new_item.valid? # => false
new_item.name = "New Item"
new_item.valid? # => true
new_item.save

# One-to-one and One-to-many associations:
item.category # => Category(id: ...)
item.subitem #= > Subitem(...)
category.items # => [Item(...), Item(...)]

# Update or delete anything:
Subitem.update_all("name = 'Updated Name'")
Category.delete_all