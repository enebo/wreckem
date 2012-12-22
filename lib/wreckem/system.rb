require 'wreckem/common_methods'

module Wreckem
  class System
    include CommonMethods
    extend CommonMethods
    attr_reader :game

    def initialize(game)
      @game = game
    end
  end
end
