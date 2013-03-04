require 'sqlite3'

module PassiveRecord
  module Adapter
    class Sqlite < PassiveRecord::Adapter::Abstract
      def initialize(opts)
        super(opts)
        establish_connection
      end

      def establish_connection
        create_db # for sqlite it is the same thing
      end

      def create_db
        @database = SQLite3::Database.new @config[:database]
      end

      # --
      # example:
      #   adapter = PassiveRecord::Adapter.connect({adapter: "sqlite", database: "test.sqlite3"})
      #   adapter.create_table({items: {name: "VARCHAR(255)", category_id: "INTEGER"}})
      #
      def create_table(opts)
        table_name, fields = opts.first
        sql =  ["CREATE TABLE #{table_name} (id INTEGER PRIMARY KEY ASC"]
        fields.each do |field_name,field_type|
          sql << "#{field_name} #{field_type}"
        end
        sql = sql.join(', ') + ")"
        execute sql
      end

      def drop_table(table_name)
        execute("DROP TABLE #{table_name}")
      end

      # execute2 returns columns names first:
      def execute(sql)
        super
        @database.execute2 sql
      end

      # the same as 'execute', but without columns names
      def run(sql)
        super
        @database.execute sql
      end

      def transaction(&block)
        @database.transaction(&block)
      end

      def insert_transaction(sql)
        super
        last_insert_row_id = nil
        transaction {
          execute sql
          last_insert_row_id = @database.last_insert_row_id
        }
        last_insert_row_id
      end

      def columns(table_name)
        @_columns[table_name] ||= columns_full_data(table_name).map { |f| f["name"] }
      end

      def columns_with_types(table_name)
        @_columns_with_types[table_name] ||= @database.table_info(table_name).map { |f| [f["name"], f["type"]] }
      end

      def columns_full_data(table_name)
        @_columns_full_data[table_name] ||= @database.table_info table_name
      end

      def table_names
        @_table_names ||= run("SELECT name FROM sqlite_master").flatten
      end
    end
  end
end
