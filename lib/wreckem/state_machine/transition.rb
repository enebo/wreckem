module Wreckem
  class Transition
    attr_accessor :name, :destination, :expression_as_string, :id
    attr_accessor :components

    def initialize(name, destination, expression_as_string, id=nil)
      @name, @destination = name, destination
      @expression_as_string = expression_as_string
      @id = id
      @components = []
    end

    def self.generate(name, destination, expression_as_string, id=nil)
      cls = eval(<<-EOS)
Class.new(Wreckem::Transition) do
  def initialize(name, destination, expression_as_string, id=nil)
    super(name, destination, expression_as_string)
  end

  def fires?(a, b)
    #{expression_as_string}
  end
end
EOS
      cls.new(name, destination, expression_as_string, id)
    end
  end
end
