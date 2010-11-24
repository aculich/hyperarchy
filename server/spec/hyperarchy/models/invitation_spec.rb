require File.expand_path("#{File.dirname(__FILE__)}/../../hyperarchy_spec_helper")

module Models
  describe Invitation do
    attr_reader :inviter, :invitation

    before do
      set_current_user(User.make)
      @inviter = User.make
      @invitation = Invitation.create!(:inviter => inviter, :sent_to_address => "bob@example.com")
    end

    describe "before create" do
      def inviter
        nil
      end

      it "assigns a guid to the invitation and assigns the current user as the inviter if none is already specified" do
        invitation.guid.should_not be_nil
        invitation.inviter.should == current_user
      end
    end

    describe "#redeem" do
      it "if not already redeemed, creates and returns a user with the given properties, otherwise raises" do
        invitation.should_not be_redeemed
        user = invitation.redeem(:first_name => "Chevy", :last_name => "Chase", :email_address => "chevy@example.com", :password => "password")
        invitation.should be_redeemed
        invitation.invitee.should == user

        user.should_not be_dirty
        user.full_name.should == "Chevy Chase"
        user.email_address.should == "chevy@example.com"

        lambda do
          invitation.redeem(:full_name => "Chevy Chase", :email_address => "chevy@example.com", :password => "password")
        end.should raise_error
      end
    end
  end
end
