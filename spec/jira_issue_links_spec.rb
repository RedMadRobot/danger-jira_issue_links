require File.expand_path("../spec_helper", __FILE__)

module Danger
  describe Danger::DangerJiraIssueLinks do
    it "should be a plugin" do
      expect(Danger::DangerJiraIssueLinks.new(nil)).to be_a Danger::Plugin
    end

    describe "with Dangerfile" do
      before do
        @dangerfile = testing_dangerfile
        @my_plugin = @dangerfile.jira_issue_links
      end

      it "some" do
        @my_plugin.print_links_only

        expect(@dangerfile.status_report[:warnings]).to eq([])
      end


    end
  end
end
