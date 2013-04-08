##  Main setup script wizard. Run it once, with "rake devcms:setup" command
##  All rights reserved, InterLink © 2000-2013

require 'io/console'

desc "Setup script"

  namespace :cms do

    task :testme do
      puts 'hello'
      ruby = File.join(*RbConfig::CONFIG.values_at('bindir', 'RUBY_INSTALL_NAME'))
      Dir.glob("devcms/test/*_test.rb").all? do |file|
        puts "test #{file}"
        sh(ruby, '-Ilib:test', file)
      end or raise "Failures"
    end

    # Installation script wizard should be able to roll back if the last run was not successful.
    task :wizard do
      
      OWNER_RAILS_ROOT=File.join(File.dirname(__FILE__), '../../../')
      OWNER_GEMFILE_PATH = OWNER_RAILS_ROOT + 'Gemfile'
      OWNER_SEED_FILE_PATH = OWNER_RAILS_ROOT + 'db/seeds.rb'    
      OWNER_ROUTE_FILE_PATH = OWNER_RAILS_ROOT + 'config/routes.rb'
      OWNER_APP_JS_PATH = OWNER_RAILS_ROOT + 'app/assets/javascripts/application.js'
      OWNER_APP_CSS_PATH = OWNER_RAILS_ROOT + 'app/assets/stylesheets/application.css'
      
      #
      # Wizard menu (todo):
      #
      
      puts "***Welcome to Cms setup Wizard. What is your wish?"
      puts "1 - Setup Cms for current project."
      ##puts "2 - Review current status of Cms"
      ##puts "3 - Repair Cms if it is not worked properly"
      ##puts "4 - Uninstall Cms (gem folder will not be deleted automatically)"
      ##puts "5 - Help with Cms"
      puts "0 - Exit Wizard"
      user_choice = STDIN.getch
      exit if user_choice != '1'
      
      #
      # Touch the database:
      #
      
      @database_status_OK = nil
      puts "..";sleep 1;puts("Check your database status...");sleep 1;
      begin
        Rake::Task['db:migrate'].reenable
        Rake::Task['db:migrate'].invoke
        @database_status_OK = true
      rescue => e
        puts "****** Database migrate error: " + e.to_s
        exit if e.to_s.index("Unknown database") == nil
        puts "rake db:create first!"
        @database_status_OK = false
      end
      
      if @database_status_OK == false
        begin
          puts "Dont worry. It seems that your database was not prepeared yet. May I create it manually with rake db:create?"
          puts "1 - yes, please"
          puts "2 - no, thanks"
          begin puts("Do it manually, if you wish."); exit; end if STDIN.getch != '1'
          puts ".."
          Rake::Task['db:create'].reenable
          Rake::Task['db:create'].invoke
          #system "rake #{name}"
          sleep 1;puts ">> Database was created!";sleep 1;
        rescue => e
          puts "Unable to invoke db:create. Check your database configuration."
          puts "Finished. Unable to setup Cms."
          exit
        end
      end
      sleep 1;puts "OK";
      
      #
      #  Invoke seed data
      #      
      
      unless text_exists?(OWNER_SEED_FILE_PATH, "Devcms::Engine.load_seed")
        sleep 1
        puts "Copy DevCms migration scripts.."
        Rake::Task["devcms:install:migrations"].reenable
        Rake::Task["devcms:install:migrations"].invoke
        sleep 1
        puts "Initialize DevCms seed data.."
        inject_text(OWNER_SEED_FILE_PATH, -1, "Devcms::Engine.load_seed")
        puts "Run all migrations.."
        Rake::Task["db:migrate"].reenable
        Rake::Task["db:migrate"].invoke
        sleep 1
        puts "Load DevCms seed data..."
        Rake::Task["db:seed"].reenable
        Rake::Task["db:seed"].invoke
        puts "Done!"
        sleep 1
      end
      
      #
      # Add gem dependencies
      #
      
      puts "Add dependencies to Gemfile..";sleep 1;
      major_gemfile_dependencies = [
        "gem 'haml' ",
        "gem 'codemirror-rails' ",
        "gem 'aloha-rails' "]
      minor_gemfile_dependencies = [
        "gem 'bootstrap-sass' " ]
      minor_gemfile_selections = [
        false
      ]
      gemfile_comment = "#=   DEVCMS REQUIREMENTS END   =#"
      major_gemfile_dependencies.each do |gem_file|
        sleep 1;
        if text_exists?(OWNER_GEMFILE_PATH, gem_file)
          puts(gem_file + " already installed."); next;
        end
        puts(gem_file + " including..")
        inject_text(OWNER_GEMFILE_PATH, -1, gem_file + "\n")
      end
      puts "Including of minor dependencies (if you wish):"
      minor_gemfile_dependencies.each_with_index do |gem_file, index|
        next if text_exists?(OWNER_GEMFILE_PATH, gem_file)
        sleep 1
        puts "Optional #{gem_file} wants to be included in Gemfile. Allow it?"
        puts "1 - yes, please"
        puts "2 - no, thanks"
        if STDIN.getch == '1'
          inject_text(OWNER_GEMFILE_PATH, -1, gem_file + "\n") 
          minor_gemfile_selections[index] = true
        end
      end
      inject_text(OWNER_GEMFILE_PATH, -1, gemfile_comment + "\n") unless text_exists?(OWNER_GEMFILE_PATH, gemfile_comment)
      
      #
      # Add javascript assets
      #
      
      puts "Add javascript assets to application.js..";sleep 1;
      major_js_assets = [
        "//= require devcms/application",
        "//= require codemirror",
        "//= require codemirror/modes/css"]
      minor_js_assets = [
        "//= require bootstrap" ]      
      major_js_assets.each do |js_asset|
        sleep 1;
        if text_exists?(OWNER_APP_JS_PATH, js_asset)
          puts(js_asset + " already included."); next;
        end
        puts(js_asset + " including..");
        inject_text(OWNER_APP_JS_PATH, -1, js_asset+"\n")
      end
      puts "Minor dependencies including.."
      minor_js_assets.each_with_index do |js_asset, index|
        if minor_gemfile_selections[index] == true
          if text_exists?(OWNER_APP_JS_PATH, js_asset)
            puts(js_asset + " already included."); next;
          end
          puts(js_asset + " including..");
          inject_text(OWNER_APP_JS_PATH, -1, js_asset+"\n")
        end
      end
      
      #
      # Add css assets
      #
      
      puts "Add css assets to application.css..";sleep 1;
      major_css_assets = [
        "require codemirror",
        "require aloha",
        "require devcms/application"]
      minor_css_assets = [
        "require bootstrap" ]
      minor_css_assets_with_prompt = [
        "require bootstrap-responsive" ]
      css_prompts = [
        "bootstrap-responsive style" ]
      puts "Minor dependencies including.."
      minor_css_assets_with_prompt.each_with_index do |css_asset, index|
        if minor_gemfile_selections[index] == true
          if text_exists?(OWNER_APP_CSS_PATH, css_asset)
            puts "Are you wish #{css_prompts[index]} to be included?"
            puts "1 - yes, please"
            puts "2 - no, thanks"
            if STDIN.getch == '1'
              inject_text(OWNER_APP_CSS_PATH, 2, "*= " + css_asset + "\n")
            end
          end
        end
      end
      minor_css_assets.each_with_index do |css_asset, index|
        if minor_gemfile_selections[index] == true
          if text_exists?(OWNER_APP_CSS_PATH, css_asset)
            puts(css_asset + " already included."); next;
          end
          puts(css_asset + " including..");
          inject_text(OWNER_APP_CSS_PATH, 2,  "*= " + css_asset + "\n")
        end
      end
      major_css_assets.each do |css_asset|
        sleep 1;
        if text_exists?(OWNER_APP_CSS_PATH, css_asset)
          puts(css_asset + " already included."); next;
        end
        puts(css_asset + " including..");
        inject_text(OWNER_APP_CSS_PATH, 2,  "*= " + css_asset + "\n")
      end
      
      #
      #  Add Cms routes
      #
      
      route_line = "\n\n  # This is a DevCms route line. Add your custom routes above this line.\n    mount Devcms::Engine, :at => '/'\n"
      route_finder = "Devcms::Engine"
      unless text_exists?(OWNER_ROUTE_FILE_PATH, route_finder)
        sleep 1; puts("Add CMS routes to routes.rb..")
        inject_text(OWNER_ROUTE_FILE_PATH, 2, route_line)
      end
      
      #
      #  Footer =)
      #
      
      puts "+++"
      puts "Finished Successfully!"
      puts "It is time to start your rails server: (rails s)."
      puts "Then, open your admin panel at 'http://localhost:3000/in'"
      puts "Default username/password are: admin/admin"
      puts "All rights reserved, InterLink (c) 2000-2013"
    end
    
    #  Inject text into specified line of file.
    #  If line_number is -1, text will be appended to the end of file.
    def inject_text(file_path, line_number, text)
      if line_number == -1
        open(file_path, 'a') do |f|
          f << text
        end
      else
        open(file_path, 'r+') do |f|
          while (line_number-=1) > 0
            f.readline
          end
          pos = f.pos
          rest = f.read
          f.seek pos
          f.write text
          f.write rest
        end
      end
    end
  
    def text_exists?(file_path, text)
      return File.readlines(file_path).grep(/#{text}/).size > 0
    end
    
    
    # TODO: Finish with autotests!!
    task :autotest do
      require File.expand_path("../../../config/environment", __FILE__)
      require 'rspec/rails'
      # Configure Rails Envinronment
      ENV["RAILS_ENV"] = "test"
      ENGINE_RAILS_ROOT=File.join(File.dirname(__FILE__), '../')
      Dir[File.join(ENGINE_RAILS_ROOT, "spec/support/**/*.rb")].each {|f| require f }

      RSpec.configure do |config|
        config.use_transactional_fixtures = true
      end

      Rake::Task['db:load_config'].invoke
      puts ActiveRecord::Base.configurations['test'].inspect

      puts "hello!"
      params = %w(--quiet)
      params << "--database=#{ENV['DB']}" if ENV['DB']
      Rake::Task['spec'].invoke
    end

end
