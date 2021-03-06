require 'thor'
module FlexSourceInspector
  class CLI < Thor

    desc "ping", "returns pong - just for testing"
    def ping()
      puts FlexSourceInspector::Inspector.ping
    end
 
    desc "inspect path_to_flex_src, path_to_link_reports [, ... path_to_link_report]", "pass in the path to the flex src, and 1..* paths to link-report xml files"
    def inspect( src_folder, *link_reports)
      puts FlexSourceInspector::Inspector.inspect( src_folder, *link_reports )
    end
  end
end

