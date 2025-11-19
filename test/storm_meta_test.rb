require 'minitest/autorun'

# Charger la lib vendored si nécessaire
begin
  $LOAD_PATH.unshift File.expand_path('../vendor/storm_meta/lib', __dir__)
  require 'storm_meta'
rescue LoadError
end

class StormMetaJITTest < Minitest::Test
  def test_supports_yjit_returns_boolean
    r = StormMeta::JIT.supports_yjit?
    assert_includes [true, false, nil], r
  end

  def test_enable_yjit_does_not_raise
    result = StormMeta::JIT.enable_yjit!(verbose: true)
    assert_includes [true, false], result
  end

  def test_with_yjit_yields
    called = false
    StormMeta::JIT.with_yjit { called = true }
    assert called
  end
end

class StormMetaMetaTest < Minitest::Test
  class Room
    extend StormMeta::Meta
    dynamic_attr :name, :owner_id
    boolean_flags :archived, :locked
    dsl do
      def greet
        'hello'
      end
    end
  end

  def test_dynamic_attr_works
    r = Room.new
    r.name = 'Alpha'
    r.owner_id = 42
    assert_equal 'Alpha', r.name
    assert_equal 42, r.owner_id
  end

  def test_boolean_flags_work
    r = Room.new
    refute r.archived?
    r.archived!
    assert r.archived?
    r.not_archived!
    refute r.archived?
  end

  def test_dsl_defines_methods
    r = Room.new
    assert_equal 'hello', r.greet
  end
end

class StormMetaAutoTuneTest < Minitest::Test
  def test_pick_best_and_last_choice
    strategies = {
      ruby: ->(x) { x.to_s },
      alt:  ->(x) { "#{x}" }
    }
    best = StormMeta::AutoTune.pick_best(strategies, warmup_input: 123, iterations: 10)
    assert_kind_of Proc, best
    assert_includes [:ruby, :alt], StormMeta::AutoTune.last_choice
  end
end

class StormMetaActionTest < Minitest::Test
  class CtxObj
    attr_reader :loaded, :banned
    def load_user
      @loaded = true
    end
    def mark_banned
      @banned = true
    end
  end

  class UserActions
    extend StormMeta::Action
    action :ban_user do
      param :user_id, :integer
      step :load_user
      step :mark_banned
    end
  end

  def test_action_calls_methods_on_ctx_object
    ctx = CtxObj.new
    UserActions.ban_user(ctx)
    assert_equal true, ctx.loaded
    assert_equal true, ctx.banned
  end

  def test_action_block_modifies_hash
    klass = Class.new do
      extend StormMeta::Action
      action :touch do
        step do |h|
          h[:x] = 1
        end
      end
    end
    h = {}
    klass.touch(h)
    assert_equal 1, h[:x]
  end
end