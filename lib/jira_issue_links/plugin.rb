require 'jira-ruby'

module Danger

  # Collect issue mentions from git commit messages.
  # Results are passed out as a table in markdown.
  #
  # @example Find issues, obtain types and titles from Jira, and make links to site.
  #
  #          jira_issue_links.print_links_with_titles
  #
  # @example Find issues and make links to Jira site.
  #
  #          jira_issue_links.print_links_only
  #
  # @see https://github.com/RedMadRobot/danger-jira_issue_links
  # @tags jira, issue, task
  #
  class DangerJiraIssueLinks < Plugin

    # Jira username
    #
    # @return   [String]
    attr_accessor :jira_username

    # Jira password
    #
    # @return   [String]
    attr_accessor :jira_password

    # Jira site url
    #
    # @return   [String]
    attr_accessor :jira_site

    # Jira context path
    # Default - empty string
    #
    # @return   [String]
    attr_accessor :jira_context_path


    # Find all issue references in commit messages.
    # Message should starts with pattern: `[TASK-123]`
    # @return   [Array<String>]
    def collect_issues_from_commits 
      all_issues = []
      git.commits.each do |c|
          captures = c.message.match(/^\[(\w+-\d+)\]*./)&.captures
          if captures
            all_issues.push(captures[0])
          end
      end
      all_issues.uniq
    end

    # Generates a `markdown` table of issues with type, title and link.
    # Required access to Jira site.
    #
    # @return  [void]
    def print_links_with_titles
      found_issues = collect_issues_from_commits
      return if found_issues.empty?

      jira_context_path = '' if jira_context_path.nil?
      client = JIRA::Client.new(
          username:     jira_username,
          password:     jira_password,
          site:         jira_site,
          context_path: jira_context_path,
          auth_type:    :basic
      )

      message = "## Jira issues\n\n"
      message << "| | |\n"
      message << "| --- | ----- |\n"

      begin
        found_issues.each do |issue_id| 
          issue = client.Issue.jql("ID = '#{issue_id}'").first
          return if issue.nil?
          description = issue.summary
          description = description.gsub(/<|>/) { |bracket| "\\#{bracket}" }
          message << "![#{issue.issuetype.name}](#{issue.issuetype.iconUrl}) | "
          message << "[#{description}](#{jira_site}/browse/#{issue_id})\n" 
        end
      rescue JIRA::HTTPError => e
        print e.message
      end

      markdown message
    end


    # Generates a `markdown` list of issues with links
    # No required access to Jira, needs only base url - `jira_site`.
    #
    # @return  [void]
    def print_links_only
      found_issues = collect_issues_from_commits
      return if found_issues.empty?

      message = "### Jira issues\n\n"
      found_issues.each do |issue_id| 
        message << "[#{issue_id}](#{jira_site}/browse/#{issue_id})\n\n" 
      end

      markdown message
    end

  end
end
