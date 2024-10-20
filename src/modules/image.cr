require "digest/md5"

# Handles image and pdf parsing and printing.
module Image
  WIDTH  = ARGV.size > 2 ? ARGV[1].to_i : 160
  HEIGHT = ARGV.size > 2 ? ARGV[2].to_i : 40

  # Generates a preview image for a pdf specified by *file_name* and calls `#image` to print it.
  def ql(file_name : String) : String
    s = File.info(file_name)
    hash = Digest::MD5.hexdigest do |ctx|
      ctx.update file_name
      ctx.update s.size.to_s
      ctx.update s.modification_time.to_unix.to_s
    end

    cache_dir = "#{ENV["HOME"]}/.cache/crpreview/"
    cache = cache_dir + "ql-#{hash}.png"

    if !File.exists?(cache)
      # `pdftoppm -jpeg -f 1 -singlefile "#{file_name}" "#{cache}"`
      `qlmanage -x -t "#{file_name}" -f 8 -o "#{cache_dir}"`
      File.rename("#{cache_dir}/#{File.basename(file_name)}.png", cache)
    end

    image(cache)
  end

  # Prints an image specified by *file_name*.
  def image(file_name : String) : String
    `chafa --size #{WIDTH}x#{HEIGHT} --animate false -f sixel "#{file_name}"`
    # `imgcat -W #{WIDTH} -H #{HEIGHT} -r #{file_name}`
  end
end
