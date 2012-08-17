-- ELF test program

-- IMPORTANT: setup package.path so it can properly access all LuaELF files
package.path = package.path .. ";lib/?.lua;lib/class/?.lua"
local sf = string.format
local ct = require "elfct"
local elf = require 'elf'

local args = { ... }
-- Get a new 'elf' object instance and load the corresponding ELF file.
-- The 'new' function gets the ELF file name as argument.
local f = elf.new( args[ 1 ] ):load()
-- Once loaded, we can retrieve various entities of the ELF file.
-- The next line retrieves the header object (an 'elfhdr' instance).
local hdr = f:get_header()
-- 'filter_sections' can be used to return an array of sections
-- that respect a set of constraints. It's possible to filter sections
-- by type and flags
local sym = f:filter_sections{ type = ct.SHT_SYMTAB }[ 1 ]
if not sym then sym = f:filter_sections{ type = ct.SHT_DYNSYM }[ 1 ] end

-- Print ELF information as decoded by our 'elfhdr' instance
print( sf( "File type:  %s", hdr:get_type_str() ) )
print( sf( "Machine:    %s", hdr:get_machine_str() ) )
print( sf( "Endianness: %s", hdr:get_endianness() ) )
print( sf( "ABI:        %s (version %d)", hdr:get_osabi_str(), hdr:get_abi_version() ) )
print( sf( "Entry:      %08X", hdr:get_entry() ) )
print( sf( "Sections:   %d, section table at %08X", f:get_num_sections(), hdr:get_sh_off() ) )
print( sf( "Symbols:    %d, starting at offset %08X", sym:get_num_symbols(), sym:get_offset() ) )
print ""

print( "Section table:" )
print( "Idx  Name                Type         Address  Offset   Size     Flg  Al" )
-- Ask the 'elf' instance for an iterator for all the sections in the ELF file
-- The iterator can receive a filter, exactly like filter_sections above
for _, elfidx, s in f:sect_iterator() do
  print( sf( "%3d %-20s %-12s %08X %08X %08X %3s %3d", elfidx, s:get_name(), s:get_type_str(), s:get_address(),
              s:get_offset(), s:get_size(), s:get_flags_str(), s:get_alignment() ) )
end
print ""

-- Now we move to symbols. We already got a reference to the symbol table handler
-- (an instance of 'elfysmtab')
print "List of the first 10 symbols of type 'function' and global binding:"
local cnt = 0
print( "Name                                  Value     Type        Binding   Sect" )
-- One can also iterate over symbols with a filter. Symbols can be filtered by
-- type, binding, the section to which the link and visibility. Below we only
-- filter by type and binding
for _, s in sym:iterator{ type = ct.STT_FUNC, binding = ct.STB_GLOBAL } do
  print( sf( "%-37s %08X  %-10s  %-8s  %s", s:get_name(), s:get_value(), s:get_type_str(), s:get_binding_str(), f:get_section_name( s:get_section_idx() ) ) )
  cnt = cnt + 1
  if cnt == 10 then break end
end

