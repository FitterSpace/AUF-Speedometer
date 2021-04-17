----- GLOBAL VARIABLES -----
local Pointer = 0x803E74F4

function onScriptStart()
end

function onScriptCancel()
end

function onScriptUpdate()
	local BaseAddress = GetPointerNormal(Pointer)
	local OnFootSpeed = ReadValueFloat(BaseAddress + 0x410)
	local FallingSpeed = ReadValueFloat(BaseAddress + 0x3F4)
	local FaceButtons = ReadValue8(BaseAddress + 0x44C)

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
		string.format("%.0f", FallingSpeed) -- .. 
		--"\nButton: " .. 
		--FaceButtons
		)
end

function onStateLoaded()
end

function onStateSaved()
end