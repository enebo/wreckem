module Wreckem
  class State
    attr_accessor :name, :transitions

    def initialize(name, transitions, goal=false)
      @name, @transitions = name, transitions
      @goal = goal
    end

    def goal?
      @goal
    end

    def execute(subject, object)
      return nil if goal?

      fired_transition = @transitions.find do |transition| 
        transition.fires?(subject, object)
      end
      fired_transition ? fired_transition.destination : self
    end
  end
end
