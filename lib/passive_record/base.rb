require 'passive_record/attributes'
require 'passive_record/query'
require 'passive_record/action'
require 'passive_record/validation'
require 'passive_record/association'
require 'passive_record/adapter'

module PassiveRecord
  class Base
    include PassiveRecord::Attributes
    extend  PassiveRecord::Quering
    include PassiveRecord::Action
    include PassiveRecord::Validation
    extend  PassiveRecord::Association
  end
end
