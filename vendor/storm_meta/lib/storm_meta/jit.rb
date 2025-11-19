module StormMeta
  module JIT
    class << self
      def supports_yjit?
        defined?(RubyVM::YJIT) && RubyVM::YJIT.respond_to?(:enable)
      rescue StandardError
        false
      end

      def enable_yjit!(verbose: false)
        return false unless supports_yjit?

        if RubyVM::YJIT.respond_to?(:enabled?)
          return true if RubyVM::YJIT.enabled?
        end

        RubyVM::YJIT.enable
        puts "[StormMeta::JIT] YJIT enabled" if verbose
        true
      rescue StandardError => e
        warn "[StormMeta::JIT] Failed to enable YJIT: #{e.class}: #{e.message}" if verbose
        false
      end

      def with_yjit(verbose: false)
        enable_yjit!(verbose: verbose)
        yield
      end
    end
  end
end