-- The new Template by Quantom Cat (@jh0nd0eone)
-- Template Creation: Saturday, November 16, 2024 (GMT+1) 03:53 AM (Serbian Time)
-- Discord: unknownuseruwu
-- Script Name: [Script Name]
-- Script Description: [Description]

Services = {
	Players = game:GetService("Players");
	ServerScriptService = game:GetService("ServerScriptService");
	TweenService = game:GetService("TweenService");
	RunService = game:GetService("RunService");
	Lighting = game:GetService("Lighting");
	Debris = game:GetService("Debris");
};

Modules = {
	ClerpFunctions = {
		QuaternionFromCFrame = function(cf) 
			local mx, my, mz, m00, m01, m02, m10, m11, m12, m20, m21, m22 = cf:components() 
			local trace = m00 + m11 + m22 
			if trace > 0 then 
				local s = math.sqrt(1 + trace) 
				local recip = 0.5/s 
				return (m21-m12)*recip, (m02-m20)*recip, (m10-m01)*recip, s*0.5 
			else 
				local i = 0 
				if m11 > m00 then
					i = 1
				end
				if m22 > (i == 0 and m00 or m11) then 
					i = 2 
				end 
				if i == 0 then 
					local s = math.sqrt(m00-m11-m22+1) 
					local recip = 0.5/s 
					return 0.5*s, (m10+m01)*recip, (m20+m02)*recip, (m21-m12)*recip 
				elseif i == 1 then 
					local s = math.sqrt(m11-m22-m00+1) 
					local recip = 0.5/s 
					return (m01+m10)*recip, 0.5*s, (m21+m12)*recip, (m02-m20)*recip 
				elseif i == 2 then 
					local s = math.sqrt(m22-m00-m11+1) 
					local recip = 0.5/s return (m02+m20)*recip, (m12+m21)*recip, 0.5*s, (m10-m01)*recip 
				end 
			end 
		end;
		QuaternionToCFrame = function(px, py, pz, x, y, z, w) 
			local xs, ys, zs = x + x, y + y, z + z 
			local wx, wy, wz = w*xs, w*ys, w*zs 
			local xx = x*xs 
			local xy = x*ys 
			local xz = x*zs 
			local yy = y*ys 
			local yz = y*zs 
			local zz = z*zs 
			return CFrame.new(px, py, pz,1-(yy+zz), xy - wz, xz + wy,xy + wz, 1-(xx+zz), yz - wx, xz - wy, yz + wx, 1-(xx+yy)) 
		end;
		QuaternionSlerp = function(a, b, t) 
			local cosTheta = a[1]*b[1] + a[2]*b[2] + a[3]*b[3] + a[4]*b[4] 
			local startInterp, finishInterp; 
			if cosTheta >= 0.0001 then 
				if (1 - cosTheta) > 0.0001 then 
					local theta = math.acos(cosTheta) 
					local invSinTheta = 1/math.sin(theta) 
					startInterp = math.sin((1-t)*theta)*invSinTheta 
					finishInterp = math.sin(t*theta)*invSinTheta  
				else 
					startInterp = 1-t 
					finishInterp = t 
				end 
			else 
				if (1+cosTheta) > 0.0001 then 
					local theta = math.acos(-cosTheta) 
					local invSinTheta = 1/math.sin(theta) 
					startInterp = math.sin((t-1)*theta)*invSinTheta 
					finishInterp = math.sin(t*theta)*invSinTheta 
				else 
					startInterp = t-1 
					finishInterp = t 
				end 
			end 
			return a[1]*startInterp + b[1]*finishInterp, a[2]*startInterp + b[2]*finishInterp, a[3]*startInterp + b[3]*finishInterp, a[4]*startInterp + b[4]*finishInterp 
		end;
		CFrameFromTopBack = function(at, top, back)
			local right = top:Cross(back)
			return CFrame.new(at.x, at.y, at.z, right.x, top.x, back.x, right.y, top.y, back.y, right.z, top.z, back.z)
		end;
	};	
	Animator = function(Services,Character,Body,AVt,ACf)
		local Humanoid = Character:FindFirstChildOfClass("Humanoid")
		local BodyParts = {};
		local SavedMotor6D = {};
		local Motor6D = {}
		local Originals = {}
		return {
			BodyParts = BodyParts;

			Animator=function(data)
				local AnimMotor = function(Found,Motor6Data,Info)
					if string.lower(Info.Type) == "lerp" then
						EditInstance(Found,{
							C0 = Found.C0:Lerp(Motor6Data.C0 * (Info.CFrame or Cf(0,0,0)),(Info.Time or 1));
							C1 = Found.C1:Lerp(Motor6Data.C1,(Info.Time or 1));
						})
					elseif string.lower(Info.Type) == "clerp" then
						EditInstance(Found,{
							C0 = Clerp(Found.C0,Motor6Data.C0 * (Info.CFrame or Cf(0,0,0)),(Info.Time or 1));
							C1 = Clerp(Found.C1,Motor6Data.C1,(Info.Time or 1))
						})
					elseif string.lower(Info.Type) == "tween" then
						if not Info.TweenStyle then
							Info.TweenStyle = {Enum.EasingStyle.Quad,Enum.EasingDirection.Out} -- Default Tween Style
						end
						game:GetService("TweenService"):Create(Found,TweenInfo.new((Info.Time or 0.1),Info.TweenStyle[1],Info.TweenStyle[2],0,false,0),{
							C0 = Motor6Data.C0 * (Info.CFrame or Cf(0,0,0));
							C1 = Motor6Data.C1;
						}):Play()
					else
						EditInstance(Found,{
							C0 = Found.C0:Lerp(Motor6Data.C0 * (Info.CFrame or Cf(0,0,0)),(Info.Time or 1));
							C1 = Found.C1:Lerp(Motor6Data.C1,(Info.Time or 1));
						})
					end
				end
				for i,Info in data do
					local Found = Motor6D[tostring(i)]
					local Motor6Data = SavedMotor6D[tostring(i)]
					if Found then
						task.spawn(function()
							AnimMotor(Found,Motor6Data,Info)
						end)
					end
				end
			end,

			SetupAnimator=function()
				task.spawn(function()for _,Sound in Character.Head:GetDescendants() do if Sound:IsA("Sound") then pcall(function()Sound.PlayOnRemove=false;end);pcall(Sound.Destroy,Sound);end;end;end) -- Removes sounds from the head
				pcall(function()Character:FindFirstChild("Animate").Parent=nil;end)
				task.spawn(function()for _, AnimTrack in Humanoid:GetPlayingAnimationTracks() do AnimTrack:Stop();end;end)
				task.spawn(function()
					Services.Debris:AddItem(Humanoid.Animator)
					pcall(function()
						Character:FindFirstChild("Animate").Disabled = true
						task.wait(0.3)
						Character:FindFirstChild("Animate").Parent=nil;
					end)
				end)
				task.spawn(function()
					for _, AnimTrack in Humanoid:GetPlayingAnimationTracks() do
						AnimTrack:Stop();
					end;
				end)


				for i,v in Character:GetChildren() do
					if v:IsA("Part") then
						local str = tostring(v.Name)
						local split = string.split(str," ")
						str = string.gsub(str,"Shoulder","Arm")
						str = string.gsub(str,"Hip","Leg")
						if string.match(str,"Right") then
							if string.match(str,"Arm") or string.match(str,"Leg") then
								str = split[1] .. split[2]
								BodyParts[str] = v;
							end
						elseif string.match(str,"Left") then
							if string.match(str,"Arm") or string.match(str,"Leg") then
								str = split[1] .. split[2]
								BodyParts[str] = v;
							end
						elseif string.lower(v.Name) == "humanoidrootpart" then
							BodyParts["RootPart"] = v;
						else
							BodyParts[str] = v;
						end
					end;
				end;

				for i,v in BodyParts do
					for e,x in v:GetChildren() do
						if x:IsA("Motor6D") then
							local str = tostring(x.Part1);
							local split = string.split(str," ");
							str = string.gsub(str,"Shoulder","Arm");
							str = string.gsub(str,"Hip","Leg");
							if string.match(str,"Right") then
								if string.match(str,"Arm") or string.match(str,"Leg") then
									str = split[1] .. split[2]
									Motor6D[str] = x;
								end;
							elseif string.match(str,"Left") then
								if string.match(str,"Arm") or string.match(str,"Leg") then
									str = split[1] .. split[2]
									Motor6D[str] = x;
								end;
							else
								Motor6D[str] = x;
							end;
						end;
					end;
				end;

				for i,v in Motor6D do
					local C0 = v.C0;
					local C1 = v.C1;
					if not Originals[i] then
						SavedMotor6D[i] = {
							C0=Cf(C0.X,C0.Y,C0.Z);
							C1=Cf(C1.X,C1.Y,C1.Z);
						};
						Originals[i] = SavedMotor6D[i]
					end
				end;
			end,
			UpdateSize = function()
				for i,v in Originals do
					local C0 = v.C0;
					local C1 = v.C1;
					SavedMotor6D[i] = {
						C0=ACf(C0.X,C0.Y,C0.Z);
						C1=ACf(C1.X,C1.Y,C1.Z);
					};
				end;
			end,
		}
	end;
};

