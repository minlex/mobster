require 'pp'
require 'haml'
require 'optparse'
require 'yaml'
require 'nokogiri'
require_relative  'mobster/issue'
require_relative  'mobster/actions/unpack'
require_relative  'mobster/actions/decompiler'
require_relative  'mobster/checks/apichecks'
require_relative  'mobster/checks/manifest'
require_relative  'mobster/checks/obfuscation'
require_relative  'mobster/checks/apichecks'
require_relative  'mobster/checks/rescheck'
require_relative  'mobster/checks/permissions'
require_relative  'mobster/checks/rules'
require_relative  'mobster/checks/filesystem'
require_relative  'mobster/checks/syntax_parser'



class Mobster

  
  def select_issue(issue)
    res = {}
    stat = {}
    ipc={}
    ipc['services'] = []
    ipc['activities'] = []
    ipc['receivers'] = []
    ipc['providers'] = []
    ipc['perms'] = []
    
    issue.each do |app|
      statapp = []
      ipc['services'] << app['man'].services.select{ |x| x.exported }
      ipc['activities'] << app['man'].activities.select{ |x| x.exported }
      ipc['receivers'] << app['man'].receivers.select{ |x| x.exported }
      ipc['providers'] << app['man'].provider
      ipc['perms'] << app['man'].c_permission
      
      IssueType.constants.each do |type|
        r =  app['api'].select{ |x| x.desc ==  IssueType.const_get(type)}

        if res.has_key? type
          res[type] << r unless r == []
          statapp << type if statapp.index(type).nil?and r!=[]
        else
          res[type] = r
          statapp << type  unless r == []
        end
      end

      
      statapp.each do |i|
        if stat.has_key? i
          stat[i]+=1
        else
          stat[i] = 1
        end
      end
      
    end
    pp ipc
    pp "Total"
    pp "Services: ", ipc['services'].flatten.length
    pp "Activites:", ipc['activities'].flatten.length
    pp "Receivers:", ipc['receivers'].flatten.length
    pp "Providers:", ipc['providers'].flatten.length
    pp "Permission:", ipc['perms'].flatten.length
  return res,stat
