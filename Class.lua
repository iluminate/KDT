Class = {}
Object = {}

Object.__index = Object

function Class.new()
	return setmetatable({}, Object)
end

setmetatable(Class, {__call = Class.new})

function Object.say()
	print("here first class in lua")
end