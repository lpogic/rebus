module Rebus
  class Context
    def to_s
      "#{inspect}:Context"
    end

    def inspect
      "[#{instance_variables.join ", "}]"
    end

    def self.generate **variables
      Class.new(self) do 
        model *variables.keys
      end.new(*variables.values)
    end
  end
end