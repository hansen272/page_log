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
        payload = event.payload
        #由于渲染监控页面时候也会触发该方法，所以需要将该方法排除
        if !(payload[:controller].to_s =="LogsController") then
          #Thread.current[:flag]=1标示当前是正常的方法执行
          Thread.current[:flag]=1
        else
          #Thread.current[:flag]=2标示当前是渲染的方法
          Thread.current[:flag]=2
        end
        #获取controller 和 action
        LogContent.set_var("#{Thread.current.to_s}","controller","1",payload[:controller]);
        LogContent.set_var("#{Thread.current.to_s}","action","1",payload[:action]);
      end

      # 日志信息
      # message = "Completed #{payload[:status]} #{Rack::Utils::HTTP_STATUS_CODES[payload[:status]]} in %.0fms" % event.duration
      # message << " (#{additions.join(" | ")})" unless additions.blank?
      # 可以提取的参数除开event，还包括:
      # payload[:status]  浏览器返回状态
      # action执行完成后触发 的方法
      def process_action(event)
        #获取当前的ssid
        ssid = Logsession.cur_session_id
        payload = event.payload
        #controller执行过程的时间消耗信息
        additions = ActionController::Base.log_process_action(payload)

        #完成信息
        tmp_msg = " "
        tmp_msg << "(#{additions.join(" | ")})" unless additions.blank?
        if tmp_msg==" " then
          tmp_msg = "(%.0fms)" % event.duration
        end
        #当前对应的指针
        i = LogContent.max_val("#{ssid}","action_id")

        #将controller的中间数据在当前action执行完成时整理到带有时间信息的完整数据中
        LogContent.replace_key1("#{Thread.current.to_s}","#{ssid}","#{i}")

        #获取时间信息和状态
        LogContent.set_var("#{ssid}","status","#{i}","#{Rack::Utils::HTTP_STATUS_CODES[payload[:status]]}");
        LogContent.set_var("#{ssid}","message","#{i}",tmp_msg);

        #info LogContent.content
        
      end

      # "Sent file %s"
      def send_file(event)

      end

      # 日志信息
      # info "Redirected to #{event.payload[:location]}"
      # 可以提取的参数除开event，还包括:
      # payload[:location]  转向地址
      # 设置当前页面是否是由Redirect to进入的
      def redirect_to(event)
        #如果该值为1表示不能删除数据，否则可以删除
        LogContent.set_var("#{Logsession.cur_session_id}","redirect_to","0","1")
      end

      #info("Sent data %s (%.1fms)" % [event.payload[:filename], event.duration])
      def send_data(event)

      end
    end
  end
end
