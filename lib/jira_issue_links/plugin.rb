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

    # Private struct 
    JiraIssue = Struct.new("JiraIssue", :id, :summary, :issuetype, :iconUrl)

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

    # If `true` then in report will be added "Resolves" keyword for automatic resolve issue in jira. 
    # @see https://docs.gitlab.com/ee/user/project/integrations/jira.html
    # Default - false
    #
    # @return   [Bool]
    attr_accessor :include_resolves_keyword

    # Regexp used to find issue id in commit message
    # By default it should start with pattern: `[TASK-123]` - this produces id = "TASK-123"
    #
    # @return   [Regexp]
    attr_accessor :issue_number_regexp

    def issue_number_regexp
      @issue_number_regexp || /^\[(\w+-\d+)\]/
    end

    # Find all issue references in commit messages that match issue_number_regexp
    # @return   [Array<String>]
    def collect_issues_from_commits 
      git.commits
         .flat_map { |c| c.message.match(issue_number_regexp)&.captures }
         .compact
         .uniq
    end

    # Generates a `markdown` table of issues with type, title and link.
    # Required access to Jira site.
    #
    # @return  [void]
    def print_links_with_titles
      found_issues = collect_issues_from_commits
      return if found_issues.empty?

      message = "## Jira issues\n\n"
      if include_resolves_keyword
        message << "| | | |\n"
        message << "| --- | --- | ----- |\n"
      else 
        message << "| | |\n"
        message << "| --- | ----- |\n"
      end

      begin
        found_issues.each do |issue_id| 
          issue = obtain_issue(issue_id)
          return if issue.nil?
          description = issue.summary
          description = description.gsub(/[<|>\[\]]/) { |bracket| "\\#{bracket}" }
          message << "![#{issue.issuetype}](#{issue.iconUrl}) | "
          if include_resolves_keyword
            message << "Resolves #{issue_id} | "
          end
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

      message = "## Jira issues\n\n"
      found_issues.each do |issue_id|
        if include_resolves_keyword
          message << "Resolves "
        end
        message << "[#{issue_id}](#{jira_site}/browse/#{issue_id})\n\n"
      end

      markdown message
    end


    private

    def jira_client
      jira_context_path = '' if jira_context_path.nil?
      @jira_client = JIRA::Client.new(
        username:     jira_username,
        password:     jira_password,
        site:         jira_site,
        context_path: jira_context_path,
        auth_type:    :basic
      ) if @jira_client.nil?
      return @jira_client
    end

    def obtain_issue(issue_id) 
      issue = jira_client.Issue.jql("ID = '#{issue_id}'").first
      return if issue.nil?
      return JiraIssue.new(issue_id, issue.summary, issue.issuetype.name, issue.issuetype.iconUrl)
    end

  end
end
