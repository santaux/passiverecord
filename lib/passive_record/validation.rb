module PassiveRecord
  module Validation
    extend ActiveSupport::Concern

    attr_reader :errors

    def initialize(*args)
      instance_eval do
        @errors = []
      end
      self.class.class_eval %{
        @@validations ||= []
      }
      super(*args)
    end

    def valid?
      @errors = []

      self.class.validations.each do |data|
        method = "validate_" + data[0].to_s
        attr_name = data[1]
        opts = data[2] || {}
        send(method, attr_name, opts)
      end

      unless @errors.size.zero?
        @errors.each { |e| puts e }
        false
      else
        true
      end
    end

    protected

    def validate_presence(attr_name, opts={})
      opts = {message: "Validation Error: Presence of '#{attr_name}' attribute is required"}.merge!(opts)
      @errors << opts[:message] if self.send(attr_name).nil?
    end

    def validate_unique(attr_name, opts={})
      opts = {message: "Validation Error: Uniqueness of '#{attr_name}' attribute is required"}.merge!(opts)
      attr_value = self.send(attr_name)
      query = self.class.query
      query = query.where("id != #{id}") unless new_record?
      if (!attr_value.nil? && query.exists?(attr_name => attr_value))
        @errors << opts[:message]
      end
    end

    module ClassMethods
      def validate(method, opts={})
        class_eval %{
          @@validations ||= []
          @@validations << [method, opts]
        }
      end

      def validations
        class_eval %{
          @@validations
        }
      end
    end
  end
end