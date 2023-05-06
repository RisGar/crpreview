require "digest/md5"
require "./clibs/chafa"
require "./clibs/magick"

# Handles image and pdf parsing and printing.
module Image
  include Clibs

  WIDTH  = ARGV.size > 2 ? ARGV[1].to_i - 5 : 160
  HEIGHT = ARGV.size > 2 ? ARGV[2].to_i : 40

  # Generates a preview image for a pdf specified by *file_name* and calls `#image` to print it.
  def pdf(file_name : String) : String
    s = File.info(file_name)
    hash = Digest::MD5.hexdigest do |ctx|
      ctx.update file_name
      ctx.update s.size.to_s
      ctx.update s.modification_time.to_unix.to_s
    end
    cache = "#{ENV["HOME"]}/.cache/lf/thumbnail.#{hash}"

    if !File.exists?(cache + ".jpg")
      `pdftoppm -jpeg -f 1 -singlefile "#{file_name}" "#{cache}"`
    end

    image(cache + ".jpg")
  end

  # Prints an image specified by *file_name*.
  def image(file_name : String) : String
    canvas_config = LibChafa.chafa_canvas_config_new
    LibChafa.chafa_canvas_config_set_geometry(canvas_config, WIDTH, HEIGHT)

    canvas = LibChafa.chafa_canvas_new(canvas_config)

    LibMagick.genesis
    wand = LibMagick.new_wand
    LibMagick.read_image(wand, file_name.to_unsafe)

    img_width = LibMagick.get_width(wand)
    img_height = LibMagick.get_height(wand)
    # multiply by 4 channels because we have "RGBA"
    img_rowstride = img_width * 4

    img_pixels = Pointer(UInt8).malloc(img_rowstride * img_height)
    LibMagick.export_pixels(wand, 0, 0, img_width, img_height,
      "RGBA".to_unsafe, LibMagick::StorageType::CharPixel, img_pixels)

    LibChafa.chafa_canvas_draw_all_pixels(canvas, LibChafa::ChafaPixelType::CHAFA_PIXEL_RGBA8_UNASSOCIATED,
      img_pixels, img_width.to_i, img_height.to_i, img_rowstride.to_i)

    term_db = LibChafa.chafa_term_db_get_default
    environment = GLib.g_get_environ
    term_info = LibChafa.chafa_term_db_detect(term_db, environment)

    printed_canvas = LibChafa.chafa_canvas_print(canvas, term_info)
    output = String.new(printed_canvas.value.str)

    LibChafa.chafa_term_db_unref(term_db)
    LibChafa.chafa_term_info_unref(term_info)
    LibChafa.chafa_canvas_unref(canvas)
    LibChafa.chafa_canvas_config_unref(canvas_config)
    GLib.g_string_free(printed_canvas, true)
    LibMagick.destroy_wand(wand)
    LibMagick.wand_terminus

    output
  end
end
