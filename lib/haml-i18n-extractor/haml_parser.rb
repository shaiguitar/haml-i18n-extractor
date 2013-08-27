require 'haml/parser'

module Haml
  module I18n
    class Extractor
      class HamlParser < Haml::Parser

        def initialize(haml)
          super(haml, Haml::Options.new)
        end

        def flattened_values
          # make the haml we passed in a parse tree!
          @ht_parse_tree = self.parse 
          ret = flatten_tree_attrs(@ht_parse_tree,[])
          ret[1..-2] # we only want the actual lines, not the root node and last line which don't really exist
          #ret
        end
        alias_method :metadata, :flattened_values

        # recurse the tree and return an array of the lines
        # don't care about the tree structure, we don't care about context, just line-by-line
        # but we want the haml::parser metadata for all the lines, iterated over
        def flatten_tree_attrs(node,array)
          array << node_attributes(node)
          node.children.each do |child|
            flatten_tree_attrs(child,array)
          end
          array
        end

        private

        def node_attributes(node)
          attrs = {}
          keep = node.members.reject{|m| m == :parent || m == :children }
          keep.each{|attr|
            attrs[attr] = node[attr]
          }
          attrs
        end

      end
    end
  end
end
