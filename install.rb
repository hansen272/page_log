# Install hook code here
require 'fileutils'

module Pagelog
  module InstallHelpers
    def self.copy_files dir, files, rails_folder="public"
      files.each do |js_file|
        dest_dir = File.join(RAILS_ROOT, rails_folder,dir)
        FileUtils.mkdir(dest_dir) unless File.exist? dest_dir
        dest_file = File.join(dest_dir, js_file)
        src_file = File.join(File.dirname(__FILE__) , dir, js_file)
        FileUtils.cp_r(src_file, dest_file) unless File.exist?(dest_file)

      end
    end
  end
end


puts "Copy started..."
Pagelog::InstallHelpers::copy_files 'javascripts',["pagelog.js"]
Pagelog::InstallHelpers::copy_files 'stylesheets',["pagelog.css"]
Swfupload::InstallHelpers::copy_files 'images',["loading.gif"]
puts "Files copied - Installation complete!"
