#!/usr/bin/env ruby
# frozen_string_literal: true

require 'benchmark'

$LOAD_PATH.unshift File.expand_path('../vendor/storm_meta/lib', __dir__)
require 'storm_meta'
require_relative '../lib/storm_flow'
require 'securerandom'

class BenchFlow
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
    raise 'Invalid email' unless email.include?('@')
  end

  def persist
    @ctx[:ok] = true
  end
end

input = { name: 'Alice', email: 'alice@example.com' }

StormMeta::JIT.with_yjit(verbose: true) do
  t = Benchmark.realtime do
    10_000.times { BenchFlow.register_user(input.dup) }
  end
  puts "YJIT run: #{t.round(4)}s, choice=#{StormMeta::AutoTune.last_choice}"
end

nojit = Benchmark.realtime do
  10_000.times { BenchFlow.register_user(input.dup) }
end
puts "No JIT:  #{nojit.round(4)}s, choice=#{StormMeta::AutoTune.last_choice}"