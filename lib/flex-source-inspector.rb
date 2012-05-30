require "flex-source-inspector/version"
require "rexml/document"

module FlexSourceInspector
  class Inspector

    def self.inspect( src_folder, *link_reports)

      puts ">-- inspect --"
      puts "pwd: #{Dir.pwd}"

      raise "FlexSourceInspector::Error source folder doesn't exist #{src_folder}" unless File.exists? src_folder

      project_files = Dir["#{src_folder}/**/*.as"]
      project_files.concat Dir["#{src_folder}/**/*.mxml"]
      
      used = Array.new

      puts ""
      puts "src folder: #{src_folder}"
      puts ""

      link_reports.each{|report|
        puts "reading: #{report}"
        raise "FlexSourceInspector::Error: #{report} doesn't exist!" unless File.exists?( report )
        
        file = File.open( report )
        doc = REXML::Document.new file
    
        debugger 
        doc.elements.each("//script"){ |script|
          name = script.attributes["name"]
          add_to_used( used, project_files, name, src_folder )
        }
      }
      unused = project_files - used
      unused.join "\n"
    end

    def self.add_to_used(used, project_files, class_declaration, src_folder)
      debugger  
      project_files.each{ |file| 
        cleaned = file.gsub( src_folder, "")
        used << file if is_declared?(cleaned, class_declaration)
      }
    end

    ###
    # A declaration can either be: 
    # "/Path/to/file/com/MyClass.as"
    # or
    # "/Path/to/My.swc(com.MyClass)"
    # We check to see if either declaration matches the given file.
    ###
    def self.is_declared?( file_name, declaration )

      # Check for a direct file declaration
      if declaration.include? file_name
        return true
      end

      # Check for a swc declaration
      class_name = convert_to_class_name file_name

      if declaration.include? class_name
        return true
      end
      false
    end

    def self.convert_to_class_name( file_name )
      out = file_name
      out.gsub!("/", ".")
      out.gsub!(".as", "")
      out.gsub!(".mxml", "")
      if out[0] == "."
        out = out[1..out.length]
      end
      out.gsub!(/(.*)\.(.*)/, '\1:\2' )
      out
    end

  end
end
