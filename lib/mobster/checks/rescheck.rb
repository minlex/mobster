
module AndroidChecks

  class ResCheck

    def self.check(path)


      begin
      content = File.open(path+"/res/values/string.xml").read()

      if content =~ /http\:\/\//
        issues = Issue.new(IssueType::HTTP_CONNECTION)
      end
      return issues
    rescue Errno::ENOENT
      return nil
    end
      
    end
  end
end
