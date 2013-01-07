module Wreckem
  class StatWrapper
    def initialize(backend)
      @backend = backend
      @counts, @times = {}, {}
    end

    def method_missing(name, *args)
      time_and_count(name) { @backend.__send__(name, *args) }
    end

    def time_and_count(method)
      start = Time.now
      ret = yield
      time_spent = Time.now - start
      
      update_count(method)
      update_time(method, time_spent)
      
      ret
    end

    def update_count(method)
      count = @counts[method] || 0
      @counts[method] = count + 1
    end

    def update_time(method, time_spent)
      time = @times[method] || 0.0
      @times[method] = time + time_spent
    end

    def all_stats
      @times.keys.sort.inject([]) { |list, method| list << stats_for(method) }
    end

    def stats_for(method)
      time = @times[method] || 0.0
      count = @counts[method] || 0
      
      [method, count, time]
    end
  end
end
