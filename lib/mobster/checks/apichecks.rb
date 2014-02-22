
require "#{File.dirname(__FILE__)}/../issue"

module AndroidChecks
  class ApiChecks
    attr_accessor :issues

    
    
    def initialize
      @issues = []

    end
    
    def checks(m)
      
      
      m.invoked_methods.each do |i|


        if (i.methodname[0] == "openFileOutput"  and (i.params[2] == 1 or i.params[2] == 2))
          @issues << Issue.new(IssueType::PUBLIC_FILE,m,i,1)
        end


        if (i.methodname[0] == "grantUriPermission")
          @issues << Issue.new(IssueType::GRANT_URI_PERMISSION,m,i,2)
        end


        if (i.methodname[0] == "DexClassLoader")
          @issues << Issue.new(IssueType::LOAD_DEX,m,i,3)
        end
        



        if (i.methodname[0] == "<init>" and i.classname == "javax.crypto.spec.PBEKeySpec")
          if (i.params.length > 2)
            if i.params[3] < 1000              
              @issues << Issue.new(IssueType::PBKEYSPEC_WITH_SMALL_ITER,m,i,1)
            end
          end
        end




        #not tested
        if (i.methodname[0] == "getInstance" and i.classname == "javax.crypto.Cipher")
          insecure_ciphers = ["DES","3DES","\w*\/EBC\/\w*" ]
          cipher = i.params[1]
          res = insecure_ciphers.find { |c| Regexp.new(c) =~ cipher }
          @issues << Issue.new(IssueType::USE_BAD_CIPHER,m,i,2) unless res.nil?
          
        end

        

        if (i.methodname[0] == "setHostnameVerifier" or i.methodname[0] == "setDefaultHostnameVerifier") 
          #puts  "Changing SSL certivicate default verifier"
          issues << Issue.new(IssueType::SET_SSL_VERIFIER,m,i,3)
        end
        
        if (i.classname[0] == "javax.net.ssl.FullX509TrustManager" and i.methodname[0]=="<init>")
          #puts  "Changing SSL certivicate default verifier"
        end

        if (i.methodname[0] == "<init>" or  i.methodname[0] == "java.net.URL" and (i.params[1] =~ /http\:\/\//)) 
          #puts  "Changing SSL certivicate default verifier"        
          issues << Issue.new(IssueType::HTTP_CONNECTION,m,i,2)
        end

        

        
        if (i.classname == "android.webkit.WebSettings" and i.methodname[0] == "setJavaScriptEnabled"  and i.params[1] = true )
          
          @issues << Issue.new(IssueType::WEBVIEW_JAVASCRIPT,m,i,2)

        end

        if (i.classname == "android.webkit.WebSettings" and i.methodname[0] == "setPluginsEnabled"  and i.params[1] = true )
          @issues << Issue.new(IssueType::WEBVIEW_PLUGINS,m,i,2)
        end

        if (i.classname == "android.webkit.WebSettings" and i.methodname[0] == "setAllowFileAccess"  and i.params[1] = true )        
          @issues << Issue.new(IssueType::WEBVIEW_FILEACCESS,m,i,2)
        end



        if (i.methodname[0]  == "rawQuery"   and i.classname == "android.database.sqlite.SQLiteDatabase" and i.params[3] != 'null' )
          @issues <<  Issue.new(IssueType::SQL_USE,m,i,1)
          
        end
        
        if (i.methodname[0]  == "getDeviceId" and i.classname == "android.telephony.TelephonyManager" )
          
          @issues << Issue.new(IssueType::SENSITIVE_INFO,m,i,1)
        end


        if (i.methodname[0]  == "getDeviceSoftwareVersion" and i.classname == "android.telephony.TelephonyManager" )    
          @issues << Issue.new(IssueType::SENSITIVE_INFO,m,i,1)
        end

        if (i.methodname[0] == "getString"  and i.params[2] == "android_id")
          @issues << Issue.new(IssueType::SENSITIVE_INFO,m,i)
        end

        # not tested
        if (i.methodname[0] == "getSimSerialNumber" and i.classname == "android.telephony.TelephonyManager")
          @issues << Issue.new(IssueType::SENSITIVE_INFO,m,i,1)
        end
        
        if (i.methodname[0]  == "registerReceiver" and i.classname == "android.content.Context"  and i.params.length == 3)
          
          @issues << Issue.new(IssueType::RECEIVER_WITHOUT_PERM,m,i,1)
        end

        # not tested
        if (i.methodname[0]  == "sendBroadcast" and i.classname == "android.content.Context"  and i.params.length == 2)
          
          @issues << Issue.new(IssueType::BROADCAST_WITHOUT_PERM,m,i,1)
        end


        if (i.methodname[0]  == "setFeature" and (i.params[1] == "http://xml.org/sax/features/external-parameter-entities" or i.params[1] == "http://xml.org/sax/features/external-general-entities"))
          @issues << Issue.new(IssueType::SET_ENTITES,m,i,1)
        end
        
        
      end
    end  
  end
end          
        
      
