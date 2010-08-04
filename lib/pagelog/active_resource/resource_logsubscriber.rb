require 'rails'
require 'pagelog/log_content'
require 'active_resource/log_subscriber'
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
    class ResourceLogSubscriber < ActiveResource::LogSubscriber

      #===================================
      #ActiveResource 对应的日志输出方法
      #===================================
      # result = event.payload[:result]
      # info "#{event.payload[:method].to_s.upcase} #{event.payload[:request_uri]}"
      # info "--> %d %s %d (%.1fms)" % [result.code, result.message, result.body.to_s.length, event.duration]
      def request(event)
        info "HHHHHHHHH"
      end

      #def self.enable
      #  if Kernel.respond_to?(:g)
        # Ironmine::Log::ResourceLogSubscriber.attach_to :active_resource
       # end
      #end

     
    end
  end
end
