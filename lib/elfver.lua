-- Library version data

module( ..., package.seeall )
local cl = require "classes"

local _elfver = cl.new_class( "elfver", "object", "ELF library version information" )
-- Version table as { version, version data } pairs
-- First element in this array is always the latest version
_elfver.versions = 
{
  { "0.1", "Initial release" }
}

new = function()
  return cl.new_instance( "elfver" )
end

_elfver.get_current_version = function( self )
  local v = self.versions[ 1 ]
  return v[ 1 ], v[ 2 ]
end

_elfver.get_version_data = function( self, v )
  v = self.versions[ v ]
  return v and v[ 2 ] or "<version not found>"
end

