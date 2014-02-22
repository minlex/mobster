require 'singleton'

class Rule

  attr_accessor :issue, :block
  
  def initialize(issue, block)
    @issue  = issue
    @block = block
  end
end

class RuleEngine
  include Singleton
  def self.new(file)
    @rules=[]
    load file
  end
  
  def self.check(m)
    
    @rules.each do |r|

      if r.block.call(m)
        puts r.issue
      end
    end
  end

  def self.add(rule)
    @rules << rule
  end
end


  
