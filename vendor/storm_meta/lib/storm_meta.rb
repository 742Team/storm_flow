require_relative "storm_meta/version"
require_relative "storm_meta/jit"
require_relative "storm_meta/meta"
require_relative "storm_meta/auto_tune"
require_relative "storm_meta/action"

module StormMeta
  class Error < StandardError; end
end