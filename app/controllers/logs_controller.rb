class LogsController < ApplicationController
 def show_log
    respond_to do |format|
      format.html
      format.js
     end
 end
end
