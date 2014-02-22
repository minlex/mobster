

class Manifest
  attr_reader :debuggable, :activities, :services, :receivers, :provider, :permission, :grant_uri_perm, :data, :c_permission, :minsdk, :targetsdk, :maxsdk, :path_perm

  def initialize(name)
    manifest = Nokogiri::XML(File.open(name))
    puts name
    @package_name = manifest.xpath("//@package").to_s

    @permission = manifest.xpath("//uses-permission/@android:name").to_a.join(':').to_s
    @debuggable = manifest.xpath("//@android:debuggable").to_s
    if @debuggable == "" or @debuggable == "false"
      @debuggable = false
    elsif @debuggable=="true"
      @debuggable = true
    end

    @minsdk = manifest.xpath("//uses-sdk/@android:minSdkVersion").to_s
    @targetsdk = manifest.xpath("//uses-sdk/@android:targetSdkVersion").to_s
    @maxsdk = manifest.xpath("//uses-sdk/@android:maxSdkVersion").to_s

    @minsdk = '1' unless @minsdk != ''   
    @targetsdk = '1' unless @targetsdk != ''


    @activities = []
    @provider = []
    @receivers = []
    @services = []
    @grant_uri_perm = []
    @data = []
    @c_permission  = []
    @path_perm = []
    manifest.xpath("//activity").each {|a| @activities.push(Activity.new(a)) }
    manifest.xpath("//receiver").each {|a| @receivers.push(Receiver.new(a)) }
    manifest.xpath("//provider").each {|a| @provider.push(Provider.new(a)) }
    manifest.xpath("//service").each {|a| @services.push(Service.new(a)) }
    manifest.xpath("//grant-uri-permission").each {|a| @grant_uri_perm.push(GrantUriPermissions.new(a)) }
    manifest.xpath("//data").each {|a| @data.push(DataTag.new(a)) }
    manifest.xpath("//permission").each {|a| @c_permission.push(a) }
     manifest.xpath("//path-permission").each {|a| @gpath_perm.push(PathPermissions.new(a)) }

  end

  def info
    res = { "Package name"=>@package_name, "Package version"=>@version,"Is debuggable"=>@debuggable, "Manifest Permission"=>@permission, "Activites:" => @activities, "Services:" => @services, "Receivers:" => @receivers , "Provider:" => @provider}
  end

  def get_public_ipc
    result = []
    result +=  @services.select{ |x| x.exported }
    result += @activities.select{ |x| x.exported } 

    result +=  @receivers.select{ |x| x.exported }
  
    return result
  end

  def get_all_ipc
    result = []
    result +=  @services
    result += @activities

    result +=  @receivers
    return result
  end

  def get_main_activity
    main =  @activities.index { |a| a.intent_filter.action == "android.intent.action.MAIN" unless a.intent_filter.nil? }
    return @activities[main].name
  end
end

