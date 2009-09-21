Origin.connection = Sequel.connect('jdbc:sqlite::memory:')
Model::Repository.create_schema
