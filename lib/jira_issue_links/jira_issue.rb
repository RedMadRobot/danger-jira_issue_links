class JiraIssue 
    def initialize(id, summary, issuetype, iconUrl) 
        @id = id
        @summary = summary
        @issuetype = issuetype
        @iconUrl = iconUrl
    end

    def id
        @id
    end

    def summary
        @summary
    end

    def issuetype
        @issuetype
    end

    def iconUrl
        @iconUrl
    end
end