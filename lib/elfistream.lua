-------------------------------------------------------------------------------
-- Abstract read-only streams with 'seek' method

module( ..., package.seeall )
require "pack"
local cl = require "classes"

local istream = cl.new_class( "elfistream", "object", "ELF stream interface" )

istream.open = function( self, arg )
  error "abstract function 'open' called"
end

istream.close = function( self )
  error "abstract function 'close' called"
end

istream.read = function( self, nbytes )
  error "abstract function 'read' called"
end

istream.seek = function( self, position ) 
  error "abstract function 'seek' called"
end

istream.getpos = function( self )
  error "abstract function 'getpos' called"
end

istream.set_endianness = function( self, endian )
  self.endianness = endian
end

istream.read_off = function( self, nbytes, offset )
  local pos = self:getpos()
  self:seek( offset )
  local res = self:read( nbytes )
  self:seek( pos )
  return res
end

istream._read_u32 = function( self )
  local d = self:read( 4 )
  assert( #d == 4 )
  local _, res = string.unpack( d, self.endianness == "big" and ">I" or "<I" )
  return res
end

istream._read_s32 = function( self )
  local d = self:read( 4 )
  assert( #d == 4 )
  local _, res = string.unpack( d, self.endianness == "big" and ">i" or "<i" )
  return res
end

istream._read_u16 = function( self )
  local d = self:read( 2 )
  assert( #d == 2 )
  local _, res = string.unpack( d, self.endianness == "big" and ">H" or "<H" )
  return res
end

istream._read_u8 = function( self )
  local d = self:read( 1 )
  assert( #d == 1 )
  local _, res = string.unpack( d, "b" )
  return res
end

istream.read_elf32_addr = istream._read_u32
istream.read_elf32_half = istream._read_u16
istream.read_elf32_off = istream._read_u32
istream.read_elf32_sword = istream._read_s32
istream.read_elf32_word = istream._read_u32
istream.read_unsigned_char = istream._read_u8

local function gen_read_with_offset( t, fname )
  t[ fname .. "_off" ] = function( self, offset )
    local crtpos = self:getpos()
    self:seek( offset )
    local res = self[ fname ]( self )
    self:seek( crtpos )
    return res
  end
end

gen_read_with_offset( istream, "read_elf32_addr" )
gen_read_with_offset( istream, "read_elf32_half" )
gen_read_with_offset( istream, "read_elf32_off" )
gen_read_with_offset( istream, "read_elf32_sword" )
gen_read_with_offset( istream, "read_elf32_word" )
gen_read_with_offset( istream, "read_unsigned_char" )