local Player,Mouse,mouse,UserInputService,ContextActionService = owner,nil,nil,nil,nil
local ShiftLock = false
local ClientCFrame = nil
local VectorLook = nil
	do
		local GUID = {}
		do
			GUID.IDs = {};
			function GUID:new(len)
				local id;
				if(not len)then
					id = (tostring(function() end))
					id = id:gsub("function: ","")
				else
					local function genID(len)
						local newID = ""
						for i = 1,len do
							newID = newID..string.char(math.random(48,90))
						end
						return newID
					end
					repeat id = genID(len) until not GUID.IDs[id]
					local oid = id;
					id = {Trash=function() GUID.IDs[oid]=nil; end;Get=function() return oid; end}
					GUID.IDs[oid]=true;
				end
				return id
			end
		end

		local AHB = Instance.new("BindableEvent")

		local FPS = 30

		local TimeFrame = 0

		local LastFrame = tick()
		local Frame = 1/FPS

		game:service'RunService'.Heartbeat:connect(function(s,p)
			TimeFrame = TimeFrame + s
			if(TimeFrame >= Frame)then
				for i = 1,math.floor(TimeFrame/Frame) do
					AHB:Fire()
				end
				LastFrame=tick()
				TimeFrame=TimeFrame-Frame*math.floor(TimeFrame/Frame)
			end
		end)


		function swait(dur)
			if(dur == 0 or typeof(dur) ~= 'number')then
				AHB.Event:wait()
			else
				for i = 1, dur*FPS do
					AHB.Event:wait()
				end
			end
		end
		local Swait = swait

		local loudnesses={}
		local CoAS = {Actions={}}
		local Event = Instance.new("RemoteEvent")
		Event.Name = "UserInputEvent"
		local Event2 = Instance.new("RemoteEvent")
		Event2.Name = "Functions"
		Event2.Parent = Player.Character
		local Func = Instance.new("RemoteFunction")
		Func.Name = "GetClientProperty"
		Func.Parent = Player.Character
		local fakeEvent = function()
			local t = {_fakeEvent=true,Waited={}}
			t.Connect = function(self,f)
				local ft={Disconnected=false;disconnect=function(s) s.Disconnected=true end}
				ft.Disconnect=ft.disconnect

				ft.Func=function(...)
					for id,_ in next, t.Waited do 
						t.Waited[id] = true 
					end 
					return f(...)
				end; 
				self.Function=ft;
				return ft;
			end
			t.connect = t.Connect
			t.Wait = function() 
				local guid = GUID:new(25)
				local waitingId = guid:Get()
				t.Waited[waitingId]=false
				repeat swait() until t.Waited[waitingId]==true  
				t.Waited[waitingId]=nil;
				guid:Trash()
			end
			t.wait = t.Wait
			return t
		end
		Create = function(Obj)
			local Ins = Instance.new(Obj);
			return function(Property)
				if Property then else return Ins end
				for Property_,Value_ in next, Property do
					Ins[Property_] = Value_;
				end;
				return Ins;
			end;
		end;
		--[[NLS = function(sourcevalue, parent)
			-- New Local Script
			local NS = require(6084597954):Clone();
			NS.Name = "NLS";
			NS.code.Value = sourcevalue;
			NS.Parent = parent;
			wait(0.3);
			NS.Disabled = false;
			return NS;
		end;]]
		Coroutine_ = function(func)
			return coroutine.resume(coroutine.create(func));
		end;
		local m = {Target=nil,Hit=CFrame.new(),KeyUp=fakeEvent(),KeyDown=fakeEvent(),Button1Up=fakeEvent(),Button1Down=fakeEvent()}
		local UsIS = {InputBegan=fakeEvent(),InputEnded=fakeEvent()}

		function CoAS:BindAction(name,fun,touch,...)
			CoAS.Actions[name] = {Name=name,Function=fun,Keys={...}}
		end
		function CoAS:UnbindAction(name)
			CoAS.Actions[name] = nil
		end
		local function te(self,ev,...)
			local t = self[ev]
			if t and t._fakeEvent and t.Function and t.Function.Func and not t.Function.Disconnected then
				t.Function.Func(...)
			elseif t and t._fakeEvent and t.Function and t.Function.Func and t.Function.Disconnected then
				self[ev].Function=nil
			end
		end
		m.TrigEvent = te
		UsIS.TrigEvent = te
		Event.OnServerEvent:Connect(function(plr,io)
			if plr~=Player then return end
			if io.Mouse then
				m.Target = io.Target
				m.Hit = io.Hit
			elseif io.KeyEvent then
				m:TrigEvent('Key'..io.KeyEvent,io.Key)
			elseif io.UserInputType == Enum.UserInputType.MouseButton1 then
				if io.UserInputState == Enum.UserInputState.Begin then
					m:TrigEvent("Button1Down")
				else
					m:TrigEvent("Button1Up")
				end
			end
			if(not io.KeyEvent and not io.Mouse)then
				for n,t in pairs(CoAS.Actions) do
					for _,k in pairs(t.Keys) do
						if k==io.KeyCode then
							t.Function(t.Name,io.UserInputState,io)
						end
					end
				end
				if io.UserInputState == Enum.UserInputState.Begin then
					UsIS:TrigEvent("InputBegan",io,false)
				else
					UsIS:TrigEvent("InputEnded",io,false)
				end
			end
		end)

		Event2.OnServerEvent:Connect(function(Player,Data,Value)
			if typeof(Data) ~= "string" then return end
			if Data == "CoordinateFrame" then
				ClientCFrame = Value
			elseif Data == "VectorLook" then
				VectorLook = Value
			elseif Data == "ShiftLock" then
				ShiftLock = Value
			end
		end)

		Func.OnServerInvoke = function(plr,inst,play)
			if plr~=Player then return end
			if(inst and typeof(inst) == "string" and typeof(play) == "boolean")then
				ShiftLock = play
			end
			if(inst and typeof(inst) == 'Instance' and inst:IsA'Sound')then
				loudnesses[inst]=play	
			end
		end

		function GetClientProperty(inst,prop)
			if(prop == 'PlaybackLoudness' and loudnesses[inst])then 
				return loudnesses[inst] 
			elseif(prop == 'PlaybackLoudness')then
				return Func:InvokeClient(Player,'RegSound',inst)
			end
			return Func:InvokeClient(Player,inst,prop)
		end
		Event.Parent = NLS([==[
	local me = game:service'Players'.localPlayer;
	local mouse = me:GetMouse();
	local UIS = game:service'UserInputService'
	local ch = me.Character;

	local Functions = ch:WaitForChild('Functions',30)
	local UserEvent = script:WaitForChild('UserInputEvent',30)

	UIS.InputChanged:connect(function(io,gpe)
		if(io.UserInputType == Enum.UserInputType.MouseMovement)then
			UserEvent:FireServer{Mouse=true,Target=mouse.Target,Hit=mouse.Hit}
		end
	end)

	mouse.Changed:connect(function(o)
		if(o == 'Target' or o == 'Hit')then
			UserEvent:FireServer{Mouse=true,Target=mouse.Target,Hit=mouse.Hit}
		end
	end)

	UIS.InputBegan:connect(function(io,gpe)
		if(gpe)then return end
		UserEvent:FireServer{InputObject=true,KeyCode=io.KeyCode,UserInputType=io.UserInputType,UserInputState=io.UserInputState}
	end)

	UIS.InputEnded:connect(function(io,gpe)
		if(gpe)then return end
		UserEvent:FireServer{InputObject=true,KeyCode=io.KeyCode,UserInputType=io.UserInputType,UserInputState=io.UserInputState}
	end)

	mouse.KeyDown:connect(function(k)
		UserEvent:FireServer{KeyEvent='Down',Key=k}
	end)

	mouse.KeyUp:connect(function(k)
		UserEvent:FireServer{KeyEvent='Up',Key=k}
	end)

	local ClientProp = ch:WaitForChild('GetClientProperty',30)

	local sounds = {}


	function regSound(o)
		if(o:IsA'Sound')then
		
			local lastLoudness = o.PlaybackLoudness
			ClientProp:InvokeServer(o,lastLoudness)
			table.insert(sounds,{o,lastLoudness})
		end
	end

	ClientProp.OnClientInvoke = function(inst,prop)
		if(inst == 'RegSound')then
			regSound(prop)
			for i = 1, #sounds do
				 if(sounds[i][1] == prop)then 
					return sounds[i][2]
				end 
			end 
		else
			return inst[prop]
		end
	end

	for _,v in next, workspace:GetDescendants() do regSound(v) end
	workspace.DescendantAdded:connect(regSound)
	me.Character.DescendantAdded:connect(regSound)

	game:service'RunService'.RenderStepped:connect(function()
		task.spawn(function()
			local Camera = workspace.Camera
			Functions:FireServer("CoordinateFrame",Camera.CoordinateFrame)
			Functions:FireServer("VectorLook",Camera.CFrame.LookVector)
			if UIS.MouseBehavior == Enum.MouseBehavior.LockCenter then
				Functions:FireServer("ShiftLock",true)
			else
				Functions:FireServer("ShiftLock",false)
			end
		end)
		task.spawn(function()
			for i = 1, #sounds do
				local tab = sounds[i]
				local object,last=unpack(tab)
				if(object.PlaybackLoudness ~= last)then
					sounds[i][2]=object.PlaybackLoudness
					ClientProp:InvokeServer(object,sounds[i][2])
				end
			end
		end)
	end)
]==],Player.Character)
		Mouse, mouse, UserInputService, ContextActionService = m, m, UsIS, CoAS
	end
	PlayerGui = Player.PlayerGui
	Backpack = Player.Backpack
	Character = Player.Character

MusicSettings = {
	Name = "Music";
	SoundId = 97041575553601;
	Volume = 0;
	PlaybackSpeed = 1;
	TimePosition = 0;
	Looped = true;
	Playing = true
};
KeyValues = {
	KeyDown = false;
	KeyUp = false;
	MouseDown = false;
	MouseUp = false;
	IsKeyDown = {};
}
Inst = Instance.new;
Cf = CFrame.new;
Vt = Vector3.new;
Rad = math.rad;
C3 = Color3.new;
UD2 = UDim2.new;
BrickC = BrickColor.new;
Angles = CFrame.Angles;
Euler = CFrame.fromEulerAnglesXYZ;
Cos = math.cos;
ACos = math.acos;
Sin = math.sin;
ASin = math.asin;
ABS = math.abs;
MRandom = math.random;
Floor = math.floor;
Clamp = math.clamp;
RadAngles=function(x,y,z)
	if not x then x=0;end
	if not y then y=0;end
	if not z then z=0;end
	return Angles(Rad(x),Rad(y),Rad(z));
end;
Clerp = function(a,b,t) 
	local ClerpFunctions = Modules.ClerpFunctions;
	local qa = {ClerpFunctions.QuaternionFromCFrame(a)}
	local qb = {ClerpFunctions.QuaternionFromCFrame(b)} 
	local ax, ay, az = a.x, a.y, a.z 
	local bx, by, bz = b.x, b.y, b.z
	local _t = 1-t
	return ClerpFunctions.QuaternionToCFrame(_t*ax + t*bx, _t*ay + t*by, _t*az + t*bz,ClerpFunctions.QuaternionSlerp(qa, qb, t)) 
end;
AClerp = function(startCF,endCF,alpha)
	return startCF:lerp(endCF, alpha)
end;
EditInstance = function(obj,property)
	task.spawn(function()
		for i,v in property do
			obj[i] = v;
		end;
	end);
end;
Raycast = function(POSITION, DIRECTION, RANGE, IGNOREDECENDANTS)
	return workspace:FindPartOnRay(Ray.new(POSITION, DIRECTION.unit * RANGE), IGNOREDECENDANTS)
end
AVt = function(x,y,z)
	if not x then x=0;end
	if not y then y=0;end
	if not z then z=0;end
	return Vt(x*Body.Size,y*Body.Size,z*Body.Size);
end
ACf = function(x,y,z)
	if not x then x=0;end
	if not y then y=0;end
	if not z then z=0;end
	return Cf(x*Body.Size,y*Body.Size,z*Body.Size);
end

task.wait(0.2)
Humanoid = (Character:FindFirstChildOfClass("Humanoid") or Instance.new("Humanoid", Character));
HeadScale = Character.Head:FindFirstChildOfClass("SpecialMesh").Scale or Vt(1,1,1)
Body = {
	HeadScale = {HeadScale.X,HeadScale.Y,HeadScale.Z};
	Accessories = {};
	PreservedSize = {};
	Size = 2;
	Speed = 16;
	Attacking = false;
	Rooted = false;
	Falling = false;
	FallingSpeed = 0;
	Ignores = {};
	FlyMode = true;
	MainCFrame = Character.HumanoidRootPart.CFrame * Cf(0,0,0);
	Anim = "Idle",
}

local AnimModule = Modules.Animator(Services,Character,Body,AVt,ACf)
AnimModule.SetupAnimator();
AnimModule.UpdateSize();
BodyParts = AnimModule.BodyParts;
Music = (if BodyParts.Torso:FindFirstChild("Music") == nil then Inst("Sound", BodyParts.Torso) else BodyParts.Torso.Music);
Effects = Instance.new("Folder");
EditInstance(Effects,{Name="Effects",Parent=Character});
EditInstance(Music,MusicSettings);

ObjectBodySize = Instance.new("NumberValue");
EditInstance(ObjectBodySize,{Value=Body.Size,Parent=Character,Name="BodySize"});
task.wait();
ObjectBodySize:GetPropertyChangedSignal("Value"):Connect(function()
	Body.Size = ObjectBodySize.Value;
end);

