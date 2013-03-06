module PassiveRecord
  module Association
    def belongs_to(assoc_name)
      define_method assoc_name do
        assoc_name.to_s.camelize.constantize.find(
          self.send(:"#{assoc_name}_id")
        )
      end
    end

    def has_one(assoc_name)
      define_method assoc_name do
        assoc_name.to_s.camelize.constantize.where(
          :"#{self.class.to_s.tableize.singularize}_id" => self.id
        ).first
      end
    end

    def has_many(assoc_name)
      define_method assoc_name do
        assoc_name.to_s.camelize.singularize.constantize.where(
          :"#{self.class.to_s.tableize.singularize}_id" => self.id
        ).load
      end
    end
  end
end
