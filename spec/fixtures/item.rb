class Item < PassiveRecord::Base
  has_one :subitem
  belongs_to :category

  validate :presence, :name
  validate :unique, :name
end
