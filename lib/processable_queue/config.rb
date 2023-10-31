module ProcessableQueue
  class Config
    # TODO: move it to config files
    DEFAULTS = {
      threads_pool: {
        thread_limit: 40,
        join_timeout: 0.1
      },
      std_out: true,
      max_job_time: 10,
      supervise_period: 1,
      logger: Log
    }
  end
end
