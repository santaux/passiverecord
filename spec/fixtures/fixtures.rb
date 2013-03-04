require 'faker'
require './spec/fixtures/item'
require './spec/fixtures/subitem'
require './spec/fixtures/category'

def create_fake_item(opts={})
  opts = {name: Faker::Lorem.word, category_id: create_fake_category.id}.merge!(opts)
  Item.create opts
end

def create_fake_subitem(opts={})
  opts = {name: Faker::Lorem.word, item_id: create_fake_item.id}.merge!(opts)
  Subitem.create opts
end

def create_fake_category(opts={})
  opts = {name: Faker::Lorem.word, description: Faker::Lorem.sentence}.merge!(opts)
  Category.create opts
end
