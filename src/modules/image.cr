require "digest/md5"

# Handles image and pdf parsing and printing.
module Image
  WIDTH  = ARGV.size > 2 ? ARGV[1].to_i : 160
  HEIGHT = ARGV.size > 2 ? ARGV[2].to_i : 40

  # Generates a preview image for a pdf specified by *file_name* and calls `#image` to print it.
  def ql(file_name : String) : String
    s = File.info(file_name)
    hash = Digest::MD5.hexdigest do |ctx| # hashes file in a way that invalidates cache after each modification
      ctx.update file_name
      ctx.update s.size.to_s
      ctx.update s.modification_time.to_unix.to_s
    end

    cache_xdg = ENV["XDG_CACHE_HOME"]? || ENV["HOME"] + "/.cache" # use xdg dir if found
    cache_dir = cache_xdg + "/crpreview/"
    cache = cache_dir + "ql-#{hash}.png"

    if !File.exists?(cache)
      `qlmanage -t "#{file_name}" -s 800 -o "#{cache_dir}"`
      File.rename("#{cache_dir}/#{File.basename(file_name)}.png", cache) # [TODO]: possible to name file directly?
    end

    image(cache)
  end

  # Prints an image specified by *file_name*.
  def image(file_name : String) : String
    `chafa --size #{WIDTH}x#{HEIGHT} --animate false -f sixel "#{file_name}"`
  end
end
