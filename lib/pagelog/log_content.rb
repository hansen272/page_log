module Pagelog
  #module Logs
    class LogContent
      @@content=nil

      #获取当前的值
      def self.content
        @@content
      end

      #根据key1,key2获取当前的最大值，并将最大值加1
      def self.max_val(key1,key2)
        if @@content.is_a?(Hash) then
          if @@content.has_key?(key1) then
            @@content.each do |ikey,ivalue|
              if ikey == key1 then
                if ivalue.has_key?(key2) then
                  k = Integer(ivalue.fetch(key2))
                  ivalue.merge!({key2=>(Integer(k)+1)})
                  return k
                else
                  ivalue.merge!({"#{key2}"=>1})
                end
              end
            end
          else
            @@content.merge!({"#{key1}" => {"#{key2}"=>1}})
          end
        else
          @@content ||={"#{key1}" => {"#{key2}"=>1}}
        end
        return 0
      end

      #获取当前的key2对应的数组的数值数目
      def self.get_count(key1,key2)
        if @@content.has_key?(key1) then
           key1_value = @@content.fetch(key1)
           if key1_value.has_key?(key2) then
             key2_value =  key1_value.fetch(key2)
             if !key2_value.is_a?(Hash)
               return key2_value.to_i
             end
           end
        end
        return 0
      end

      #根据三段键值值设置键值
       def self.set_var(key1 ,key2,key3,value)
         #确保键值不能为空
         if key1.nil? || key2.nil? || key3.nil? then
           return
         end
         if @@content.is_a?(Hash) then
           tmp = {"#{key1}"=>{"#{key2}"=>{"#{key3}"=>"#{value}"}}}
           if @@content.has_key?(key1.to_s) then
             key1_value = @@content.fetch(key1.to_s)
             if key1_value.has_key?(key2.to_s) then
               key2_value=key1_value.fetch(key2.to_s)
               key2_value.merge!({"#{key3}"=>"#{value}"})
             else
               key1_value.merge!({"#{key2}"=>{"#{key3}"=>"#{value}"}})
             end
           else
              @@content.merge!(tmp)
           end
         else
           @@content = {"#{key1}"=>{"#{key2}"=>{"#{key3}"=>"#{value}"}}}
         end
       end

       
       #根据第一个键值替换,在讲Thread的值转换为session的值的时候很有用
       def self.replace_key1(old_key1 ,new_key1,key3)
         if @@content.has_key?(old_key1) then
           tmp = @@content.fetch(old_key1)
           tmp.each do |ikey2,ivalue2|
              ivalue2.each do |ikey3,ivalue3|
                self.set_var(new_key1.to_s,ikey2.to_s,key3.to_s,ivalue3.to_s)
              end
           end
            @@content.delete(old_key1)
         end
       end

      #根据键值1删除对应的值
       def self.delete_var(key)
         if @@content.is_a?(Hash) then
           if @@content.has_key?(key) then
             @@content.delete(key)
           end
         end
       end

       #根据当前的key1,key2以及count值获取对应的数组，该数组是hash中key2对应的排序后的值列表
       def self.get_sorted_values(key1,key2)
         ret =[]
         if @@content.has_key?(key1) then
           key1_value = @@content.fetch(key1)
           if key1_value.has_key?(key2) then
             key2_value =key1_value.fetch(key2)
             if key2_value.is_a?(Hash) then
               arry_sort = key2_value.sort_by{|key ,value| key.to_i}
               for i in 0..arry_sort.count-1
                 ret << arry_sort.to_a[i].to_a[1]
               end
             end
           end
         end
         #返回当前对应排序后的数组
         ret
       end

        #根据key值，获取value的值
        def self.get_var(key1,key2=nil,key3=nil)
          if @@content.has_key?(key1) then
            key1_value = @@content.fetch(key1)
            return key1_value if key2.nil?
            if key1_value.has_key?(key2) then
              key2_value = key1_value.fetch(key2)
              return key2_value if key3.nil?
              if key2_value.has_key?(key3) then
                 key3_value = key2_value.fetch(key3)
                 if !key3_value.is_a?(Hash) then
                   return key3_value
                 end
              end            
            end
          end
          nil
        end

    end
  end
#end