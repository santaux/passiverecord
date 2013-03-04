require 'active_support/concern'
require 'active_support/core_ext/module/delegation'

module PassiveRecord
  module Action
    extend ActiveSupport::Concern

    def save
      return false unless valid?

      if new_record?
        id = create
        @id = id
      else
        update
      end
    end

    def create
      opts = Hash[self.class.updateable_columns.map { |c| [c, instance_variable_get(:"@#{c}")] }]
      self.class.create opts
    end

    def update
      update_opt = self.class.updateable_columns.map { |c|
        quoted_value = self.class.add_quotes(instance_variable_get(:"@#{c}"))
        "#{c} = #{quoted_value}"
      }.join(', ')
      where_opt  = "id = #{id}"
      self.class.update_all update_opt, where_opt
      reload
    end

    def delete
      self.class.delete_all "id = #{self.id}"
    end

    def update_attributes(opts)
      opts.each do |key,value|
        instance_variable_set(:"@#{key}", value)
      end
      save
    end

    def reload
      self.class.find(self.id)
    end

    module ClassMethods
      def create(opts)
        mock_obj = self.new opts
        return false unless mock_obj.valid?

        fields = opts.keys.join(',')
        values = opts.values.map { |v| add_quotes(v)  }.join(',')
        sql =  "INSERT INTO #{table_name} (#{fields}) VALUES (#{values})"

        PassiveRecord::Adapter.insert_transaction sql
      end

      def update_all(update_opt,where_opt=nil)
        sql =  "UPDATE #{table_name} SET #{update_opt}"
        sql += " WHERE " + where_opt.to_s if where_opt

        PassiveRecord::Adapter.execute sql
        true
      end

      def delete_all(where_opt=nil)
        sql =  "DELETE FROM #{table_name} "
        sql += "WHERE " + where_opt.to_s if where_opt

        PassiveRecord::Adapter.execute sql
      end

      def add_quotes(value)
        value.is_a?(Integer) ? value : "'#{value.to_s}'"
      end

    end
  end
end