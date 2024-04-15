--Pointer addresses
BaseAddress = memory.read_u32_be(0x803E74F4)
HealthPointer = memory.read_u32_be(0x803F0108)

--Velocity Graph info
MinimumGraphValue = 200
MaximumGraphValue = 700
GraphScale = 0.15
GraphXPos = 1
GraphYPos = 491

--Creating an array for the velocity meter
SpeedArray = {}
for i=1, 180 do
	table.insert(SpeedArray,MinimumGraphValue)
end

--The screen position of the input display
PositionX = 414
PositionY = 48
ControlStickScale = 0.20

--Individual X and Y positions of each object in the input display
LeftStickPositionX = PositionX
LeftStickPositionY = PositionY
RightStickPositionX = PositionX + 76
RightStickPositionY = PositionY
AButtonPositionX = RightStickPositionX + 80
AButtonPositionY = RightStickPositionY - 18
BButtonPositionX = AButtonPositionX - 28
BButtonPositionY = AButtonPositionY + 20
YButtonPositionX = AButtonPositionX
YButtonPositionY = AButtonPositionY - 22
XButtonPositionX = AButtonPositionX + 44
XButtonPositionY = AButtonPositionY - 2
ZButtonPositionX = AButtonPositionX + 41
ZButtonPositionY = AButtonPositionY - 23
DpadPositionX = AButtonPositionX - 42
DpadPositionY = AButtonPositionY - 8
SButtonPositionX = LeftStickPositionX + ((RightStickPositionX-LeftStickPositionX)/2) - 7
SButtonPositionY = LeftStickPositionY - 32
RButtonPositionX = RightStickPositionX - 32
RButtonPositionY = RightStickPositionY - 45
LButtonPositionX = LeftStickPositionX - 32
LButtonPositionY = LeftStickPositionY - 45

ControlStickPolygon = {{-128,0},{-95,95},{0,128},{95,95},{128,0},{95,-95},{0,-128},{-95,-95}}
ControlStickPolygonOutline = {{-128,0},{-95,95},{0,128},{95,95},{128,0},{95,-95},{0,-128},{-95,-95}}

--Scales the control stick by the scaling factor
for i=1,8 do
	for j=1,2 do
		ControlStickPolygon[i][j] = ControlStickPolygon[i][j]*(ControlStickScale*1.2)
	end
end
for i=1,8 do
	for j=1,2 do
		ControlStickPolygonOutline[i][j] = ControlStickPolygonOutline[i][j]*(ControlStickScale*1.3)
	end