end

  def calc_weights(issues)
    weights = {}
    ipc = 0
    totalipc = 0
    color_stats = {:red =>0, :yellow => 0, :white => 0}
    red = ["android.permission.READ_PHONE_STATE","android.permission.WRITE_EXTERNAL_STORAGE","android.permission.READ_LOGS"]
    yellow = ["android.permission.WRITE_SETTINGS","android.permission.READ_SMS","android.permission.WRITE_CONTACTS","android.permission.CAMERA","android.permission.READ_CONTACTS","android.permission.CALL_PHONE"]
    issues.each do |app|
      types=[]
      weight = 11
      (app['api']+app['manifest']).each do |issue|
        if types.index(issue.desc) == nil
          weight -= 1
          types << issue.desc
        end
      end
      if app['obfuscation'] == 'false'
        weight -=1
      end
      flag = true
     state = :white
      app['permission'].each do |a|
        if red.index(a)
          state = :red
        elsif yellow.index(a) and state != :red
          state = :yellow
        elsif (state != :red and state != :yellow)
          state = :white
          
        end
          if red.index(a) or yellow.index(a)
            weight -= 1
            break
         end
      end
      color_stats[state] +=1

      if app['ipc'].length >= 1
        weight -= 1
      end
      if app['ipc'].length >= 1
        ipc+=1
      end
      totalipc += app['ipc'].length 
      weights[app['appname']]=weight        
    end

    return weights
  end
  
  def initialize(options)

    @is_unpack = true if options.has_key?("unpack_dir")
    @is_unzip = true if options.has_key?("unzip_di")
    @is_decomp = true if options.has_key?("decomp_dir")
    @unpack_dir = options["unpack_dir"]
    @unzip_dir = options["unzip_dir"]
            
    @apktool = options["apktool"]    
    @dex2jar = options["dex2jar"]    
    @adb = options[:adb]    
    @work_dir = File.dirname(__FILE__)
    
    
    @up = Unpacker.new(@apktool,@unpack_dir,@unzip_dir)
    @all_issues = []

  end

  def decompile(path)
    @dex2jar = Dex2JarDecompiler.new @dex2jar_dir
    @dex2jar.decompile(path)
  end
  


  def scan_apk(apk_path)
    pp "Application: #{File.basename(apk_path)}"
    issues = {}
    issues['appname'] = File.basename(apk_path)

    if @is_unpack
      p apk_path
      unpack_path = @up.unpack(apk_path)
    else
      unpack_path = @unpack_dir+File.basename(apk_path,".apk")
   end
    
    if @is_unzip 
      @up.unzip(apk_path)
    end
    
    if @is_decompile
      decompile(File.basename(apk_path,".apk"))
    end
    
    manifest = Manifest.new( unpack_path+'/AndroidManifest.xml')

    
    parser = SyntaxParserSmali.new
    parser.walk( unpack_path + "/smali/")
    methods = parser.get_methods()
    api =  AndroidChecks::ApiChecks.new 
    methods.each do |m|
      api.checks(m) 
    end

    res = AndroidChecks::ResCheck.check(unpack_path)
    
    issues['debug'] = AndroidChecks::IsDebuggable.check(manifest).to_s
    pp "Debug:" +     issues['debug']
    issues['obfuscation'] = AndroidChecks::Obfuscation.check(parser.classes).to_s
    pp "Obfuscation:" +     issues['obfuscation']
    issues['permission'] = manifest.permission.split(':')
    pp "Permisison:" + issues['permission'].to_s

    issues['ipc'] =  manifest.get_public_ipc
    pp issues['ipc']
    api.issues.each { |p| pp p }
    issues['api']  = api.issues
    if res != [] and res != nil
      issues['api'] << res
    end
    appfiles =  AppFiles.new @adb

    pkg_name = File.basename(apk_path,".apk").split('-')[0]

    issues['manifest'] =  AndroidChecks::ManifestCheck.check(manifest)
    issues['man'] = manifest
    issues['files'] = 'files'
    @all_issues << issues

  end
  
  def scan_dir(path)

    Dir.glob(path+"/*.apk") do  |p|
      scan_apk(p)
      end

  end

  def scann(path)
    
    
    if File.directory?(path)
      scan_dir(path)
    elsif path.end_with?(".apk")      
      scan_apk(path)
    end
    pp    @all_issues

    ssl_issues =[]
    stat= {}

    ssl_issues ,stat= select_issue(@all_issues)
    pp calc_weights(@all_issues).sort_by { |k,v| v}.reverse
    pp stat
    File.new("result_ssl.txt","w").write(ssl_issues.to_s)
    report = Haml::Engine.new(File.read('lib/template.html.haml')).render(Object.new, :issues => @all_issues, :stat => calc_stat)
    File.new("report.html","w").write(report)
  end

  def calc_stat
    stat = {}
    stat['appnum'] = @all_issues.length

    stat['debug'] = @all_issues.count { |c| c['debug'] == "true" }
    stat['obfuscated'] = @all_issues.count { |c|  c['obfuscation'] == "true"}
    stat['ipc'] = @all_issues.inject(0) { |acc,c| acc + c['ipc'].length }
    stat['api'] = @all_issues.inject(0) { |acc,c| acc + c['api'].length }

    
    return stat    
  end

                
end

class Hash
  def add_one(key)
    if self.has_key? key
      self[key] +=1 
    else
      self[key] = 1
    end
  end
end

  

if __FILE__ == $0

  options = {}

  parser = OptionParser.new do |opts|
    opts.banner = "Usage: mobster [options] path"
    opts.on("-c", "--config FILE", "path to config file") do |v|
      options[:config] = v 
    end
  end
  
  parser.parse!

  path = ARGV.pop       
  if options[:config].nil? or path.nil?
     puts parser.help
     exit
  end  
     
  options =  YAML::load(File.open(options[:config]))
  mob = Mobster.new(options)
  mob.scann(path)
  
  pp Issue.stat
  
end