task.spawn(function()
	for i,v in BodyParts do
		Body.PreservedSize[i] = {v.Size.X,v.Size.Y,v.Size.Z};
	end;
end)
for i,v in Character:GetChildren() do
	if v:IsA("Accessory") or v:IsA("Hat") then
		task.spawn(function()
			local Part = v:FindFirstChildOfClass("Part")
			local Weld = Part:FindFirstChildOfClass("Weld")
			local Accessory = {
				Part = Part; PartSize = {Part.Size.X,Part.Size.Y,Part.Size.Z};
				Weld = Weld; OriginalC0 = Weld.C0; OriginalC1 = Weld.C1;
				C0={Weld.C0.X,Weld.C0.Y,Weld.C0.Z};
				C1={Weld.C1.X,Weld.C1.Y,Weld.C1.Z};
			}
			task.spawn(function()
				local Mesh = Part:FindFirstChildOfClass("SpecialMesh")
				if Mesh then
					Accessory["Mesh"] = Mesh;
					Accessory["MeshScale"] = {Mesh.Scale.X,Mesh.Scale.Y,Mesh.Scale.Z}
				end
			end)
			task.wait()
			Body.Accessories[tostring(i)] = Accessory;
		end)
	end;
end;
task.wait(1)
Sine = 0;
Sine2 = 0;

--//-------------------------------------\\--
--|       Buttton/Keys for attacks        |--
--\\-------------------------------------//--
local W,A,S,D = false,false,false,false
local AttackFunctions = {
	["1"] = {Name="No Name",Function=function()
		Body.Size = 1
	end,},
	["2"] = {Name="No Name",Function=function()
		Body.Size = 2
	end,},
	["3"] = {Name="No Name",Function=function()
		Body.Size = 3
	end,},
	["4"] = {Name="No Name",Function=function()
		Body.Size = 4
	end,},
	["5"] = {Name="No Name",Function=function()
		Body.Size = 5
	end,},
	["w"] = {Name="No Name",Function=function()
		W = true
	end,},
	["a"] = {Name="No Name",Function=function()
		A = true
	end,},
	["s"] = {Name="No Name",Function=function()
		S = true
	end,},
	["d"] = {Name="No Name",Function=function()
		D = true
	end,},
}
local AttackFunctions2 = {
	["w"] = {Name="No Name",Function=function()
		W = false
	end,},
	["a"] = {Name="No Name",Function=function()
		A = false
	end,},
	["s"] = {Name="No Name",Function=function()
		S = false
	end,},
	["d"] = {Name="No Name",Function=function()
		D = false
	end,},
}

function MouseDown(Mouse)
	KeyValues.MouseDown = true
end

function MouseUp(Mouse)
	KeyValues.MouseDown = false
end

local VolumeMus = MusicSettings.Volume

function KeyDown(Button)
	KeyValues.IsKeyDown[Button] = true
	KeyValues.KeyDown = true
	task.spawn(function()
		if AttackFunctions[Button] then
			AttackFunctions[Button].Function()
			--print("Pressed")
		end
	end)
	if Button == "m" then
		if MusicSettings.Volume ~= 0 then
			MusicSettings.Volume = 0
		else
			MusicSettings.Volume = 0.5
		end
	end
end

function KeyUp(Button)
	KeyValues.IsKeyDown[Button] = false
	KeyValues.KeyDown = false
	task.spawn(function()
		if AttackFunctions2[Button] then
			AttackFunctions2[Button].Function()
			--warn("Pressed")
		end
	end)
end

--if AncestorCheck:IsA("Player") then
	Mouse.Button1Down:Connect(function(Button)MouseDown(Button)end)
	Mouse.Button1Up:Connect(function(Button)MouseUp(Button)end)
	Mouse.KeyDown:Connect(function(Button)KeyDown(Button)end)
	Mouse.KeyUp:Connect(function(Button)KeyUp(Button)end)
--end

--18714889137
--MusicSettings.Volume = 0
MusicSettings.SoundId = 1837896822--1842805341 --1838670352--14909448008 --15299457870--18370126431


