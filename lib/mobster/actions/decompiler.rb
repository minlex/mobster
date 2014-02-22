
class Dex2JarDecompiler

  def initialize(path)
    @path = path
  end

  def decompile(app)
    FileUtils.mkdir_p 'jars'
    pwd=`pwd`.chop
    app.sub!(" ","\\ ") 
    v = "#{@path}  -f -o \"#{pwd}/jars/#{app}.jar\"   \"#{pwd}/unziped/#{app}/classes.dex\""
    puts v
    res = system(v)

    puts res
  end

end
    
