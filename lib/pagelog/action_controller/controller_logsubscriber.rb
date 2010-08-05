require 'rails'
require 'pagelog/log_content'
require 'action_controller/log_subscriber'
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
    class ControllerLogSubscriber < ActionController::LogSubscriber
      #===================================
      #ActionController 对应的日志输出方法
      #===================================
      # 日志信息:
      #info "  Processing by #{payload[:controller]}##{payload[:action]} as #{payload[:formats].first.to_s.upcase}"
      #info "  Parameters: #{params.inspect}" unless params.empty?
      # 可以提取的参数除开event，主要为layout参数 raw_payload参数:
      #raw_payload = {
      # :controller => self.class.name,
      # :action     => self.action_name,
      # :params     => request.filtered_parameters,
      # :formats    => request.formats.map(&:to_sym),
      # :method     => request.method,
      # :path       => (request.fullpath rescue "unknown")
      # }
      #
      def start_processing(event)
        ssid = Logsession.cur_session_id
        payload = event.payload
        #if LogContent.get_var("#{Identity.cur_session_id}","redirect_to","0").nil? then
         #  LogContent.delete_var("#{Thread.current.to_s}")
       # end
        if !(payload[:controller].to_s =="LogsController") then
          Thread.current[:flag]=1
        else
          Thread.current[:flag]=2
        end         
        LogContent.set_var("#{Thread.current.to_s}","controller","1",payload[:controller]);
        LogContent.set_var("#{Thread.current.to_s}","action","1",payload[:action]);
      end

      # 日志信息
      # message = "Completed #{payload[:status]} #{Rack::Utils::HTTP_STATUS_CODES[payload[:status]]} in %.0fms" % event.duration
      # message << " (#{additions.join(" | ")})" unless additions.blank?
      # 可以提取的参数除开event，还包括:
      # payload[:status]  浏览器返回状态
      def process_action(event)
        ssid = Logsession.cur_session_id
        payload = event.payload
        additions = ActionController::Base.log_process_action(payload)

        #完成信息
        tmp_msg = " "
        tmp_msg << "(#{additions.join(" | ")})" unless additions.blank?
        if tmp_msg==" " then
          tmp_msg = "(%.0fms)" % event.duration
        end
        #当前对应的指针
        i = LogContent.max_val("#{ssid}","action_id")

        #将controller的数据在当前action执行完成时整理到Completed事件对应的位置中
        LogContent.replace_key1("#{Thread.current.to_s}","#{ssid}","#{i}")
        LogContent.set_var("#{ssid}","status","#{i}","#{Rack::Utils::HTTP_STATUS_CODES[payload[:status]]}");
        LogContent.set_var("#{ssid}","message","#{i}",tmp_msg);

        #p LogContent.content
        
      end

      # "Sent file %s"
      def send_file(event)

      end

      # 日志信息
      # info "Redirected to #{event.payload[:location]}"
      # 可以提取的参数除开event，还包括:
      # payload[:location]  转向地址
      def redirect_to(event)
        
        LogContent.set_var("#{Logsession.cur_session_id}","redirect_to","0","1")

      end

      #info("Sent data %s (%.1fms)" % [event.payload[:filename], event.duration])
      def send_data(event)

      end
    end
  end
end
