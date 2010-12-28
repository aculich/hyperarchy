require File.expand_path("#{File.dirname(__FILE__)}/thor_helper")

class Worker < Thor
  map "fg" => :foreground

  desc "foreground [environment] [--verbose --vverbose --interval=5]", "Runs resque in the foreground."
  method_options :verbose => false, :vverbose => false, :interval => 5
  def foreground(env="development")
    start_resque(env, options[:interval], options[:verbose], options[:vverbose])
  end

  desc "start [environment] [--verbose --vverbose --interval=5]", "Start a Resque worker reading queues from the specified environment."
  method_options :verbose => false, :vverbose => false, :interval => 5, :pidfile => nil
  def start(env="development")
    require_hyperarchy(env)
    worker = Hyperarchy::Worker.new(env, options)
    worker.start
  end

  desc "stop [environment]", "Stops the Resque worker corresponding to the given environment."
  def stop(env="development")
    require_hyperarchy(env)
    Hyperarchy::Worker.stop(env)
  end
end