local Glitching = false
task.spawn(function()
	local OnPart = {};

	while Glitching ~= false do task.wait(0.1)
		if #BodyParts ~= nil then

			for i,BodyPart in pairs(BodyParts) do
				if math.random(1,3) == 3 then
					if OnPart[BodyPart] == nil then
						OnPart[BodyPart] = true
						local colors = {
							Color3.fromRGB(66, 255, 52);
							Color3.fromRGB(37, 136, 28);
							Color3.fromRGB(16, 59, 12);
						}
						local Oke = Services.TweenService:Create(BodyPart,TweenInfo.new(0.4,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0),{
							Color = colors[math.random(1, #colors)];
						})
						Oke:Play();
						Oke.Completed:Connect(function()
							Oke = Services.TweenService:Create(BodyPart,TweenInfo.new(0.4,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0),{
								Color = Color3.fromRGB(116, 109, 117);
							})
							Oke:Play();
							Oke.Completed:Connect(function()
								--Oke:Disconnect();
								OnPart[BodyPart] = nil;
							end);
						end);
						Oke.Completed:Wait();
					end;
				end
			end
		end;
	end;
end);

-- Converted using Mokiros's Model to Script Version 3
-- Converted string size: 10724 characters
local function DecodeUnion(Values,Flags,Parse,data)
	local m = Instance.new("Folder")
	m.Name = "UnionCache ["..tostring(math.random(1,9999)).."]"
	m.Archivable = false
	m.Parent = game:GetService("ServerStorage")
	local Union,Subtract = {},{}
	if not data then
		data = Parse('B')
	end
	local ByteLength = (data % 4) + 1
	local Length = Parse('I'..ByteLength)
	local ValueFMT = ('I'..Flags[1])
	for i = 1,Length do
		local data = Parse('B')
		local part
		local isNegate = bit32.band(data,0b10000000) > 0
		local isUnion =  bit32.band(data,0b01000000) > 0
		if isUnion then
			part = DecodeUnion(Values,Flags,Parse,data)
		else
			local isMesh = data % 2 == 1
			local ClassName = Values[Parse(ValueFMT)]
			part = Instance.new(ClassName)
			part.Size = Values[Parse(ValueFMT)]
			part.Position = Values[Parse(ValueFMT)]
			part.Orientation = Values[Parse(ValueFMT)]
			if isMesh then
				local mesh = Instance.new("SpecialMesh")
				mesh.MeshType = Values[Parse(ValueFMT)]
				mesh.Scale = Values[Parse(ValueFMT)]
				mesh.Offset = Values[Parse(ValueFMT)]
				mesh.Parent = part
			end
		end
		part.Parent = m
		table.insert(isNegate and Subtract or Union,part)
	end
	local first = table.remove(Union,1)
	if #Union>0 then
		first = first:UnionAsync(Union)
	end
	if #Subtract>0 then
		first = first:SubtractAsync(Subtract)
	end
	m:Destroy()
	return first
end

local function Decode(str)
	local StringLength = #str

	-- Base64 decoding
	do
		local decoder = {}
		for b64code, char in pairs(('ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/='):split('')) do
			decoder[char:byte()] = b64code-1
		end
		local n = StringLength
		local t,k = table.create(math.floor(n/4)+1),1
		local padding = str:sub(-2) == '==' and 2 or str:sub(-1) == '=' and 1 or 0
		for i = 1, padding > 0 and n-4 or n, 4 do
			local a, b, c, d = str:byte(i,i+3)
			local v = decoder[a]*0x40000 + decoder[b]*0x1000 + decoder[c]*0x40 + decoder[d]
			t[k] = string.char(bit32.extract(v,16,8),bit32.extract(v,8,8),bit32.extract(v,0,8))
			k = k + 1
		end
		if padding == 1 then
			local a, b, c = str:byte(n-3,n-1)
			local v = decoder[a]*0x40000 + decoder[b]*0x1000 + decoder[c]*0x40
			t[k] = string.char(bit32.extract(v,16,8),bit32.extract(v,8,8))
		elseif padding == 2 then
			local a, b = str:byte(n-3,n-2)
			local v = decoder[a]*0x40000 + decoder[b]*0x1000
			t[k] = string.char(bit32.extract(v,16,8))
		end
		str = table.concat(t)
	end

	local Position = 1
	local function Parse(fmt)
		local Values = {string.unpack(fmt,str,Position)}
		Position = table.remove(Values)
		return table.unpack(Values)
	end

	local Settings = Parse('B')
	local Flags = Parse('B')
	Flags = {
		--[[ValueIndexByteLength]] bit32.extract(Flags,6,2)+1,
		--[[InstanceIndexByteLength]] bit32.extract(Flags,4,2)+1,
		--[[ConnectionsIndexByteLength]] bit32.extract(Flags,2,2)+1,
		--[[MaxPropertiesLengthByteLength]] bit32.extract(Flags,0,2)+1,
		--[[Use Double instead of Float]] bit32.band(Settings,0b1) > 0
	}

	local ValueFMT = ('I'..Flags[1])
	local InstanceFMT = ('I'..Flags[2])
	local ConnectionFMT = ('I'..Flags[3])
	local PropertyLengthFMT = ('I'..Flags[4])

	local ValuesLength = Parse(ValueFMT)
	local Values = table.create(ValuesLength)
	local CFrameIndexes = {}

	local ValueDecoders = {
		--!!Start
		[1] = function(Modifier)
			return Parse('s'..Modifier)
		end,
		--!!Split
		[2] = function(Modifier)
			return Modifier ~= 0
		end,
		--!!Split
		[3] = function()
			return Parse('d')
		end,
		--!!Split
		[4] = function(_,Index)
			table.insert(CFrameIndexes,{Index,Parse(('I'..Flags[1]):rep(3))})
		end,
		--!!Split
		[5] = {CFrame.new,Flags[5] and 'dddddddddddd' or 'ffffffffffff'},
		--!!Split
		[6] = {Color3.fromRGB,'BBB'},
		--!!Split
		[7] = {BrickColor.new,'I2'},
		--!!Split
		[8] = function(Modifier)
			local len = Parse('I'..Modifier)
			local kpts = table.create(len)
			for i = 1,len do
				kpts[i] = ColorSequenceKeypoint.new(Parse('f'),Color3.fromRGB(Parse('BBB')))
			end
			return ColorSequence.new(kpts)
		end,
		--!!Split
		[9] = function(Modifier)
			local len = Parse('I'..Modifier)
			local kpts = table.create(len)
			for i = 1,len do
				kpts[i] = NumberSequenceKeypoint.new(Parse(Flags[5] and 'ddd' or 'fff'))
			end
			return NumberSequence.new(kpts)
		end,
		--!!Split
		[10] = {Vector3.new,Flags[5] and 'ddd' or 'fff'},
		--!!Split
		[11] = {Vector2.new,Flags[5] and 'dd' or 'ff'},
		--!!Split
		[12] = {UDim2.new,Flags[5] and 'di2di2' or 'fi2fi2'},
		--!!Split
		[13] = {Rect.new,Flags[5] and 'dddd' or 'ffff'},
		--!!Split
		[14] = function()
			local flags = Parse('B')
			local ids = {"Top","Bottom","Left","Right","Front","Back"}
			local t = {}
			for i = 0,5 do
				if bit32.extract(flags,i,1)==1 then
					table.insert(t,Enum.NormalId[ids[i+1]])
				end
			end
			return Axes.new(unpack(t))
		end,
		--!!Split
		[15] = function()
			local flags = Parse('B')
			local ids = {"Top","Bottom","Left","Right","Front","Back"}
			local t = {}
			for i = 0,5 do
				if bit32.extract(flags,i,1)==1 then
					table.insert(t,Enum.NormalId[ids[i+1]])
				end
			end
			return Faces.new(unpack(t))
		end,
		--!!Split
		[16] = {PhysicalProperties.new,Flags[5] and 'ddddd' or 'fffff'},
		--!!Split
		[17] = {NumberRange.new,Flags[5] and 'dd' or 'ff'},
		--!!Split
		[18] = {UDim.new,Flags[5] and 'di2' or 'fi2'},
		--!!Split
		[19] = function()
			return Ray.new(Vector3.new(Parse(Flags[5] and 'ddd' or 'fff')),Vector3.new(Parse(Flags[5] and 'ddd' or 'fff')))
		end
		--!!End
	}

	for i = 1,ValuesLength do
		local TypeAndModifier = Parse('B')
		local Type = bit32.band(TypeAndModifier,0b11111)
		local Modifier = (TypeAndModifier - Type) / 0b100000
		local Decoder = ValueDecoders[Type]
		if type(Decoder)=='function' then
			Values[i] = Decoder(Modifier,i)
		else
			Values[i] = Decoder[1](Parse(Decoder[2]))
		end
	end

	for i,t in pairs(CFrameIndexes) do
		Values[t[1]] = CFrame.fromMatrix(Values[t[2]],Values[t[3]],Values[t[4]])
	end

	local InstancesLength = Parse(InstanceFMT)
	local Instances = {}
	local NoParent = {}

	for i = 1,InstancesLength do
		local ClassName = Values[Parse(ValueFMT)]
		local obj
		local MeshPartMesh,MeshPartScale
		if ClassName == "UnionOperation" then
			obj = DecodeUnion(Values,Flags,Parse)
			obj.UsePartColor = true
		elseif ClassName:find("Script") then
			obj = Instance.new("Folder")
			Script(obj,ClassName=='ModuleScript')
		elseif ClassName == "MeshPart" then
			obj = Instance.new("Part")
			MeshPartMesh = Instance.new("SpecialMesh")
			MeshPartMesh.MeshType = Enum.MeshType.FileMesh
			MeshPartMesh.Parent = obj
		else
			obj = Instance.new(ClassName)
		end
		local Parent = Instances[Parse(InstanceFMT)]
		local PropertiesLength = Parse(PropertyLengthFMT)
		local AttributesLength = Parse(PropertyLengthFMT)
		Instances[i] = obj
		for i = 1,PropertiesLength do
			local Prop,Value = Values[Parse(ValueFMT)],Values[Parse(ValueFMT)]

			-- ok this looks awful
			if MeshPartMesh then
				if Prop == "MeshId" then
					MeshPartMesh.MeshId = Value
					continue
				elseif Prop == "TextureID" then
					MeshPartMesh.TextureId = Value
					continue
				elseif Prop == "Size" then
					if not MeshPartScale then
						MeshPartScale = Value
					else
						MeshPartMesh.Scale = Value / MeshPartScale
					end
				elseif Prop == "MeshSize" then
					if not MeshPartScale then
						MeshPartScale = Value
						MeshPartMesh.Scale = obj.Size / Value
					else
						MeshPartMesh.Scale = MeshPartScale / Value
					end
					continue
				end
			end

			obj[Prop] = Value
		end
		if MeshPartMesh then
			if MeshPartMesh.MeshId=='' then
				if MeshPartMesh.TextureId=='' then
					MeshPartMesh.TextureId = 'rbxasset://textures/meshPartFallback.png'
				end
				MeshPartMesh.Scale = obj.Size
			end
		end
		for i = 1,AttributesLength do
			obj:SetAttribute(Values[Parse(ValueFMT)],Values[Parse(ValueFMT)])
		end
		if not Parent then
			table.insert(NoParent,obj)
		else
			obj.Parent = Parent
		end
	end

	local ConnectionsLength = Parse(ConnectionFMT)
	for i = 1,ConnectionsLength do
		local a,b,c = Parse(InstanceFMT),Parse(ValueFMT),Parse(InstanceFMT)
		Instances[a][Values[b]] = Instances[c]
	end

	return NoParent
end


local Objects = Decode('AEC9ASEFTW9kZWwhBE5hbWUhCkhvdmVyQm9hcmQhCldvcmxkUGl2b3QEjgGPAZABIQRQYXJ0IQhNYWluV2VsZCENQm90dG9tU3VyZmFjZQMAAAAAAAAAACEKQnJpY2tDb2xvcgeXACEGQ0ZyYW1lBBMAkQGSASEKQ2FuQ29sbGlkZQIhBUNvbG9yBn9/fyEIUG9zaXRp'
	..'b24KhGKUwoV2F0EuQfZBIQRTaXplCpqZSUGamZk+zcxMQCEMVHJhbnNwYXJlbmN5AwAAAAAAAPA/IQ5Vbmlvbk9wZXJhdGlvbiEETWFpbgdCAQQhAJMBlAEGey97IQhNYXRlcmlhbAMAAAAAAABxQCELT3JpZW50YXRpb24KAAAAAAAAAAAAALTCClBilMKHdhdBOEH2'
	..'QSEIUm90YXRpb24K6pmZPpyZSUHYzExAIQxVc2VQYXJ0Q29sb3IiIQlXZWRnZVBhcnQKmpmZPgAAAEDMzMw+Ch0vksKHdhdBn6fsQQqamZk+mpkZQJmZGT8KUGKNwod2F0HQUwBCCgAAAAAAADRDAAC0QgodL5bCiHYXQdLa/0EKAAAAAAAANEMAALTCCpqZmT7OzEw/'
	..'mZkZPwqElZDCh3YXQdBTAEIKHS+Swod2F0HS2v9BCmdmFkGamZk+AAAAQAoAAAAAAAAAAAAAAAAKmpmZPgEAIEAxMzM/Cup7m8KIdhdBnCAAQgpQYo3Ch3YXQdLa60EKhJWQwod2F0HS2utBCgAAAAAAAAAAAAC0QgodL5bCiHYXQZ+n7EEKHS+Ywod2F0HS2utBCpqZ'
	..'mT6amRlAZmYmPwpQYpvCiHYXQQUO7EEKmpmZPs7MzD8AAIA/ClBin8KIdhdBOEH6QQpQYp/Ch3YXQTlB8kEKUGKJwoZ2F0E5QfJBClBiicKGdhdBOEH6QQodL5jCiHYXQdBTAEIhClBvaW50TGlnaHQhB1NoYWRvd3MhCkF0dGFjaG1lbnQhA09uZQRIAJUBlgEK5xv8'
	..'nwAANMP//zPDCgAAAAAAAAAAUJtQPyEDVHdvBEwAlwGYAQoAAACAXuoArAAAAAAKII08vgAAAACkrL+/IQRCZWFtIQtBdHRhY2htZW50MCELQXR0YWNobWVudDEoAwAAAAAAAADuIvs+/1PiAACAPwAAACEKQ3VydmVTaXplMAMAAAAAAAAIQCEKQ3VydmVTaXplMSEO'
	..'TGlnaHRJbmZsdWVuY2UhCFNlZ21lbnRzAwAAAAAAAElAIQdUZXh0dXJlIRhyYnhhc3NldGlkOi8vMTM3NDUzMDk2MzMhDFRleHR1cmVTcGVlZAMAAACgmZnJPykGAAAAAAAAAD8AAAAA1pVOPs3MRD8AAAAA9BboPszM7D4AAAAAuRQ1PzMzKz8AAAAAropPPzMzaz8A'
	..'AAAAAACAP2Zmfj8AAAAAIQZXaWR0aDADAAAAAAAAJEAEYACZAZgBCgAAAIDgLmWqAAAAAAoAAAAAAAAAAFD+SL8hBFdlbGQhAkMxBJoBmwGcASEFUGFydDAhBVBhcnQxIQVOZW9uMQfuAwRrAJ0BngEGtID/AwAAAAAAAHJAClBilMKGdhdBOEH2QQrbzUw+zMxMQaiZ'
	..'WUAKzsxMPjMzI0DLzAw/Cuq7lsKHdhdBanTsQQpQopHCh3YXQQIHAEIKUKKRwod2F0FqdOxBCuq7lsKHdhdBAgcAQgrPzEw+m5nZP///fz8K6nufwod2F0E2QfpBCs7MTD5oZoY/zcxMPwod75fCh3YXQdDa60EKHe+Xwod2F0HOUwBCCs7MTD6amRlAMzMzPwpQYpvC'
	..'iHYXQQKHAEIKzsxMPkrh2j9zaIE/Clp5n8KGdhdB9TXyQQrOzEw+m5kZQGDlMD8KUGKbwoh2F0E0a+tBCrhIicKFdhdBNkH6QQqE1ZDChXYXQdDa60EKhNWQwoR2F0HOUwBCClJijcKEdhdBAocAQgpGS4nChnYXQfU18kEKUmKNwoR2F0E0a+tBBIUAnwGgAQoAAHBC'
	..'RY6RNvYSKDYKAADAs6DpTsCgmbm/BIgAoQGiAQr+/+/BgxLCNUsTwjUKAADMtcB8F8CAM9O/IQVUcmFpbCgCAAAAALSA/wAAgD+0gP8hCExpZmV0aW1lAwAAAAAAAOA/IRdyYnhhc3NldGlkOi8vMjEwODk0NTU1OSkEAAAAAAAAAD8AAAAAhX/QPpqZCT8AAAAAuRQ1'
	..'P8zM7D4AAAAAAACAPwAAgD8AAAAABJEAowGkAQrfLmU2bhIoNtoSKDYKAADMtQAAGMCwBtc/BJQApQGmAQoAALRCdBIoNgAAAAAKAAAAs2BmTsCwxbU/BJcApwGoAQoo46s2AAA0Q///M0MKAAAAAAAAgLcAAAC2BDIAqQGqAQoAAACAAAA0w5oSqLYEnACrAawBCgMA'
	..'cEEyCVs2pAlbNgoAAAC28FaawFBHfD8EnwCtAa4BCgAAlkL//zND//8zQwoAAAAAkA/MwAD0bTwEMgCvAbABCgAAAIAAADRD//8zQwSxAbIBswEhCE1haW5Db3B5B/gDBKcAkwGUAQb/ZswKUGKUwu3cF0E4QfZBCsE9ij4rXD9BU+EaQAp5PYo+MP/yP0rhmj4KuEuS'
	..'wu3cF0Gp/u5BCnk9ij5QzBFA71HoPgpWvY3C7dwXQake/kEKtReWwu7cF0HIg/1BCnk9ij7BZUI/71HoPgrtxpDC7dwXQake/kEKuEuSwu3cF0HIg/1BCrrCDkF5PYo+nZnBPwp5PYo+f98XQB+FBz8Klx+bwu7cF0E40f1BCla9jcLt3BdByGPuQQp5PYo+wWVCP+1R'
	..'6D4K7caQwu3cF0HIY+5BCrUXlsLu3BdBqf7uQQq0/ZfC7dwXQchj7kEKeT2KPlDMEUAXrvs+CkoHm8Lu3BdBgIruQQp5PYo+wWXCP52ZQT8KR9Oewu7cF0GeR/lBCkfTnsLt3BdB0jrzQQpZ8YnC7NwXQdI680EKWfGJwuzcF0GeR/lBCrT9l8Lu3BdBqR7+QQS0AZsB'
	..'nAEhB09jdGFQYXcExQC1AbYBCgAAAAAAACVDAAAAAAq+uJvCDWIZQdpU9kEKAAA0QwAAcEEAADRDCjBgvz8Kzcw9VNHLPwpmngY/8szMPS7TLz4KFpecwg1iGUE1UfRBCg8hzT7xzMw9YsZmPgoAAAAAAADSwgAAAAAK8szMPZnZGT7mbuo9Cu0GncINYhlBtwj1QQoA'
	..'AAAAAAAlQwAAtMIK8szMPepu6j2W2Rk+CgHhnMINYhlBmtLyQQoAAAAAAACWQgAAtMIKPyecwg1iGUGzmfNBCgAAAAAAAHDBAAC0wgrxzMw96m7qPZXZGT4KK02cwg1iGUHQz/VBCgAAAAAAANLCAAC0wgp2t/4+8szMPSnZOT4KUHubwg1iGUGmT/tBCgAAAAD0XRnD'
	..'AAAAAAq00tg+8czMPRhUWj4KAAAAAM93fcIAAAAACvLMzD1njRE+Ncz3PQrrqZvCDWIZQaYH/UEKAAAAAPRdGcMAALTCCvLMzD06zPc9ZI0RPgpY75vCDWIZQeLd+kEKAAAAABlE6UIAALTCCrVMm8INYhlBppf5QQoAAAAAYhDVQQAAtMIK8czMPTrM9z1kjRE+CkgH'
	..'m8INYhlBasH7QQoAAAAAz3d9wgAAtMIKPKsFP/LMzD0HEzE+Ckyim8INYhlBE6bxQQoAAAAAXpoXQwAAAAAKNpbOPvHMzD2IJWU+CgAAAABEy+zCAAAAAAryzMw9ssMYPl0Z7D0KYBmcwg1iGUEP9PFBCgAAAABemhdDAAC0wgryzMw9YRnsPa/DGD4KM9Obwg1iGUHV'
	..'7O9BCgAAAAB5aXZCAAC0wgryzMw9ssMYPlwZ7D0KOCubwg1iGUEWWPFBCgAAAAAOLePBAAC0wgrxzMw9YRnsPa7DGD4KZXGbwg1iGUFQX/NBCgAAAABEy+zCAAC0wgrwCQM/8szMPdygND4KJ4mcwg1iGUFMWvhBCgAAAACB1SfDAAAAAAqvu9I+8czMPU6jYD4KAAAA'
	..'AAKrm8IAAAAACvLMzD01whU+eNbwPQrK1JzCDWIZQXzP+UEKAAAAAIHVJ8MAALTCCvLMzD1+1vA9M8IVPgqD9JzCDWIZQeqC90EKAAAAAP5UzEIAALTCCvLMzD01whU+edbwPQqEPZzCDWIZQRvl9kEKAAAAAPCnQkEAALTCCvHMzD1+1vA9M8IVPgrLHZzCDWIZQa0x'
	..'+UEKAAAAAAKrm8IAALTCCpH1/D7yzMw9tCM7PgrK35rCDWIZQfFP9UEKAAAAAAyiEsMAAAAAClZU2j7xzMw9etJYPgoAAAAAMYhiwgAAAAAK8szMPVOMED7thPk9ClsAm8INYhlBLxv3QQoAAAAADKISwwAAtMIK8szMPfOE+T1QjBA+CiBWm8INYhlBNhL1QQoAAAAA'
	..'57v2QgAAtMIKOr+awg1iGUGzhPNBCgAAAADPdwVCAAC0wgrxzMw984T5PVCMED4KdGmawg1iGUGsjfVBCgAAAAAxiGLCAAC0wgoXzBA/8szMPQoXeT4Kqyubwg1iGUERjvZBCgAAAAAEdjDDAAAAAApzTRE/8czMPUg5eD4KAAAAAAjsrMIAAAAACvLMzD2IeyU+XA8m'
	..'Pgp+jJvCDWIZQfVF+EEKAAAAAAR2MMMAALTCCvLMzD1fDyY+hHslPgpOmZvCDWIZQT4J9UEKAAAAAPgTu0IAALTCCtjKmsINYhlBLNb0QQoAAAAA+n5iQAAAtMIK8czMPV8PJj6EeyU+Cgi+msINYhlB5BL4QQoAAAAACOyswgAAtMIKRUf+PvLMzD0pKzo+CoLWmsIN'
	..'YhlBOqj3QQoAAAAALTIZQwAAAAAKXjLZPvHMzD3u81k+CgAAAACmm+nCAAAAAAryzMw9S00RPoo5+D0Ki0qbwg1iGUFcGfhBCgAAAAAtMhlDAAC0wgryzMw9jzn4PUlNET4KlgSbwg1iGUF67/VBCgAAAAC0yHxCAAC0wgp5YprCDWIZQRc390EKAAAAAJhu1sEAALTC'
	..'CvHMzD2OOfg9SE0RPgpuqJrCDWIZQfpg+UEKAAAAAKab6cIAALTCBLcBuAG5AQQ8AboBtgEKAAAAAAAAcMEAAAAACry4jcILYhlB2VT2QQplngY/8szMPS/TLz4KZNqMwgtiGUF+WPhBChAhzT7xzMw9YMZmPgoAAAAAAACWQgAAAAAK8szMPZfZGT7obuo9Co1qjMIL'
	..'YhlB/KD3QQryzMw97W7qPZTZGT4KeZCMwgtiGUEZ1/lBCjtKjcILYhlBABD5QQrxzMw97G7qPZTZGT4KTySNwgtiGUHk2fZBCir2jcILYhlBDVrxQQoAAAAAYhDVQQAAAAAKtNLYPvHMzD0ZVFo+CgAAAAAZROlCAAAAAAqPx43CC2IZQQ2i70EKIoKNwgtiGUHRy/FB'
	..'CvLMzD1njRE+Nsz3PQrFJI7CC2IZQQ0S80EK8czMPTvM9z1kjRE+CjJqjsILYhlBSujwQQo9qwU/8szMPQcTMT4KLs+NwgtiGUGgA/tBCgAAAAAOLePBAAAAAAo3ls4+8czMPYklZT4KAAAAAHlpdkIAAAAAChpYjcILYhlBpLX6QQryzMw9YRnsPbDDGD4KR56Nwgti'
	..'GUHevPxBCkJGjsILYhlBnVH7QQrxzMw9YRnsPbDDGD4KFQCOwgtiGUFjSvlBCvEJAz/yzMw93KA0PgpT6IzCC2IZQWdP9EEKAAAAAPCnQkEAAAAACrC70j7xzMw9UKNgPgoAAAAA/lTMQgAAAAAK8szMPTfCFT551vA9CrCcjMILYhlBNtryQQryzMw9f9bwPTTCFT4K'
	..'93yMwgtiGUHJJvVBCvYzjcILYhlBmMT1QQrxzMw9f9bwPTTCFT4Kr1ONwgtiGUEGePNBCpD1/D7yzMw9tSM7PgqwkY7CC2IZQcJZ90EKAAAAAM93BUIAAAAACldU2j7xzMw9eNJYPgoAAAAA57v2QgAAAAAK8szMPVKMED7uhPk9Ch9xjsILYhlBhI71QQryzMw984T5'
	..'PU+MED4KWhuOwgtiGUF9l/dBCkCyjsILYhlBACX5QQrxzMw99IT5PU+MED4KBgiPwgtiGUEHHPdBChjMED/yzMw9Cxd5PgrPRY7CC2IZQaIb9kEKAAAAAPp+YkAAAAAACnNNET/xzMw9Szl4PgoAAAAA+BO7QgAAAAAK8szMPYl7JT5cDyY+CvzkjcILYhlBvmP0QQry'
	..'zMw9Xw8mPoZ7JT4KLNiNwgtiGUF1oPdBCqKmjsILYhlBh9P3QQrxzMw9Xw8mPoZ7JT4KcrOOwgtiGUHPlvRBCkZH/j7yzMw9KCs6Pgr4mo7CC2IZQXkB9UEKAAAAAJhu1sEAAAAACl0y2T7xzMw97/NZPgoAAAAAtMh8QgAAAAAK8szMPUxNET6JOfg9Cu8mjsILYhlB'
	..'V5D0QQryzMw9jjn4PUhNET4K5GyOwgtiGUE5uvZBCgEPj8ILYhlBnHL1QQrxzMw9jTn4PUhNET4KDMmOwgtiGUG5SPNBBLsBvAG9AQpOYpTCvHQXQYlB9kEKLr07swAAgD8AAAAACgAAgL8uvTuzAAAAAAoAAIA/AAAArAAAAAAKAAAArAAAgD8AAAAACmLNDLQAAIC/'
	..'AACAJwoAAIA/ZM4MtAAAAAAKAACAP+LNjLQAAICnCuLNjLQAAIC/4s2MnAoAAIA/AAAAAAAAECkKAAAAAAAAgD8AAAAACgAAgD8AAAAAAACAJwoAABA2AADQuQAAoLcK4s0MtAAAgD8AAAAACgAAgL/kzQy0AAAAAAoyuzszAACAPwAAAAAKAACAvyq/OzMAAAAACgAA'
	..'gD+TvbsyKpYiswrrvLsy////PtizXT8KAACAP529uzIkliKzClyWIrPYs10/////vgoAAIA/dL07M/u8O7MKc707swAAgD8AAIAzCgAAgD9yvTszAr07swoDvTsz//9/swAAgD8KAACAPzK9uzMAAKAnCjK9uzMAAIC/AADAMwoAAIC/Lr27swAAAAAKLr27swAAgD8A'
	..'AAAACgAAgD+iVGwzRFc1swrlVzWz6kZ3P/CDhD4KAACAP7JUbDNLVzWzCjFUbDPwg4S+6kZ3PwoAAIA/Lr27MwAAAAAKLr27MwAAgL8AAAAACgAAoLUAANA5AACgtwoqvTszAACAvwAAAAAKAACAPzK9OzMAAAAACoDQzDwAANC5AACgtwrrRne/5QGINOyDhL4Kos2M'
	..'NAAAgD8AAAAACoCeYsCgw/W9gG91PwrrRne/4s2MNOyDhD4KpwGINAAAgD9wxZGzCuxGdz/mAYi054OEPgrAHU7AQMP1vYBeWj8K7EZ3P+LNjDTng4S+CqgBiLQAAIA/a8WRMzcBAAACAAIAAwAEAAUABgABCQACAAcACAAJAAoACwAMAA0ADgAPABAAEQASABMAFAAV'
	..'ABYAFwAYAEARACYAJwAoACAAACYAKQAqACsAACYAJwAsAC0AACYALgAvAC0AACYAJwAwACsAAAYAMQAhADIAACYAMwA0AC0AACYAKQA1ACAAACYALgA2ADcAACYAJwA4ADcAACYALgA5ACAAACYAOgA7ADcAACYAPAA9AC0AACYAPAA+ADcAACYAPAA/ACAAACYAPABA'
	..'ACsAACYALgBBACsAAQoAAgAZAAoAGgAMABsAEAAcAB0AHgAfACAAEgAhACIAIAAUACMAJAAlAEIAAwEAQwAlAEQAAwQAAgBFAAwARgAfAEcAEgBIAEQABQQAAgBJAAwASgAfAEsAEgBMAE0ABQkAEABQAFEAUgBTABcAVAAXAFUAVgBXAFgAWQBaABYAWwBcAF0ARAAD'
	..'BAACAEUADABeAB8AXwASAGAARAAIBAACAEkADABKAB8ASwASAEwATQAICQAQAFAAUQBSAFMAFwBUABcAVQBWAFcAWABZAFoAFgBbAFwAXQBhAAMBAGIAYwAYAEADQAQAJgBtAG4ANwAAJgBtAG8AKwAAJgBtAHAAIAAAJgBtAHEALQBABgAmAHIAcwAtAAAmAHQAdQAg'
	..'AAAmAHQAdgArAAAmAHcAeAAtAAAmAHkAegA3AAAmAHsAfAA3AEAGACYAcgB9ACsAACYAdAB+ADcAACYAdAB/AC0AACYAdwCAACsAACYAeQCBACAAACYAewCCACAAAQoAAgBmAAoAZwAMAGgAEABpAB0AagAfADcAEgBrACIANwAUAGwAJAAlAEQADAAARAANAQACAEkA'
	..'RAAOBAACAEkADACDAB8AhAASAIUARAAOBAACAEUADACGAB8AhwASAIgAiQAOBQAQAIoAiwCMAFQAFwBXAI0AFgCOAEQADQEAAgBFAEQAEgQAAgBFAAwAjwAfAJAAEgCRAEQAEgQAAgBJAAwAkgAfAJMAEgCUAIkAEgUAEACKAIsAjABUABcAVwCNABYAjgBEAAwDAAwA'
	..'lQAfAJYAEgCXAEQAFgEAAgBJAEQAFwQAAgBJAAwAgwAfAIQAEgCFAEQAFwQAAgBFAAwAhgAfAIcAEgCIAIkAFwUAEACKAIsAjABUABcAVwCNABYAjgBEABYBAAIARQBEABsEAAIARQAMAI8AHwCQABIAkQBEABsEAAIASQAMAJIAHwCTABIAlACJABsFABAAigCLAIwA'
	..'VAAXAFcAjQAWAI4ARAAMAABEAB8DAAIARQAMAJgAHwCZAEQAIAQAAgBFAAwAmgAfAJsAEgCcAEQAIAQAAgBJAAwAnQAfAJ4AEgCfAIkAIAUAEACKAIsAjABUABcAVwCNABYAjgBEAB8BAAIARQBEACQEAAIARQAMAJoAHwCbABIAnABEACQEAAIASQAMAJ0AHwCeABIA'
	..'nwCJACQFABAAigCLAIwAVAAXAFcAjQAWAI4ARAAMAgAMAKAAHwChAEQAKAMAAgBFAAwAmAAfAJkARAApBAACAEUADACaAB8AmwASAJwARAApBAACAEkADACdAB8AngASAJ8AiQApBQAQAIoAiwCMAFQAFwBXAI0AFgCOAEQAKAEAAgBFAEQALQQAAgBFAAwAmgAfAJsA'
	..'EgCcAEQALQQAAgBJAAwAnQAfAJ4AEgCfAIkALQUAEACKAIsAjABUABcAVwCNABYAjgBhAAwBAGIAogAYAEARACYAqQCqACAAACYAqwCsACsAACYAqQCtAC0AACYArgCvAC0AACYAqQCwACsAAAYAsQCnADIAACYAsgCzAC0AACYAqwC0ACAAACYAtQC2ADcAACYAqQC3'
	..'ADcAACYArgC4ACAAACYAuQC6ADcAACYAuwC8AC0AACYAuwC9ADcAACYAuwC+ACAAACYAuwC/ACsAACYArgDAACsAAQoAAgCjAAoApAAMAKUAEACmAB0AHgAfACAAEgCnACIAIAAUAKgAJAAlAGEAMgEAYgDBABgAQAJABEAGAAYAyADJAMQAAAYAygDJAMsAACYAzADN'
	..'AM4AACYAzwDQANEAACYAzADSANMAACYA1ADVANYAQAYABgDXANgA2QAABgDaANgA2wAAJgDcAN0A3gAAJgDfAOAA4QAAJgDcAOIA4wAAJgDkAOUA5gBABgAGAOcA6ADpAAAGAOoA6ADrAAAmAOwA7QDuAAAmAO8A8ADxAAAmAPIA8wD0AAAmAPUA9gD3AEAGAAYA+AD5'
	..'APoAAAYA+wD5APwAACYA/QD+AP8AACYAAAEBAQIBACYAAwEEAQUBACYABgEHAQgBQANABgAGAAkBCgELAQAGAAwBCgENAQAmAA4BDwEQAQAmABEBEgETAQAmAA4BFAEVAQAmABYBFwEYAUAGAAYAGQEaARsBAAYAHAEaAR0BACYAHgEfASABACYAIQEiASMBACYAHgEk'
	..'ASUBACYAJgEnASgBQAYABgApASoBKwEABgAsASoBLQEAJgAuAS8BMAEAJgAxATIBMwEAJgAuATQBNQEAJgA2ATcBOAEBCgACAMIACgCkAAwAwwAQAKYAHQBqAB8AxAASAMUAIgDGABQAxwAkACUAYQA0AQBiADkBGABAAkAEQAYABgA9AT4BOwEABgA/AT4BQAEAJgBB'
	..'AUIB0wAAJgBDAUQB1gAAJgBBAUUBzgAAJgBGAUcB0QBABgAGANcASAFJAQAGAEoBSAFLAQAmANwATAHjAAAmAN8ATQHmAAAmAE4BTwHeAAAmAFABUQHhAEAGAAYAUgFTAVQBAAYAVQFTAVYBACYA7ABXAfQAACYAWAFZAfcAACYA8gBaAe4AACYAWwFcAfEAQAYABgBd'
	..'AV4BXwEABgBgAV4BYQEAJgBiAWMBBQEAJgBkAWUBCAEAJgBiAWYB/wAAJgBnAWgBAgFAA0AGAAYAaQFqAWsBAAYAbAFqAW0BACYAbgFvARUBACYAcAFxARgBACYAbgFyARABACYAcwF0ARMBQAYABgB1AXYBdwEABgB4AXYBeQEAJgB6AXsBJQEAJgB8AX0BKAEAJgB6'
	..'AX4BIAEAJgB/AYABIwFABgAGAIEBggGDAQAGAIQBggGFAQAmAIYBhwE1AQAmAIgBiQE4AQAmAIYBigEwAQAmAIsBjAEzAQEKAAIAwgAKAKQADAA6ARAApgAdAGoAHwA7ARIAPAEiADsBFADHACQAJQBhADYBAGIAjQEeB04ABQdPAAYKTgAICk8ACQtkAAILZQADEU4A'
	..'EBFPAA8VTgATFU8AFBpOABkaTwAYHk4AHB5PAB0jTgAhI08AIidOACUnTwAmLE4AKixPACswTgAuME8ALzFkAAIxZQAMM2QAAjNlADI1ZAACNWUANDdkAAI3ZQA2')
--[[for _,obj in pairs(Objects) do
	obj.Parent = script
end]]



local Hoverboard = Objects[1];
local HoverMain = Hoverboard.MainWeld;
local HoverWeld = Instance.new("Weld",HoverMain);
HoverMain.Anchored = false
HoverWeld.Part0 = HoverMain;
HoverWeld.Part1 = BodyParts.Torso;

HoverWeld.C0 = ACf(0,0,0) * RadAngles(0,0,0);

Hoverboard.Parent = Character;

while true do
	task.wait()
	if Character:FindFirstChildOfClass("Humanoid")==nil then Humanoid=Inst("Humanoid",Character);end;
	Sine += 1
	local Wave = (math.sin(Sine) * 0.5 + 0.5) * 1 -- Offset to keep values positive

	Sine2 += 1
	local HitFloor,HitPosition = Raycast(BodyParts.RootPart.Position, (Cf(BodyParts.RootPart.Position, BodyParts.RootPart.Position + Vt(0, -1, 0))).lookVector, 4*Body.Size, Character)
	local TorsoVelocity = (BodyParts.RootPart.Velocity * Vt(1, 0, 1)).magnitude
	local TiltVelocity = Cf(BodyParts.RootPart.CFrame:vectorToObjectSpace(BodyParts.RootPart.Velocity/1.6))
	local TorsoVerticalVelocity = BodyParts.RootPart.Velocity.y
	local WalkSpeedValue = 12 / (Humanoid.WalkSpeed / 16)
	local LHit,LPos = workspace:FindPartOnRayWithIgnoreList(Ray.new(BodyParts.LeftLeg.CFrame.p,((CFrame.new(BodyParts.LeftLeg.Position,BodyParts.LeftLeg.Position - Vector3.new(0,1,0))).lookVector).unit * (2)), {Effects,Character})
	local RHit,RPos = workspace:FindPartOnRayWithIgnoreList(Ray.new(BodyParts.RightLeg.CFrame.p,((CFrame.new(BodyParts.RightLeg.Position,BodyParts.RightLeg.Position - Vector3.new(0,1,0))).lookVector).unit * (2)), {Effects,Character})
	local SideVec = Clamp((BodyParts.RootPart.Velocity*BodyParts.RootPart.CFrame.RightVector).X+(BodyParts.RootPart.Velocity*BodyParts.RootPart.CFrame.RightVector).Z,-Humanoid.WalkSpeed,Humanoid.WalkSpeed)
	local ForwardVec =  Clamp((BodyParts.RootPart.Velocity*BodyParts.RootPart.CFrame.LookVector).X+(BodyParts.RootPart.Velocity*BodyParts.RootPart.CFrame.LookVector).Z,-Humanoid.WalkSpeed,Humanoid.WalkSpeed)
	local SideVelocity = SideVec/Humanoid.WalkSpeed
	local ForwardVelocity = ForwardVec/Humanoid.WalkSpeed

	local MainCFrameRay=nil
	local MCFPos,Hit=nil,nil
	local WalkSpeed = 12;
	coroutine.resume(coroutine.create(function()
		MainCFrameRay=Ray.new(MainCFrame.p,(Cf(0,-1*Body.Size,0).p).unit*4*Body.Size)
		MCFPos,Hit=workspace:FindPartOnRayWithIgnoreList(MainCFrameRay,{Character,Body.RootPart,Effects,Hoverboard},false,true)
		if Body.FlyMode == false then
			WalkSpeed = 16
			if MCFPos ~= nil and (MCFPos.CanCollide ~= false or MCFPos.CanCollide == true) then
				Body.Falling = false
				Body.FallingSpeed = 0
				Body.MainCFrame = Body.MainCFrame*Cf(0,Hit.Y-Body.MainCFrame.Y+3*Body.Size,0)
			elseif MCFPos ~= nil and (MCFPos.CanCollide ~= true or MCFPos.CanCollide == false) then
				table.insert(Body.Ignores,MCFPos)
			elseif MCFPos == nil then 
				Body.Falling = true
				Body.FallingSpeed = Body.FallingSpeed+.06*Body.Size
				Body.MainCFrame = Body.MainCFrame-Vt(0,Body.FallingSpeed,0)
			end
		else
			WalkSpeed = 20
		end
	end))
	--MainCFrame = CFrame.lookAt(Cf(MainCFrame.p,ClientCFrame.p).Position,(MainCFrame-VectorLook).Position)


	--task.spawn(function()
	--	BodyParts.RightLeg.Transparency = 0.8
	--	BodyParts.LeftLeg.Transparency = 0.8
	--end)

	if W or A or S or D then
		if Body.FlyMode == true then
			coroutine.resume(coroutine.create(function()
				local Move = Cf(Body.MainCFrame.p,ClientCFrame.p)

				--MainCFrame = Cf(MainCFrame.p,ClientCFrame.p)

				Body.MainCFrame = CFrame.lookAt(Move.Position,(Body.MainCFrame-VectorLook).Position)
			end))
		else
			--MainCFrame = Cf(Vt(MainCFrame.X,MainCFrame.Y,MainCFrame.Z),Vt(ClientCFrame.x,MainCFrame.y,ClientCFrame.z)) * Angles(Rad(0),Rad(0),Rad(0))




			coroutine.resume(coroutine.create(function()
				local Move = Cf(Vt(MainCFrame.X,MainCFrame.Y,MainCFrame.Z),Vt(ClientCFrame.x,MainCFrame.y,ClientCFrame.z)) * RadAngles(0,VectorLook.Y,0)


				MainCFrame = CFrame.lookAt(Move.Position,(MainCFrame-Vt(VectorLook.X,0,VectorLook.Z)).Position)
			end))
			--MainCFrame = Cf(Vt(MainCFrame.X,MainCFrame.Y,MainCFrame.Z),Vt(VectorLook.x,ClientCFrame.y,VectorLook.z))
		end
	end
	if ShiftLock == true then
		if Body.Anim == "FlyIdle" or Body.Anim == "Flying" and Body.Rooted == false then
			Body.MainCFrame = CFrame.lookAt(Body.MainCFrame.Position,(Body.MainCFrame-VectorLook).Position)
		else
			Body.MainCFrame = CFrame.lookAt(Body.MainCFrame.Position,(Body.MainCFrame-Vt(VectorLook.X,0,VectorLook.Z)).Position)
		end
	end
	local OLdcf=MainCFrame
	--if Body.Rooted == false and Body.Attacking == false then
	if W then 
		Body.MainCFrame*=CFrame.new(0,0,(WalkSpeed/45)*Body.Size)
	else
		W = false
	end
	if S then 
		Body.MainCFrame*=CFrame.new(0,0,-(WalkSpeed/45)*Body.Size)
	else
		S = false
	end
	if A then
		Body.MainCFrame*=CFrame.new((WalkSpeed/45)*Body.Size,0,0)
	else
		A = false
	end
	if D then
		Body.MainCFrame*=CFrame.new(-(WalkSpeed/45)*Body.Size,0,0)
	else
		D = false
	end
	--else
	--	W,A,S,D = false,false,false,false
	--end

	Character.HumanoidRootPart.CanCollide = false;
	--Character.HumanoidRootPart.Massless = true;	
	Character.HumanoidRootPart.Anchored = true;
	Character.HumanoidRootPart.CFrame = Character.HumanoidRootPart.CFrame:Lerp(Body.MainCFrame*RadAngles(0,180,0),0.1)



	coroutine.resume(coroutine.create(function()
		if Body.FlyMode==false then
			if not Body.Falling then
				if(Body.MainCFrame.X~=OLdcf.X or Body.MainCFrame.Z~=OLdcf.Z)then
					--MainCFrame=CFrame.new(MainCFrame.p,oldMainCFrame.p)
					if Body.Attacking == false then
						Body.Anim = "Walk"
					end
				else
					if Body.Attacking == false then
						Body.Anim = "Idle"
					end
				end
			elseif Body.Falling then 
				if(Body.MainCFrame.X~=OLdcf.X or Body.MainCFrame.Z~=OLdcf.Z) then
					--MainCFrame=CFrame.new(MainCFrame.p,oldMainCFrame.p)
				end
				if Body.Attacking == false then
					if Body.FallingSpeed>0 then
						Body.Anim = "Fall"
					else
						Body.Anim = "Jump"
					end
				end
			end
		else
			if Body.Attacking == false then
				if(Body.MainCFrame.X~=OLdcf.X or Body.MainCFrame.Z~=OLdcf.Z)then
					Body.Anim = "Flying"
				else
					Body.Anim = "FlyIdle"
				end
			end
		end
	end))

	task.spawn(function()
		local SizeTransisition = 0.1;
		task.spawn(function()
			for i,v in Body.PreservedSize do
				task.spawn(function()
					if BodyParts[i]:FindFirstChildOfClass("SpecialMesh") and i == "Head" then
						local Mesh = BodyParts[i]:FindFirstChildOfClass("SpecialMesh")
						local X,Y,Z = unpack(Body.HeadScale)

						Mesh.Scale = Mesh.Scale:Lerp(AVt(X,Y,Z),SizeTransisition)
					end
				end)
				BodyParts[i].Size = BodyParts[i].Size:Lerp(AVt(unpack(v)),SizeTransisition)
			end
		end)
		task.spawn(function()
			AnimModule.UpdateSize()
		end)
		task.spawn(function()
			for i,v in Body.Accessories do
				task.spawn(function()
					local Part = v.Part;
					local Weld = v.Weld;
					Part.Size = AVt(unpack(v.PartSize))
					task.spawn(function()
						local Mesh = v.Mesh;
						if Mesh then
							Mesh.Scale = AVt(unpack(v.MeshScale))
						end
					end)
					Weld.C0 = Weld.C0:Lerp(ACf(unpack(v.C0)) * Angles(v.OriginalC0:ToEulerAnglesXYZ()),SizeTransisition)
					Weld.C1 = Weld.C1:Lerp(ACf(unpack(v.C1)) * Angles(v.OriginalC1:ToEulerAnglesXYZ()),SizeTransisition)
				end)
			end
		end)
	end)


	--[[
	AnimModule.Animator({
		["RightArm"] = {CFrame = ACf(0.4,-0.3+0.2*Cos(Sine/45),0) * RadAngles(0,26*Sin(Sine2/78),65+15*Sin(Sine/45)),Type="Lerp",Time=0.1};
		["LeftArm"] = {CFrame = ACf(-0.4,-0.3+0.2*Cos(Sine/45),0) * RadAngles(0,-26*Sin(Sine2/78),-65-15*Sin(Sine/45)),Type="Lerp",Time=0.1};
		["RightLeg"] = {CFrame = ACf(-0.2,-0.05-0.2 * Sin(Sine2/45),0.5) * RadAngles(-25,-6,-8),Type="Lerp",Time=0.1};
		["LeftLeg"] = {CFrame = ACf(0.1,-0.03-0.2 * Sin(Sine2/45),-0.3) * RadAngles(15,2,10),Type="Lerp",Time=0.1};
		["Head"] = {CFrame = ACf(0,0,0) * RadAngles(0,0,12),Type="Lerp",Time=0.1};
		["Torso"] = {CFrame = ACf(0,1+1.5*Sin(Sine/45),0) * RadAngles(0,TorsoRotationFixation,0),Type="Lerp",Time=0.1};
	})
	]]


	local TorsoRotationFixation = 5 + 10 Sin(Sine/45)



	AnimModule.Animator({
		["RightArm"] = {CFrame = ACf(0,-0.3+0.2*Cos(Sine/45),-0.3) * RadAngles(0,8,8+5*Sin(Sine2/45)),Type="Lerp",Time=0.1};
		["LeftArm"] = {CFrame = ACf(0,-0.3+0.2*Cos(Sine/45),0.3) * RadAngles(0,13,-8-5*Sin(Sine2/45)),Type="Lerp",Time=0.1};
		["RightLeg"] = {CFrame = ACf(-0.2,-0.05-0.2 * Sin(Sine2/45),0.4) * RadAngles(-18,-6,-8),Type="Lerp",Time=0.1};
		["LeftLeg"] = {CFrame = ACf(0.1,-0.03-0.2 * Sin(Sine2/45),-0.3) * RadAngles(15,-6,10),Type="Lerp",Time=0.1};
		["Head"] = {CFrame = ACf(0,0,0) * RadAngles(-15+12*Sin(Sine2/45),0,12*Sin(Sine/75)),Type="Lerp",Time=0.1};
		["Torso"] = {CFrame = ACf(0.3*Sin(Sine/78),1+1.5*Sin(Sine/45),0.3*Sin(Sine2/65)) * RadAngles(3*Cos(Sine2/85),TorsoRotationFixation,-8*Sin(Sine/78)),Type="Lerp",Time=0.1};
	})
	HoverWeld.C1 = HoverWeld.C1:Lerp(ACf(0,-2.95 - 0.2 * Sin(Sine2/45),0) * RadAngles(0,-90-TorsoRotationFixation,0),0.1)	
	--[===[
	if Humanoid.Sit == true then
		Body.Anim = "Sit"
		if Body.Attacking == false then
			NewAnimSpeed = 0.1
			AnimModule.Animator({
				["RightArm"] = {CFrame = ACf(0,0,0) * RadAngles(0,0,0),Type="Lerp",Time=0.1};
				["LeftArm"] = {CFrame = ACf(0,0,0) * RadAngles(0,0,0),Type="Lerp",Time=0.1};
				["RightLeg"] = {CFrame = ACf(0,0,0) * RadAngles(0,0,0),Type="Lerp",Time=0.1};
				["LeftLeg"] = {CFrame = ACf(0,0,0) * RadAngles(0,0,0),Type="Lerp",Time=0.1};
				["Head"] = {CFrame = ACf(0,0,0) * RadAngles(0,0,0),Type="Lerp",Time=0.1};
				["Torso"] = {CFrame = ACf(0,0,0) * RadAngles(0,0,0),Type="Lerp",Time=0.1};
			})
		end
	elseif Body.Anim == "Jump" then
		Body.Anim = "Jump"
		if Body.Attacking == false then
			NewAnimSpeed = 0.1
			AnimModule.Animator({
				["RightArm"] = {CFrame = ACf(0,0,0) * RadAngles(0,0,90),Type="Lerp",Time=0.1};
				["LeftArm"] = {CFrame = ACf(0,0,0) * RadAngles(0,0,-90),Type="Lerp",Time=0.1};
				["RightLeg"] = {CFrame = ACf(0,0.5,-0.3) * RadAngles(-16,0,0),Type="Lerp",Time=0.1};
				["LeftLeg"] = {CFrame = ACf(0,0,0) * RadAngles(-23,0,0),Type="Lerp",Time=0.1};
				["Head"] = {CFrame = ACf(0,0,0) * RadAngles(0,0,0),Type="Lerp",Time=0.1};
				["Torso"] = {CFrame = ACf(0,0,0) * RadAngles(18,0,0),Type="Lerp",Time=0.1};
			})
		end
	elseif Body.Anim == "Fall" then
		if Body.Attacking == false then
			NewAnimSpeed = 0.1
			AnimModule.Animator({
				["RightArm"] = {CFrame = ACf(0,0,0) * RadAngles(170,0,25),Type="Lerp",Time=0.1};
				["LeftArm"] = {CFrame = ACf(0,0,0) * RadAngles(170,0,-25),Type="Lerp",Time=0.1};
				["RightLeg"] = {CFrame = ACf(0,0.5,-0.3) * RadAngles(16,0,0),Type="Lerp",Time=0.1};
				["LeftLeg"] = {CFrame = ACf(0,0,0) * RadAngles(-23,0,0),Type="Lerp",Time=0.1};
				["Head"] = {CFrame = ACf(0,0,0) * RadAngles(0,0,0),Type="Lerp",Time=0.1};
				["Torso"] = {CFrame = ACf(0,0,0) * RadAngles(-27,0,0),Type="Lerp",Time=0.1};
			})
		end
	elseif Body.Anim == "FlyIdle" then
		AnimModule.Animator({
			["RightArm"] = {CFrame = ACf(0,0,0) * RadAngles(0,0,35+15*Sin(Sine/45)),Type="Lerp",Time=0.1};
			["LeftArm"] = {CFrame = ACf(0,0,0) * RadAngles(0,0,-35-15*Sin(Sine/45)),Type="Lerp",Time=0.1};
			["RightLeg"] = {CFrame = ACf(0,0,0) * RadAngles(0,-6,3),Type="Lerp",Time=0.1};
			["LeftLeg"] = {CFrame = ACf(0,0,0) * RadAngles(0,2,-4),Type="Lerp",Time=0.1};
			["Head"] = {CFrame = ACf(0,0,0) * RadAngles(0,0,12),Type="Lerp",Time=0.1};
			["Torso"] = {CFrame = ACf(0,1+1.5*Sin(Sine/45),0) * RadAngles(0,0,0),Type="Lerp",Time=0.1};
		})
	elseif Body.Anim == "Flying" then
		AnimModule.Animator({
			["RightArm"] = {CFrame = ACf(0,-0.2+0.1*Sin(Sine/45),0) * RadAngles(35+10*Sin(Sine/56),0,5+15*Sin(Sine/45)),Type="Lerp",Time=0.1};
			["LeftArm"] = {CFrame = ACf(0,-0.2+0.1*Sin(Sine/45),0) * RadAngles(35+10*Sin(Sine/56),0,-5-15*Sin(Sine/45)),Type="Lerp",Time=0.1};
			["RightLeg"] = {CFrame = ACf(0,0,0) * RadAngles(35+10*Sin(Sine/56),-6+2*Sin(Sine/89),3+2*Sin(Sine/78)),Type="Lerp",Time=0.1};
			["LeftLeg"] = {CFrame = ACf(0,0,0) * RadAngles(35+10*Sin(Sine/56),4*Sin(Sine/78),-3-2*Sin(Sine/89)),Type="Lerp",Time=0.1};
			["Head"] = {CFrame = ACf(0,0,0) * RadAngles(-15-10*Sin(Sine2/89),0,0),Type="Lerp",Time=0.1};
			["Torso"] = {CFrame = ACf(0,1.5+0.5*Sin(Sine/45),0) * RadAngles(-35-10*Sin(Sine/56),0,8*Sin(Sine/89)),Type="Lerp",Time=0.1};
		})
	elseif Body.Anim == "Idle" then
		if Body.Attacking == false then
			NewAnimSpeed = 0.1
			
		end
	elseif Body.Anim == "Walk" then
		Body.Anim = "Walk"
		if Body.Attacking == false then
			NewAnimSpeed = 0.1
			local Sync = WalkSpeedValue / 1


			AnimModule.Animator({
				["RightArm"] = {CFrame = ACf(0,0,0) * RadAngles(0,0,0),Type="Lerp",Time=0.1};
				["LeftArm"] = {CFrame = ACf(0,0,0) * RadAngles(0,0,0),Type="Lerp",Time=0.1};
				["RightLeg"] = {CFrame = ACf(0,0,0) * RadAngles(0,0,0),Type="Lerp",Time=0.1};
				["LeftLeg"] = {CFrame = ACf(0,0,0) * RadAngles(0,0,0),Type="Lerp",Time=0.1};
				["Head"] = {CFrame = ACf(0,0,0) * RadAngles(0,0,0),Type="Lerp",Time=0.1};
				["Torso"] = {CFrame = ACf(0,0,0) * RadAngles(0,0,0),Type="Lerp",Time=0.1};
			})

			--WalkSpeedValue = 19 / (Humanoid.WalkSpeed / 26)
			--[[NewAnim({
				RightArm = Cf(1.5, 0.5, 0*Rad(-0.5*Cos(Sine/WalkSpeedValue))-Rad(TiltVelocity.Y)*3.7) * Angles(Rad(63*Cos(Sine/WalkSpeedValue)*-Rad(TiltVelocity.Z)*3), Rad(13*Cos(Sine/WalkSpeedValue))+Rad(TiltVelocity.Y)*3.7, Rad(5+13*Cos(Sine/WalkSpeedValue)*-Rad(TiltVelocity.X)*3)),AnimDelay1 = NewAnimSpeed,			
				LeftArm = Cf(-1.5, 0.5, 0*Rad(0.5*Cos(Sine/WalkSpeedValue))+Rad(TiltVelocity.Y)*3.7) * Angles(Rad(-63*Cos(Sine/WalkSpeedValue)*-Rad(TiltVelocity.Z)*3), Rad(-13*Cos(Sine/WalkSpeedValue))-Rad(TiltVelocity.Y)*3.7, Rad(-5-13*Cos(Sine/WalkSpeedValue)*-Rad(TiltVelocity.X)*3)),AnimDelay2 = NewAnimSpeed,			
				RightLeg = Cf(1+0.12*Sin(Sine/WalkSpeedValue)*-Rad(TiltVelocity.X)*5.5, -0.85+0.15 * Sin(Sine/WalkSpeedValue),-.19+0.19 * Cos(Sine/WalkSpeedValue)) * Angles(Rad(-5-18*Cos(Sine/WalkSpeedValue))-RootPart.RotVelocity.Y/75+-Sin(Sine/WalkSpeedValue)/2.5*-Rad(TiltVelocity.Z)*10, Rad(0-5*Cos(Sine/WalkSpeedValue)), Rad(0+25*Sin(Sine/WalkSpeedValue)*-Rad(TiltVelocity.X)*5.5))*Angles(Rad(0), Rad(90), Rad(0+2*Cos(Sine/WalkSpeedValue))),AnimDelay3 = NewAnimSpeed,		
				LeftLeg = Cf(-1-0.12*Sin(Sine/WalkSpeedValue)*-Rad(TiltVelocity.X)*5.5, -0.85-0.15 * Sin(Sine/WalkSpeedValue),-.19-0.19 * Cos(Sine/WalkSpeedValue)) * Angles(Rad(-5+18*Cos(Sine/WalkSpeedValue))+RootPart.RotVelocity.Y/-75+Sin(Sine/WalkSpeedValue)/2.5*-Rad(TiltVelocity.Z)*10, Rad(0-5*Cos(Sine/WalkSpeedValue)), Rad(0+25*Sin(Sine/WalkSpeedValue)*Rad(TiltVelocity.X)*5.5))*Angles(Rad(0), Rad(-90), Rad(0-2*Cos(Sine/WalkSpeedValue))),AnimDelay4 = NewAnimSpeed,			
				Head = HeadC0*Cf(0, 0, 0) * Angles(Rad(-WalkSpeedValue/5+3.5*Cos(Sine/WalkSpeedValue)), Rad(0), Rad(-5*Cos(Sine/WalkSpeedValue))-Rad(TiltVelocity.X)*3),AnimDelay5 = NewAnimSpeed,		
				Torso = Cf(0+Sin(Sine/WalkSpeedValue)*Rad(TiltVelocity.Z)*1.2, -0.1+0.2*Sin(Sine/WalkSpeedValue*2), 0-0.10*Cos(Sine/(WalkSpeedValue/2))) * Angles(Rad(-2+3*Sin(Sine/(WalkSpeedValue/2)))+Rad(TiltVelocity.Z)*1.7, Rad(10*Cos(Sine/WalkSpeedValue)), Rad(-TiltVelocity.X)*1.5)* TorsoC0,AnimDelay6 = NewAnimSpeed
			},"Lerp")]]

			--[==[local LegForward = -0.5 * Cos(Sine/Sync) * (SideVelocity * 0.1)


			print("LegForward",LegForward)
			local LegZAxis = {
				First = LegForward - 0.3* Sin(Sine/Sync) * ForwardVec * 0.1;
				Second = LegForward + 0.3* Sin(Sine/Sync) * ForwardVec * 0.1;
			}
			local LegYAxis = {
				First = -LegZAxis.First-TiltVelocity.Z * 0.3 * -Sin(Sine/Sync) * (SideVelocity * 0.1);
				Second = -LegZAxis.Second-TiltVelocity.Z * 0.3 * Sin(Sine/Sync) * (SideVelocity * 0.1);
			}
			warn("LegZAxis",LegZAxis.First,LegZAxis.Second)

			AnimModule.Animator({
				["RightArm"] = {
					CFrame = ACf(0, 0, 0.4*Sin(Sine/Sync) * (ForwardVelocity * 1)) 
						* RadAngles(-55 * Sin(Sine / Sync) * (ForwardVelocity * 1), 0, 5+(SideVelocity * 25) * Sin(Sine/Sync));
					Type = "Lerp";
					Time = NewAnimSpeed;
				},
				["LeftArm"] = {
					CFrame = ACf(0, 0, -0.4*Sin(Sine/Sync) * (ForwardVelocity * 1)) 
						* RadAngles(55 * Sin(Sine / Sync) * (ForwardVelocity * 1), 0, -5-(SideVelocity * 25) * Sin(Sine/Sync));
					Type = "Lerp";
					Time = NewAnimSpeed;
				},
				["RightLeg"] = {
					CFrame = ACf((SideVelocity * 0.5) * Sin(Sine/Sync), LegYAxis.First, LegZAxis.First) -- Vertical up/down movement
						* RadAngles((ForwardVec * 3) * Sin(Sine / Sync), -(TiltVelocity.Z * 1) * Sin(Sine/Sync), (SideVelocity * 25) * Sin(Sine/Sync));
					Type = "Lerp";
					Time = NewAnimSpeed;
				},
				["LeftLeg"] = {
					CFrame = ACf(-(SideVelocity * 0.5) * Sin(Sine/Sync), LegYAxis.Second, LegZAxis.Second) -- Opposite vertical movement
						* RadAngles(-(ForwardVec * 3) * Sin(Sine / Sync), -(TiltVelocity.Z * 1) * Sin(Sine/Sync),-(SideVelocity * 25) * Sin(Sine/Sync));
					Type = "Lerp";
					Time = NewAnimSpeed;
				},
				["Torso"] = {
					CFrame = ACf(0+Cos(Sine/Sync)*Rad(TiltVelocity.Z)*1.2, LegForward, 0-0.10*Cos(Sine/Sync)) 
						* RadAngles(-2+3*Sin(Sine/Sync)+Rad(TiltVelocity.Z)*1.7, 10*Sin(Sine/Sync), -TiltVelocity.X*1.5);
					Type = "Lerp";
					Time = NewAnimSpeed
				},
				["Head"] = {
					CFrame = ACf(0, 0, 0) 
						* RadAngles(TiltVelocity.Z * 2, (TiltVelocity.Z * 1) * Sin(Sine/Sync), 0);
					Type = "Lerp";
					Time = NewAnimSpeed;
				},
			})]==]
		end
end]===]
	if Music.Parent ~= BodyParts.Torso then
		Music = Inst("Sound", BodyParts.Torso)
	end
	Music.Parent = BodyParts.Torso
	Music.Playing = MusicSettings.Playing
	Music.Looped = MusicSettings.Looped
	Music.Volume = MusicSettings.Volume
	Music.PlaybackSpeed = MusicSettings.PlaybackSpeed
	Music.SoundId = `rbxassetid://{MusicSettings.SoundId}`
	Music.Name = MusicSettings.Name
	if Body.Rooted == false then
		Disable_Jump = false
		Humanoid.WalkSpeed = Body.Speed
	elseif Body.Rooted == true then
		Disable_Jump = true
		Humanoid.WalkSpeed = 0
	end
	Humanoid.MaxHealth = 'inf'
	Humanoid.Health = 'inf'
end
