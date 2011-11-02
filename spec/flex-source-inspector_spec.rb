require 'flex-source-inspector'

describe FlexSourceInspector::Inspector do
  it "can ping" do
    FlexSourceInspector::Inspector.ping.should eql("pong")
  end

  it "will return an array of unused classes" do
    link_report = "spec/data/ApplicationOne_link-report.xml"
    src = "spec/data/LinkReportTestProject/flex-src"
    result = FlexSourceInspector::Inspector.inspect(src, link_report)
    puts "result: #{result}"
    result.should( include "NotUsedOne.as")
  end

  it "will return an array of unused classes for multiple link reports" do
    link_report = "spec/data/ApplicationOne_link-report.xml"
    link_report_two = "spec/data/ApplicationTwo_link-report.xml"
    src = "spec/data/LinkReportTestProject/flex-src"
    result = FlexSourceInspector::Inspector.inspect(src, link_report, link_report_two)
    puts "result: #{result}"
    result.should( include "NotUsedOne.as" )
    result.should_not( include "ModelTwo.as")

  end
end
