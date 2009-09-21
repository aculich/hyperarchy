if jruby?
  Origin.connection = Sequel.connect("jdbc:mysql://localhost/hyperarchy_development?user=root&password=password")
else
  Origin.connection = Sequel.mysql("hyperarchy_development", :user => 'root', :password => "password")
end
