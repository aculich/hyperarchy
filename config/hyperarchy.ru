dir = ::File.dirname(__FILE__)
require "#{dir}/../server/lib/hyperarchy"

$0 = "hyperarchy #{RACK_ENV} server"
Signal.trap("QUIT") { exit }
run Hyperarchy::App