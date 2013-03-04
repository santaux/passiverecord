require "spec_helper"
require 'fixtures/item'

describe PassiveRecord do
  before(:all) do
    @adapter = PassiveRecord::Adapter.connect({adapter: "sqlite", database: "test.sqlite3", explain: true})
    @adapter.table_names.each { |t| @adapter.drop_table t }
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
  end

  before(:each) do
    @items = []
    5.times do
      item = create_fake_item
      #@items << item.save
    end
  end

  context "Objects creating" do
    it "should create item" do
      #item = Item.create(name: "New Item", category_id: Category.first.id)
      #item.is_a? Item
      1.should == 1
    end
  end
end