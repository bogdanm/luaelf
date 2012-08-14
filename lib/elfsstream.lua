-------------------------------------------------------------------------------
-- String stream

module( ..., package.seeall )
local cl = require "classes"
local sf = string.format

local _strstream = cl.new_class( 'elfsstream', 'elfistream', "ELF string stream" )
_strstream.__tostring = function( self )
  return self.str and sf( "[elfsstream (len=%d)]", #self.str ) or "[elfsstream <no data>]"
end

new = function()
  local self = cl.new_instance( "elffstream" )
  self.pos = 1
  return self
end

_strstream.open = function( self, s )
  self.str = s
  return s
end

_strstream.close = function( self )
  self.str = nil
end

_strstream.read = function( self, nbytes )
  assert( self.str and self.pos <= #self.str )
  local last = self.pos + nbytes - 1
  if last > #self.str then last = #self.str end
  local res = self.str:sub( self.pos, last )
  self.pos = self.pos + last
  return res
end

_strstream.seek = function( self, position )
  assert( self.str )
  self.pos = position
end

_strstream.getpos = function( self )
  assert( self.str )
  return self.pos
end


