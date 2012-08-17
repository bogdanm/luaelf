-- ELF REL relocation

module( ..., package.seeall )
local cl = require "classes"
local elfutils = require "elfutils"
local ct = require "elfct"
local sf = string.format

local _rel = cl.new_class( "elfrel", "object", "ELF REL relocation data" )
_rel.__tostring = function( self )
  return sf( "[rel '%s' (%d)]", self:get_sym() and self:get_sym():get_name() or "<no sym name>", self:get_rel_type() )
end

new = function( stream, offset, elfobj, link )
  local self = cl.new_instsance( "elfrel" )
  self:init( stream, offset, elfobj, link )
  return self
end

_rel.init = function( self, stream, offset, elfobj, link )
  self.stream = stream
  self.offset = offset
  self.elfobj = elfobj
  self.link = link
end

_rel.load = function( self )
  local s = self.stream
  s:seek( self.offset )
  if s:get_bitness() == "32" then
    self.r_offset = s:read_elf32_addr()
    self.r_info = s:read_elf32_word()
  else
    self.r_offset = s:read_elf64_addr()
    self.r_info = s:read_elf64_xword()
  end
  return self
end

_rel.get_sym_idx = function( self )
  return self.stream:get_bitness() == "32" and bit.rshift( self.r_info, 8 ) or bit.rshift( self.r_info, 32 )
end

_rel.get_rel_type = function( self )
  return self.stream:get_bitness() == "32" and bit.band( self.r_info, 0xFF ) or bit.band( self.r_info, 0xFFFFFFFF )
end

_rel.get_sym = function( self )
  local sh_link = self.link
  if sh_link < self.elfobj:get_num_sections() then
    local symidx = self:get_sym_idx()
    local s = self.elfobj:get_section_at( sh_link )
    assert( s:get_type() == ct.SHT_SYMTAB or s:get_type() == ct.SHT_DYNSYM )
    return s:get_symbol_at( symidx )
  end
end

_rel.is_rela = function( self )
  return false
end

elfutils.generate_accessors( _rel, {
  { "rel_offset", "r_offset" },
  { "rel_info", "r_info" }
} )

