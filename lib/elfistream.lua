-------------------------------------------------------------------------------
-- Abstract read-only streams with 'seek' method

module( ..., package.seeall )
require "pack"
local cl = require "classes"
local bit = require "bit"

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

istream._read_u64 = function( self )
  local l, h = self:_read_u32()
  if self.endianness == "big" then l, h = h, l end
  if h > 2 ^ 21 then error( "64-bit number overflow" ) end
  return h * ( 2 ^ 32 ) + l
end

istream._read_s64 = function( self )
  local l, h = self:_read_u32()
  if self.endianness == "big" then l, h = h, l end
  local sign = 1
  if bit.band( h, 0x80000000 ) ~= 0 then -- this is a negative number
    h, l, sign = bit.bnot( h ), bit.bnot( l ) + 1, -1
    if bit.band( l, 0xFFFFFFFF ) == 0 then h, l = h + 1, 0 end
  end
  if h > 2 ^ 21 then error( "64-bit number overflow" ) end
  return sign * ( h * ( 2 ^ 32 ) + l )
end

istream.read_elf32_addr = istream._read_u32
istream.read_elf32_half = istream._read_u16
istream.read_elf32_off = istream._read_u32
istream.read_elf32_sword = istream._read_s32
istream.read_elf32_word = istream._read_u32
istream.read_unsigned_char = istream._read_u8
istream.read_elf64_addr = istream._read_u64
istream.read_elf64_off = istream._read_u64
istream.read_elf64_half = istream._read_u16
istream.read_elf64_word = istream._read_u32
istream.read_elf64_sword = istream._read_s32
istream.read_elf64_xword = istream._read_u64
istream.read_elf64_sxword = istream._read_s64

local function gen_read_with_offset( t, fname )
  t[ fname .. "_off" ] = function( self, offset )
    local crtpos = self:getpos()
    self:seek( offset )
    local res = self[ fname ]( self )
    self:seek( crtpos )
    return res
  end
end

local flist = { "read_elf32_addr", "read_elf32_half", "read_elf32_off", "read_elf32_sword",
  "read_elf32_word", "read_unsigned_char", "read_elf64_addr", "read_elf64_off", "read_elf64_half",
  "read_elf64_word", "read_elf64_sword", "read_elf64_xword", "read_elf64_sxword" }
for _, v in pairs( flist ) do
  gen_read_with_offset( istream, v )
end  

