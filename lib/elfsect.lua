-- Generic section reader for ELF files

module( ..., package.seeall )
local sf = string.format
local elfutils = require "elfutils"
local cl = require "classes"
local ct = require "elfct"
local bit = require "bit"

---------------------------------------
-- ELF section object

local _sect = cl.new_class( "elfsect", "object", "ELF section handler (generic)" )
_sect.__tostring = function( self )
  return sf( "[%s '%s']", self:get_class_name(), self:get_name() )
end

new = function( stream, offset )
  local self = cl.new_instance( "elfsect" )
  self:init( stream, offset )
  return self
end

_sect.init = function( self, stream, offset )
  self.stream = stream
  self.offset = offset
end

_sect.load = function( self )
  local s = self.stream
  s:seek( self.offset )
  if self.stream:get_bitness() == "32" then
    self.sh_name = s:read_elf32_word()
    self.sh_type = s:read_elf32_word()
    self.sh_flags = s:read_elf32_word()
    self.sh_addr = s:read_elf32_addr()
    self.sh_offset = s:read_elf32_off()
    self.sh_size = s:read_elf32_word()
    self.sh_link = s:read_elf32_word()
    self.sh_info = s:read_elf32_word()
    self.sh_addralign = s:read_elf32_word()
    self.sh_entsize = s:read_elf32_word()
  else
    self.sh_name = s:read_elf64_word()
    self.sh_type = s:read_elf64_word()
    self.sh_flags = s:read_elf64_xword()
    self.sh_addr = s:read_elf64_addr()
    self.sh_offset = s:read_elf64_off()
    self.sh_size = s:read_elf64_xword()
    self.sh_link = s:read_elf64_word()
    self.sh_info = s:read_elf64_word()
    self.sh_addralign = s:read_elf64_xword()
    self.sh_entsize = s:read_elf64_xword()
  end
  return self
end

_sect.get_name = function( self )
  assert( self.strtab )
  return self.strtab:get_string( self.sh_name )
end

_sect.set_strtab = function( self, strtab )
  self.strtab = strtab
end

_sect.set_elf_idx = function( self, idx )
  self.elf_idx = idx
end

_sect.get_data = function( self )
  if not self.data then
    self.data = self.stream:read_off( self.sh_size, self.sh_offset )
  end
  return self.data
end

_sect.get_flags_str = function( self )
  local fstr, f = "", self.sh_flags
  local check = { "SHF_WRITE", "SHF_ALLOC", "SHF_EXECINSTR", "SHF_MERGE", "SHF_STRINGS", "SHF_INFO_LINK", "SHF_LINK_ORDER", "SHF_GROUP" }
  local encs = { "W", "A", "X", "M", "S", "I", "L", "G" }
  for i = 1, #check do
    if bit.band( f, ct[ check[ i ] ] ) ~= 0 then
      fstr = fstr .. encs[ i ] 
    end
  end
  return fstr
end

_sect.get_type_str = function( self )
  return ct.elf_secttype_to_str( self.sh_type )
end

elfutils.generate_accessors( _sect, {
  { "name_idx", "sh_name" },
  { "type", "sh_type" },
  { "flags", "sh_flags" },
  { "address", "sh_addr" },
  { "offset", "sh_offset" },
  { "size", "sh_size" },
  { "link", "sh_link" },
  { "info", "sh_info" },
  { "alignment", "sh_addralign" },
  { "entry_size", "sh_entsize" },
  { "elf_idx", "elf_idx" }
} )

