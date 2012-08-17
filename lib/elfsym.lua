-- ELF symbol class

module( ..., package.seeall )
local cl = require "classes"
local ct = require "elfct"
local bit = require "bit"
local elfutils = require "elfutils"
local sf = string.format

local _elfsym = cl.new_class( "elfsym", "object", "ELF symbol data" )
_elfsym.__tostring = function( self )
  return sf( "[elfsym %s (%s)]", self:get_name(), self:get_type_str() )
end

new = function( stream, offset )
  local self = cl.new_instance( "elfsym" )
  self.stream = stream
  self.offset = offset
  return self
end

_elfsym.set_strtab = function( self, sect )
  self.strtab = sect
end

_elfsym.load = function( self )
  local s = self.stream
  s:seek( self.offset )
  if s:get_bitness() == "32" then
    self.st_name = s:read_elf32_word()
    self.st_value = s:read_elf32_addr()
    self.st_size = s:read_elf32_word()
    self.st_info = s:read_unsigned_char()
    self.st_other = s:read_unsigned_char()
    self.st_shndx = s:read_elf32_half()
  else
    self.st_name = s:read_elf64_word()
    self.st_info = s:read_unsigned_char()
    self.st_other = s:read_unsigned_char()
    self.st_shndx = s:read_elf64_half()
    self.st_value = s:read_elf64_addr()
    self.size = s:read_elf64_xword()
  end
  return self
end

_elfsym.get_name = function( self )
  assert( self.strtab )
  return self.strtab:get_string( self.st_name )
end

_elfsym.get_binding = function( self )
  return bit.rshift( self.st_info, 4 )
end

_elfsym.get_binding_str = function( self )
  return ct.elf_symbind_to_str( self:get_binding() )
end

_elfsym.get_type = function( self )
  return bit.band( self.st_info, 0x0F )
end

_elfsym.get_type_str = function( self )
  return ct.elf_symtype_to_str( self:get_type() ) 
end

_elfsym.get_visibility = function( self )
  return bit.band( self.st_other, 0x03 )
end

_elfsym.get_visibilty_str = function( self )
  return ct.elf_symvisibility_map[ self:get_visibility() ]
end

elfutils.generate_accessors( _elfsym, {
  { "name_idx", "st_name" },
  { "value", "st_value" },
  { "size", "st_size" },
  { "info", "st_info" },
  { "other", "st_other" },
  { "section_idx", "st_shndx" },
} )

