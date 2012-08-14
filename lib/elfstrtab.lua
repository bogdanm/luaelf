-- ELF string table section handler

module( ..., package.seeall )

local cl = require "classes"
local elfs = require "elfsect"
local _strtab = cl.new_class( "elfstrtab", "elfsect", "ELF string tab section handler" )
local sf = string.format 
local ct = require "elfct"

new = function( stream, offset )
  local self = cl.new_instance( "elfstrtab" )
  _strtab.base.init( self, stream, offset )
  return self
end

_strtab.load = function( self )
  local s = self.stream
  _strtab.base.load( self )
  -- Check proper section type
  assert( self:get_type() == ct.SHT_STRTAB )
  if self:get_size() == 0 then return self end -- empty string section
  -- Read section data
  self.data = s:read_off( self:get_size(), self:get_offset() )
  assert( self.data:byte( 1 ) == 0 ) -- the first byte must always be '\0'
  return self
end

_strtab.get_string = function( self, index )
  assert( self.data )
  local _, s = string.unpack( self.data:sub( index + 1 ), "z" )
  if type( s ) ~= "string" or #s == 0 then s = "" end
  return s
end

