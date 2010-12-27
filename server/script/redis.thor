require File.expand_path("#{File.dirname(__FILE__)}/thor_helper")

class RedisTask < Thor
  namespace :redis
  
  PID_FILE_PATH = "/usr/local/var/run/redis.pid"

  desc "start", "start redis"
  def start
    raise "Redis is already running with pid #{redis_pid}" if redis_running?
    system("redis-server /usr/local/etc/redis.conf")
  end

  desc "stop", "stop redis"
  def stop
    system ("kill #{redis_pid}")
  end

  protected
  def redis_pid
    File.read(PID_FILE_PATH).to_i
  end

  def redis_running?
    Process.getpgid(redis_pid)
    true
  rescue Errno::ESRCH
    false
  end
end
