require "spec_helper"
require 'fixtures/item'

describe PassiveRecord do
  before(:all) do
    @adapter = PassiveRecord::Adapter.connect({adapter: "sqlite", database: "test.sqlite3", explain: false})
    @adapter.table_names.each { |t| @adapter.drop_table t }
  end

  context "Tables" do
    def create_tables
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

    it "should create tables" do
      create_tables
      ["items", "subitems", "categories"].each do |table_name|
        @adapter.table_names.should include(table_name)
      end
    end
  end

  context "Records" do
    before(:all) do
      @items = []
      5.times do
        @items << create_fake_item(name: "Item#{rand}")
      end
      2.times do
        @items << create_fake_item(name: "Item#{rand}", category_id: 1)
      end

      @subitems = []
      2.times do
        @subitems << create_fake_subitem(name: "Subitem", item_id: 1)
      end
      2.times do
        @subitems << create_fake_subitem(name: "Subitem2", item_id: 2)
      end
    end

    context "creating" do
      it "should create item" do
        item = Item.create(name: "New Item", category_id: 2)
        item.is_a? Item
      end

      it "should create category" do
        category = Category.create(name: "New Item", description: "I am a category")
        category.is_a? Category
      end

      it "should create subitem" do
        subitem = Subitem.create(name: "New Subitem", item_id: 1)
        subitem.is_a? Subitem
      end
    end

    context "initializing" do
      it "should initialize item with correct name" do
        item = Item.new(name: "New Item")
        item.name.should == "New Item"
      end

      it "should initialize item with correct multiple attributes" do
        item = Item.new(name: "New Item", category_id: 1)
        item.name.should == "New Item"
        item.category_id.should == 1
      end
    end

    context "saving and validating" do
      it "should create item with valid attributes" do
        item = Item.new(name: "Unique item")
        item.save.should_not be_false
      end

      it "should not create item with existed name" do
        item = Item.new(name: "Unique item")
        item.save.should be_false
      end

      it "should not create item with blank name" do
        item = Item.new
        item.save.should be_false
      end

      it "should update name" do
        item = Item.first
        item.name = "Updated name"
        item.save.reload.name.should == "Updated name"
      end
    end

    context "quering" do
      it "should find item with correct id" do
        Item.find(1).id.should == 1
      end

      it "should return nil for noexistent record" do
        Item.find(0).should be_nil
      end

      it "should fetch array or records" do
        Item.where(category_id: 1).load.is_a?(Array).should be_true
      end

      it "order items by categories" do
        @adapter.execute("DELETE FROM items WHERE category_id IS NULL")
        Item.order("category_id ASC").load[0].category_id.should be_equal(1)
        Item.order("category_id DESC").load[0].category_id.should_not be_equal(1)
      end

      it "limit items by categories" do
        Item.limit(1).load.size.should be_equal(1)
      end

      it "merge where opt with OR" do
        Subitem.where(item_id: 1, name: 'Subitem2').load.size.should be_equal(5)
      end

      it "chain queries" do
        Item.where(category_id: 1).limit(2).load.size.should be_equal(2)
        Item.where(category_id: 1).order("category_id DESC").limit(2).load.size.should be_equal(2)
      end

      it "merge where opt with AND" do
        Subitem.where(item_id: 2).where(name: 'Subitem2').load.size.should be_equal(2)
      end
    end

    context "associations" do
      it "should have valid belongs_to association" do
        item = Item.first
        category = Category.find(item.category_id)
        item.category.id.should be_equal(category.id)
      end

      it "should have valid has_one association" do
        item = Item.first
        subitem = Subitem.find(item.id)
        item.subitem.id.should be_equal(subitem.id)
      end

      it "should have valid has_many association" do
        category = Category.first
        category.items.map(&:category_id).each do |category_id|
          category.id.should be_equal(category_id)
        end
      end
    end

    context "updating and deleting" do
      it "should update records" do
        items_size = Item.where(category_id: [1, 2]).load.size
        Item.update_all("category_id = 2", "category_id = 1")
        Item.where(category_id: 2).load.size.should be_equal(items_size)
      end

      it "should delete records with category_id equal 2" do
        Item.delete_all("category_id = 2")
        Item.where(category_id: 2).load.size.should be_equal(0)
      end

      it "should update all records" do
        items_size = Item.count
        Item.update_all("category_id = 2")
        Item.where(category_id: 2).load.size.should be_equal(items_size)
      end

      it "should delete all records" do
        Item.delete_all
        Item.count.should be_equal(0)
      end
    end
  end
end