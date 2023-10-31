# frozen_string_literal: true

module ProcessableQueue
  class Log
    include Singleton

    attr_accessor :std_out

    def self.puts_system_info(message, color = :cyan)
      instance.puts_system_info(message, color)
    end

    def self.puts_success(message, color = :green)
      instance.puts_system_info(message, color)
    end

    def self.puts_alert(message, color = :red)
      instance.puts_system_info(message, color)
    end

    def initialize(config = {})
      @std_out = config[:std_out] || true
    end

    def puts_system_info(message, color = :cyan)
      return unless std_out

      puts message.colorize(color)
    end
  end
end
