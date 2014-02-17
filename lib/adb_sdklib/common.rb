# coding: utf-8
require 'rjb'

module AdbSdkLib
  class RadbError < StandardError; end

  module Common
    def load_jar(lib)
      raise RadbError, "Not found #{lib}" unless File.exist?(lib)
      Rjb::load(lib)
    end

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

    module_function(:load_jar, :convert_map_to_hash)
  end
end

