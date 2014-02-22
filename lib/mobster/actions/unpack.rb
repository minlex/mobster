require 'fileutils'

class Unpacker
  def initialize (path,packdir, zipdir)
    @apktool   = path
    @unpackdir = packdir
    @unzipdir  = zipdir
  end

  def unpack(name)
    puts "Unpacking and dissambling #{name}"
    FileUtils.mkdir_p @unpackdir

    d="#{@apktool}  d \"#{name}\" \"#{@unpackdir}/#{File.basename(name,'.apk')}\""
    res= `#{@apktool} d  \"#{name}\" \"#{@unpackdir}/#{File.basename(name,'.apk')}\"`

    
    return "#{@unpackdir}/#{File.basename(name,'.apk')}"
  #  puts res
  end

  def unzip(name)
    FileUtils.mkdir_p 'unziped'
    puts "Unziping #{name}"
    res= `unzip  -o #{name} -d \"unziped/#{File.basename(name,'.apk')}\"`
    puts res
  end
  
end

