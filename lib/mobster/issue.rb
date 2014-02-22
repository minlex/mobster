
module IssueType

  SENSITIVE_INFO =   "Trying to get IMEI"
  SQL_USE =   "Use of SQL statement"
  PUBLIC_FILE = "Opening File with perrmission to all"
  SIMPLE_RANDOM = "Initialize Random with bad seed"
  SET_SSL_VERIFIER = "Changing SSL certivicate default verifier"
  USE_WEBVIEW =   "Use of webView"
  RECEIVER_WITHOUT_PERM = "A receiver without the brodcaster permission"
  BROADCAST_WITHOUT_PERM = "Broadcast send without permission"
  STICKY_BROADCAST = "Using Sticky broadcast"
  PBKEYSPEC_WITH_SMALL_ITER = "Initialization PBEKeySpec with small iteration count"
  USE_BAD_CIPHER = "Application use insecure cipher"
  WEBVIEW_JAVASCRIPT = "Webview with enabled javascript"
  WEBVIEW_PLUGINS = "Webview with enabled plugins"
  WEBVIEW_FILEACCESS = "Webview with enabled local file access"
  HTTP_CONNECTION = "Using http connection without ssl"
  PROVIDER_PERMISSION = "Provider with read and write permission"
  RECEIVER_WITHOUT_PERMISSION = "Receiver without permission"

  GRANT_URI_PERMISSION = "Grant uri permission"

  LOAD_DEX = "Loarding dynamicly dex file "
  SET_ENTITES = "Set external entites feature"
  USING_LOG = "Using logging"
  PATH_PREFIX = "Using path prefix with /"
  SECRET_CODE = "Found secret code"
  PRIORITY  = "Using priority"

  NOPERMISSION = "No Permssion Attribute"
  LOWSDK = "Low sdk version"
  GRANT_URI_PERMISSION = "Provider with grantUriPermission"
  NOWRITEORREADPERMISSION = "NO Permission read or write attribute for provider"

end

module IssueWeight

  SENSITIVE_INFO =  1
  SQL_USE =   1
  PUBLIC_FILE =1
  SIMPLE_RANDOM = 1
  SET_SSL_VERIFIER = 3
  USE_WEBVIEW =   1
  RECEIVER_WITHOUT_PERM =1
  BROADCAST_WITHOUT_PERM =1
  STICKY_BROADCAST = 1
  PBKEYSPEC_WITH_SMALL_ITER =1
  USE_BAD_CIPHER = 1
  WEBVIEW_JAVASCRIPT = 2
  WEBVIEW_PLUGINS = 2
  WEBVIEW_FILEACCESS =3
  HTTP_CONNECTION = 2
  PROVIDER_PERMISSION = 1
  RECEIVER_WITHOUT_PERMISSION =1
end  

class Issue
  attr_reader :desc,:stat,:weight

  @@stat = {}
  def initialize(desc,m=nil,i=nil,w=1)
    @@stat.add_one(desc)
    @desc = desc
    @filename = m.pclass.filename unless m.nil?
    @classname = m.pclass.classname unless m.nil?
    @methodname = m.name[0] unless m.nil?
    if not i.nil?
      @line = i.line
    end
    @method = m
    @invoked = i

    @weight = w
  end
  
  def self.stat
    @@stat
  end
  
  def to_s
    if @method.nil?
      return "#{@desc}"
    else
      return  "#{@method.pclass.filename}: #{@method.pclass.classname} -> #{@method.name[0]}:#{@invoked.methodname[0]} #{@invoked.line} #{@invoked.params.inspect}\r\n #{@desc} "
    end
  end
  
end

