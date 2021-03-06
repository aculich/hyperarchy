Sequel.migration do
  up do
    create_table :votes do
      primary_key :id
      Integer :election_id
      Integer :user_id
      Time :created_at
      Time :updated_at
    end

    add_column(:rankings, :vote_id, Integer)
  end
end
