module Wreckem
  class System
    attr_reader :game

    def initialize(game)
      @game = game
    end

    def manager
      game.manager
    end
  end
end
