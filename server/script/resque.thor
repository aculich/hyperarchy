require File.expand_path("#{File.dirname(__FILE__)}/thor_helper")

class ResqueTask < Thor
  namespace :resque
  map "fg" => :foreground

  desc "foreground [environment] [--verbose --vverbose --interval=5]", "Runs resque in the foreground"
  method_options :verbose => false, :vverbose => false, :interval => 5
  def foreground(env="development")
    start_resque(env, options[:interval], options[:verbose], options[:vverbose])
  end

  desc "start [environment] [--verbose --vverbose --interval=5]", "Start a Resque worker reading queues from the specified environment"
  method_options :verbose => false, :vverbose => false, :interval => 5
  def start(env="development")
    fork { start_resque(env, options[:interval], options[:verbose], options[:vverbose]) }
  end

  protected

  def start_resque(env, interval, verbose, vverbose)
    require 'resque'
    
    worker = nil
    queue = "#{env}_calc_scores"

    begin
      worker = Resque::Worker.new(queue)
      worker.verbose = options[:verbose]
      worker.very_verbose = options[:vverbose]
    rescue Resque::NoQueueError
      abort "Error finding queue for #{env} resque worker"
    end

    worker.log "Starting worker #{worker}"
    worker.work(options[:interval])

  end


end
