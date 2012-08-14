--[[
Simple, easy to use class system, single inheritance only.
Each class must be implemented in its own module
To create a _class_ (not an instance), call new_class( class_name, superclass_name )
To create an instance, call new_instance( class_name )
--]]

module( ..., package.seeall )
local sf = string.format

local classes = {}
local modules = {}

function get_class_meta( name )
  return classes[ name ]
end

function get_class_module( name )
  return modules[ name ]
end

function new_class( name, super, info )
  if super then require( super ) end -- to let the superclass register itself with the classes framework
  if( get_class_meta( name ) ~= nil ) then return get_class_meta( name ) end
  local meta = { subclasses = {}, class_name = name }
  local super_meta = super and assert( get_class_meta( super ), sf( "superclass '%s' not found", super ) )
  classes[ name ] = meta
  modules[ name ] = getfenv( 2 )
  if super_meta then
    setmetatable( meta, { __index = super_meta } )
    super_meta.subclasses[ #super_meta.subclasses + 1 ] = meta
    meta.class_type = super_meta.class_type .. '/' .. name
    meta.base = super_meta
    meta.__tostring = super_meta.__tostring
  else
    meta.class_type = name
  end
  meta.class_info = info or "<no class info>"
  return meta
end

function new_instance( name )
  local c = {}
  local meta = assert( get_class_meta( name ), sf( "class '%s' not found", name ) )
  c.__class__ = meta
  setmetatable( c, { __index = meta, __tostring = meta.__tostring } )
  return c
end

function get_subclasses( o )
  if type( o ) == "string" then
    o = assert( get_class_meta( o ), sf( "class '%s' not found", o ) )
  end
  return o.subclasses
end

function get_class_type( class )
  local meta = assert( get_class_meta( class ), sf( "class '%s' not found", class ) )
  return meta.class_type
end

function _traverse( meta, indent, visited )
  indent = indent or 0
  visited = visited or {}
  if not visited[ meta ] then
    print( sf( "%-30s %s", string.rep( ' ', indent ) .. meta.class_name, meta.class_info ) )
    visited[ meta ] = true
    for _, v in pairs( meta.subclasses ) do
      _traverse( v, indent + 2, visited )
    end
  end
end
 
function print_class_tree()
  _traverse( get_class_meta( "object" ) )
end

