class Logsession < ActiveRecord::Base
  def self.cur_session_id=(cur_session_id)
    @cur_session_id =cur_session_id
  end

  def self.cur_session_id
    @cur_session_id
  end
end
