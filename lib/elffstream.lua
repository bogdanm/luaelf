-------------------------------------------------------------------------------
-- File stream

module( ..., package.seeall )
local cl = require "classes"
local sf = string.format

local _fstream = cl.new_class( "elffstream", "elfistream", "ELF file stream" )
_fstream.__tostring = function( self )
  return sf( "[elffstream '%s']", self.name or "<no file>" )
end

new = function()
  return cl.new_instance( "elffstream" )
end

_fstream.open = function( self, name )
  local f, err = io.open( name, "rb" )
  if not f then error( sf( "unable to open file '%s': %s", name, err ) ) end
  self.handle = f
  self.name = name
end

_fstream.close = function( self )
  if self.handle then
    self.handle:close()
    self.handle = nil
    self.name = name
  end
end

_fstream.read = function( self, nbytes )
  assert( self.handle )
  local data, err = self.handle:read( nbytes )
  data = data or ""
  return data, err
end

_fstream.seek = function( self, position )
  assert( self.handle )
  assert( self.handle:seek( "set", position ) )
end

_fstream.getpos = function( self )
  assert( self.handle )
  return self.handle:seek()
end

