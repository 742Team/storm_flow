require "benchmark"

module StormMeta
  module AutoTune
    @last_choice = nil

    class << self
      attr_reader :last_choice
    end

    def self.pick_best(strategies, warmup_input:, iterations: 50)
      raise ArgumentError, "Need at least one strategy" if strategies.empty?

      # Warmup
      strategies.each_value do |fn|
        3.times { fn.call(warmup_input) }
      end

      timings = {}

      strategies.each do |name, fn|
        time = Benchmark.realtime do
          iterations.times { fn.call(warmup_input) }
        end

        timings[name] = time
      end

      best_name, _ = timings.min_by { |_, t| t }
      @last_choice = best_name

      strategies[best_name]
    end
  end
end
