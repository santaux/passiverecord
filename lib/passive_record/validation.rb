module PassiveRecord
  module Validation
    extend ActiveSupport::Concern

    attr_reader :errors

    def initialize(*args)
      instance_eval do
        @errors = []
      end
      super
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
      opts.merge!(message: "Validation Error: Presence of '#{attr_name}' attribute is required")
      @errors << opts[:message] if self.send(attr_name).nil?
    end

    def validate_unique(attr_name, opts={})
      opts.merge!(message: "Validation Error: Uniqueness of '#{attr_name}' attribute is required")
      attr_value = self.send(attr_name)
      @errors << opts[:message] if (!attr_value.nil? && self.class.query.exists?(attr_name => attr_value))
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