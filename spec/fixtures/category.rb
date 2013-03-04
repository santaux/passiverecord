class Category < PassiveRecord::Base
  has_many :items
end
