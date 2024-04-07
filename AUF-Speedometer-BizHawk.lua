--Pointer addresses
BaseAddress = memory.read_u32_be(0x803E74F4)
HealthPointer = memory.read_u32_be(0x803F0108)

while true do
	--All the player info is kept in memory at values offset from the pointer location
	PlayerSpeed = memory.readfloat(BaseAddress + 0x410,1)
	XSpeed = memory.readfloat(BaseAddress + 0x3EC,1)
	YSpeed = memory.readfloat(BaseAddress + 0x3F0,1)
	ViewAngle = memory.readfloat(BaseAddress + 0x42C,1) + 180

	--AirMoveX and Y represent the position you're holding on the analog stick. Values for each are always between -1 and 1.
	--This is used to calculate the direction of player acceleration.
	AirMoveX = memory.readfloat(BaseAddress + 0x53C,1)
	AirMoveY = memory.readfloat(BaseAddress + 0x540,1)

	--Similar to AirMoveX and Y, except the values are always between -128 and 127
	GroundMoveX = memory.readfloat(BaseAddress + 0x554,1)
	GroundMoveY = memory.readfloat(BaseAddress + 0x558,1)

	FallingSpeed = memory.readfloat(BaseAddress + 0x3F4,1)

	XPosition = memory.readfloat(0x803E7504,1)
	YPosition = memory.readfloat(0x803E7508,1)
	ZPosition = memory.readfloat(0x803E750C,1)

	Health = memory.readfloat(HealthPointer + 0x290,1)
	
	--Early in development, Agent Under Fire had separate health and body armor, like GoldenEye.
	--The developers took out all the body armor, but there is one secret area that has some.
	--https://youtu.be/7bdCVksRIgc?si=OM0T6remJYKyljMI&t=60
	BodyArmor = memory.readfloat(HealthPointer + 0x294,1) 


	--This game has separate addresses for your air movement direction and your ground movement direction.
	--To figure out the direction we're inputting from these, we'll first need to check if we're in the air.
	if FallingSpeed ~= 0 then
		--Figure out the angle you're inputting on the analog stick, given the X and Y angle.
		--If the analog stick X and Y positions are sides of a triangle, the direction we are holding will be the hypotenuse.
		wishdir = math.deg(math.acos(AirMoveX / math.sqrt(AirMoveX^2 + AirMoveY^2)))

		--The above calculation always returns a positive number, so this will make it negative if you're analog stick Y is negative
		if AirMoveY < 0 then
			wishdir = wishdir * -1
		end

	else --Same as before, just with ground movement instead.
		wishdir = math.deg(math.acos(GroundMoveX / math.sqrt(GroundMoveX^2 + GroundMoveY^2)))

		--Make wishdir negative if the analog stick Y is negative
		if GroundMoveY < 0 then
			wishdir = wishdir * -1
		end

	end

	--Wishdir is normally between -180 and 180, but I added 180 so it goes from 0 to 360.
	wishdir = wishdir + 180

	--Find the direction the player is currently moving in.
	if PlayerSpeed > 0 then
		dir = math.deg(math.acos(XSpeed / PlayerSpeed))

		--The above calculation always returns a positive number, so multiply by -1 if Y speed is negative.
		if YSpeed < 0 then
			dir = dir * -1
		end

		--Given everything above, direction is always between -180 and 180, but I added 180 so it goes from 0 to 360
		dir = dir + 180

	else 
		dir = 0
	end

	--The difference between dir (player movement direction) and wishdir (input direction) is very important for speedruns.
	--You want this value to be as close to 90 degrees as possible without going over.
	DirDifference = ((dir-wishdir+180) % 360)-180

	--Only display body armor if we have some
	if BodyArmor > 0 then 
		BodyArmorText = '\nArmor: ' .. string.format("%.0f", BodyArmor)
	else
		BodyArmorText = ''
	end

	--Here is all the text that will be drawn. I'm setting this as a variable
	--so it's easier to work with.
	TextToDraw = 'Speed: ' .. string.format("%.1f",PlayerSpeed) ..
	'\nFalling Speed: ' .. string.format("%.1f",FallingSpeed) ..
	'\nX Speed: ' .. string.format("%.1f",XSpeed) ..
	'\nY Speed: ' .. string.format("%.1f",YSpeed) ..
	
	'\n\nWishdir: ' .. string.format("%.2f",wishdir) ..
	'\nDirection: ' .. string.format("%.2f",dir) ..
	'\nDifference: ' .. string.format("%.2f",DirDifference) ..
	'\nView Angle: ' .. string.format("%.2f",ViewAngle) ..

	"\n\nX: " .. string.format("%.2f", XPosition) ..
	"\nY: " .. string.format("%.2f", YPosition) ..
	"\nZ: " .. string.format("%.2f", ZPosition) ..
	"\n\nHealth: " .. string.format("%.0f", Health) ..
	BodyArmorText

	--Draw all the text in the TextToDraw variable with the following format
	gui.drawText(9,9,TextToDraw,'black',nil,14,'Arial')
	gui.drawText(8,8,TextToDraw,'white',nil,14,'Arial')
	
	--Once the script is done running, advance to the next frame, then do it all over again. Forever.
	emu.frameadvance();
end