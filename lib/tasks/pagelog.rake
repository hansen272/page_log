require 'rails/deprecation'
require 'fileutils'
namespace :page_log do
  desc "Create the plugin need images,js,and css file"
  task :setup do
    puts "============start copy file============"
    puts "-------loading.gif-------"
    FileUtils.copy(File.join(File.dirname(__FILE__), "../../images", "loading.gif"), File.join(Rails.root, "public/images", "loading.gif"))
    puts "-------pagelog.js-------"
    FileUtils.copy(File.join(File.dirname(__FILE__), "../../javascripts", "pagelog.js"), File.join(Rails.root, "public/javascripts", "pagelog.js"))
    puts "-------pagelog.css-------"
    FileUtils.copy(File.join(File.dirname(__FILE__), "../../stylesheets", "pagelog.css"), File.join(Rails.root, "public/stylesheets", "pagelog.css"))
    puts "============end copy file============"

  end
end

