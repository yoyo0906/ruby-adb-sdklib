# coding: utf-8
require "adb_sdklib/version"
require 'adb_sdklib/common'
require 'adb_sdklib/device'

module AdbSdkLib
  class Adb
    include Common

    @@AndroidDebugBridge = nil

    def initialize(adb_location = nil, force_new_bridge = false)
      if adb_location.nil?
        @adbpath = `which adb`.chomp!
      else
        @adbpath = adb_location
      end
      raise RadbError, "Not found 'adb' command in $PATH" unless @adbpath

      # load AndroidDebugBridge
      libpath = File.expand_path('../tools/lib/', File.dirname(@adbpath))

      if @@AndroidDebugBridge.nil?
        load_jar("#{libpath}/ddmlib.jar")
        @@AndroidDebugBridge = Rjb::import('com.android.ddmlib.AndroidDebugBridge')
        @@AndroidDebugBridge.initIfNeeded(false)
        at_exit { Adb.terminate }
      end

      @adb = @@AndroidDebugBridge.createBridge(@adbpath, force_new_bridge)
      10.times { |i|
        break if @adb.connected?
        sleep(0.25)
      }
      raise RadbError, 'Connect adb error (timeout)' unless @adb.connected?
    end

    def self.terminate
      unless @@AndroidDebugBridge.nil?
        @@AndroidDebugBridge.terminate
        @@AndroidDebugBridge = nil
      end
    end

    def devices
      devices = @adb.devices.map { |d| Device.new(d) }
      class << devices
        def [](serial); self.find { |d| d.serial_number == serial  } end
      end
      return devices
    end
  end
end
