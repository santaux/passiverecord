require 'singleton'
require 'active_support/inflector'
require 'active_support/core_ext/module/delegation.rb'
require './lib/passive_record/adapter/abstract'
require './lib/passive_record/adapter/sqlite'

module PassiveRecord
  module Adapter extend self
    mattr_accessor :config, :db_adapter

    def connect(config)
      @@config = config

      begin
        @@db_adapter = "PassiveRecord::Adapter::#{config[:adapter].camelize}".constantize.new @@config
      rescue
        raise "Unknown adapter!"
      end
    end

    delegate :create_db, :create_table, :table_names, :columns, :columns_with_types, :columns_full_data,
             :execute, :run, :find, :insert, :update, :delete, :exist?,
             :transaction, :insert_transaction, :to => :@@db_adapter
  end
end