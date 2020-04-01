require "json"

class StackdriverIncidentController < ApplicationController
  skip_before_action :verify_authenticity_token
  accept_api_auth :webhook

  def webhook
    incident_json = JSON.parse(request.raw_post()).with_indifferent_access[:incident]
    @project = Project.find(params[:project_id])

    unless User.current.allowed_to?(:add_issues, @project, :global => true)
      raise ::Unauthorized
    end

    incident = CustomField.select(
      'id',
      'custom_values.customized_id'
    ).joins(:custom_values).where(
      'name' => 'incident_id',
      'custom_values.customized_type' => 'Issue',
      'custom_values.value' => incident_json[:incident_id]
    )

    if incident.exists? then
      issue = Issue.find(incident.take[:customized_id])

      journal = Journal.new(
        :journalized => issue,
        :user => User.current,
        :notes => incident_json[:policy_name] + ' alert is ' + incident_json[:state],
        :private_notes => false
      )
      journal.save!

      render inline: journal.to_json
    else
      incident_field = CustomField.where('name' => 'incident_id').take

      issue = Issue.new(
        :author => User.current,
        :project => @project,
        :subject => incident_json[:policy_name] + ' alert',
        :description => incident_json[:policy_name] + ' alert is ' + incident_json[:state],
        :custom_field_values => {
          incident_field.id => incident_json[:incident_id]
        },
        :tracker_id => params[:tracker_id],
        :status_id => params[:creation_status_id]
      )
      issue.save!

      render inline: issue.to_json
    end
  end
end
