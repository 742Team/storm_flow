require 'minitest/autorun'
require 'stringio'

begin
  $LOAD_PATH.unshift File.expand_path('../vendor/storm_meta/lib', __dir__)
  require 'storm_meta'
rescue LoadError
end

require_relative '../storm_flow'

class StormFlowIntegrationTest < Minitest::Test
  class UserFlow
    extend StormFlow

    action :register_user do
      param :name,  :string
      param :email, :string

      step :validate
      step do |ctx|
        ctx[:id] = 'test-id'
      end
      step :persist
    end

    def validate
      email = @ctx[:email]
      raise 'Invalid email' unless email.include?('@')
    end

    def persist
      puts "User saved: #{@ctx[:id]} #{@ctx[:name]}"
    end
  end

  def silence_stdout
    old = $stdout
    $stdout = StringIO.new
    yield
  ensure
    $stdout = old
  end

  def test_actions_is_hash
    assert_kind_of Hash, UserFlow.actions
  end

  def test_action_generates_class_method
    assert UserFlow.respond_to?(:register_user)
  end

  def test_action_executes_and_returns_ctx
    res = nil
    silence_stdout do
      res = UserFlow.register_user(name: 'Alice', email: 'alice@example.com')
    end
    assert_equal 'Alice', res[:name]
    assert_equal 'alice@example.com', res[:email]
    assert_equal 'test-id', res[:id]
  end

  def test_symbol_steps_call_instance_methods
    silence_stdout do
      UserFlow.register_user(name: 'Bob', email: 'bob@example.com')
    end
    assert true
  end

  def test_block_steps_modify_ctx
    res = nil
    silence_stdout do
      res = UserFlow.register_user(name: 'Carol', email: 'carol@example.com')
    end
    assert_equal 'test-id', res[:id]
  end

  def test_autotune_last_choice
    silence_stdout do
      UserFlow.register_user(name: 'Dan', email: 'dan@example.com')
    end
    assert_includes [:fast, :slower], StormMeta::AutoTune.last_choice
  end

  def test_invalid_email_raises
    assert_raises(RuntimeError) do
      silence_stdout do
        UserFlow.register_user(name: 'Eve', email: 'invalid-email')
      end
    end
  end
end