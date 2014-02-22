require 'yaml'
require 'strscan'
require 'pp'


class JavaClass
  
  attr_accessor :superclass,:source,:fields,:methods, :interfaces, :classname, :filename
  
  def self.clean_value(s)
    s.strip!
    s.gsub!(/\'|\;/,"")
    s.gsub!(/\//,".")
    s.gsub!(/^L/,"")
  end
  
  def initialize(classname, flags, filename)
    @classname = JavaClass.clean_value(classname)
    @flags = flags
    @superclass = ''
    @interfaces = []
    @fields = []
    @methods = []
    @filename = File.basename filename
  end

  

  def add_intefaces
    
  end
end

class Field
  
  def initialize(flags,name_type)
    @flags = flags
    @name, @type = name_type[0].split(':')
  end
end
    


class JavaMethod
    attr_accessor :invoked_methods, :name, :pclass

  
    
  def self.parse_methodcall(name_type)
    name = name_type.scan /^[^\(\)]+/
    return_type = name_type.scan /[^\(\)]+$/
    s = name_type.scan(/\((.*)\)/)
    args =  s[0][0].split(';') unless s[0].nil?
    return name, args, return_type
  end
  
  def initialize(flags, name_type, pclass)
    @invoked_methods = []
    @flags = flags
    @name = name_type.scan /^[^\(\)]+/
    @return_type = name_type.scan /[^\(\)]+$/
    s=name_type.scan(/\((.*)\)/)[0]
    @args = s[0].split(';') unless s.nil?
    @pclass = pclass
  end

end

class SyntaxParserDexDumper

  def parse(filename)
    content = File.open(filename)
    classes = []
    scanner = StringScanner.new(content.read)
    while (line = scanner.scan(/.*/))
      property, value =  line.lstrip.split(/:|-/)


      case property
      when /Class descriptor/
        classname =  value
      when /Access flags/
        flags = value
      when /Superclass/
        superclass = value
        java_class = JavaClass.new classname, flags, filename
        classes.push java_class
      else        
      end
    end
   # puts classes.inspect
  end
    
end

def trans_to_int(s)
  if (s =~ /^0x([0-9a-fA-F]+)$/)
    res = s.to_i 16
  elsif (s =~ /^[0-9]+$/)
    res = s.to_i
  else
    res = s
  end
  pp 'res',res
  return res
end

class MethodInvocation
  attr_reader :methodname, :params, :classname, :line
  def initialize(args,line=0)
    @params= args.join.scan(/\{(.*)\}/)[0][0].split(',')
    @line = line
    @classname, @methodname = args[-1].split('->')
    @methodname = @methodname.scan(/(.*)\(/)[0]
    JavaClass.clean_value(@classname)
  end
  def resolve_vars(vars)
  #  puts "vars",vars
    @params=@params.collect do |x|
      if vars.has_key?(x)
#        puts "x",x
        x=vars[x]
      else
        x=x
      end
    end
  end

  
  def type_conversetion
    @params=@params.collect do |s|
      begin        
        s=Integer(s)
      rescue Exception
        s
      end
    end

  end
  
end
    
class SyntaxParserSmali
  attr_reader :classes

  def initialize()
    @classes = []
  end
  def tokenize(ar)
    f = ar.select { |x| x =~ /^[a-z]+$/}
    return f,ar-f
  end
  
  def parse(filename)
    content = File.open(filename)
    count_lines = 0
    while (line = content.gets)
      count_lines += 1
      tokens =  line.lstrip.split(' ')
      case tokens[0]
      when /\.class/
        if tokens[1] =~ /public|final|private|protected/
          flags = tokens[1]
          classname = tokens[2]
        else
          flags = ''
          classname = tokens[1]
        end
        java_class = JavaClass.new classname, flags, filename
        @classes.push java_class unless java_class == []
      when /\.super/
        java_class.superclass = tokens[1]
      when /.source/
        java_class.source = tokens[1]
      when /\.implements/
        java_class.interfaces.push tokens[1]
      when /\.field/
        flags, classname = tokenize tokens[1..-1]        
        java_class.fields.push Field.new flags, classname        
      when /\.method/
        flags, method_desc = tokenize tokens[1..-1]
        java_method = JavaMethod.new(flags, method_desc[0],java_class)
        java_class.methods.push(java_method)
        vars = {}
        while (not line.start_with?(".end method"))
          line = content.readline
          line = line.lstrip
          opcodes  = line.split ' '
          case opcodes[0]
          when /invoke/
            #puts opcodes
            invoked = MethodInvocation.new(opcodes[1..-1],count_lines)
            invoked.resolve_vars(vars)
            invoked.type_conversetion
            java_method.invoked_methods.push(invoked)
          when /const/
#            puts opcodes.join(" ")
            var_name = opcodes[1].delete("\"").delete(",")
            
            if opcodes[2].start_with?('"')
              a=opcodes[2..-1].join " "
            else
              a=opcodes[2]
            end
            vars[var_name] =  a.delete("\"")
          end
        end
      else        
      end
    end
    return @classes
  end

  def walk(path)
    Dir.glob(path+"/*").each do |file|
      if File.directory? file
        walk(file)
      elsif file.end_with? '.smali'
        parse(file)
      end
    end
  end

  def get_methods()
    methods =[]
    @classes.each { |c|  c.methods.each { |m|  methods << m}}
    return methods
  end
    
end


test = SyntaxParserSmali.new
