
class AppFiles

  def initialize(adb_path)
    @adb = adb_path
    @all_files = []

  end

  def install(apk_file)
    puts "Insalling apk file on device"
    res = `#{@adb} install #{apk_file}`
    puts res
  end

  def walk(pkg_name)
    res = `#{@adb} shell ls -l /data/data/#{pkg_name}/`
    if ( /No such file or directory/ =~ res)
      return
    end
#    puts res.inspect
    @all_files +=  (res.split("\r\n"))#.split('\r\n')
    #puts @all_files.inspect
    @all_files.each do |c|
      #puts c
      if c.start_with? "d"
        name = c.split(' ')[-1]
      #  puts "Name:",name
        walk(pkg_name+"/"+name)
      end
    end
  end

  def run(pkg_name,main_activity)
    res = `#{@adb} shell  am start -a android.intent.action.MAIN -n #{pkg_name}/#{main_activity}`
    puts res
  end
  
  def check(pkg_name)

    shared_prefs = `#{@adb} shell ls /data/data/#{pkg_name}/shared_prefs`
    lib = `#{@adb} shell ls /data/data/#{pkg_name}/lib`
    files = `#{@adb} shell ls /data/data/#{pkg_name}/files`


    walk(pkg_name)
    
    puts "Files:"
    @all_files.each { |c| puts c }
#    all_files = `#{@adb} shell ls -l
    #    /data/data/#{pkg_name}/`.split("\n")
    return @all_files
  end

end

if __FILE__ == $0
  adb_path = "/Users/alexmin/android-sdks/platform-tools/adb"
  a = AppFiles.new adb_path
  pkg = "/Users/alexmin/repo/mobster/mobile_banks/cip.wallet.android-13.apk"
  a.install(pkg)
  a.check("cip.wallet.android")
end
