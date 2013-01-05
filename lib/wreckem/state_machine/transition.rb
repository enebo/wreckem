module Wreckem
  class Transition
    attr_accessor :name, :destination

    def initialize(name, destination)
      @name, @destination = name, destination
    end
  end
end
