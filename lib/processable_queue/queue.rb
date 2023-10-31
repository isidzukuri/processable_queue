# frozen_string_literal: true

module ProcessableQueue
  class Queue
    SUPERVISE_PERIOD = 1

    attr_reader :queue, :threads_pool, :processor, :errors, :config, :logger

    def initialize(processor, queue = nil, config = Config::DEFAULTS)
      @processor = processor
      @config = config
      @logger = config[:logger]
      @queue = queue || ConcurrentSet.new
      @threads_pool = ThreadsPool.new(Config::DEFAULTS[:threads_pool], logger)
      @errors = ConcurrentSet.new
    end

    def process
      start_supervisor

      threads_pool.join

      true
    end

    def push(items)
      queue.push(items)
    end

    private

    def start_supervisor
      threads_pool.start_thread { supervisor }
    end

    def start_workers
      queue.next_remain.times do
        res = threads_pool.start_thread { worker(processor) }

        break if res[:status] == :limit_reached
      end
    end

    def supervisor
      while queue.next_remain > 0
        start_workers
        sleep(config[:supervise_period] || SUPERVISE_PERIOD)
      end
    end

    def worker(processor)
      while (item = queue.next)
        begin
          Timeout.timeout(config[:max_job_time]) do
            processor.call(item)
          end
          puts_info
          start_workers
        rescue StandardError => e
          error = "#{e.class}: #{e.message}"
          backtrace = e.backtrace.join("\n")
          errors.push({ item:, error:, backtrace: })
          logger&.puts_alert(error)
          logger&.puts_system_info(backtrace, :grey)
        end
      end
    end

    def puts_info
      logger&.puts_system_info(info)
    end

    def info
      "Queue: #{queue.current_position}/#{queue.size}"
    end
  end
end
