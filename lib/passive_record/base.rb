module PassiveRecord
  class Base
    include PassiveRecord::Attributes
    extend  PassiveRecord::Quering
    include PassiveRecord::Action
    include PassiveRecord::Validation
    extend  PassiveRecord::Association
  end
end
