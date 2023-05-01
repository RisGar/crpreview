require "./clibs/chafa"
require "./clibs/magick"

module Crpreview
  class CanvasConfig
    getter canvas_config : LibChafa::ChafaCanvasConfig*

    def initialize(width, height)
      @canvas_config = LibChafa.chafa_canvas_config_new
      LibChafa.chafa_canvas_config_set_geometry(@canvas_config, width, height)

      # pixel_mode(LibChafa::ChafaPixelMode::CHAFA_PIXEL_MODE_ITERM2)
    end

    def pixel_mode(mode : LibChafa::ChafaPixelMode) : Void
      LibChafa.chafa_canvas_config_set_pixel_mode(@canvas_config, mode)
    end

    def close : Void
      LibChafa.chafa_canvas_config_unref(@canvas_config)
    end
  end

  # Wrapper around `ChafaCanvas` with methods to create, draw and print images.
  class Canvas
    @canvas : LibChafa::ChafaCanvas*

    def initialize(config : CanvasConfig)
      @canvas = LibChafa.chafa_canvas_new(config.canvas_config)
    end

    def draw_all_pixels(pixels : Pointer(UInt8), width : LibC::Int, height : LibC::Int, rowstride : LibC::Int) : Void
      LibChafa.chafa_canvas_draw_all_pixels(@canvas, LibChafa::ChafaPixelType::CHAFA_PIXEL_RGBA8_UNASSOCIATED, pixels, width, height, rowstride)
    end

    def print : String
      term_db = TermDb.new
      term_info = term_db.detect

      printed_canvas : GLib::GString* = LibChafa.chafa_canvas_print(@canvas, term_info.term_info)

      term_db.close
      term_info.close

      output = String.new(printed_canvas.value.str)

      GLib.g_string_free(printed_canvas, true)

      output
    end

    def close : Void
      LibChafa.chafa_canvas_unref(@canvas)
    end
  end

  # Wrapper around `ChafaTermDb` with method to detect the terminal type.
  class TermDb
    @term_db : LibChafa::ChafaTermDb*

    def initialize
      @term_db = LibChafa.chafa_term_db_get_default
    end

    def detect : TermInfo
      environment = GLib.g_get_environ
      info = LibChafa.chafa_term_db_detect(@term_db, environment)
      TermInfo.new(info)
    end

    def close : Void
      LibChafa.chafa_term_db_unref(@term_db)
    end
  end

  class TermInfo
    getter term_info : LibChafa::ChafaTermInfo*

    def initialize(term_info : LibChafa::ChafaTermInfo*)
      @term_info = term_info
    end

    def close : Void
      LibChafa.chafa_term_info_unref(@term_info)
    end
  end

  # Wrapper around `MagickWand` that opens an image and extracts the data
  class ImageData
    getter height : LibC::SizeT
    getter width : LibC::SizeT
    getter rowstride : LibC::SizeT
    property pixels : UInt8*

    def initialize(file_path : String)
      LibMagick.genesis
      wand = LibMagick.new_wand
      LibMagick.read_image(wand, file_path.to_unsafe)

      @width = LibMagick.get_width(wand)
      @height = LibMagick.get_height(wand)
      # multiply by 4 channels because we have "RGBA"
      @rowstride = @width * 4

      @pixels = Pointer(UInt8).malloc(@rowstride * @height)

      LibMagick.export_pixels(wand, 0, 0, @width, @height,
        "RGBA".to_unsafe, LibMagick::StorageType::CharPixel, pixels)
    end

    def close : Void
    end
  end
end
