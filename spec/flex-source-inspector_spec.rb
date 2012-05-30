require 'flex-source-inspector'

describe FlexSourceInspector::Inspector do
 
  it "will return an array of unused classes" do
    link_report = "spec/data/ApplicationOne_link-report.xml"
    src = "spec/data/LinkReportTestProject/flex-src"
    result = FlexSourceInspector::Inspector.inspect(src, link_report)
    puts "#{result}"
    result.should( include "NotUsedOne.as")
  end
  
  it "will return an array of unused classes for multiple link reports" do
    link_report = "spec/data/ApplicationOne_link-report.xml"
    link_report_two = "spec/data/ApplicationTwo_link-report.xml"
    src = "spec/data/LinkReportTestProject/flex-src"
    result = FlexSourceInspector::Inspector.inspect(src, link_report, link_report_two)
    puts "#{result}"
    result.should( include "NotUsedOne.as" )
    result.should_not( include "ModelOne.as")
  end

  it "will find classes declared within swcs" do
    link_report = "spec/data/swc_link_report.xml"
    src = "spec/data/LinkReportTestProject/flex-src"
    result = FlexSourceInspector::Inspector.inspect(src, link_report)
    puts "#{result}"
    result.should( include "NotUsedOne.as" )
    result.should_not( include "ModelOne.as")
  end

end
