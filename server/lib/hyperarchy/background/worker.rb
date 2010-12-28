module Process
  # Returns +true+ the process identied by +pid+ is running.
  def running?(pid)
    Process.getpgid(pid) != -1
  rescue Errno::ESRCH
    false
  end
  module_function :running?
end

require 'etc'
require 'daemons'

module Hyperarchy
  class Worker
    include Thin::Daemonizable

    def self.pid_file(env)
      "#{HYPERARCHY_ROOT}/log/worker_#{env}.pid"
    end

    def self.log_file(env)
      "#{HYPERARCHY_ROOT}/log/worker_#{env}.log"
    end

    def self.stop(env)
      kill(pid_file(env))
    end

    attr_reader :env, :options
    def initialize(env, options)
      @env = env
      @options = options
      @pid_file = self.class.pid_file(env)
      @log_file = self.class.log_file(env)
    end

    def name
      "worker_#{env}"
    end

    def log(s)
      puts s
    end

    def start
      daemonize
      run
    end

    def run
      worker = nil
      begin
        worker = Resque::Worker.new(queue = env)
        worker.verbose = options[:verbose]
        worker.very_verbose = options[:vverbose]
      rescue Resque::NoQueueError
        abort "Error finding queue for #{env} resque worker"
      end

      worker.log "Starting worker #{worker}"

      puts "calling worker.work"
      worker.work(options[:interval])
    end
  end
end