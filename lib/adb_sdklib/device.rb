# coding: utf-8
require 'adb_sdklib/common'

module AdbSdkLib
  class Device
    include Common

    def initialize(device)
      unless device.instance_of?(Rjb::Rjb_JavaProxy) &&
          device.getClass.getCanonicalName == 'com.android.ddmlib.Device'
        raise TypeError, "Parameter is not com.android.ddmlib.Device class"
      end
      @device = device
    end

    def serial;          @device.serial_number end
    def state;           @device.state.toString.to_sym end
    def online?;         @device.online?     end
    def emulator?;       @device.emulator?   end
    def offline?;        @device.offline?    end
    def bootloader?;     @device.bootloader? end
    def reboot(into=nil) @device.reboot(into) end
    def property_count;  @device.property_count end
    def property(prop);  @device.property(prop) end
    def properties
      convert_map_to_hash(@device.properties) { |hash, key, value|
        hash[key.toString] = value.toString
      }
    end
    def build_version;   @device.property(@device.PROP_BUILD_VERSION) end
    def api_level;       @device.property(@device.PROP_BUILD_API_LEVEL) end
    def build_codename;  @device.property(@device.PROP_BUILD_CODENAME) end
    def device_model;    @device.property(@device.PROP_DEVICE_MODEL) end
    def device_manufacturer; @device.property(@device.PROP_DEVICE_MANUFACTURER) end
    def debuggable;      @device.property(@device.PROP_DEBUGGABLE) end

    def battery_level(freshness_ms=nil)
      if freshness_ms.nil?
        @device.battery_level.int_value
      else
        @device.battery_level(freshness_ms).int_value
      end
    end
    
    def method_missing(action, *args)
      return @device.__send__(action, *args)
    end

    def to_s
      "Android: ID:#{self.serial}"
    end

    def inspect
      "#<AdbSdkLib::Device:#{self.serial}>"
    end

    private
    def to_ary; nil end
  end
end

