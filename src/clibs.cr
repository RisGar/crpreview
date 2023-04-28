# TODO: Automated (complete) module typedefs
module Crpreview
  @[Link("magickwand")]
  lib LibMagick
    struct MagickWand
      id : LibC::SizeT
    end

    enum StorageType
      UndefinedPixel
      CharPixel
      DoublePixel
      FloatPixel
      LongPixel
      LongLongPixel
      QuantumPixel
      ShortPixel
    end

    fun genesis = MagickWandGenesis
    fun new_wand = NewMagickWand : MagickWand*
    fun read_image = MagickReadImage(wand : MagickWand*, filename : LibC::Char*) : Bool
    fun get_width = MagickGetImageWidth(wand : MagickWand*) : LibC::SizeT
    fun get_height = MagickGetImageHeight(wand : MagickWand*) : LibC::SizeT
    fun export_pixels = MagickExportImagePixels(wand : MagickWand*, x : LibC::SSizeT, y : LibC::SSizeT,
                                                width : LibC::SizeT, height : LibC::SizeT,
                                                map : LibC::Char*, storage : StorageType, pixels : Void*) : Bool
  end

  @[Link("glib-2.0")]
  lib GLib
    # GString
    struct GString
      str : LibC::Char*
      len : LibC::SizeT
      allocated_size : LibC::SizeT
    end

    fun g_string_free(string : GString*, free_segment : Bool)

    # Environment

    fun g_get_environ : LibC::Char**
  end

  @[Link("chafa")]
  lib LibChafa
    fun chafa_symbol_map_new : ChafaSymbolMap*
    fun chafa_symbol_map_add_by_tags(symbol_map : ChafaSymbolMap*, tags : ChafaSymbolTags)
    fun chafa_symbol_map_unref(symbol_map : ChafaSymbolMap*)

    # --- ChafaCanvas ---
    struct ChafaCanvas
      refs : Int32
    end

    fun chafa_canvas_new(config : ChafaCanvasConfig*) : ChafaCanvas*
    fun chafa_canvas_draw_all_pixels(canvas : ChafaCanvas*, src_pixel_type : ChafaPixelType, src_pixels : UInt8*, src_width : Int32, src_height : Int32, src_rowstride : Int32)
    fun chafa_canvas_print(canvas : ChafaCanvas*, term_info : ChafaTermInfo*) : GLib::GString*

    # --- ChafaCanvasConfig ---
    struct ChafaCanvasConfig
      refs : Int32
    end

    enum ChafaPixelMode
      CHAFA_PIXEL_MODE_SYMBOLS
      CHAFA_PIXEL_MODE_SIXELS
      CHAFA_PIXEL_MODE_KITTY
      CHAFA_PIXEL_MODE_ITERM2
    end

    fun chafa_canvas_config_new : ChafaCanvasConfig*
    fun chafa_canvas_config_set_geometry(config : ChafaCanvasConfig*, width : Int32, height : Int32)
    # fun chafa_canvas_config_set_symbol_map(config : ChafaCanvasConfig*, symbol_map : ChafaSymbolMap*)
    fun chafa_canvas_config_set_pixel_mode(config : ChafaCanvasConfig*, pixel_mode : ChafaPixelMode)

    # --- ChafaSymbolMap ---
    struct ChafaSymbolMap
      refs : Int32
    end

    enum ChafaSymbolTags
      CHAFA_SYMBOL_TAG_NONE; CHAFA_SYMBOL_TAG_SPACE; CHAFA_SYMBOL_TAG_SOLID
      CHAFA_SYMBOL_TAG_STIPPLE; CHAFA_SYMBOL_TAG_BLOCK; CHAFA_SYMBOL_TAG_BORDER
      CHAFA_SYMBOL_TAG_DIAGONAL; CHAFA_SYMBOL_TAG_DOT; CHAFA_SYMBOL_TAG_QUAD
      CHAFA_SYMBOL_TAG_HHALF; CHAFA_SYMBOL_TAG_VHALF; CHAFA_SYMBOL_TAG_HALF
      CHAFA_SYMBOL_TAG_INVERTED; CHAFA_SYMBOL_TAG_BRAILLE; CHAFA_SYMBOL_TAG_TECHNICAL
      CHAFA_SYMBOL_TAG_GEOMETRIC; CHAFA_SYMBOL_TAG_ASCII; CHAFA_SYMBOL_TAG_ALPHA
      CHAFA_SYMBOL_TAG_DIGIT; CHAFA_SYMBOL_TAG_ALNUM; CHAFA_SYMBOL_TAG_NARROW
      CHAFA_SYMBOL_TAG_WIDE; CHAFA_SYMBOL_TAG_AMBIGUOUS; CHAFA_SYMBOL_TAG_UGLY
      CHAFA_SYMBOL_TAG_LEGACY; CHAFA_SYMBOL_TAG_SEXTANT; CHAFA_SYMBOL_TAG_WEDGE
      CHAFA_SYMBOL_TAG_LATIN; CHAFA_SYMBOL_TAG_EXTRA; CHAFA_SYMBOL_TAG_BAD
      CHAFA_SYMBOL_TAG_ALL
    end

    # --- ChafaTermDb ---
    struct ChafaTermDb
      refs : Int32
    end

    fun chafa_term_db_get_default : ChafaTermDb*
    fun chafa_term_db_detect(term_db : ChafaTermDb*, envp : LibC::Char**) : ChafaTermInfo*

    # --- ChafaTermInfo ---
    struct ChafaTermInfo
      refs : Int32
    end

    # fun chafa_term_info_new : ChafaTermInfo*
    # fun chafa_term_info_unref(term_info : ChafaTermInfo*)

    # --- Miscellaneous ---
    enum ChafaPixelType
      CHAFA_PIXEL_RGBA8_PREMULTIPLIED; CHAFA_PIXEL_BGRA8_PREMULTIPLIED; CHAFA_PIXEL_ARGB8_PREMULTIPLIED; CHAFA_PIXEL_ABGR8_PREMULTIPLIED
      CHAFA_PIXEL_RGBA8_UNASSOCIATED; CHAFA_PIXEL_BGRA8_UNASSOCIATED; CHAFA_PIXEL_ARGB8_UNASSOCIATED; CHAFA_PIXEL_ABGR8_UNASSOCIATED
      CHAFA_PIXEL_RGB8; CHAFA_PIXEL_BGR8; CHAFA_PIXEL_MAX
    end
  end
end
