# Stackdriver Incident plugin for Redmine

Plugin to operate issues with webhooks from stackdriver.

Put plugin into plugins directory, then restart Redmine.

Create project for alerts and custom field incident_id for issues. Create user for alerting and add to project as reporter.

Add Webhook notification channel in Stackdriver with this url:
https://<your_domain>/projects/<project_id>/stackdriver_incident/webhook?tracker_id=<tracker_id>&creation_status_id=<id_of_issue_status_on_creation>

