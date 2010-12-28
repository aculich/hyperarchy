require File.expand_path(File.dirname(__FILE__) + "/../../hyperarchy_spec_helper")

module Models
  describe Election do
    attr_reader :election, :memphis, :knoxville, :chattanooga, :nashville, :unranked

    before do
      Timecop.freeze(Time.now)

      @election = Election.make(:body => "Where should the capital of Tennesee be?")
      @memphis = election.candidates.create!(:body => "Memphis")
      @knoxville = election.candidates.create!(:body => "Knoxville")
      @chattanooga = election.candidates.create!(:body => "Chattanooga")
      @nashville = election.candidates.create!(:body => "Nashville")
      @unranked = election.candidates.create!(:body => "Unranked")
    end

    describe "before create" do
      it "assigns the creator to the Model::Record.current_user" do
        set_current_user(User.make)
        election = Election.make
        election.creator.should == current_user
      end

      it "assigns the initial score" do
        election.score.should_not be_nil
      end
    end

    describe "after create" do
      attr_reader :organization, :creator, :opted_in, :opted_out, :non_member

      before do
        @organization = Organization.make
        @creator = User.make
        @opted_in = User.make
        @opted_out = User.make
        @non_member = User.make

        organization.memberships.create!(:user => creator, :notify_of_new_elections => true, :suppress_invite_email => true)
        organization.memberships.create!(:user => opted_in, :notify_of_new_elections => true, :suppress_invite_email => true)
        organization.memberships.create!(:user => opted_out, :notify_of_new_elections => false, :suppress_invite_email => true)

        set_current_user(creator)
      end

      it "sends an email to any members of the organization who have opted to receive one, except for the creator himself" do
        organization.elections.create!(:body => "What should we eat for dinner?")
        Mailer.emails.length.should == 1
        Mailer.emails.first[:to].should == opted_in.email_address
      end

      it "does not try to send email if there are no people to notify" do
        organization.memberships.update(:notify_of_new_elections => false)
        organization.elections.create!(:body => "What should we eat for dinner?")
        Mailer.emails.should be_empty
      end
    end

    describe "before destroy" do
      it "destroys any candidates, votes and visits that belong to the election" do
        election = Election.make
        user_1 = make_member(election.organization)
        user_2 = make_member(election.organization)
        candidate_1 = election.candidates.create!(:body => "A")
        candidate_2 = election.candidates.create!(:body => "B")
        Ranking.create!(:user => user_1, :candidate => candidate_1, :position => 64)
        Ranking.create!(:user => user_1, :candidate => candidate_2, :position => 32)
        Ranking.create!(:user => user_2, :candidate => candidate_1, :position => 64)
        election.election_visits.create!(:user => user_1)

        election.election_visits.size.should == 1
        election.candidates.size.should == 2
        election.votes.size.should == 2
        election.destroy
        election.candidates.should be_empty
        election.votes.should be_empty
        election.election_visits.should be_empty


      end
    end

    describe "#compute_global_ranking" do
      it "uses the ranked-pairs algoritm to produce a global ranking, assigning a position of null to any unranked candidates" do
        Timecop.freeze(Time.now + 60)

        4.times do
          user = User.make
          election.rankings.create(:user => user, :candidate => memphis, :position => 4)
          election.rankings.create(:user => user, :candidate => nashville, :position => 3)
          election.rankings.create(:user => user, :candidate => chattanooga, :position => 2)
          election.rankings.create(:user => user, :candidate => knoxville, :position => 1)
        end

        3.times do
          user = User.make
          election.rankings.create(:user => user, :candidate => nashville, :position => 4)
          election.rankings.create(:user => user, :candidate => chattanooga, :position => 3)
          election.rankings.create(:user => user, :candidate => knoxville, :position => 2)
          election.rankings.create(:user => user, :candidate => memphis, :position => 1)
        end

        1.times do
          user = User.make
          election.rankings.create(:user => user, :candidate => chattanooga, :position => 4)
          election.rankings.create(:user => user, :candidate => knoxville, :position => 3)
          election.rankings.create(:user => user, :candidate => nashville, :position => 2)
          election.rankings.create(:user => user, :candidate => memphis, :position => 1)
        end

        2.times do
          user = User.make
          election.rankings.create(:user => user, :candidate => knoxville, :position => 4)
          election.rankings.create(:user => user, :candidate => chattanooga, :position => 3)
          election.rankings.create(:user => user, :candidate => nashville, :position => 2)
          election.rankings.create(:user => user, :candidate => memphis, :position => 1)
        end

        election.compute_global_ranking

        nashville.reload.position.should == 1
        chattanooga.position.should == 2
        knoxville.position.should == 3
        memphis.position.should == 4
        unranked.position.should == 5

        election.updated_at.to_i.should == Time.now.to_i
      end
    end

    describe "security" do
      attr_reader :organization, :member, :owner, :admin, :non_member

      before do
        @organization = Organization.make
        @member = make_member(organization)
        @owner = make_owner(organization)
        @admin = User.make(:admin => true)
        @non_member = User.make
      end

      describe "#can_create?" do
        it "only allows admins and members of an organization to create elections in it" do
          set_current_user(non_member)
          election = organization.elections.build(:body => "What should we do?")

          election.can_create?.should be_false

          set_current_user(member)
          election.can_create?.should be_true

          set_current_user(admin)
          election.can_create?.should be_true
        end
      end

      describe "#can_update? and #can_destroy?" do
        it "only allows admins, organization owners, and the creator of the election itself to update or destroy it" do
          other_member = set_current_user(User.make)
          organization.memberships.create!(:user => other_member, :suppress_invite_email => true)
          election = organization.elections.create!(:body => "What should we do?")

          set_current_user(member)
          election.can_update?.should be_false
          election.can_destroy?.should be_false


          set_current_user(other_member)
          election.can_update?.should be_true
          election.can_destroy?.should be_true

          set_current_user(owner)
          election.can_update?.should be_true
          election.can_destroy?.should be_true

          set_current_user(admin)
          election.can_update?.should be_true
          election.can_destroy?.should be_true
        end
      end
    end
  end
end