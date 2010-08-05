require 'rails'
require 'pagelog/log_content'
require 'action_view/log_subscriber'
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
    class ViewLogSubscriber < ActionView::LogSubscriber
      #===================================
      #ActionView 对应的日志输出方法
      #===================================
      # 日志信息
      # message = "Rendered #{from_rails_root(event.payload[:identifier])}"
      # message << " within #{from_rails_root(event.payload[:layout])}" if event.payload[:layout]
      # message << (" (%.1fms)" % event.duration)
      # 可以输出参数，重点为event中的payload:
      # :identifier 渲染路径文件
      # :layout     引用文件
      def  render_template(event)
        # info LogContent.content.to_s
        ssid = Logsession.cur_session_id
        #info "#{ssid}  render_template #{Thread.current[:flag]}"
        if !ssid.nil? && Thread.current[:flag]!=2  then
          i = LogContent.max_val("#{ssid}","render_id")
          k = LogContent.get_var("#{ssid}","redirect_to","0")
          #info "#{Thread.current[:flag]} FFFF #{event.payload[:name]} FFF  #{ssid} FF #{k}"

          if Thread.current[:flag]==1  then
             if k.to_s != "1" then
               info "view delete"
               LogContent.delete_var("#{ssid}")
             end
             Thread.current[:flag]=0
          else
             LogContent.set_var("#{ssid}","redirect_to","0","0")
          end

          LogContent.set_var("#{ssid}","identifier","#{i}",from_rails_root(event.payload[:identifier]));
          LogContent.set_var("#{ssid}","rendertime","#{i}",event.duration);

        end
      end
      alias :render_partial :render_template
      alias :render_collection :render_template
      protected
        def from_rails_root(string)
          string.sub("#{Rails.root}/", "").sub(/^app\/views\//, "")
        end
    end
  end
end

