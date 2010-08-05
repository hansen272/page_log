require 'pagelog/log_content'
module Pagelog
  module LogHelper
    
    #引用css
    def pagelog_head()

      html = stylesheet_link_tag('pagelog')+javascript_include_tag('pagelog')      
      html
    end

    #创建链接
    def pagelog_link()

      html = link_to("log_info", {:controller=>"logs",:action=>"show_log"},:remote => true,:id=>"log_link",:class=>"log_link")
      html
    end

    #创建显示区域
    def pagelog_showdiv()

      html = content_tag(:div,"",{:id=>"log_content"})
      html
    end

    #输出log的详细信息
    def log_output()
      #获取session_id
      ssid = "#{Logsession.cur_session_id}";
      #---------------整理controller的信息-----------------
      td_action_tag = content_tag(:td,log_action_tag,nil,false)

      #---------------整理page的信息-----------------
      td_render_tag = content_tag(:td,log_render_tag,nil,false)

      #----------------整理sql信息--------------------
      td_sql_tag = content_tag(:td,log_sql_tag,nil,false)
      
      html = content_tag(:table,content_tag(:tr,td_action_tag)+content_tag(:tr,td_render_tag)+content_tag(:tr,td_sql_tag),{:class => "logs"},false);
      #返回html
      html = content_tag(:div,html,{:class=>"logs"},false)
    end

    #输出action部分对应的表格
    def log_action_tag
      ssid = "#{Logsession.cur_session_id}";
      action_header_tag = content_tag(:tr,content_tag(:th,"controller#action")+content_tag(:th,"耗时情况"),nil,false);
      action_body_tag = ""
      #获取对应的有序数组
      arry_c = LogContent.get_sorted_values("#{ssid}","controller")
      arry_a = LogContent.get_sorted_values("#{ssid}","action")
      arry_m = LogContent.get_sorted_values("#{ssid}","message")
      arry_s = LogContent.get_sorted_values("#{ssid}","status")
      for i in 0..arry_c.count-1
         action_body_tag << content_tag(:tr,content_tag(:td,"#{arry_c[i]}##{arry_a[i]}")+content_tag(:td,arry_m[i]),nil,false);
      end

      action_tag = content_tag(:table,action_header_tag+raw(action_body_tag),{:class=>"sublogs"},false);
    end

    #输出view部分对应的表格
    def log_render_tag
      ssid = "#{Logsession.cur_session_id}";
      render_header_tag = content_tag(:tr,content_tag(:th,"页面名称")+content_tag(:th,"渲染耗时"),nil,false);

      #组织render body信息
      render_body_tag=""
      arry_i = LogContent.get_sorted_values("#{ssid}","identifier")
      arry_r = LogContent.get_sorted_values("#{ssid}","rendertime")

      for i in 0..arry_i.count-1
        render_body_tag << content_tag(:tr,content_tag(:td,"#{arry_i[i]}")+content_tag(:td,arry_r[i]),nil,false);
      end

      #输出render body信息
      render_tag = content_tag(:table,render_header_tag+raw(render_body_tag),{:class=>"sublogs"},false);
    end

    #输出active_record部分对应的表格
    def log_sql_tag
      ssid = "#{Logsession.cur_session_id}";
      sql_header_tag = content_tag(:tr,content_tag(:th,"sql语句")+content_tag(:th,"sql耗时"),nil,false);

      #组织sql body信息
      sql_body_tag =""
      arry_m = LogContent.get_sorted_values("#{ssid}","model")
      arry_s = LogContent.get_sorted_values("#{ssid}","sqlvar")
      arry_t = LogContent.get_sorted_values("#{ssid}","sqltime")
      for i in 0..arry_m.count-1
        #这里使用tmp的目的是在进行增删改操作的时候，对应的耗时是在commit的时候才有的
        tmp = arry_s[i]
        if arry_t[i] != "(0.0ms)" then
          if tmp == "COMMIT"
            tmp= arry_s[i-1]
          end
          sql_body_tag << content_tag(:tr,content_tag(:td,"#{tmp}")+content_tag(:td,arry_t[i]),nil,false);
        end
      end
      #输出sql body信息
      sql_tag = content_tag(:table,sql_header_tag+raw(sql_body_tag),{:class=>"sublogs"},false);
    end
  end
end