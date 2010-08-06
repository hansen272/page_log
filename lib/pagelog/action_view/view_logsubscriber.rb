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
        #获取session_id
        ssid = Logsession.cur_session_id
        #info "#{ssid}  render_template #{Thread.current[:flag]}"
        #这里的逻辑验证时为:如果ssid不为空并且不是有显示监控页面触发的就进行下面的逻辑，否则不执行
        if !ssid.nil? && Thread.current[:flag]!=2  then
          #获取render指针值
          i = LogContent.max_val("#{ssid}","render_id")
          #获取Redirect to开关值，该值在ControllerLogSubscriber的redirect_to方法实现
          k = LogContent.get_var("#{ssid}","redirect_to","0")
          #info "#{Thread.current[:flag]} FFFF #{event.payload[:name]} FFF  #{ssid} FF #{k}"

          #如果是新打开页面页面
          if Thread.current[:flag]==1  then
             #如果不是redirect 痛进入的则删除hash中的数据
             if k.to_s != "1" then
               #info "view delete"
               LogContent.delete_var("#{ssid}")
             end
             #将新页面标示置为0
             Thread.current[:flag]=0
          else
             #将redirect标示置为0
             LogContent.set_var("#{ssid}","redirect_to","0","0")
          end

          #存储render信息， identifier为路径，rendertime为时间
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

