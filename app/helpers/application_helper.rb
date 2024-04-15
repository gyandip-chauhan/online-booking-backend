# frozen_string_literal: true

module ApplicationHelper
    # def user_avatar(user)
    #   if user.avatar.attached?
    #     url_for(user.avatar)
    #   else
    #     image_url "avatar.svg"
    #   end
    # end
  
    # def company_logo(company)
    #   if company.logo.attached?
    #     company.logo
    #   else
    #     image_url "company.svg"
    #   end
    # end
  
    def error_message_on(resource, attribute)
      return unless resource.respond_to?(:errors) && resource.errors.include?(attribute)
  
      field_error(resource, attribute)
    end
  
    def error_message_class(resource, attribute)
      if resource.respond_to?(:errors) && resource.errors.include?(attribute)
        "border-red-600 focus:ring-red-600 focus:border-red-600"
      else
        "border-gray-100 focus:ring-miru-gray-1000 focus:border-miru-gray-1000"
      end
    end
  
    def auth_brand_logo
      content_tag(:div, class: "mx-auto h-8 w-auto text-center") do
        image_tag("brand/ac-logo.svg", width: "20%")
      end
    end
  
    def get_initial_props
      {
        user: current_user
        # userProfile: current_user && user_avatar(current_user),
        # avatar_url: current_user && current_user.avatar_url,
        # company_role: current_user && current_user.roles.find_by(resource: current_company)&.name,
        # confirmed_user: current_user && current_user.confirmed?,
        # company: current_company,
        # google_oauth_success: @google_oauth_success.present?,
        # calendar_enabled: current_user && current_user.calendar_enabled,
        # calendar_connected: current_user && current_user.calendar_connected,
        # permissions: current_user ? {
        #   "leads" => LeadPolicy.new(current_user, nil).index?,
        #   "engagements" => EngagementPolicy.new(current_user, nil).index?,
        #   'engagementsDashboard': EngagementPolicy.new(current_user, nil).admin_access?,
        #   'recruitment': Recruitment::CandidatePolicy.new(current_user, nil).allowed_users?,
        #   'deviceUpdate': DevicePolicy.new(current_user, nil).update?,
        #   'employmentUpdate': TeamPolicy.new(current_user, current_employment).update?,
        #   'teams': TeamPolicy.new(current_user, current_employment).index?,
        #   'clients': ClientPolicy.new(current_user, nil).index?,
        #   'projectCreate': ProjectPolicy.new(current_user, nil).create?,
        #   'timesheetLeadFilter': TimesheetEntryPolicy.new(current_user, nil).lead_filter?,
        #   'reports': ReportPolicy.new(current_user, nil).allowed_user?,
        #   'profileUpdate': Profiles::TeamMemberPolicy.new(current_user, nil).update?,
        #   'teamLead': TeamPolicy.new(current_user, nil).team_lead_allowed
        # } : {}
      }
    end
  
    private
  
      def field_error(resource, attribute)
        resource.errors[attribute].first
      end
  end