module PassiveRecord
  module Adapter
    class Abstract
      attr_reader :config

      def initialize(config)
        @config = config
        columns_reset
      end

      def table_exists?(table_name)
        @table_names.include? table_name
      end

      def columns_reset
        @_columns = {}
        @_columns_full_data = {}
        @_columns_with_types = {}
        @_table_names = nil
      end

      def execute(sql)
        puts sql if @config[:explain]
      end

      def run(sql)
        puts sql if @config[:explain]
      end

      def insert_transaction(sql)
        puts sql if @config[:explain]
      end
    end
  end
end