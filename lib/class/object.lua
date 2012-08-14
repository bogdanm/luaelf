-- Base class for all the classes

module( ..., package.seeall )

local cl = require "classes" 
local sf = string.format

local objtable = cl.new_class( "object", nil, "base class for all classes" )
objtable.__tostring = function( self )
  return sf( "[%s]", self:get_class_name() )
end

objtable.new = function()
  return cl.new_instance( "object" )
end

objtable.get_type = function( self )
  return self.otype
end

objtable.is_kind_of = function( self, super )
  return self.class_type:find( super .. "/" )
end

objtable.get_class_name = function( self )
  return self.class_name
end

objtable.get_class_type = function( self )
  return self.class_type
end

-- Report a function as "abstract" (no implementation)
abstract = function()
  error( sf( "Function '%s' does not have an implementation", debug.getinfo( 2, "n" ).name ) )
end

