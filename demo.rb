begin
  $LOAD_PATH.unshift File.expand_path("vendor/storm_meta/lib", __dir__)
  require "storm_meta"
rescue LoadError
end
require_relative "lib/storm_flow"
require "securerandom"

class UserFlow
  extend StormFlow

  action :register_user do
    param :name,  :string
    param :email, :string

    step :validate
    step do |ctx|
      ctx[:id] = SecureRandom.uuid
    end
    step :persist
  end

  def validate
    email = @ctx[:email]
    raise "Invalid email" unless email.include?("@")
  end

  def persist
    puts "User saved: #{@ctx[:id]} #{@ctx[:name]}"
  end
end

result = UserFlow.register_user(name: "Alice", email: "alice@example.com")
puts "AutoTune choice: #{StormMeta::AutoTune.last_choice}"
puts result.inspect