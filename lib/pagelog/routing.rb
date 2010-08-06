Rails.application.routes.draw do |map|
  match 'logs/show_log' => 'logs#show_log'
end