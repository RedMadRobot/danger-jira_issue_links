require File.expand_path("../spec_helper", __FILE__)

module Danger
  describe Danger::DangerJiraIssueLinks do

    # alias
    JiraIssue = Danger::DangerJiraIssueLinks::JiraIssue

    it "should be a plugin" do
      expect(Danger::DangerJiraIssueLinks.new(nil)).to be_a Danger::Plugin
    end

    describe "with Dangerfile" do
      before do
        @dangerfile = testing_dangerfile
        @plugin = @dangerfile.jira_issue_links
      end

      it "collect issues with regex" do 
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

      it "print simple links" do 
        @plugin.jira_site = "http://site"

        commits = [
          "[XX-123] fix it"
        ].map do |message|
          instance_double('Commit', message: message)
        end

        expect(@plugin.git).to receive(:commits).and_return(commits)
        expect(@plugin.print_links_only)
        output = @plugin.status_report[:markdowns].first
        expect(output.message).to eq("## Jira issues\n\n[XX-123](http://site/browse/XX-123)\n\n")
      end
    

      it "print jira task without resolves" do 
        @plugin.jira_site = "http://site"

        commits = [
          "[XX-123] fix it"
        ].map do |message|
          instance_double('Commit', message: message)
        end

        expect(@plugin.git).to receive(:commits).and_return(commits)
        expect(@plugin).to receive(:obtain_issue).and_return(JiraIssue.new("XX-123", "summary", "Task", "url"))

        expect(@plugin.print_links_with_titles)
        output = @plugin.status_report[:markdowns].first
        expect(output.message).to eq("## Jira issues\n\n| | |\n| --- | ----- |\n![Task](url) | [summary](http://site/browse/XX-123)\n")
      end


      it "print jira task with resolves keyword" do 
        @plugin.include_resolves_keyword = true
        @plugin.jira_site = "http://site"

        commits = [
          "[XX-123] fix it"
        ].map do |message|
          instance_double('Commit', message: message)
        end

        expect(@plugin.git).to receive(:commits).and_return(commits)
        expect(@plugin).to receive(:obtain_issue).and_return(JiraIssue.new("XX-123", "summary", "Task", "url"))

        expect(@plugin.print_links_with_titles)
        output = @plugin.status_report[:markdowns].first
        expect(output.message).to eq("## Jira issues\n\n| | | |\n| --- | --- | ----- |\n![Task](url) | Resolves XX-123 | [summary](http://site/browse/XX-123)\n")
      end

    end
  end
end
