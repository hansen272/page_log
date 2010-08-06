require 'rails'
require 'pagelog/log_content'
require 'active_record/log_subscriber'
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
        #获取sessionId
        ssid = Logsession.cur_session_id

        #这里的逻辑验证时为:如果ssid不为空并且不是有显示监控页面触发的就进行下面的逻辑，否则不执行
        if !ssid.nil? && Thread.current[:flag]!=2  then
          #获取sql存储指针
          i = LogContent.max_val("#{ssid}","sql_id")
          #获取redirect 开关值
          k = LogContent.get_var("#{ssid}","redirect_to","0")
          #info "#{Thread.current[:flag]} FFFF #{event.payload[:name]} FFF  #{ssid} FF #{k}"

          #当是新打开页面页面
          if Thread.current[:flag]==1  then
             #如果不是redirect 痛进入的则删除hash中的数据
             if k.to_s != "1" then
               #info "Record #{LogContent.content}"
               LogContent.delete_var("#{ssid}")
             end
             #将新页面标示置为0
             Thread.current[:flag]=0
          else
            #将redirect标示置为0
            LogContent.set_var("#{ssid}","redirect_to","0","0")
          end

          #存储sql信息数据，
          #model名称
          LogContent.set_var("#{ssid}","model","#{i}",event.payload[:name]);
          #sql代码
          LogContent.set_var("#{ssid}","sqlvar","#{i}",event.payload[:sql]);
          #sql执行时间
          LogContent.set_var("#{ssid}","sqltime","#{i}",'(%.1fms)' % event.duration);
        end
      end
    end
  end
end
