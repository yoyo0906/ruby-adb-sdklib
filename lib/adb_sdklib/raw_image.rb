# coding: utf-8

module AdbSdkLib
  class RawImage
    include Common

    def initialize(image)
      unless image.instance_of?(Rjb::Rjb_JavaProxy) &&
          image._classname == 'com.android.ddmlib.RawImage'
        raise TypeError, "Parameter is not com.android.ddmlib.RawImage class"
      end
      class << image
        def call_java_method(method_name, *args)
          rjb_method_missing(method_name, *args)
        rescue => e
          raise SdkLibError.new(e.message, e.class.to_s, self._classname, method_name)
        end
        alias_method :rjb_method_missing, :method_missing
        alias_method :method_missing, :call_java_method
      end
      @image = image
    end

    def get_argb(index)
      @image.getARGB(index)
    end

    def color(index)
      argb = @image.getARGB(index)
      {
        alpha: (argb >> 8*3) & 0xFF,
        red: (argb >> 8*2) & 0xFF,
        green: (argb >> 8*1) & 0xFF,
        blue: (argb >> 8*0) & 0xFF
      }
    end

    def width()
      @image.width
    end

    def height()
      @image.height
    end

    def bpp()
      @image.bpp
    end

    def point_to_index(x,y)
      return (x*(bpp >> 3))+(y*((bpp >> 3)*(width)))
    end
  end
end
