require 'active_support/core_ext/module/delegation.rb'

module PassiveRecord
  class Query
    attr_accessor :table_name, :where_list, :order_by, :limit_with

    def initialize(table_name)
      @table_name = table_name
      @where_list = []
    end

    def all
      self.load
    end

    def find(id)
      find_by_field('id', id)
    end

    def method_missing(meth, *args, &block)
      if meth.to_s =~ /^find_by_(\w+)$/
        find_by_field($1, args[0])
      else
        super
      end
    end

    def respond_to?(meth)
      if meth.to_s =~ /^find_by_\w+$/
        true
      else
        super
      end
    end

    def find_by_field(name, value)
      value = add_quotes(value)
      self.where_list << "#{name} = #{value}"
      self.first
    end

    def where(opts)
      if opts.is_a? Hash
        hash_where(opts)
      elsif !where_list.include? opts
        self.where_list << "AND" unless where_list.size.zero?
        self.where_list << opts
      end
      self
    end

    def order(opt)
      self.order_by = opt.to_s
      self
    end

    def limit(opt)
      self.limit_with = opt.to_s
      self
    end

    def to_sql(select='*')
      @sql =  "SELECT #{select} FROM #{table_name} "
      @sql += " WHERE "    + where_list.join(' ') unless where_list.size.zero?
      @sql += " ORDER BY " + order_by   if order_by
      @sql += " LIMIT "    + limit_with if limit_with
      @sql
    end

    # load data from database and initialize array of objects
    def load
      rows = fire
      columns = rows.shift
      result = []
      rows.map do |el|
        obj = table_name.camelize.singularize.constantize.new
        columns.each_with_index do |column,index|
          obj.instance_variable_set("@#{column}".to_sym, el[index])
        end
        result << obj
      end
      reset
      result
    end

    # PassiveRecord::Adapter.executes the search of chain
    def fire
      PassiveRecord::Adapter.execute to_sql
    end

    def first
      result = limit(1).load[0]
      reset
      result
    end

    def count
      result = PassiveRecord::Adapter.run(to_sql("COUNT(*)")).flatten.first.to_i
      reset
      result
    end

    def exists?(where_opt)
      !where(where_opt).count.zero?
    end

    def reset
      @where_list = []
      @order_by, @limit_with = nil
    end

    private

    def hash_where(opts)
      opts.each_with_index do |el,index|
        opt = nil
        union = index.zero? ? 'AND' : 'OR'
        key, value = el

        if value.is_a? Array
          opt = "#{key} IN (#{value.to_s.gsub(/\"/, "'").gsub(/\[|\]/, '')})"
        else
          value = add_quotes(value)
          opt = "#{key} = #{value}"
        end

        unless where_list.include? opt
          self.where_list << union unless where_list.size.zero?# or index.zero?
          self.where_list << opt
        end
      end
    end

    def add_quotes(value)
      value.is_a?(String) ? "'#{value}'" : value
    end
  end

  module Quering
    def method_missing(meth, *args, &block)
      if meth.to_s =~ /^find_by_(\w+)$/
        query.find_by_field($1, args[0])
      else
        super
      end
    end

    def query
      PassiveRecord::Query.new(self.table_name)
    end

    delegate :all, :find, :where, :order, :limit, :count, :first, :exists?, :to => :query
  end
end
