-------------------------------------------------------------------------------
-- ELF file object
-- Uses specs from http://www.sco.com/developers/gabi/latest/contents.html

module( ..., package.seeall )

local elfutils = require "elfutils"
local elfhdr = require "elfhdr"
local elfstream = require "elffstream"
local elfsect = require "elfsect"
local sf = string.format
local elfstrtab = require "elfstrtab"
local elfsymtab = require "elfsymtab"
local elfrelsect = require "elfrelsect"
local cl = require "classes"
local ct = require "elfct"
local sf = string.format
local bit = require "bit"

local _elf = cl.new_class( "elf", "object", "ELF file handler" )

new = function( fname )
  local self = cl.new_instance( "elf" )
  self.elfname = fname
  self.sections = {}
  self.name_to_sect = {}
  return self
end

_elf._load_sections = function( self )
  -- Read section table and create each section in turn as needed
  assert( self.hdr:get_num_sections() > 0, "unable to parse ELF file without sections" )
 local h = self.hdr
  local numsect = h:get_num_sections()
  local s, shoff = self.stream, h:get_sh_off()
  local shentsize = h:get_shent_size()
  -- Read all sections, creating corresponding objects
  for i = 1, numsect do
    local crtoff = shoff + ( i - 1 ) * shentsize
    -- Read section type and create the corresponding section object
    local t = s:read_elf32_word_off( crtoff + 4 )
    local sobj
    if t == ct.SHT_STRTAB then
      sobj = elfstrtab.new( s, crtoff )
    elseif t == ct.SHT_SYMTAB or t == ct.SHT_DYNSYM then
      sobj = elfsymtab.new( s, crtoff )
    elseif t == ct.SHT_REL or t == ct.SHT_RELA then
      sobj = elfrelsect.new( s, crtoff, self )
    else
      sobj = elfsect.new( s, crtoff )
    end
    sobj:set_elf_idx( i - 1 )
    sobj:load()
    self.sections[ i ] = sobj
  end
  -- Link all sections to the strtab index in the header
  if h:get_strtab_index() ~= ct.SHN_UNDEF then
    for i = 1, numsect do
      self.sections[ i ]:set_strtab( self.sections[ h:get_strtab_index() + 1 ] )
      self.name_to_sect[ self.sections[ i ]:get_name() ] = self.sections[ i ]
    end
  end
  -- Link SYMTAB sections to their corresponding string tab section
  for i = 1, numsect do
    if self.sections[ i ]:get_type() == ct.SHT_SYMTAB then
      local s = self.sections[ i ]
      local strtabsect = self.sections[ s:get_link() + 1 ] 
      assert( strtabsect:get_type() == ct.SHT_STRTAB )
      s:set_sym_strtab( strtabsect )
    end
  end
end

_elf.load = function( self )
  -- Open file
  local s = elfstream.new()
  s:open( self.elfname )
  -- Read and interpret header
  self.stream = s
  self.hdr = elfhdr.new( s ):load()
  -- Read and interpret section table
  self:_load_sections()
  return self
end

_elf.get_header = function( self )
  return self.hdr
end

_elf.get_num_sections = function( self )
  return #self.sections
end

_elf.get_section_at = function( self, idx )
  assert( idx >= 0 and idx < #self.sections, sf( "invalid index '%d'", idx ) )
  return self.sections[ idx + 1 ]
end

_elf.filter_sections = function( self, filter, negate )
  if not filter.type and not filter.flags then return self.sections end
  local allowed_types, flagmask, allowed_flags
  -- Check filter (type or flags)
  if filter.type then allowed_types = elfutils.to_table( filter.type ) end
  if filter.flags then
    allowed_flags = elfutils.to_table( filter.flags )
    flagmask = 0
    for _, v in pairs( allowed_flags ) do flagmask = bit.bor( flagmask, v ) end
  end
  local filtered, include = {}
  for idx, s in ipairs( self.sections ) do
    if allowed_types then include = elfutils.has_value( allowed_types, s:get_type() ) end
    if flagmask then include = include and bit.band( s:get_flags(), flagmask ) ~= 0 end
    filtered[ idx ] = include
    if negate then filtered[ idx ] = not filtered[ idx ] end
  end
  local sects = {}
  for idx = 1, #filtered do
    if filtered[ idx ] then sects[ #sects + 1 ] = self.sections[ idx ] end  
  end
  return sects
end

_elf.sect_iterator = function( self, stype, negate )
  local fiter = function( sects, n )
    n = n + 1
    if n <= #sects then
      return n, sects[ n ]:get_elf_idx(), sects[ n ]
    end
  end
  local sects = stype and self:filter_sections( stype, negate ) or self.sections
  return fiter, sects, 0
end

_elf.find_section = function( self, sname )
  return self.name_to_sect[ sname ]
end

