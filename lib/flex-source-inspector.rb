require "flex-source-inspector/version"
require "rexml/document"

module FlexSourceInspector
  class Inspector
    def self.ping()
      "pong"
    end

    def self.inspect( src_folder, *link_reports)

      puts "-- inspect --"
      project_files = Dir["#{src_folder}/**/*.as"]
      project_files.concat Dir["#{src_folder}/**/*.mxml"]
      
      used = Array.new

      puts ""
      puts "src folder: #{src_folder}"

      link_reports.each{|report|
        puts "reading: #{report}"
        file = File.open( report )
        doc = REXML::Document.new file
     
        doc.elements.each("//script"){ |script|
          name = script.attributes["name"]
          add_to_used( used, project_files, name, src_folder )
        }
      }

      unused = project_files - used
      unused.each{|file|
        puts "#{file}"
      }
      puts "--"

      unused
    end

    def self.add_to_used(used, project_files, class_declaration, src_folder)
      project_files.each{ |file| 
        cleaned = file.gsub( src_folder, "")
        used << file if class_declaration.include? cleaned
      }
    end
  end
end
