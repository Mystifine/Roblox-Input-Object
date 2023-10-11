local userinputservice = game:GetService("UserInputService");
local httpservice = game:GetService("HttpService");

local InputObject = {}
InputObject.__index = InputObject;

local input_objects = {
	hold = {},
	button_up = {},
	button_down = {},	
};

userinputservice.InputBegan:Connect(function(input : InputObject, gpe : boolean)
	if gpe then return end;
	
	for _, button_down_object in pairs(input_objects.button_down) do 
		-- if the enum type is keycode
		if button_down_object.input_object.EnumType == Enum.KeyCode then
			if input.KeyCode == button_down_object.input_object then
				task.spawn(button_down_object.buttonDown);
			end
		end
	end
	
	for _, button_hold_object in pairs(input_objects.hold) do 
		-- if the enum type is keycode
		if button_hold_object.input_object.EnumType == Enum.KeyCode then
			if input.KeyCode == button_hold_object.input_object then
				task.spawn(function()
					button_hold_object.holdStart();
					while userinputservice:IsKeyDown(button_hold_object.input_object) 
						and button_hold_object.holdCondition() do 
						button_hold_object.onHold()
						task.wait();
					end
					button_hold_object.holdEnd();
				end)
			end
		end
	end
end)

userinputservice.InputEnded:Connect(function(input : InputObject, gpe : boolean)
	if gpe then return end;
	
	for _, button_up_object in pairs(input_objects.button_up) do 
		-- if the enum type is keycode
		if button_up_object.input_object.EnumType == Enum.KeyCode then
			if input.KeyCode == button_up_object.input_object then
				button_up_object.buttonUp();
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
	newButtonUp = function(input : Enum, buttonUp : () -> any)
		local input_object = {}
		input_object._type = "button_up"
		input_object.input_object = input;
		input_object.buttonUp = buttonUp;
		setmetatable(input_object, InputObject);
		addInputObjectToList(input_object);
		return input_object
	end,
	newButtonDown = function(input : Enum, buttonDown : () -> any)
		local input_object = {}
		input_object._type = "button_down";
		input_object.input_object = input;
		input_object.buttonDown = buttonDown;
		setmetatable(input_object, InputObject);
		addInputObjectToList(input_object);
		return input_object
	end,
}
