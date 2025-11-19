require "benchmark"

module StormMeta
  module AutoTune
    def self.pick_best(strategies, warmup_input:, iterations: 50)
      raise ArgumentError, "Need at least one strategy" if strategies.empty?

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

      best_name, = timings.min_by { |_, t| t }
      best_fn = strategies[best_name]

      define_singleton_method(:last_choice) { best_name }

      best_fn
    end
  end
end