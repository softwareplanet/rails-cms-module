require 'fileutils'
require 'spec_helper'

module Devcms
  describe Devcms::Source do

    # Remove source test directory before each test case:
    before(:each) do
      FileUtils.rm_rf TEST_SOURCE_FOLDER
      FileUtils.rm_rf TEST_SOURCE_FOLDERS[SourceType::CSS]
      FileUtils.rm_rf TEST_SOURCE_FOLDERS[SourceType::IMAGE]
    end

    describe "*new_record?* method" do
      it "should returns true if object hasn't been saved yet" do
        @layout = Factory.build(Devcms:layout) # <-  FactoryGirl#build method did not triggers the save! of the object
        @layout.new_record?.should be_true
      end
      it "should returns false if object is saved" do
        @layout = Factory.create(:layout) # <-  FactoryGirl#create method triggers the save! of the object
        @layout.new_record?.should be_false
      end
    end

    describe "*save* method" do
      describe "with invalid parameters" do
        before(:each) do
          @source = Factory.build(:source, :name => "")
        end
        describe "dangerous version" do
          it "should raise exception if source name is not specified" do
            lambda{@source.save!}.should raise_error(ArgumentError)
          end
        end
        describe "non-dangerous version" do
          it "should send back with false result if source name not specified" do
            @source.save.should == false
          end
        end
      end
      describe "with valid parameters both-dangerous versions" do
        before(:each) do
          @layout = Factory.build(:layout)
          @content = Factory.build(:content)
        end
        it "should creates new source files in source folders" do
          @layout.save
          @layout.new_record?.should == false
          @content.save!
          @content.new_record?.should == false
        end
        it "should write data into source files" do
          @layout.data = "layout data"
          @content.data = "content data"
          @layout.save
          @content.save!
          File.open(@layout.get_source_path, "r") { |file| file.read.should == @layout.data }
          File.open(@content.get_source_path, "r") { |file| file.read.should == @content.data }
        end
        it "should modify attaches (css) filenames to include target objects" do
          @layout_css = Factory.build(:css, :target => @layout, :name => "css1")
          @layout_css.save
          @layout_css.new_record?.should be_false
          @layout_css.get_target_type.should == @layout.type.to_s
          @layout_css.get_target_name.should == @layout.name
        end
      end
    end


    describe "targets and attaches relations - " do
      before(:each) do
        @layout = Factory(:layout)
        @layout_css = Factory(:css, :target => @layout)
      end
      describe "target object" do
        it "should be able to get its attach" do
          attach_type = SourceType::CSS # it is by default
          # reload all sources, because we want delayed reading:
          layout = Source.find_by_type(SourceType::LAYOUT).first
          layout_css = Source.find_by_type(SourceType::CSS).first
          layout.get_attach.should == layout_css
          layout.get_attach(attach_type).should == layout_css
        end
      end
      describe "attach object" do
        it "should be able to get its target" do
          # reload all sources, because we want delayed reading:
          layout = Source.find_by_type(SourceType::LAYOUT).first
          layout_css = Source.find_by_type(SourceType::CSS).first
          layout_css.get_target.should == layout
        end
      end
    end

    describe "*delete* method" do
      describe "dangerous version" do
        it "should raise exception if source is not saved yet" do
          @s = Factory::build(:source)
          lambda {@s.delete!}.should raise_error(StandardError)
        end
        it "should raise exception if source name not specified" do
          @s = Factory(:source, :name => "source_name")
          @s.name = ""
          lambda {@s.delete!}.should raise_error(ArgumentError)
        end
      end
      describe "non-dangerous version" do
        it "should return false if source is not saved yet" do
          @s = Factory::build(:source)
          @s.delete.should == false
        end
        it "should return false if source name not specified" do
          @s = Factory(:source, :name => "source_name")
          @s.name = ""
          @s.delete.should == false
        end
      end
      describe "both versions" do
        it "should delete source" do
          @css = Factory(:css)
          @layout = Factory(:layout)
          @content = Factory(:content)
          @content_css = Factory(:css, :target => @content)
          File.exists?(@css.get_source_path).should == true
          File.exists?(@layout.get_source_path).should == true
          File.exists?(@content.get_source_path).should == true
          File.exists?(@content_css.get_source_path).should == true
          @css.delete
          File.exists?(@css.get_source_path).should == false
          @layout.delete!
          File.exists?(@layout.get_source_path).should == false
          @content.delete
          File.exists?(@content.get_source_path).should == false
          @content_css.delete!
          File.exists?(@content_css.get_source_path).should == false
        end
      end
    end

    describe "*rename* method" do
      before(:each) do
        @layout = Factory(:layout)
        @content = Factory(:content)
        @content_css = Factory(:css, :target => @content)
        @css = Factory(:css)
      end
      it "should raise exception if object hasn't been saved yet" do
        @layout = Source.new(:name => "layout")
        lambda {@layout.rename("12")}.should raise_error
      end
      it "should raise exception if new name is blank (or incorrect)" do
        @layout = Source.new(:name => "layout")
        @layout.save!
        lambda {@layout.rename("")}.should raise_error
      end
      it "should rename source file " do
        old_filepath = @content.get_source_path
        new_filename = "new_filename"
        File.exists?(old_filepath).should == true
        @content.rename(new_filename).should == true
        File.exists?(old_filepath).should == false
        File.exists?(@content.get_source_folder + new_filename).should == true
      end
      it "should rename attached files automatically" do
        new_filename = "new_filename"
        @content.rename(new_filename)
        @content.get_attach.name.to_s.should include(new_filename)
        File.exists?(@content.get_attach.get_source_path).should == true
      end
    end

    describe "search methods" do
      before(:each) do
        @content1 = Factory.create(:content)
        @content2 = Factory.create(:content)
        @content3 = Factory.create(:content)
        @content4 = Factory.create(:content)
        @layout1 = Factory.create(:layout)
        @layout2 = Factory.create(:layout)
        @layout3 = Factory.create(:layout)
        @layout4 = Factory.create(:layout)
        @css1 = Factory.create(:css, :target => @content1)
        @css2 = Factory.create(:css, :target => @content2)
        @css3 = Factory.create(:css, :target => @layout1)
        @css4 = Factory.create(:css, :target => @layout2)
      end
      it "should read file data only when data access required" do
        content = Source.find_by_type(SourceType::CONTENT).first
        content.marshal_dump[:data].should == nil
        content.data.should == @content1.data
      end
      describe "*all* method" do
        it "should return match data array with all sources" do
          Source.all.size.should == 12
        end
      end
      describe "*where*  method" do
        it "should return match data array by source type and source name parameters" do
          Source.where(:type => SourceType::CONTENT).size.should == 4
          Source.where(:type => SourceType::CONTENT, :name => @content1.name ).size.should == 1
          Source.where(:type => SourceType::CONTENT, :name => @layout1.name ).size.should == 0
        end
      end
      describe "*find_by_..* complex method " do
        it "should return match data array by source type and source name parameters" do
          Source.where(:type => SourceType::CONTENT).size.should == 4
          Source.where(:type => SourceType::CONTENT, :name => @content1.name ).size.should == 1
          Source.where(:type => SourceType::CONTENT, :name => @layout1.name ).size.should == 0
        end
      end

    end

    describe "source extensions" do
      it "should be assigned with source files automatically, based on SourceType" do
        source = Source.new( :name => "with_extension", :type => SourceType::CSS)
        source.save!
        source.get_filename.should == "with_extension" + "." + SOURCE_TYPE_EXTENSIONS[SourceType::CSS]
        source.get_filepath.should == TEST_SOURCE_FOLDERS[SourceType::CSS] +  "with_extension" + "." + SOURCE_TYPE_EXTENSIONS[SourceType::CSS]
        File.exists?(source.get_filepath).should == true
      end
      it "should not be modified after source renaming" do
        source = Source.new( :name => "with_extension", :type => SourceType::CSS)
        source.save!
        source.rename("new_with_ext")
        source.get_filename.should == "new_with_ext" + "." + SOURCE_TYPE_EXTENSIONS[SourceType::CSS]
        source.get_filepath.should == TEST_SOURCE_FOLDERS[SourceType::CSS] +  "new_with_ext" + "." + SOURCE_TYPE_EXTENSIONS[SourceType::CSS]
        File.exists?(source.get_filepath).should == true
      end
    end

    describe "Unique ID constraints" do
      it "should be unique and should not contain incorrect symbols (like dots, because jQuery $ perceives dots as a class selectors) " do
        source = Source.new( :name => "with_extension", :type => SourceType::CSS, :data => nil)
        source.save!
        source.get_id.should_not include "."
        Source.find_by_id(source.get_id).should == source
      end
    end

    describe "Sources, that specified their extencions with '*', should be able to store their private extensions (png, bmp, jpg are the single Image source type)" do
      it "should be unique and should not contain incorrect symbols (like dots, because jQuery $ perceives dots as a class selectors)"do
        s = Source.new(:type => SourceType::IMAGE, :name => "hello.txt", :data => "pff")
        s.save!
      end
    end


  end
end