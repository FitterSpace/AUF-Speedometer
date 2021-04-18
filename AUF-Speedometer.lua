----- GLOBAL VARIABLES -----
local SpeedPointer = 0x803E74F4
local XAddress = 0x803E7504
local YAddress = 0x803E7508
local ZAddress = 0x803E750C
local HealthPointer = 0x803F0108

function onScriptStart()
end

function onScriptCancel()
end

function onScriptUpdate()
	local BaseAddress = GetPointerNormal(SpeedPointer)
	local OnFootSpeed = ReadValueFloat(BaseAddress + 0x410)
	local FallingSpeed = ReadValueFloat(BaseAddress + 0x3F4)
	local FaceButtons = ReadValue8(BaseAddress + 0x44C)
	local XPosition = ReadValueFloat(XAddress)
	local YPosition = ReadValueFloat(YAddress)
	local ZPosition = ReadValueFloat(ZAddress)
	local HealthAddress = GetPointerNormal(HealthPointer)
	local Health = ReadValueFloat(HealthAddress + 0x290)
	local SecretHealth = ReadValueFloat(HealthAddress + 0x294) --A beta leftover that adds another health bar for some reason. Watch aleckermit's AuF Secrets video for more info.

	if FaceButtons > 0 then 
		--WriteValueFloat(BaseAddress + 0x410, 200) --trying to make a moonjump cheat
		ReleaseButton("Y")
		PressButton("Y")
		ReleaseButton("Y")
	end

	if SecretHealth > 0 then 
		SecretHealthText = "\nExtra Health: " .. string.format("%.0f", SecretHealth)
	else
		SecretHealthText = ""
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
		string.format("%.2f", ZPosition) ..
		"\nHealth: " ..
		string.format("%.0f", Health) ..
		SecretHealthText
		)
end

function onStateLoaded()
end

function onStateSaved()
end