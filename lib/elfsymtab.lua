-- ELF symbol table section handler

module( ..., package.seeall )

local cl = require "classes"
local sf = string.format 
local ct = require "elfct"
local sym = require "elfsym"

local _symtab = cl.new_class( "elfsymtab", "elfsect", "ELF symbol table section handler" )

new = function( stream, offset )
  local self = cl.new_instance( "elfsymtab" )
  getmetatable( self ).__index = function( table, key )
    if type( key ) == "number" then
      assert( key >= 0 and key < #self.symbols, sf( "invalid index '%d'", key ) )
      return self.symbols[ key + 1 ]
    else
      return _symtab[ key ]
    end
  end
  _symtab.base.init( self, stream, offset )
  self.symbols = {}
  self.name_to_sym = {}
  return self
end

_symtab.set_sym_strtab = function( self, sect )
  self.sym_strtab = sect
  for i = 1, #self.symbols do
    self.symbols[ i ]:set_strtab( sect )
    self.name_to_sym[ self.symbols[ i ]:get_name() ] = self.symbols[ i ]
  end
end

_symtab.get_num_symbols = function( self )
  return #self.symbols
end

_symtab.get_symbol_at = function( self, idx )
  return self.symbols[ idx + 1 ]
end

_symtab.load = function( self )
  local s = self.stream
  _symtab.base.load( self )
  -- Check proper section type
  assert( self:get_type() == ct.SHT_SYMTAB or self:get_type() == ct.SHT_DYNSYM )
  if self:get_size() == 0 then return self end -- empty string section
  -- Read and interpret each symbol in turn
  local symsize = self:get_entry_size()
  local numsym = self:get_size() / symsize
  for i = 1, numsym do
    self.symbols[ i ] = sym.new( s, self:get_offset() + ( i - 1 ) * symsize ):load()
  end
  return self
end

_symtab.filter = function( self, filter, negate )
  if not filter.type and not filter.binding and not filter.section and not filter.visibility then return self.symbols end
  local allowed_types, allowed_bindings, allowed_sections, allowed_visibility
  -- Check filter (type or binding or section or visibility)
  if filter.type then allowed_types = elfutils.to_table( filter.type ) end
  if filter.binding then allowed_bindings = elfutils.to_table( filter.binding ) end
  if filter.section then allowed_sections = elfutils.to_table( filter.section ) end
  if filter.visibility then allowed_visibility = elfutils.to_table( filter.visibility ) end
  local filtered, include = {}
  for idx, s in ipairs( self.symbols ) do
    if allowed_types then include = elfutils.has_value( allowed_types, s:get_type() ) end
    if allowed_bindings then include = include and elfutils.has_value( allowed_bindings, s:get_binding() ) end
    if allowed_sections then include = include and elfutils.has_value( allowed_sections, s:get_section_idx() ) end
    if allowed_visibility then include = include and elfutils.has_value( allowed_visibility, s:get_visibility() ) end
    filtered[ idx ] = include
    if negate then filtered[ idx ] = not filtered[ idx ] end
  end
  local syms = {}
  for idx = 1, #filtered do
    if filtered[ idx ] then syms[ #syms + 1 ] = self.symbols[ idx ] end  
  end
  return syms
end

_symtab.iterator = function( self, stype, negate )
  local fiter = function( syms, n )
    n = n + 1
    if n <= #syms then return n, syms[ n ] end
  end
  local syms = stype and self:filter( stype, negate ) or self.symbols
  return fiter, syms, 0
end

_symtab.find_symbol = function( self, name )
  return self.name_to_sym[ name ]
end

_symtab.get_undefined_symbols = function( self )
  return self:filter{ section = ct.SHN_UNDEF } 
end

_symtab.get_function_symbols = function( self )
  return self:filter{ type = ct.STT_FUNC }
end

_symtab.get_file_symbols = function( self )
  return self:filter{ type = ct.STT_FILE }
end

_symtab.get_object_symbols = function( self )
  return self:filter{ type = ct.STT_OBJECT }
end


