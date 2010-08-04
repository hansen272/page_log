require 'rails'
require 'pagelog/log_content'
require 'active_support/core_ext/time/conversions'

module Pagelog
  #该Logs module主要是收集各个模块log日志信息中各个event的数据，event的代码如下
  #class Event
  #  attr_reader :name, :time, :end, :transaction_id, :payload
  #
  #  def initialize(name, start, ending, transaction_id, payload)
  #    @name           = name
  #    @payload        = payload.dup
  #    @time           = start
  #    @transaction_id = transaction_id
  #    @end            = ending
  #  end
  #
  #  def duration
  #    @duration ||= 1000.0 * (@end - @time)
  #  end
  #
  #  def parent_of?(event)
  #    start = (self.time - event.time) * 1000
  #    start <= 0 && (start + duration >= event.duration)
  #  end
  #end
  #在与ActiveSupport::Notifications绑定时，还会传入相应的参数
  module Logs
    class RecordLogSubscriber < ActiveRecord::LogSubscriber
   
      #===================================
      #ActiveRcord 对应的日志输出方法，主要对应sql执行情况的处理
      #===================================
      # 日志信息:
      # :sql => sql, :name => "CACHE", :connection_id => self.object_id
      # name = '%s (%.1fms)' % [event.payload[:name], event.duration]
      # sql  = event.payload[:sql].squeeze(' ')
      # 可以提取的参数:
      # event.payload[:name]  model名称
      # event.payload[:sql]   sql代码
      # event.transaction_id
      # event.duration        sql执行时间
      def sql(event)
        ssid = Identity.cur_session_id
        if !ssid.nil? && Thread.current[:flag]!=2  then
          i = LogContent.max_val("#{Identity.cur_session_id}","sql_id")
          k = LogContent.get_var("#{Identity.cur_session_id}","redirect_to","0")
         #p "#{Thread.current[:flag]} FFFF #{event.payload[:name]} FFF  #{Identity.cur_session_id} FF #{k}"

          if Thread.current[:flag]==1  then
             if k.to_s != "1" then
               LogContent.delete_var("#{Identity.cur_session_id}")
             end
             Thread.current[:flag]=0
          else
             LogContent.set_var("#{Identity.cur_session_id}","redirect_to","0","0")
          end

          LogContent.set_var("#{Identity.cur_session_id}","model","#{i}",event.payload[:name]);
          LogContent.set_var("#{Identity.cur_session_id}","sqlvar","#{i}",event.payload[:sql]);
          LogContent.set_var("#{Identity.cur_session_id}","sqltime","#{i}",'(%.1fms)' % event.duration);
        end
      end
    end
  end
end
