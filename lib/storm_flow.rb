# frozen_string_literal: true
require 'storm_meta'

module StormFlow
  def action(name, &block)
    StormMeta::JIT.enable_yjit! rescue nil

    @actions ||= {}
    definition = StormMeta::Action::ActionDefinition.new(name)
    definition.instance_eval(&block) if block_given?
    @actions[name] = definition

    define_singleton_method(name) do |ctx = {}|
      h = ctx
      k = self

      proxy = Object.new
      proxy.define_singleton_method(:[]) { |key| h[key] }
      proxy.define_singleton_method(:[]=) { |key, value| h[key] = value }
      proxy.define_singleton_method(:respond_to?) { |m, inc = false| k.instance_methods.include?(m) || super(m, inc) }
      proxy.define_singleton_method(:method_missing) do |m, *args, &blk|
        if k.instance_methods.include?(m)
          inst = k.new
          inst.instance_variable_set(:@ctx, h)
          inst.public_send(m, *args, &blk)
        else
          super(m, *args, &blk)
        end
      end

      best = StormMeta::AutoTune.pick_best(
        {
          fast:   ->(x) { definition.call(x) },
          slower: ->(x) { definition.call(x) }
        },
        warmup_input: proxy,
        iterations: 50
      )
      best.call(proxy)
      ctx
    end
  end

  def actions
    @actions || {}
  end
end