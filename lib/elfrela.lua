-- ELF RELA relocation

module( ..., package.seeall )
local cl = require "classes"
local sf = string.format

local _rela = cl.new_class( "elfrela", "elfrel", "ELF RELA relocation data" )

new = function( stream, offset, elfobj, link )
  local self = cl.new_instance( "elfrela" )
  _rela.base.init( self, stream, offset, elfobj, link )
  return self
end

_rela.load = function( self )
  local s = self.stream
  _rela.base.load( self )
  if s:get_bitness() == "32" then
    self.r_addend = s:read_elf32_sword()
  else
    self.r_addend = s:read_elf64_sxword()
  end
  return self
end

_rela.is_rela = function( self )
  return true
end

_rela.get_rel_addend = function( self )
  return self.r_addend
end

