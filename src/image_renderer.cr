require "./clibs"

module Crpreview
  class CanvasConfig
    getter height : Int32
    getter width : Int32
    getter canvas_config : LibChafa::ChafaCanvasConfig*

    def initialize(width, height)
      @width = width
      @height = height

      @canvas_config = LibChafa.chafa_canvas_config_new
      LibChafa.chafa_canvas_config_set_geometry(@canvas_config, width, height)

      # pixel_mode(LibChafa::ChafaPixelMode::CHAFA_PIXEL_MODE_ITERM2)
    end

    def pixel_mode(mode : LibChafa::ChafaPixelMode)
      LibChafa.chafa_canvas_config_set_pixel_mode(@canvas_config, mode)
    end
  end

  class Canvas
    @canvas : LibChafa::ChafaCanvas*

    def initialize(config : CanvasConfig)
      @canvas = LibChafa.chafa_canvas_new(config.canvas_config)
    end

    def draw_all_pixels(type : LibChafa::ChafaPixelType, pixels : Pointer(UInt8), width : Int32, height : Int32, rowstride : Int32)
      LibChafa.chafa_canvas_draw_all_pixels(@canvas, type, pixels, width, height, rowstride)
    end

    def print : String
      term_db = TermDb.new
      term_info = term_db.detect

      output = LibChafa.chafa_canvas_print(@canvas, term_info)
      String.new(output.value.str)
    end
  end

  class TermDb
    @term_db : LibChafa::ChafaTermDb*

    def initialize
      @term_db = LibChafa.chafa_term_db_get_default
    end

    def detect : LibChafa::ChafaTermInfo*
      environment = GLib.g_get_environ
      LibChafa.chafa_term_db_detect(@term_db, environment)
    end
  end

  class Loader
    getter height : Int32
    getter width : Int32
    getter rowstride : Int32
    getter pixel_type : LibChafa::ChafaPixelType
    property pixels : UInt8*

    def initialize(file_path : String)
      LibMagick.genesis
      wand = LibMagick.new_wand
      image = LibMagick.read_image(wand, file_path.to_unsafe)

      @width = LibMagick.get_width(wand).to_i
      @height = LibMagick.get_height(wand).to_i
      # multiply by 4 channels because we have "RGBA"
      @rowstride = @width * 4

      @pixels = Pointer(UInt8).malloc(@rowstride * @height)

      LibMagick.export_pixels(wand, 0, 0, @width, @height,
        "RGBA".to_unsafe, LibMagick::StorageType::CharPixel, pixels)

      @pixel_type = LibChafa::ChafaPixelType::CHAFA_PIXEL_RGBA8_UNASSOCIATED
    end
  end
end
