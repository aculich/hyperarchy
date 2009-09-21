if jruby?
  Origin.connection = Sequel.connect('jdbc:sqlite::memory:')
else
  Origin.connection = Sequel.sqlite
end
Model::Repository.create_schema
