module Wreckem
  class State
    attr_accessor :name, :transitions, :id
    attr_accessor :components

    def initialize(name, transitions, goal=false, id=nil)
      @name, @transitions = name, transitions
      @goal, @id = goal, id
      @components = []
    end

    def goal?
      @goal
    end

    # Trying to navigate from one state to another means trying
    # to see if any tranisition will fire.  If so then you will 
    # get the next state which you can execute.  Otherwise you will
    # get nil to indicate you cannot transition.  Note that nil might
    # also be because you are already at a goal state.
    def execute(subject, object)
      return nil if goal?  # Cannot transition from goal state

      fired_transition = @transitions.find do |transition| 
        transition.fires?(subject, object)
      end
      fired_transition ? fired_transition.destination : nil
    end
  end
end
