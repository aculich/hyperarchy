class Invitation < Monarch::Model::Record
  column :guid, :string
  column :sent_to_address, :string
  column :first_name, :string, :default => ""
  column :last_name, :string, :default => ""
  column :redeemed, :boolean
  column :inviter_id, :key
  column :invitee_id, :key

  belongs_to :inviter, :class_name => "User"
  belongs_to :invitee, :class_name => "User"
  has_many :memberships
  relates_to_many :organizations do
    memberships.join_through(Organization)
  end

  def before_create
    self.guid = Guid.new.to_s
    self.inviter ||= current_user
  end

  def email_address
    sent_to_address
  end

  def redeem(user_attributes)
    raise "Already redeemed" if redeemed?

    user = User.new(user_attributes)
    if user.valid?
      user.save
    else
      return user
    end
    self.invitee = user
    self.redeemed = true
    save

    memberships.each do |membership|
      membership.update!(:pending => false, :user => user)
    end
    user
  end

  def signup_url
    "#{Mailer.base_url}/signup?invitation_code=#{guid}"
  end
end