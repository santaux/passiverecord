load './lib/passive_record/attributes.rb'
load './lib/passive_record/action.rb'
load './lib/passive_record/association.rb'
load './lib/passive_record/validation.rb'
load './lib/passive_record/adapter.rb'
load './lib/passive_record/query.rb'
load './lib/passive_record/base.rb'

@adapter = PassiveRecord::Adapter.connect({adapter: "sqlite", database: "test.sqlite3", explain: true})

class Item < PassiveRecord::Base
  has_one :subitem

  validate :presence, :name
  validate :unique, :name
end

class Subitem < PassiveRecord::Base
  belongs_to :item
end


class Category < PassiveRecord::Base
  has_many :items
end
