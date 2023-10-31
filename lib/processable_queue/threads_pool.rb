# frozen_string_literal: true

module ProcessableQueue
  class ThreadsPool
    attr_reader :pool, :thread_limit, :join_timeout, :logger

    THREAD_LIMIT = 5
    JOIN_TIMEOUT = 0.1

    def initialize(config = Config::DEFAULTS[:threads_pool], logger = nil)
      @pool = ConcurrentSet.new
      @thread_limit = config[:thread_limit] || THREAD_LIMIT
      @join_timeout = config[:join_timeout] || JOIN_TIMEOUT
      @logger = logger
    end

    def limit_reached?
      thread_limit <= alive_count
    end

    def alive_count
      threads.count(&:alive?)
    end

    def start_thread(&process)
      return { status: :limit_reached } if limit_reached?

      thr = Thread.new { process&.call }

      pool.push(thr)
      puts_info

      { status: :ok, thread: thr }
    end

    def threads
      pool.store
    end

    def join
      sleep(join_timeout) while alive_count > 0
      threads.each(&:join)
    end

    def puts_info
      color = limit_reached? ? :yellow : :cyan

      logger&.puts_system_info(info, color)
    end

    def info
      "Threads: #{alive_count}/#{thread_limit}"
    end
  end
end
