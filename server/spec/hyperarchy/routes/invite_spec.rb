require File.expand_path("#{File.dirname(__FILE__)}/../../hyperarchy_spec_helper")

describe "POST /invite", :type => :rack do
  attr_reader :organization, :owner, :member

  before do
    @organization = Organization.make
    @owner = make_owner(organization)
    @member = make_member(organization)
  end

  context "if the current user is an owner of the specified organization" do
    before do
      login_as(owner)
    end

    it "creates a pending membership to the organization of the specified role with each of the given email addresses" do
      prev_membership_count = organization.memberships.size
      post "/invite", :organization_id => organization.id, :role => "owner", :email_addresses => ["foo@example.com", "bar@example.com"].to_json
      organization.memberships.size.should == prev_membership_count + 2

      i1 = Invitation.find(:sent_to_address => "foo@example.com", :inviter => current_user)
      i2 = Invitation.find(:sent_to_address => "bar@example.com", :inviter => current_user)
      m1 = organization.memberships.find(:invitation_id => i1.id, :pending => true)
      m2 = organization.memberships.find(:invitation_id => i2.id, :pending => true)
      m1.role.should == "owner"
      m2.role.should == "owner"

      dataset = last_response.body_from_json["dataset"]
      dataset["memberships"].should have_key(m1.id.to_s)
      dataset["memberships"].should have_key(m2.id.to_s)
    end
  end

  context "if the current user is not the owner of the specified organization" do
    before do
      login_as(member)
    end

    it "raises a security error" do
      dont_allow(Membership.table).insert
      post "/invite", :organization_id => organization.id, :email_addresses => ["foo@example.com", "bar@example.com"].to_json
      last_response.status.should == 401
    end
  end
end
