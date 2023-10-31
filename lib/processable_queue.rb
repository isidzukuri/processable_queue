# frozen_string_literal: true

require 'colorize'
require 'singleton'
require 'timeout'
require_relative "processable_queue/log"
require_relative "processable_queue/version"
require_relative "processable_queue/concurrent_set"
require_relative "processable_queue/config"
require_relative "processable_queue/queue"
require_relative "processable_queue/threads_pool"

module ProcessableQueue
  class Error < StandardError; end
  
  def self.process(processor, objects_set)
    items = ConcurrentSet.new
    items.push(objects_set)
    Queue.new(processor, items, Config::DEFAULTS).process
  end
end
