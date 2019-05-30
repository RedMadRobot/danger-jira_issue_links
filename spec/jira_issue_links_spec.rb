require File.expand_path("../spec_helper", __FILE__)

module Danger
  describe Danger::DangerJiraIssueLinks do
    it "should be a plugin" do
      expect(Danger::DangerJiraIssueLinks.new(nil)).to be_a Danger::Plugin
    end

    describe "with Dangerfile" do
      before do
        @dangerfile = testing_dangerfile
        @plugin = @dangerfile.jira_issue_links
      end

      it "dsafd " do 
        @plugin.include_resolves_keyword = true

        commits = [
          "[XX-123] fix it",
          "xxx",
          "[XX-123] fix it",
          "[A-1] fix it, [B-2] df"
        ].map do |message|
          instance_double('Commit', message: message)
        end

        expect(@plugin.git).to receive(:commits).and_return(commits)
        expect(@plugin.collect_issues_from_commits).to eql([
          "XX-123", "A-1"
        ])

      end
    
      it "dsafd 1" do 
        @plugin.include_resolves_keyword = true

        commits = [
          "[XX-123] fix it",
          "xxx",
          "[XX-123] fix it",
          "[A-1] fix it, [B-2] df"
        ].map do |message|
          instance_double('Commit', message: message)
        end

        expect(@plugin.git).to receive(:commits).and_return(commits)
        expect(@plugin.print_links_with_titles)
        expect(@plugin.status_report[:warnings]).to eq([])
      end

    end
  end
end
