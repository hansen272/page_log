class LogsController < ApplicationController
  #由page_log link远程调用，执行对应的js文件show_log.js.erb
  def show_log
    respond_to do |format|
      format.html
      format.js
    end
  end
end
