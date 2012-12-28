require 'wreckem/common_methods'

module Wreckem
  class Game
    include Wreckem::CommonMethods
    attr_reader :systems, :async_systems, :manager

    def initialize(backend=nil)
      @systems, @async_systems = [], []
      if backend
        @manager = Wreckem::EntityManager.new(backend)
      else
        @manager = Wreckem::EntityManager.new
      end
    end

    def run
      register_entities
      register_systems
      register_async_systems

      async_systems.each do |system|
        Thread.new do
          loop do
            system.process
          end
        end
      end

      loop do
        systems.each do |system|
          time(system.class.name) { system.process }
        end
        sleep 0.25
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
