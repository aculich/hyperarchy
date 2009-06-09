require File.expand_path("#{File.dirname(__FILE__)}/../../hyperarchy_spec_helper")

module Model
  describe Repository do
    describe "#insert" do
      it "performs a database insert into the table corresponding to the #global_name of the given Set with the given attribute values" do
        id = Guid.new.to_s

        dataset = Origin.connection[:candidates]
        dataset[:id => id].should be_nil

        record = {:id => id, :body => "Bulgar Wheat", :election_id => "grain" }
        Origin.insert(Candidate.set, record)

        retrieved_record = dataset[:id => id]
        retrieved_record[:id].should == record[:id]
        retrieved_record[:body].should == record[:body]
        retrieved_record[:election_id].should == record[:election_id]
      end
    end

    describe "#read" do
      context "when reading a Tuple that is in the identity map" do
        it "returns the instance of the Tuple from the identity map associated with the given Set instead of instantiating another" do
          tuple_in_id_map = Candidate.find('grain_quinoa')
          Candidate.set.identity_map['grain_quinoa'] = tuple_in_id_map

          tuples = Origin.read(Candidate.set, Candidate.where(Candidate[:id].eq("grain_quinoa")).to_sql)
          tuples.size.should == 1
          tuple = tuples.first
          tuple.should equal(tuple_in_id_map)
        end
      end

      context "when reading a Tuple that is not in the identity map" do
        it "instantiates instances of the given Set's #tuple_class with the attribute values returned by the query and inserts them into the identity map" do
          Origin.connection[:candidates].delete
          Origin.connection[:candidates] << { :id => "1", :body => "Quinoa" }
          Origin.connection[:candidates] << { :id => "2", :body => "Barley" }
          Candidate.set.identity_map['1'].should be_nil
          Candidate.set.identity_map['2'].should be_nil

          tuples = Origin.read(Candidate.set, "select id, body from candidates;")
          tuples.size.should == 2
          
          tuple_1 = tuples.find {|t| t.id == "1"}
          tuple_1.body.should == "Quinoa"
          Candidate.set.identity_map['1'].should == tuple_1

          tuple_2 = tuples.find {|t| t.id == "2"}
          tuple_2.body.should == "Barley"
          Candidate.set.identity_map['2'].should == tuple_2
        end
      end
    end
  end
end