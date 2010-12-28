dir = ::File.expand_path(::File.dirname(__FILE__))
require "#{dir}/../lib/hyperarchy"

trap("QUIT") { exit }
trap("INT") { exit }

Hyperarchy::Background::Scheduler.start
run Hyperarchy::App
