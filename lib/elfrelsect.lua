-- ELF relocation section object

module( ..., package.seeall )

local cl = require "classes"
local ct = require "elfct"
local rel = require "elfrel"
local rela = require "elfrela"
local sf = string.format
local elfutils = require "elfutils"

local _relsect = cl.new_class( "elfrelsect", "elfsect", "ELF REL/RELA section handler" )

new = function( stream, offset, elfobj )
  local self = cl.new_instance( "elfrelsect" )
  getmetatable( self ).__index = function( table, key )
    if type( key ) == "number" then
      assert( key >= 0 and key < #self.relocs, sf( "invalid index '%d'", key ) )
      return self.relocs[ key + 1 ]
    else
      return _relsect[ key ]
    end
  end
  _relsect.base.init( self, stream, offset )
  self.relocs = {}
  self.elfobj = elfobj
  return self
end

_relsect.get_num_relocations = function( self )
  return #self.relocs
end

_relsect.get_relocation_at = function( self, idx )
  assert( idx >= 0 and idx < #self.relocs, sf( "invalid index '%d'", idx ) )
  return self.relocs[ idx + 1 ]
end

_relsect.load = function( self )
  local s = self.stream
  _relsect.base.load( self )
  assert( self:get_type() == ct.SHT_REL or self:get_type() == ct.SHT_RELA )
  if self:get_size() == 0 then return self end
  self.data = s:read_off( self:get_size(), self:get_offset() )
  local relsize = self:get_entry_size()
  local numrels = self:get_size() / relsize
  for i = 1, numrels do
    if self:get_type() == ct.SHT_REL then
      self.relocs[ i ] = rel.new( s, self:get_offset() + ( i - 1 ) * relsize, self.elfobj, self:get_link() ):load()
    else
      self.relocs[ i ] = rela.new( s, self:get_offset() + ( i - 1 ) * relsize, self.elfobj, self:get_link() ):load()
    end
  end
  return self
end

_relsect.filter = function( self, filter, negate )
  if not filter.type then return self.relocs end
  local allowed_types = elfutils.to_table( filter.type )
  local filtered = {}
  for idx, s in ipairs( self.relocs ) do
    filtered[ idx ] = elfutils.has_value( allowed_types, s:get_rel_type() )
    if negate then filtered[ idx ] = not filtered[ idx ] end
  end
  local rels = {}
  for idx = 1, #filtered do
    if filtered[ idx ] then rels[ #rels + 1 ] = self.relocs[ idx ] end  
  end
  return rels
end

_relsect.iterator = function( self, stype, negate )
  local fiter = function( rels, n )
    n = n + 1
    if n <= #rels then return n, rels[ n ] end
  end
  local rels = stype and self:filter( stype, negate ) or self.relocs
  return fiter, rels, 0
end

