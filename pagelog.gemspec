# pagelog.gemspec
Gem::Specification.new do |s|
  s.version = '0.0.1'
  s.name = "pagelog"
  s.extra_rdoc_files = [
    "README.textile"
  ]
  s.files = Dir["MIT-LICENSE",
                "README.textile",
                "Rakefile",
                "VERSION",
                "init.rb",
                "install.rb",
                "uninstall.rb",
                "app/**/*",
                "images/**/*",
                "javascripts/**/*",
                "lib/**/*",
                "stylesheets/**/*",
                "test/**/*"]
  s.summary = "A web page log plugin"
  s.description = "This plugin is used to show the current page log information!"
  s.email = "hansen272@gmail.com"
  s.homepage =  %q{http://github.com/hansen/page_log}
  s.authors = ["Hansen.wang"]
  s.test_files = []
  s.require_paths = [".", "lib"]
  s.rubygems_version = %q{1.3.6}
  s.has_rdoc = true
  s.rdoc_options = ["--main", "README.textile", "--inline-source", "--line-numbers"]  
end
