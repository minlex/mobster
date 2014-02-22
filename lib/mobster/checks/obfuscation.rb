

module AndroidChecks
  class Obfuscation

    def self.check(classes)
      count = 0
      classes.each do |c|
        names = c.classname.split('.')[-1] unless c.classname.nil?
        if  names =~ /^.{1,3}$/
          count += 1
        end
      end

      coef = Float(count)/Float(classes.length)    
      if (coef > 0.1)
        return true
      else
        
        return false
      end
    end
  end
end

if __FILE__ == $0

  parser = SyntaxParserSmali.new
  parser.walk(ARGV[0])
  pp Obfuscation.check(parser.classes)
end
 
