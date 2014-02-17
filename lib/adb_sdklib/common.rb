# coding: utf-8
require 'rjb'

module AdbSdkLib
  # ADB error
  class AdbError < StandardError; end
  
  # Error on java
  class SdkLibError < StandardError
    # @return [String] error message
    attr_reader :error_message
    # @return [String] exception class name on Java
    attr_reader :exception_name
    # @return [String] class name
    attr_reader :class_name
    # @return [String] method name
    attr_reader :method_name
    
    # @param [String] message error message
    # @param [String] exception_name exception class name on Java
    # @param [String] class_name class name
    # @param [String] method_name method name
    def initialize(message, exception_name, class_name, method_name)
      super("#{message} (#{exception_name}) - [#{class_name}##{method_name}()]")
      @error_message = message
      @exception_name = exception_name
      @class_name = class_name
      @method_name = method_name
    end
  end

  # @private
  class CommandCapture
    def initialize(line_receiver = nil)
      @output = ''
      @line_receiver = line_receiver
    end
    
    # Override
    def addOutput(data, offset, length)
      out = data[offset..(offset + length - 1)] # -1 for ¥x00
      @output << out.force_encoding('UTF-8')
      unless @line_receiver.nil?
        lines = @output.split("\n")
        @output = (@output[-1] != "\n") ? lines.pop : ''
        lines.each { |line|
          @line_receiver.call(line.chomp)
        }
      end
    end

    # Override
    def flush
      if !@line_receiver.nil? && !@output.empty?
        @line_receiver.call(@output)
        @output = ''
      end
    end

    # Override
    def isCancelled; false end
    
    def to_s; @output end
  end
  
  # @private
  module Common
    # @private
    System = Rjb::import('java.lang.System')

    # Inspects whether two objects are the same of Java instance.
    def same_jobject?(obj1, obj2)
      System.identityHashCode(obj1) \
        == System.identityHashCode(obj2)
    end
    
    # Converts Java Map object to Ruby Hash object.
    def convert_map_to_hash(object, &block)
      hash = Hash.new
      i = object.entrySet.iterator
      if block_given?
        while i.hasNext
          entry = i.next
          yield hash, entry.getKey, entry.getValue
        end
      else
        while i.hasNext
          entry = i.next
          hash[entry.getKey] = entry.getValue
        end
      end
      hash
    end

    module_function(:same_jobject?, :convert_map_to_hash)
  end
end