end

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
	--The optimal angle changes depending on your speed.
	DirDifference = ((dir-wishdir+180) % 360)-180

	--Only display body armor if we have some
	if BodyArmor > 0 then 
		BodyArmorText = '\nArmor: ' .. string.format("%.0f", BodyArmor)
	else
		BodyArmorText = ''
	end

	--Inserting the player's velocity into the array if it's between the min and max range, then removing the oldest value	
	if PlayerSpeed <= MaximumGraphValue
	and PlayerSpeed >= MinimumGraphValue then
		table.insert(SpeedArray,1,PlayerSpeed)
	elseif PlayerSpeed > MaximumGraphValue then
		table.insert(SpeedArray,1,MaximumGraphValue)
	else
		table.insert(SpeedArray,1,MinimumGraphValue)
	end
	table.remove(SpeedArray,table.getn(SpeedArray))

	--Reading player inputs for the input display
	if bit.check(memory.read_u8(0x803C1340),0) then ButtonA = 'A' else ButtonA = '' end
	if bit.check(memory.read_u8(0x803C1340),1) then ButtonB = 'B' else ButtonB = '' end
	if bit.check(memory.read_u8(0x803C1340),2) then ButtonX = 'X' else ButtonX = '' end
	if bit.check(memory.read_u8(0x803C1340),3) then ButtonY = 'Y' else ButtonY = '' end
	if bit.check(memory.read_u8(0x803C1340),4) then ButtonS = 'S' else ButtonS = '' end
	if bit.check(memory.read_u8(0x803C1341),0) then ButtonDpadL = 'L' else ButtonDpadL = '' end
	if bit.check(memory.read_u8(0x803C1341),1) then ButtonDpadR = 'R' else ButtonDpadR = '' end
	if bit.check(memory.read_u8(0x803C1341),2) then ButtonDpadD = 'D' else ButtonDpadD = '' end
	if bit.check(memory.read_u8(0x803C1341),3) then ButtonDpadU = 'U' else ButtonDpadU = '' end
	if bit.check(memory.read_u8(0x803C1341),4) then ButtonZ = 'Z' else ButtonZ = '' end
	if bit.check(memory.read_u8(0x803C1341),5) then ButtonR = 'R' else ButtonR = '' end
	if bit.check(memory.read_u8(0x803C1341),6) then ButtonL = 'L' else ButtonL = '' end

	LeftStickX = memory.read_u8(0x803C1342)-128
	LeftStickY = memory.read_u8(0x803C1343)-128
	RightStickX = memory.read_u8(0x803C1344)-128
	RightStickY = memory.read_u8(0x803C1345)-128

	ControllerInput = memory.read_u8(0x803C1340)

	--Here is all the text that will be drawn. I'm setting this as a variable
	--so it's easier to work with.
	TextToDraw = 'Speed: ' .. string.format("%.1f",PlayerSpeed) ..
	'\nFalling Speed: ' .. string.format("%.1f",FallingSpeed) ..
	'\nX Speed: ' .. string.format("%.1f",XSpeed) ..
	'\nY Speed: ' .. string.format("%.1f",YSpeed) ..
	
	'\n\nDirection: ' .. string.format("%.2f",dir) ..
	'\nWishdir: ' .. string.format("%.2f",wishdir) ..
	'\nDifference: ' .. string.format("%.2f",DirDifference) ..
	'\nView Angle: ' .. string.format("%.2f",ViewAngle) ..

	"\n\nX: " .. string.format("%.2f", XPosition) ..
	"\nY: " .. string.format("%.2f", YPosition) ..
	"\nZ: " .. string.format("%.2f", ZPosition) ..
	"\n\nHealth: " .. string.format("%.0f", Health) ..
	BodyArmorText

	--Draw the background for the velocity graph
	gui.drawBox(GraphXPos-1,GraphYPos,GraphXPos-1+table.getn(SpeedArray),GraphYPos-((MaximumGraphValue-MinimumGraphValue)*GraphScale),'#7F000000','#7F000000')

	--Draw the values for the velocity graph
	for i=1, table.getn(SpeedArray) do
		gui.drawLine(i-GraphXPos,GraphYPos,i-GraphXPos,GraphYPos-(SpeedArray[i]-MinimumGraphValue)*GraphScale,'#cd2e2e')
	end

	--Drawing grid lines for the velocity graph, which represent 300, 400, 500, etc.
	--gui.drawLine(GraphXPos-1,GraphYPos-(300-MinimumGraphValue)*GraphScale,GraphXPos-1+table.getn(SpeedArray),GraphYPos-(300-MinimumGraphValue)*GraphScale,'#7Fafafaf')
	--gui.drawLine(GraphXPos-1,GraphYPos-(400-MinimumGraphValue)*GraphScale,GraphXPos-1+table.getn(SpeedArray),GraphYPos-(400-MinimumGraphValue)*GraphScale,'#7Fafafaf')
	--gui.drawLine(GraphXPos-1,GraphYPos-(500-MinimumGraphValue)*GraphScale,GraphXPos-1+table.getn(SpeedArray),GraphYPos-(500-MinimumGraphValue)*GraphScale,'#7Fafafaf')
	--gui.drawLine(GraphXPos-1,GraphYPos-(600-MinimumGraphValue)*GraphScale,GraphXPos-1+table.getn(SpeedArray),GraphYPos-(600-MinimumGraphValue)*GraphScale,'#7Fafafaf')
	
	--Drawing the player's velocity number on the graph
	gui.drawText(GraphXPos+5,GraphYPos-21,string.format("%.0f",PlayerSpeed),'black',nil,14,'Arial')
	gui.drawText(GraphXPos+4,GraphYPos-22,string.format("%.0f",PlayerSpeed),'#ffffff',nil,14,'Arial')

	--Draw all the text in the TextToDraw variable with the following format
	gui.drawText(9,9,TextToDraw,'black',nil,14,'Arial')
	gui.drawText(8,8,TextToDraw,'#00ffff',nil,14,'Arial')
	
	---------------------------------------
	------------ INPUT DISPLAY ------------
	---------------------------------------
	--Drawing the gray and yellow backgrounds for the control stick and C stick.
	gui.drawPolygon(ControlStickPolygonOutline,LeftStickPositionX,LeftStickPositionY,"#333333", "#333333")
	gui.drawPolygon(ControlStickPolygon,LeftStickPositionX,LeftStickPositionY,"#5b5b5b", "#5b5b5b")
	gui.drawPolygon(ControlStickPolygonOutline,RightStickPositionX,RightStickPositionY,"#765900", "#765900")
	gui.drawPolygon(ControlStickPolygon,RightStickPositionX,RightStickPositionY,"#bf9000", "#bf9000")

	--Drawing text for the button presses
	
	--gui.drawText(PositionX,PositionY,ButtonA,'#00c93c',nil,16,'Arial','bold')
	--gui.drawText(PositionX,PositionY,TextToDraw,'white',nil,16,'Arial','bold')

	--Drawing the button backgrounds, which are seen when the button isn't being pressed
	gui.drawEllipse(AButtonPositionX,AButtonPositionY,40,40,'#000000','#002c0d')
	gui.drawEllipse(BButtonPositionX,BButtonPositionY,24,24,'#000000','#640000')
	gui.drawEllipse(YButtonPositionX,YButtonPositionY,36,18,'#000000','#303030')
	gui.drawEllipse(XButtonPositionX,XButtonPositionY,18,36,'#000000','#303030')
	gui.drawEllipse(ZButtonPositionX,ZButtonPositionY,16,16,'#000000','#20124d')
	gui.drawEllipse(SButtonPositionX,SButtonPositionY,14,14,'#000000','#303030')
	gui.drawRectangle(LButtonPositionX+4,LButtonPositionY,56,8,'#000000','#303030')
	gui.drawRectangle(RButtonPositionX+4,RButtonPositionY,56,8,'#000000','#303030')

	--Drawing the D-pad background
	gui.drawRectangle(DpadPositionX-1, DpadPositionY-1, 34, 12,'#000000','#000000')
	gui.drawRectangle(DpadPositionX+10, DpadPositionY-12, 12, 34,'#000000','#000000')
	gui.drawRectangle(DpadPositionX, DpadPositionY, 32, 10,'#303030','#303030')
	gui.drawRectangle(DpadPositionX+11, DpadPositionY-11, 10, 32,'#303030','#303030')

	--Checking each button to see if it's being pressed
	if ButtonA == 'A' then
		gui.drawEllipse(AButtonPositionX,AButtonPositionY,40,40,'#006b20','#00b135')
		gui.drawText(AButtonPositionX+11,AButtonPositionY+10,ButtonA,'Black',nil,18,'Arial','bold')
	end
	if ButtonB == 'B' then
		gui.drawEllipse(BButtonPositionX,BButtonPositionY,24,24,'#640000','#cc0000')
		gui.drawText(BButtonPositionX+4,BButtonPositionY+4,ButtonB,'Black',nil,15,'Arial','bold')
	end
	if ButtonY == 'Y' then
		gui.drawEllipse(YButtonPositionX,YButtonPositionY,36,18,'#303030','#999999')
		gui.drawText(YButtonPositionX+11,YButtonPositionY+2,ButtonY,'Black',nil,14,'Arial','bold')
	end
	if ButtonX == 'X' then
		gui.drawEllipse(XButtonPositionX,XButtonPositionY,18,36,'#303030','#999999')
		gui.drawText(XButtonPositionX+3,XButtonPositionY+10,ButtonX,'Black',nil,14,'Arial','bold')
	end
	if ButtonZ == 'Z' then
		gui.drawEllipse(ZButtonPositionX,ZButtonPositionY,16,16,'#20124d','#6e45ef')		
		gui.drawText(ZButtonPositionX+3,ZButtonPositionY+1,ButtonZ,'Black',nil,12,'Arial','bold')
	end
	if ButtonDpadU == 'U' then
		gui.drawRectangle(DpadPositionX+11, DpadPositionY-11, 10, 9,'#999999','#999999')
	end
	if ButtonDpadD == 'D' then
		gui.drawRectangle(DpadPositionX+11, DpadPositionY+12, 10, 9,'#999999','#999999')
	end
	if ButtonDpadL == 'L' then
		gui.drawRectangle(DpadPositionX, DpadPositionY, 9, 10,'#999999','#999999')
	end
	if ButtonDpadR == 'R' then
		gui.drawRectangle(DpadPositionX+23, DpadPositionY, 9, 10,'#999999','#999999')
	end
	if ButtonS == 'S' then
		gui.drawEllipse(SButtonPositionX,SButtonPositionY,14,14,'#303030','#999999')
		gui.drawText(SButtonPositionX+2,SButtonPositionY+1,ButtonS,'Black',nil,10,'Arial','bold')
	end
	if ButtonL == 'L' then
		gui.drawRectangle(LButtonPositionX+4,LButtonPositionY,56,8,'#303030','#999999')
	end
	if ButtonR == 'R' then
		gui.drawRectangle(RButtonPositionX+4,RButtonPositionY,56,8,'#303030','#999999')
	end

	--Drawing the line for the left stick
	gui.drawLine(LeftStickPositionX+1,LeftStickPositionY+1,LeftStickPositionX+(LeftStickX*ControlStickScale)+1,LeftStickPositionY-(LeftStickY*ControlStickScale)+1,'black')
	gui.drawLine(LeftStickPositionX,LeftStickPositionY,LeftStickPositionX+(LeftStickX*ControlStickScale),LeftStickPositionY-(LeftStickY*ControlStickScale),'white')
	gui.drawEllipse(LeftStickPositionX+(LeftStickX*ControlStickScale)-2,LeftStickPositionY-(LeftStickY*ControlStickScale)-2,4,4,'#9a9a9a','#9a9a9a')		


	--Drawing the line for the right stick
	gui.drawLine(RightStickPositionX+1,RightStickPositionY+1,RightStickPositionX+(RightStickX*ControlStickScale)+1,RightStickPositionY-(RightStickY*ControlStickScale)+1,'black')
	gui.drawLine(RightStickPositionX,RightStickPositionY,RightStickPositionX+(RightStickX*ControlStickScale),RightStickPositionY-(RightStickY*ControlStickScale),'white')
	gui.drawEllipse(RightStickPositionX+(RightStickX*ControlStickScale)-2,RightStickPositionY-(RightStickY*ControlStickScale)-2,4,4,'#f4b800','#f4b800')		
	

	--Once the script is done running, advance to the next frame, then do it all over again. Forever.
	emu.frameadvance();
end