----- GLOBAL VARIABLES -----
local Pointer = 0x803E74F4
local XAddress = 0x803E7504
local YAddress = 0x803E7508
local ZAddress = 0x803E750C

function onScriptStart()
end

function onScriptCancel()
end

function onScriptUpdate()
	local BaseAddress = GetPointerNormal(Pointer)
	local OnFootSpeed = ReadValueFloat(BaseAddress + 0x410)
	local FallingSpeed = ReadValueFloat(BaseAddress + 0x3F4)
	local FaceButtons = ReadValue8(BaseAddress + 0x44C)
	local XPosition = ReadValueFloat(XAddress)
	local YPosition = ReadValueFloat(YAddress)
	local ZPosition = ReadValueFloat(ZAddress)

	if FaceButtons > 0 then 
		--WriteValueFloat(BaseAddress + 0x410, 200) --trying to make a moonjump cheat
		ReleaseButton("Y")
		PressButton("Y")
		ReleaseButton("Y")
	end

	local text = "Speed: "
	SetScreenText(
		text .. 
		string.format("%.0f", OnFootSpeed) .. 
		"\nFalling Speed: " .. 
		string.format("%.0f", FallingSpeed) ..
		"\nX: " ..
		string.format("%.2f", XPosition) ..
		"\nY: " ..
		string.format("%.2f", YPosition) ..
		"\nZ: " ..
		string.format("%.2f", ZPosition)
		)
end

function onStateLoaded()
end

function onStateSaved()
end