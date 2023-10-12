local userinputservice = game:GetService("UserInputService");
local httpservice = game:GetService("HttpService");

local InputObject = {}
InputObject.__index = InputObject;

local input_objects = {
	hold = {},
	input_began = {},
	input_ended = {},	
};

userinputservice.InputBegan:Connect(function(input : InputObject, gpe : boolean)
	if gpe then return end;
	
	for _, input_began_object in pairs(input_objects.input_began) do 
		-- if the enum type is keycode
		local input_enum_type = input_began_object.input_object.EnumType;
		if input_enum_type == Enum.KeyCode then
			if input.KeyCode == input_began_object.input_object then
				task.spawn(input_began_object.inputBegan);
			end
		elseif input_enum_type == Enum.UserInputType then
			if input.UserInputType == input_began_object.input_object then
				task.spawn(input_began_object.inputBegan)
			end
		end
	end
	
	for _, input_hold_object in pairs(input_objects.hold) do 
		-- if the enum type is keycode
		local input_enum_type = input_hold_object.input_object.EnumType;
		if input_enum_type == Enum.KeyCode then
			if input.KeyCode == input_hold_object.input_object then
				task.spawn(function()
					input_hold_object.holdStart();
					while userinputservice:IsKeyDown(input_hold_object.input_object) 
						and input_hold_object.holdCondition() do 
						input_hold_object.onHold()
						task.wait();
					end
					input_hold_object.holdEnd();
				end)
			end
		elseif input_enum_type == Enum.UserInputType then
			task.spawn(function()
				input_hold_object.holdStart();
				while (userinputservice:IsMouseButtonPressed(input_hold_object.input_object))
					and input_hold_object.holdCondition() do 
					input_hold_object.onHold()
					task.wait();
				end
				input_hold_object.holdEnd();
			end)
		end
	end
end)

userinputservice.InputEnded:Connect(function(input : InputObject, gpe : boolean)
	if gpe then return end;
	
	for _, input_ended_object in pairs(input_objects.input_ended) do 
		-- if the enum type is keycode
		local input_enum_type = input_ended_object.input_object.EnumType;

		if input_enum_type == Enum.KeyCode then
			if input.KeyCode == input_ended_object.input_object then
				task.spawn(input_ended_object.inputEnded);
			end
		elseif input_enum_type == Enum.UserInputType then
			if input.UserInputType == input_ended_object.input_object then
				task.spawn(input_ended_object.inputEnded);
			end
		end
	end
end)

function InputObject:Destroy()
	input_objects[self._type][self._uuid] = nil;
end

local function addInputObjectToList(object : {})
	local uuid = httpservice:GenerateGUID(false);
	object._uuid = uuid;
	input_objects[object._type][object._uuid] = object;
end

return {
	newHold = function(input : Enum, holdStart : () -> any, onHold : () -> any, holdEnd : () -> any, holdCondition : () -> boolean)
		local input_object = {}
		input_object._type = "hold"
		input_object.input_object = input;
		input_object.holdStart = holdStart;
		input_object.onHold = onHold;
		input_object.holdEnd = holdEnd;
		input_object.holdCondition = holdCondition;
		setmetatable(input_object, InputObject);
		addInputObjectToList(input_object);
		return input_object;
	end,
	newInputBegan = function(input : Enum, inputBegan : () -> any)
		local input_object = {}
		input_object._type = "input_began"
		input_object.input_object = input;
		input_object.inputBegan = inputBegan;
		setmetatable(input_object, InputObject);
		addInputObjectToList(input_object);
		return input_object
	end,
	newInputEnded = function(input : Enum, inputEnded : () -> any)
		local input_object = {}
		input_object._type = "input_ended";
		input_object.input_object = input;
		input_object.inputEnded = inputEnded;
		setmetatable(input_object, InputObject);
		addInputObjectToList(input_object);
		return input_object
	end,
}
