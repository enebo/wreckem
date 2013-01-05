module Wreckem
  class Transition
    attr_accessor :name, :destination, :expression_as_string

    def initialize(name, destination, expression_as_string)
      @name, @destination = name, destination
      @expression_as_string = expression_as_string
    end

    def self.generate(name, destination, expression_as_string)
      cls = eval(<<-EOS)
Class.new(Wreckem::Transition) do
  def initialize(name, destination, expression_as_string)
    super(name, destination, expression_as_string)
  end

  def fires?(a, b)
    #{expression_as_string}
  end
end
EOS
      cls.new(name, destination, expression_as_string)
    end
  end
end
