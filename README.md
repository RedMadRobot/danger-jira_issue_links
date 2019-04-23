# danger-jira_issue_links

Collect issue mentions from git commit messages and obtain info from Jira issue tracker.<br>
Commit message should starts with pattern `[TASK-123]`, where TASK is id of jira project, 123 is issue number. For example commit message: 
```
[JSGLK-1145] Resolve bug with incorrect price calculation
```
Results are passed out as a table in the Danger comment for merge request.

![Screenshot](resources/danger-screenshot.png)


## Installation

    $ gem install danger-jira_issue_links

## Usage

Configure connection to you Jira instance

```
jira_issue_links.jira_username = "email"
jira_issue_links.jira_password = "password"
jira_issue_links.jira_site = "https://your-company.atlassian.net"
```

Find all issue mentions in commit messages, obtain info from Jira and make table of links
```
jira_issue_links.print_links_with_titles
```

Find all issue mentions in commit messages and make links. <br>
No required access to Jira, needs only base url - `jira_site`.
```
jira_issue_links.print_links_only
```


## Development

1. Clone this repo
2. Run `bundle install` to setup dependencies.
3. Run `bundle exec rake spec` to run the tests.
4. Use `bundle exec guard` to automatically have tests run as you make changes.
5. Make your changes.
