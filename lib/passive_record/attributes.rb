require 'active_support/concern'
#require 'query'

module PassiveRecord
  module Attributes
    extend ActiveSupport::Concern

    attr_reader :id

    def self.included(mod)
      puts "Included: #{mod}"
    end

    def inspect
      self.class.set_attributes

      info = "#{self.class.to_s} ("
      fields = []
      self.class.columns.each do |column|
        value = self.send(column.to_sym)
        value = "nil" if value.nil?
        fields << "#{column}: #{value}"
      end
      info += fields.join(', ') + ")"
      info
    end

    # define accessors as table columns names
    def method_missing(meth, *args, &block)
      if self.class.columns.include?(meth.to_s.sub(/=$/, ''))
        Item.set_attributes
        send(meth, *args)
      else
        super
      end
    end

    def initialize(attrs={})
      attrs.each do |name,value|
        send("#{name}=", value)
      end
      #super
    end

    def new_record?
      id.nil?
    end

    def id=(value)
      puts "Sorry, you can't change id value..."
    end

    module ClassMethods
      def table_name
        to_s.tableize
      end

      def columns
        PassiveRecord::Adapter.columns table_name
      end

      def updateable_columns
        updateable = columns.clone
        updateable.delete "id"
        updateable
      end

      def columns_with_types
        PassiveRecord::Adapter.columns_with_types table_name
      end

      def inspect
        set_attributes

        info = "#{self.to_s} ("
        fields = []
        columns_with_types.each do |column|
          fields << "#{column[0]}: #{column[1]}"
        end
        info += fields.join(', ') + ")"
        info
      end

      def set_attributes
        columns.each do |column|
          set_attribute(column)
        end
      end

      protected

      def set_attribute(column)
        self.class_eval do
          attr_accessor column.to_sym
        end unless instance_methods.include?(column.to_sym)
      end
    end
  end
end