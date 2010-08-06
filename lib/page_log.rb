# PageLog
#扩展logs
require 'pagelog/action_controller/controller_logsubscriber'
require 'pagelog/action_view/view_logsubscriber'
require 'pagelog/active_record/record_logsubscriber'
require 'pagelog/active_resource/resource_logsubscriber'
require 'pagelog/routing'
require 'page_log_helper'
Pagelog::Logs::RecordLogSubscriber.attach_to :active_record
Pagelog::Logs::ViewLogSubscriber.attach_to :action_view
Pagelog::Logs::ControllerLogSubscriber.attach_to :action_controller
Pagelog::Logs::ResourceLogSubscriber.attach_to :active_resource


ActionView::Base.send(:include, Pagelog::LogHelper)

