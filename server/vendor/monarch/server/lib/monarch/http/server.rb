dir = File.dirname(__FILE__)
if jruby?
  require "#{dir}/server/jruby_server"
else
  require "#{dir}/server/mri_server"
end