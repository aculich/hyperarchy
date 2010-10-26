require File.expand_path("#{File.dirname(__FILE__)}/thor_helper")

class Server < Thor
  map "fg" => :foreground
  
  desc "start [environment=development]", "starts the app server for the specified environment in the background"
  def start(env="development")
    exec_thin(:start, env, :daemonize)
  end

  desc "stop [environment=development]", "stops the app server for the specified environment"
  def stop(env="development")
    exec_thin(:stop, env, :daemonize)
  end

  desc "foreground [environment=development]", "runs the app server in the foreground"
  def foreground(env="development")
    exec_thin(:start, env)
  end

  private
  def exec_thin(command, env, daemonize=nil)
    Dir.chdir(ROOT)

    command = [
      "bundle exec thin #{command}",
      "--environment #{env}",
      "--config config/thin.#{env}.yml",
      "--rackup config/hyperarchy.ru",
      (daemonize ? "--daemonize --log #{LOG_DIR}/thin_#{env}.log --pid #{LOG_DIR}/hyperarchy_#{env}.pid"  : nil)
    ].compact.join(" ")

    exec(command)
  end
end
