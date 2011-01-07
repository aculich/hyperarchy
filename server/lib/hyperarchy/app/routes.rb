module Hyperarchy
  class App < Sinatra::Base
    before do
      no_internet_explorer
    end

    error Monarch::Unauthorized do
      status 401
      warden.custom_failure!
      "Sorry. That action is not authorized."
    end

    get "/" do
      redirect_if_logged_in
      render_page Views::Home
    end

    get "/learn_more" do
      redirect_if_logged_in
      render_page Views::LearnMore
    end

    get "/app" do
      use_ssl
      authentication_required
      render_page Views::App
    end

    get "/login" do
      use_ssl
      render_page Views::Login
    end

    post "/login" do
      warden.logout(:default)
      if warden.authenticate

        if params[:redirected_from]
          redirect params[:redirected_from]
        else
          redirect "/app#view=organization"
        end
      else
        flash[:errors] = warden.errors.full_messages
        flash[:email_address_errors] = warden.errors[:email_address]
        flash[:entered_email_address] = params[:email_address]
        redirect "/login"
      end
    end

    post "/logout" do
      warden.logout(:default)
      redirect "/"
    end

    get "/signup" do
      redirect_if_logged_in
      use_ssl
      if invitation_code = params[:invitation_code] || session[:invitation_code]
        invitation = validate_invitation_code(invitation_code)
        session[:invitation_code] = invitation_code
      end

      render_page Views::Signup, :invitation => invitation, :user => User.new
    end

    post "/signup" do
      redirect_if_logged_in
      if invitation_code = session[:invitation_code]
        invitation = validate_invitation_code(invitation_code)
      else
        organization_name = params[:organization][:name]
        if organization_name.blank?
          flash[:errors] = ["You must enter an organization name."]
          redirect "/signup"
          return
        end
      end

      if invitation
        redeem_invitation(invitation)
      else
        create_user_and_organization(organization_name)
      end
    end

    def redeem_invitation(invitation)
      new_user = invitation.redeem(params[:user])
      if new_user.valid?
        warden.set_user(new_user)
        session.delete(:invitation_code)
        redirect "/app#view=organization&organizationId=#{new_user.organizations.first.id}"
      else
        flash[:errors] = new_user.validation_errors
        redirect "/signup"
      end
    end

    def create_user_and_organization(organization_name)
      new_user = User.create(params[:user])
      if new_user.valid?
        warden.set_user(new_user)
        organization = Organization.create!(:name => organization_name)
        redirect "/app#view=organization&organizationId=#{organization.id}"
      else
        flash[:errors] = new_user.validation_errors
        redirect "/signup"
      end
    end

    get "/confirm_membership/:membership_id" do |membership_id|
      authentication_required

      membership = Membership.find(membership_id)
      membership.update(:pending => false) if membership.user == current_user
      redirect "/app#view=organization&organizationId=#{membership.organization_id}"
    end

    post "/invite" do
      begin
        email_addresses = Mail::AddressList.new(params[:email_addresses]).addresses.map(&:address)
      rescue Mail::Field::ParseError => e
        halt unsuccessful_json_response
      end

      organizations = params[:organization_ids].from_json.map {|id| Organization.find(id)}

      unless current_user.admin?
        organizations.each do |organization|
          unless organization.members_can_invite? || organization.has_owner?(current_user)
            raise Monarch::Unauthorized
          end
        end
      end

      memberships = organizations.map do |organization|
        email_addresses.map do |email_address|
          if existing_user = User.find(:email_address => email_address)
            organization.memberships.find_or_create(:user => existing_user)
          elsif existing_invitation = Invitation.find(:sent_to_address => email_address)
            organization.memberships.find_or_create(:invitation_id => existing_invitation.id)
          else
            organization.memberships.create!(:email_address => email_address)
          end
        end
      end.flatten

      successful_json_response(nil, memberships)
    end

    post "/feedback" do
      Mailer.send(
        :to => ["admin@hyperarchy.com", "nathansobo+hyperarchy@gmail.com"],
        :subject => "#{current_user.full_name} submitted feedback",
        :body => "User id: #{current_user.id}\n\nTheir comments: #{params[:feedback]}"
      )
      successful_json_response
    end

    post "/dismiss_welcome_blurb" do
      current_user.update(:dismissed_welcome_blurb => true)
      successful_json_response
    end

    post "/dismiss_welcome_guide" do
      organization = Organization.find(params[:organization_id])
      organization.update!(:dismissed_welcome_guide => true)
      current_user.update!(:dismissed_welcome_guide => true)
      successful_json_response
    end

    post "/subscribe_to_organization/:id" do |organization_id|
      organization = Organization.find(organization_id)
      subscription_id = SubscriptionManager.subscribe_to_organization(current_real_time_client, organization)

      if subscription_id
        successful_json_response(subscription_id)
      else
        unsuccessful_json_response
      end
    end

    get "/fetch_organization_page" do
      organization = Organization.find(params[:organization_id])
      raise Monarch::Unauthorized unless organization.current_user_is_member? || current_user.admin?
      items_per_page = params[:items_per_page].to_i
      page = params[:page].to_i
      prev_page = page - 1
      num_pages_to_fetch = page > 1 ? 3 : 2
      offset = prev_page > 1 ? (prev_page - 1) * items_per_page : nil
      limit = num_pages_to_fetch * items_per_page

      elections = organization.elections.order_by(Election[:score].desc).limit(limit)
      elections = elections.offset(offset) if offset

      successful_json_response(nil, [elections, elections.join_through(Candidate), elections.join_through(current_user.election_visits)])
    end

    post "/visited" do
      authentication_required
      visit = ElectionVisit.find_or_create(:user_id => current_user.id, :election_id => params[:election_id])
      visit.update!(:updated_at => Time.now)
      successful_json_response(nil, visit)
    end

    post "/rankings" do
      authentication_required

      organization = Candidate.find(params[:candidate_id]).election.organization
      unless current_user && organization.has_member?(current_user)
        raise Monarch::Unauthorized
      end

      attributes = { :user_id => current_user.id, :candidate_id => params[:candidate_id] }

      if ranking = Ranking.find(attributes)
        ranking.update(:position => params[:position])
      else
        ranking = Ranking.create!(attributes.merge(:position => params[:position]))
      end
      successful_json_response({:ranking_id => ranking.id}, ranking)
    end

    post "/client_error" do
      Mailer.send(
        :to => ["admin@hyperarchy.com", "nathansobo+hyperarchy@gmail.com"],
        :subject => "#{current_user.full_name} encountered a client error",
        :body => "User id: #{current_user.id}\n\nError info: #{params[:error]}"
      )
      successful_json_response
    end
  end
end