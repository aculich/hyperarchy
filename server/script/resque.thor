require File.expand_path("#{File.dirname(__FILE__)}/thor_helper")

class Worker < Thor
  map "fg" => :foreground

  desc "foreground [environment] [--verbose --vverbose --interval=5]", "Runs resque in the foreground."
  method_options :verbose => false, :vverbose => false, :interval => 5
  def foreground(env="development")
    start_resque(env, options[:interval], options[:verbose], options[:vverbose])
  end

  desc "start [environment] [--verbose --vverbose --interval=5]", "Start a Resque worker reading queues from the specified environment."
  method_options :verbose => false, :vverbose => false, :interval => 5
  def start(env="development")
    fork { start_resque(env, options[:interval], options[:verbose], options[:vverbose]) }
  end

  desc "stop [environment]", "Stops the Resque worker corresponding to the given environment."
  def stop(env="development")
    require "resque"
    pids = Resque.workers.map do |worker|
      host, pid, queue = worker.id.split(':')
      pid if queue == env
    end.compact

    if pids.empty?
      puts "No workers to stop for #{env} environment"
    else
      command = "kill -QUIT #{pids.join(" ")}"
      puts command
      system(command)
    end
  end

  protected

  def start_resque(env, interval, verbose, vverbose)
    require_hyperarchy(env)
    STDERR.sync = STDOUT.sync = true

    worker = nil
    begin
      worker = Resque::Worker.new(queue = env)
      worker.verbose = options[:verbose]
      worker.very_verbose = options[:vverbose]
    rescue Resque::NoQueueError
      abort "Error finding queue for #{env} resque worker"
    end

    worker.log "Starting worker #{worker}"
    worker.work(options[:interval])
  end
end
