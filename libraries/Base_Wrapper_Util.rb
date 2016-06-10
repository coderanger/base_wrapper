
require 'rubygems/package'

class Chef::Recipe::Base_Wrapper_Util

  def whyrun_supported?
    true
  end

  # @param tgt [Hash] target hash that we will be **altering**
  # @param src [Hash] read from this source hash
  # @return the modified target hash
  # @note this one does not merge Arrays
  # @note This does not overwrite values already in tgt_hash
  def self.deep_merge(tgt_hash, src_hash)
    if tgt_hash.kind_of?(Hash) && src_hash.kind_of?(Hash)
      tgt_hash.merge(src_hash) { |key, oldval, newval|
        deep_merge(oldval, newval) 
      }
    else
      src_hash
    end
  end

  # @param tgt [Hash] target hash that we will be **altering**
  # @param src [Hash] read from this source hash
  # @return the modified target hash
  # @note this one does not merge Arrays
  # @note This does overwrite values already in tgt_hash
  def self.deep_merge!(tgt_hash, src_hash)
    if tgt_hash.kind_of?(Hash) && src_hash.kind_of?(Hash)
      tgt_hash.merge!(src_hash) { |key, oldval, newval|
        deep_merge!(oldval, newval) 
      }
    else
      src_hash
    end
  end

  # @param path [String] the 
  def self.recursive_ls_with_type(path)
    nodesWithType = {}
    if File.directory?(path)
      Dir[File.join(path, "**/*")].each do |node|
        nodeHash = { }
        if File.exists?(node) || File.symlink?(node)
          nodeHash['type'] = File.ftype(node)
          if nodeHash['type'] == "link"
            nodeHash['link_to'] = File.readlink(node)
          else
            mode = sprintf("%o", File.stat(node).mode)
            mode = mode[2,5]
            nodeHash['mode'] = mode
          end
          nodesWithType["#{node}"] = nodeHash
        end
      end
    end
    nodesWithType
  end

end
