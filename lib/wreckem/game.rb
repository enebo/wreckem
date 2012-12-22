require 'wreckem/common_methods'

module Wreckem
  class Game
    include Wreckem::CommonMethods
    attr_reader :systems

    def initialize
      @systems = []
    end

    def run
      register_entities
      register_systems

      loop do
        systems.each do |system|
          time(system.class.name) { system.process }
        end
      end
    end

    def register_entities
      raise "A Zero entity game is pretty boring (implement register_entities)"
    end

    def register_systems
      raise "A Zero system game is pretty boring (implement register_systems)"
    end

    def time(name)
#      puts "Processing #{name} #{Time.now}"
      yield
#      puts "Done processing #{name} #{Time.now}"
    end
  end
end
