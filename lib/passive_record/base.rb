require './lib/passive_record/attributes'
require './lib/passive_record/query'
require './lib/passive_record/action'
require './lib/passive_record/validation'
require './lib/passive_record/association'
require './lib/passive_record/adapter'

module PassiveRecord
  class Base
    include PassiveRecord::Attributes
    extend  PassiveRecord::Quering
    include PassiveRecord::Action
    include PassiveRecord::Validation
    extend  PassiveRecord::Association
  end
end
