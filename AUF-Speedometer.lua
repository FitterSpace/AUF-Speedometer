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
	local XSpeed = ReadValueFloat(BaseAddress + 0x3EC)
	local YSpeed = ReadValueFloat(BaseAddress + 0x3F0)
	local ViewAngle = ReadValueFloat(BaseAddress + 0x42C) + 180
	local AirMoveX = ReadValueFloat(BaseAddress + 0x53C)
	local AirMoveY = ReadValueFloat(BaseAddress + 0x540)
	local GroundMoveX = ReadValueFloat(BaseAddress + 0x554)
	local GroundMoveY = ReadValueFloat(BaseAddress + 0x558)
	local FallingSpeed = ReadValueFloat(BaseAddress + 0x3F4)
	local FaceButtons = ReadValue8(BaseAddress + 0x44C)
	local XPosition = ReadValueFloat(XAddress)
	local YPosition = ReadValueFloat(YAddress)
	local ZPosition = ReadValueFloat(ZAddress)
	local HealthAddress = GetPointerNormal(HealthPointer)
	local Health = ReadValueFloat(HealthAddress + 0x290)
	local SecretHealth = ReadValueFloat(HealthAddress + 0x294) --A beta leftover that adds another health bar for some reason. Watch aleckermit's AuF Secrets video for more info.


	--Calculating input direction (aka "wishdir")
	--This will be undefined if the player is not moving. I can't get it to work when I account for dividing by zero.
	if FallingSpeed ~= 0 then
		wishdir = math.deg(math.acos(AirMoveX / math.sqrt(AirMoveX^2 + AirMoveY^2)))

		if AirMoveY < 0 then
			wishdir = wishdir * -1
		end

	else
		wishdir = math.deg(math.acos(GroundMoveX / math.sqrt(GroundMoveX^2 + GroundMoveY^2)))

		if GroundMoveY < 0 then
			wishdir = wishdir * -1
		end

	end

	wishdir = wishdir + 180

	--Angles
	if OnFootSpeed > 0 then
		dir = math.deg(math.acos(XSpeed / OnFootSpeed))

		if YSpeed < 0 then
			dir = dir * -1
		end

		dir = dir + 180

	else 
		dir = 0
	end

	

	

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
		"\nX Speed: " .. 
		string.format("%.0f", XSpeed) ..
		"\nY Speed: " .. 
		string.format("%.0f", YSpeed) ..
		"\n\nView Angle: " .. 
		string.format("%.2f", ViewAngle) ..
		"\nDirection: " .. 
		string.format("%.2f", dir) ..
		"\nWishdir: " .. 
		string.format("%.2f", wishdir) ..
		"\nDifference: " .. 
		string.format("%.2f", ((dir-wishdir+180) % 360)-180      ) ..
		
		"\n\nX: " ..
		string.format("%.2f", XPosition) ..
		"\nY: " ..
		string.format("%.2f", YPosition) ..
		"\nZ: " ..
		string.format("%.2f", ZPosition) ..
		"\n\nHealth: " ..
		string.format("%.0f", Health) ..
		SecretHealthText
		)
end

function onStateLoaded()
end

function onStateSaved()
end