require File.expand_path("#{File.dirname(__FILE__)}/../../hyperarchy_spec_helper")

describe "GET /fetch_organization_page", :type => :rack do
  attr_reader :organization, :elections, :member, :non_member,
              :excluded_visit, :included_visit_1, :included_visit_2

  before do
    @organization = Organization.make
    @member = make_member(organization)
    @non_member = User.make

    @elections = []
    10.downto(1) do |i|
      election = organization.elections.make
      election.update(:score => i)
      election.candidates.make
      elections.push(election)
    end

    @excluded_visit = elections.first.election_visits.create!(:user => member)
    @included_visit_1 = elections[4].election_visits.create!(:user => member)
    @included_visit_2 = elections[7].election_visits.create!(:user => member)
  end

  it "returns elections, candidates, and election visits for the current, previous, and next page" do
    # must be logged in
    get "/fetch_organization_page", :organization_id => organization.id, :page => 3, :items_per_page => 2
    last_response.status.should == 401

    # must be a member of election's organization
    login_as(non_member)
    get "/fetch_organization_page", :organization_id => organization.id, :page => 3, :items_per_page => 2
    last_response.status.should == 401

    login_as(member)
    get "/fetch_organization_page", :organization_id => organization.id, :page => 3, :items_per_page => 2
    last_response.should be_ok
    

    dataset = last_response.body_from_json["dataset"]

    puts dataset

    dataset["elections"].should_not have_key(elections[0].id.to_s)
    dataset["candidates"].should_not have_key(elections[0].candidates.first.id.to_s)

    dataset["elections"].should have_key(elections[3].id.to_s)
    dataset["candidates"].should have_key(elections[3].candidates.first.id.to_s)

    dataset["elections"].should have_key(elections[7].id.to_s)
    dataset["candidates"].should have_key(elections[7].candidates.first.id.to_s)

    dataset["elections"].should_not have_key(elections[8].id.to_s)
    dataset["candidates"].should_not have_key(elections[8].candidates.first.id.to_s)

    dataset["election_visits"].should_not have_key(excluded_visit.id.to_s)
    dataset["election_visits"].should have_key(included_visit_1.id.to_s)
    dataset["election_visits"].should have_key(included_visit_2.id.to_s)
  end
end
