
require 'rubygems'
require 'nokogiri'

class IntentFilter
  attr_reader :action, :priority
    def initialize(node)
      @action=node.xpath("intent-filter/action/@android:name").to_s
      @category=node.xpath("intent-filter/category/@android:name").to_s
      @priority = ""
      @priority  =node.xpath("intent-filter/@android:priority").to_s
      @priority  =node.xpath("intent-filter/action/@android:priority").to_s if @priority ==""
      

    end
    def to_s
      return @action
    end
  end

  class AndroidIPC
    attr_reader :exported, :intent_filter, :permission, :name, :node
  def initialize(node)


    @name = node['name']


    @permission = node['permission']
    @exported = false
    
    @node = node
    res =  node.xpath('child::intent-filter')

    if not res.empty?
      @intent_filter = IntentFilter.new node
    end

    if @intent_filter !=  nil
      @exported = true
    end


    attr = node['exported']
    if attr != nil
      if attr =~ /true/
        @exported = true
      elsif attr =~ /false/
        @exported = false
      end
    end
    
  end

  def to_s
    return "#{self.class.to_s} #{@name.to_s} Intent-filter:#{@intent_filter.to_s}"
  end
end

class Activity < AndroidIPC
  def initialize(node)
    super    
  end

    def to_s
    return "#{self.class.to_s} #{@name.to_s} Intent-filter:#{@intent_filter.to_s}"
  end
end

class Service < AndroidIPC
  def initialize(node)
    super
  end
end

class Receiver < AndroidIPC
  
  def initialize(node)
    super
  end
end


class Provider
  attr_reader :permission,:read_permission,:write_permission, :grant_uri_permission
  
  def initialize(node)
    @name = node['name']

    @permission = node['permission']
    @read_permission = node['readPermission']
    @write_permission = node['writePermission']
    @exported = node['exported']
    @grant_uri_permission = node['grant_uri_permission']
  end
end

class GrantUriPermissions
  attr_reader :path
  
  def initialize(node)
    @path =  node['pathPrefix']
    
    if @path.nil?
      @path = node['path']
    elsif @path.nil?
      @path = node['pathPattern']
    end
    
  end
end

class PathPermissions
  attr_reader :permission
 
  def initialize(node)
    @path =  node['pathPrefix']
    
    if @path.nil?
      @path = node['path']
    elsif @path.nil?
      @path = node['pathPattern']
    end
   
   @permission = node['permission'] 
  end
end

class DataTag
  attr_reader :scheme, :host, :port 
  def initialize(node)
    @scheme  = node["scheme"]
    @host  = node["host"]
    @port = node["port"]
  end  
end


class Check
  def check
  end  
end

module AndroidChecks
  
class IsDebuggable < Check
  @desc = "Is application debuggable"
  
  def self.check(manifest)
    
    return manifest.debuggable
    
  end
end

class GetPermissions < Check
  def self.check(manifest)
    return true
  end
end


class ManifestCheck
  
  def self.check(manifest)
     @issues = []
    # not tested
    manifest.provider.each do |p|
      if p.permission == "content.permission.READ_AND_WRITE_CONTENT"
        @issues << Issue.new(IssueType::PROVIDER_PERMISSION)
      end

      if (p.write_permission == nil) or (p.read_permission == nil)  
        @issues << Issue.new(IssueType::NOWRITEORREADPERMISSION)
      end

      if (p.grant_uri_permission == 'true')
        @issues << Issue.new(IssueType::GRANT_URI_PERMISSION)
      end

    end

    manifest.receivers.each do |r|
      if r.permission == nil
        @issues << Issue.new(IssueType::RECEIVER_WITHOUT_PERMISSION,)
      end
    end

    manifest.grant_uri_perm.each do |r|
      if (r.path == "/" or r.path == '*')
        @issues << Issue.new(IssueType::PATH_PREFIX)
      end
    end

    manifest.data.each do |r|
      #puts r
      if (r.scheme == "android_secret_code")
        @issues << Issue.new(IssueType::SECRET_CODE)
      end
    end
    

    manifest.get_public_ipc.each do |r|


      
      if  r.intent_filter.priority != ""        
        @issues << Issue.new(IssueType::PRIORITY)
      end unless r.intent_filter.nil?

      if r.permission == nil
        @issues << Issue.new(IssueType::NOPERMISSION)
      end

    end

    if (manifest.minsdk.to_i <= 16) or (manifest.targetsdk.to_i <= 16) 
      @issues << Issue.new(IssueType::LOWSDK)
    end

    manifest.path_perm.each do |r|

      if r.permission == nil
        @issues << Issue.new(IssueType::NOPERMISSION)
      end

    end


    return @issues
  end
  end

  end
