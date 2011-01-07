class Organization < Monarch::Model::Record
  column :name, :string
  column :description, :string, :default => ""
  column :members_can_invite, :boolean, :default => false
  column :dismissed_welcome_guide, :boolean, :default => false
  column :use_ssl, :boolean, :default => true
  column :election_count, :integer, :default => 0
  column :created_at, :datetime
  column :updated_at, :datetime

  has_many :elections
  has_many :memberships

  attr_accessor :suppress_membership_creation

  def can_update_or_destroy?
    current_user.admin? || has_owner?(current_user)
  end
  alias can_update? can_update_or_destroy?
  alias can_destroy? can_update_or_destroy?

  def after_create
    memberships.create(:user => current_user, :role => "owner", :pending => false) unless suppress_membership_creation
  end

  def has_member?(user)
    !memberships.find(:user_id => user.id).nil?
  end

  def current_user_is_member?
    return false unless current_user
    has_member?(current_user)
  end

  def has_owner?(user)
    !memberships.find(:user_id => user.id, :role => "owner").nil?
  end

  def organization_ids
    [id]
  end
end
