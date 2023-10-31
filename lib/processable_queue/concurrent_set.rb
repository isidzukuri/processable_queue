# frozen_string_literal: true

module ProcessableQueue
  class ConcurrentSet
    attr_reader :store, :current_position, :next_remain

    def initialize(store = [])
      @next_remain = 0
      @current_position = 0
      @mutex = Mutex.new
      @store = store
    end

    def next
      mutex.synchronize do
        value = store[current_position]
        if value
          @current_position += 1
          @next_remain -= 1
        end

        value
      end
    end

    def push(data)
      data = [data] unless data.is_a?(Array)

      mutex.synchronize do
        data.each do |item|
          next if item.nil? || store.include?(item)

          @next_remain += 1

          store << item
        end
      end
    end

    def size
      store.size
    end

    def [](index)
      store[index]
    end

    private

    attr_reader :mutex
  end
end
