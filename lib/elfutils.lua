-------------------------------------------------------------------------------
-- Various utilities

module( ..., package.seeall )

require "pack"

function str2array( s, first )
  first = first or 1
  local a = {}
  for i = 1, #s do
    a[ first + i - 1 ] = s:byte( i, i )
  end
  return a
end

function generate_accessors( t, alist )
  for _, v in pairs( alist ) do
    if #v == 2 then
      t[ "get_" .. v[ 1 ] ] = function( self )
        return self[ v[ 2 ] ]
      end
    else
      t[ "get_" .. v[ 1 ] ] = function( self )
        return v[ 3 ][ self[ v[ 2 ] ] ]
      end
    end
  end
end

function to_table( v )
  return type( v ) == "table" and v or { v }
end

function key_of_value( table, value )
  for k, v in pairs( table ) do
    if v == value then
      return k
    end
  end
end

function has_value( table, value )
  local k = key_of_value( table, value )
  if not k then return false else return true end
end

