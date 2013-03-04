lib = File.expand_path('../../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'passive_record'

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
