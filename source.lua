getgenv().GG = {
    Language = {
        CheckboxEnabled  = "Enabled",
        CheckboxDisabled = "Disabled",
        SliderValue      = "Value",
        DropdownSelect   = "Select",
        DropdownNone     = "None",
        DropdownSelected = "Selected",
        ButtonClick      = "Click",
        TextboxEnter     = "Enter",
        ModuleEnabled    = "Enabled",
        ModuleDisabled   = "Disabled",
        TabGeneral       = "General",
        Loading          = "Loading...",
        Error            = "Error",
        Success          = "Success"
    }
}

local SelectedLanguage = GG.Language

function convertStringToTable(inputString)
    local result = {}
    for value in string.gmatch(inputString, "([^,]+)") do
        table.insert(result, value:match("^%s*(.-)%s*$"))
    end
    return result
end

function convertTableToString(inputTable)
    return table.concat(inputTable, ", ")
end

local UserInputService = cloneref(game:GetService("UserInputService"))
local ContentProvider  = cloneref(game:GetService("ContentProvider"))
local TweenService     = cloneref(game:GetService("TweenService"))
local HttpService      = cloneref(game:GetService("HttpService"))
local TextService      = cloneref(game:GetService("TextService"))
local RunService       = cloneref(game:GetService("RunService"))
local Lighting         = cloneref(game:GetService("Lighting"))
local Players          = cloneref(game:GetService("Players"))
local CoreGui          = cloneref(game:GetService("CoreGui"))
local Debris           = cloneref(game:GetService("Debris"))

local C = {
    BG          = Color3.fromRGB(12,  12,  12),
    BG2         = Color3.fromRGB(18,  18,  18),
    Panel       = Color3.fromRGB(22,  22,  22),
    PanelLight  = Color3.fromRGB(30,  30,  30),
    Border      = Color3.fromRGB(48,  48,  48),
    Accent      = Color3.fromRGB(210, 210, 210),
    AccentDim   = Color3.fromRGB(105, 105, 105),
    TextPrimary = Color3.fromRGB(228, 228, 228),
    TextDim     = Color3.fromRGB(110, 110, 110),
    White       = Color3.fromRGB(255, 255, 255),
    Black       = Color3.fromRGB(0,   0,   0),
    Toggle      = Color3.fromRGB(65,  65,  65),
    ToggleOn    = Color3.fromRGB(218, 218, 218),
    TabActive   = Color3.fromRGB(32,  32,  32),
}

local W     = 698
local H     = 479
local SW    = 129
local SEC_W = 243
local MOD_W = 241
local EL_W  = 207

local mouse  = Players.LocalPlayer:GetMouse()
local oldGui = CoreGui:FindFirstChild("click")
if oldGui then Debris:AddItem(oldGui, 0) end
if not isfolder("click") then makefolder("click") end

local Connections = setmetatable({
    disconnect = function(self, k)
        if not self[k] then return end
        self[k]:Disconnect(); self[k] = nil
    end,
    disconnect_all = function(self)
        for _, v in self do
            if typeof(v) ~= "function" then pcall(function() v:Disconnect() end) end
        end
    end,
}, {})

local Util = {}
Util.map = function(_, v, iMin, iMax, oMin, oMax)
    return (v - iMin) * (oMax - oMin) / (iMax - iMin) + oMin
end
Util.vp2w = function(_, loc, dist)
    local ray = workspace.CurrentCamera:ScreenPointToRay(loc.X, loc.Y)
    return ray.Origin + ray.Direction * dist
end
Util.offset = function(self)
    return self:map(workspace.CurrentCamera.ViewportSize.Y, 0, 2560, 8, 56)
end

local AcrylicBlur = {}
AcrylicBlur.__index = AcrylicBlur
function AcrylicBlur.new(obj)
    local self = setmetatable({_object=obj,_folder=nil,_frame=nil,_root=nil}, AcrylicBlur)
    self:_setup(); return self
end
function AcrylicBlur:_makeFolder()
    local f = workspace.CurrentCamera:FindFirstChild("AcrylicBlur")
    if f then Debris:AddItem(f,0) end
    f = Instance.new("Folder"); f.Name="AcrylicBlur"
    f.Parent=workspace.CurrentCamera; self._folder=f
end
function AcrylicBlur:_makeDOF()
    local d = Lighting:FindFirstChild("AcrylicBlur") or Instance.new("DepthOfFieldEffect")
    d.FarIntensity=0; d.FocusDistance=0.05; d.InFocusRadius=0.1
    d.NearIntensity=1; d.Name="AcrylicBlur"; d.Parent=Lighting
    for _,o in Lighting:GetChildren() do
        if not o:IsA("DepthOfFieldEffect") or o==d then continue end
        Connections[o] = o:GetPropertyChangedSignal("FarIntensity"):Connect(function() o.FarIntensity=0 end)
        o.FarIntensity=0
    end
end
function AcrylicBlur:_makeFrame()
    local f = Instance.new("Frame")
    f.Size=UDim2.new(1,0,1,0); f.Position=UDim2.new(0.5,0,0.5,0)
    f.AnchorPoint=Vector2.new(0.5,0.5); f.BackgroundTransparency=1
    f.Parent=self._object; self._frame=f
end
function AcrylicBlur:_makePart()
    local p = Instance.new("Part")
    p.Name="Root"; p.Color=Color3.new(0,0,0); p.Material=Enum.Material.Glass
    p.Size=Vector3.new(1,1,0); p.Anchored=true; p.CanCollide=false
    p.CanQuery=false; p.Locked=true; p.CastShadow=false; p.Transparency=0.98
    p.Parent=self._folder
    local m=Instance.new("SpecialMesh"); m.MeshType=Enum.MeshType.Brick
    m.Offset=Vector3.new(0,0,-0.000001); m.Parent=p; self._root=p
end
function AcrylicBlur:_setup()
    self:_makeDOF(); self:_makeFolder(); self:_makePart(); self:_makeFrame()
    self:_render(0.001); self:_checkQL()
end
function AcrylicBlur:_render(dist)
    local pos={tl=Vector2.new(),tr=Vector2.new(),br=Vector2.new()}
    local function upPos(sz,p) pos.tl=p; pos.tr=p+Vector2.new(sz.X,0); pos.br=p+sz end
    local function update()
        local tl=Util:vp2w(pos.tl,dist); local tr=Util:vp2w(pos.tr,dist); local br=Util:vp2w(pos.br,dist)
        if not self._root then return end
        local cam=workspace.CurrentCamera
        self._root.CFrame=CFrame.fromMatrix((tl+br)/2,cam.CFrame.XVector,cam.CFrame.YVector,cam.CFrame.ZVector)
        self._root.Mesh.Scale=Vector3.new((tr-tl).Magnitude,(tr-br).Magnitude,0)
    end
    local function onChange()
        local off=Util:offset()
        upPos(self._frame.AbsoluteSize-Vector2.new(off,off),self._frame.AbsolutePosition+Vector2.new(off/2,off/2))
        task.spawn(update)
    end
    Connections["ab_cf"]  = workspace.CurrentCamera:GetPropertyChangedSignal("CFrame"):Connect(update)
    Connections["ab_vp"]  = workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(update)
    Connections["ab_fov"] = workspace.CurrentCamera:GetPropertyChangedSignal("FieldOfView"):Connect(update)
    Connections["ab_fp"]  = self._frame:GetPropertyChangedSignal("AbsolutePosition"):Connect(onChange)
    Connections["ab_fs"]  = self._frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(onChange)
    task.spawn(update)
end
function AcrylicBlur:_checkQL()
    local gs=UserSettings().GameSettings
    if gs.SavedQualityLevel.Value < 8 then self:setVisible(false) end
    Connections["ab_ql"]=gs:GetPropertyChangedSignal("SavedQualityLevel"):Connect(function()
        self:setVisible(UserSettings().GameSettings.SavedQualityLevel.Value >= 8)
    end)
end
function AcrylicBlur:setVisible(s) self._root.Transparency = s and 0.98 or 1 end

local Config = {}
Config.__index = Config
function Config:save(name, data)
    local ok,e=pcall(function() writefile("click/"..name..".json", HttpService:JSONEncode(data)) end)
    if not ok then warn("Config save failed:", e) end
end
function Config:load(name)
    local ok,r=pcall(function()
        if not isfile("click/"..name..".json") then return nil end
        local raw=readfile("click/"..name..".json")
        return raw and HttpService:JSONDecode(raw) or nil
    end)
    if not ok or not r then r={_flags={},_keybinds={},_library={}} end
    return r
end
local Cfg = setmetatable({}, Config)

local function mkCorner(r, p)
    local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,r); c.Parent=p; return c
end
local function mkStroke(col, tr, p)
    local s=Instance.new("UIStroke"); s.Color=col; s.Transparency=tr
    s.Thickness=1; s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; s.Parent=p; return s
end
local function mkLabel(txt, sz, col, tr, fw, p)
    local l=Instance.new("TextLabel")
    l.Text=txt; l.TextSize=sz; l.TextColor3=col; l.TextTransparency=tr
    l.FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json",fw or Enum.FontWeight.SemiBold,Enum.FontStyle.Normal)
    l.BackgroundTransparency=1; l.BorderSizePixel=0; l.Parent=p; return l
end

local Library = {}
Library.__index = Library

function Library.new(title)
    local self = setmetatable({
        _config = Cfg:load(game.GameId),
        _title  = title or "UI",
        _tab    = 0,
        _open   = true,
        _scale  = 1,
        _device = nil,
        _loaded = false,
        _ui     = nil,
        _drag   = false,
        _dStart = nil,
        _dPos   = nil,
    }, Library)
    self:_build()
    return self
end

function Library:_flagType(flag, t)
    if not self._config._flags[flag] then return end
    return typeof(self._config._flags[flag]) == t
end
function Library:_getDevice()
    if not UserInputService.TouchEnabled and UserInputService.KeyboardEnabled then self._device="PC"
    elseif UserInputService.TouchEnabled then self._device="Mobile"
    else self._device="Console" end
end
function Library:_getScale()
    self._scale = workspace.CurrentCamera.ViewportSize.X / 1400
end

function Library:_build()
    local old=CoreGui:FindFirstChild("click")
    if old then Debris:AddItem(old,0) end

    local click=Instance.new("ScreenGui")
    click.Name="click"; click.ResetOnSpawn=false
    click.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; click.Parent=CoreGui

    local Container=Instance.new("Frame")
    Container.Name="Container"; Container.AnchorPoint=Vector2.new(0.5,0.5)
    Container.Position=UDim2.new(0.5,0,0.5,0); Container.Size=UDim2.fromOffset(W,H)
    Container.Visible=false
    Container.BackgroundColor3=C.BG; Container.BackgroundTransparency=0.05
    Container.BorderSizePixel=0; Container.ClipsDescendants=false; Container.Active=true
    Container.Parent=click
    mkCorner(10, Container)
    mkStroke(C.Border, 0.42, Container)

    local Handler=Instance.new("Frame")
    Handler.Name="Handler"; Handler.Size=UDim2.fromOffset(W,H)
    Handler.BackgroundTransparency=1; Handler.BorderSizePixel=0
    Handler.ClipsDescendants=true; Handler.Parent=Container
    mkCorner(10, Handler)

    local Tabs=Instance.new("ScrollingFrame")
    Tabs.ScrollBarImageTransparency=1; Tabs.ScrollBarThickness=0
    Tabs.Name="Tabs"; Tabs.Size=UDim2.fromOffset(SW,401)
    Tabs.Selectable=false; Tabs.AutomaticCanvasSize=Enum.AutomaticSize.XY
    Tabs.BackgroundTransparency=1
    Tabs.Position=UDim2.new(0.026097271591424942,0,0.1111111119389534,0)
    Tabs.BorderSizePixel=0; Tabs.CanvasSize=UDim2.new(0,0,0.5,0)
    Tabs.Parent=Handler

    local TabsLayout=Instance.new("UIListLayout")
    TabsLayout.Padding=UDim.new(0,4); TabsLayout.SortOrder=Enum.SortOrder.LayoutOrder
    TabsLayout.Parent=Tabs

    local ClientName=mkLabel(" "..self._title,13,C.Accent,0.2,Enum.FontWeight.SemiBold,Handler)
    ClientName.Name="ClientName"; ClientName.Size=UDim2.fromOffset(150,20)
    ClientName.AnchorPoint=Vector2.new(0,0.5)
    ClientName.Position=UDim2.new(0.056,0,0.055,0)
    ClientName.TextXAlignment=Enum.TextXAlignment.Left
    local CNG=Instance.new("UIGradient")
    CNG.Color=ColorSequence.new{
        ColorSequenceKeypoint.new(0,C.Accent),
        ColorSequenceKeypoint.new(1,C.White)
    }
    CNG.Parent=ClientName

    local Pin=Instance.new("Frame")
    Pin.Name="Pin"; Pin.Position=UDim2.new(0.026,0,0.136,0)
    Pin.BorderColor3=C.Border; Pin.Size=UDim2.fromOffset(2,16)
    Pin.BorderSizePixel=0; Pin.BackgroundColor3=C.Accent; Pin.Parent=Handler
    mkCorner(99,Pin)

    local LogoIcon=Instance.new("ImageLabel")
    LogoIcon.ImageColor3=C.Accent; LogoIcon.ScaleType=Enum.ScaleType.Fit
    LogoIcon.BorderColor3=C.Border; LogoIcon.AnchorPoint=Vector2.new(0,0.5)
    LogoIcon.Image="rbxassetid://13712658531"; LogoIcon.BackgroundTransparency=1
    LogoIcon.Position=UDim2.new(0.021,0,0.053,0); LogoIcon.Name="Icon"
    LogoIcon.Size=UDim2.fromOffset(27,26); LogoIcon.BorderSizePixel=0; LogoIcon.Parent=Handler

    local Divider=Instance.new("Frame")
    Divider.Name="Divider"; Divider.BackgroundTransparency=0.4
    Divider.Position=UDim2.new(0.23499999940395355,0,0,0)
    Divider.BorderColor3=C.Border; Divider.Size=UDim2.fromOffset(1,H)
    Divider.BorderSizePixel=0; Divider.BackgroundColor3=C.Border; Divider.Parent=Handler

    local Sections=Instance.new("Folder"); Sections.Name="Sections"; Sections.Parent=Handler

    local Minimize=Instance.new("TextButton")
    Minimize.FontFace=Font.new("rbxasset://fonts/families/SourceSansPro.json",Enum.FontWeight.Regular,Enum.FontStyle.Normal)
    Minimize.TextColor3=C.Border; Minimize.BorderColor3=C.Border
    Minimize.Text=""; Minimize.AutoButtonColor=false; Minimize.Name="Minimize"
    Minimize.BackgroundTransparency=1
    Minimize.Position=UDim2.new(0.020057305693626404,0,0.02922755666077137,0)
    Minimize.Size=UDim2.fromOffset(24,24); Minimize.BorderSizePixel=0
    Minimize.TextSize=14; Minimize.Parent=Handler

    local UIScale=Instance.new("UIScale"); UIScale.Parent=Container

    local lp = Players.LocalPlayer
    local BarW = W - 40

    local BarOuter=Instance.new("Frame")
    BarOuter.Name="PlayerBar"
    BarOuter.AnchorPoint=Vector2.new(0.5,0)
    BarOuter.Size=UDim2.fromOffset(BarW, 38)
    BarOuter.Position=UDim2.new(0.5,0,1,10)
    BarOuter.BackgroundColor3=Color3.fromRGB(8,8,8)
    BarOuter.BackgroundTransparency=1
    BarOuter.BorderSizePixel=0
    BarOuter.ClipsDescendants=false
    BarOuter.Parent=Container
    mkCorner(99, BarOuter)
    local BarStroke = mkStroke(Color3.fromRGB(38,38,38), 1, BarOuter)

    local AvatarFrame=Instance.new("Frame")
    AvatarFrame.Size=UDim2.fromOffset(26,26)
    AvatarFrame.AnchorPoint=Vector2.new(0,0.5)
    AvatarFrame.Position=UDim2.new(0,8,0.5,0)
    AvatarFrame.BackgroundColor3=C.Border
    AvatarFrame.BackgroundTransparency=1
    AvatarFrame.BorderSizePixel=0
    AvatarFrame.Parent=BarOuter
    mkCorner(99, AvatarFrame)

    local AvatarImg=Instance.new("ImageLabel")
    AvatarImg.Size=UDim2.fromScale(1,1)
    AvatarImg.BackgroundTransparency=1
    AvatarImg.BorderSizePixel=0
    AvatarImg.ScaleType=Enum.ScaleType.Crop
    AvatarImg.ImageTransparency=1
    AvatarImg.Image="https://www.roblox.com/headshot-thumbnail/image?userId="..lp.UserId.."&width=48&height=48&format=png"
    AvatarImg.Parent=AvatarFrame
    mkCorner(99, AvatarImg)

    local BarDiv=Instance.new("Frame")
    BarDiv.Size=UDim2.fromOffset(1,22)
    BarDiv.AnchorPoint=Vector2.new(0,0.5)
    BarDiv.Position=UDim2.new(0,42,0.5,0)
    BarDiv.BackgroundColor3=C.Border
    BarDiv.BackgroundTransparency=1
    BarDiv.BorderSizePixel=0
    BarDiv.Parent=BarOuter

    local DispName=Instance.new("TextLabel")
    DispName.Text=lp.DisplayName
    DispName.TextSize=11
    DispName.TextColor3=C.Accent
    DispName.TextTransparency=1
    DispName.FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.Bold,Enum.FontStyle.Normal)
    DispName.BackgroundTransparency=1
    DispName.BorderSizePixel=0
    DispName.AnchorPoint=Vector2.new(0,0.5)
    DispName.Position=UDim2.new(0,50,0.5,-7)
    DispName.Size=UDim2.fromOffset(180,13)
    DispName.TextXAlignment=Enum.TextXAlignment.Left
    DispName.Parent=BarOuter

    local UserName=Instance.new("TextLabel")
    UserName.Text="@"..lp.Name
    UserName.TextSize=9
    UserName.TextColor3=Color3.fromRGB(100,100,100)
    UserName.TextTransparency=1
    UserName.FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.Regular,Enum.FontStyle.Normal)
    UserName.BackgroundTransparency=1
    UserName.BorderSizePixel=0
    UserName.AnchorPoint=Vector2.new(0,0.5)
    UserName.Position=UDim2.new(0,50,0.5,6)
    UserName.Size=UDim2.fromOffset(180,11)
    UserName.TextXAlignment=Enum.TextXAlignment.Left
    UserName.Parent=BarOuter

    local GameName=Instance.new("TextLabel")
    GameName.Text=game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
    GameName.TextSize=9
    GameName.TextColor3=Color3.fromRGB(80,80,80)
    GameName.TextTransparency=1
    GameName.FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.Regular,Enum.FontStyle.Normal)
    GameName.BackgroundTransparency=1
    GameName.BorderSizePixel=0
    GameName.AnchorPoint=Vector2.new(1,0.5)
    GameName.Position=UDim2.new(1,-12,0.5,0)
    GameName.Size=UDim2.fromOffset(200,13)
    GameName.TextXAlignment=Enum.TextXAlignment.Right
    GameName.TextTruncate=Enum.TextTruncate.AtEnd
    GameName.Parent=BarOuter

    local function showBar()
        local ti = TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        TweenService:Create(BarOuter,   ti, {BackgroundTransparency=0.08}):Play()
        TweenService:Create(BarStroke,  ti, {Transparency=0.3}):Play()
        TweenService:Create(AvatarFrame,ti, {BackgroundTransparency=0.5}):Play()
        TweenService:Create(AvatarImg,  ti, {ImageTransparency=0}):Play()
        TweenService:Create(BarDiv,     ti, {BackgroundTransparency=0.4}):Play()
        TweenService:Create(DispName,   ti, {TextTransparency=0.1}):Play()
        TweenService:Create(UserName,   ti, {TextTransparency=0}):Play()
        TweenService:Create(GameName,   ti, {TextTransparency=0}):Play()
    end
    local function hideBar()
        local ti = TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        TweenService:Create(BarOuter,   ti, {BackgroundTransparency=1}):Play()
        TweenService:Create(BarStroke,  ti, {Transparency=1}):Play()
        TweenService:Create(AvatarFrame,ti, {BackgroundTransparency=1}):Play()
        TweenService:Create(AvatarImg,  ti, {ImageTransparency=1}):Play()
        TweenService:Create(BarDiv,     ti, {BackgroundTransparency=1}):Play()
        TweenService:Create(DispName,   ti, {TextTransparency=1}):Play()
        TweenService:Create(UserName,   ti, {TextTransparency=1}):Play()
        TweenService:Create(GameName,   ti, {TextTransparency=1}):Play()
    end

    self._ui = click

    Container.InputBegan:Connect(function(inp)
        if inp.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        if Library._blockDrag then Library._blockDrag = false; return end
        self._drag=true; self._dStart=inp.Position; self._dPos=Container.Position
        Connections["de"]=inp.Changed:Connect(function()
            if inp.UserInputState ~= Enum.UserInputState.End then return end
            Connections:disconnect("de"); self._drag=false
        end)
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if not self._drag then return end
        if inp.UserInputType ~= Enum.UserInputType.MouseMovement then return end
        local d=inp.Position-self._dStart
        TweenService:Create(Container,TweenInfo.new(0.2),{
            Position=UDim2.new(self._dPos.X.Scale,self._dPos.X.Offset+d.X,
                               self._dPos.Y.Scale,self._dPos.Y.Offset+d.Y)
        }):Play()
    end)

    click.AncestryChanged:Once(function() self._ui=nil; Connections:disconnect_all() end)

    Minimize.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then Library._blockDrag = true end
    end)

    function self:change_visiblity(state)
        if state then
            Handler.Visible = true
            TweenService:Create(Container,TweenInfo.new(0.5,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{
                Size=UDim2.fromOffset(W,H)
            }):Play()
        else
            TweenService:Create(Container,TweenInfo.new(0.5,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{
                Size=UDim2.fromOffset(158,52)
            }):Play()
            task.delay(0.5, function() if not self._open then Handler.Visible = false end end)
        end
    end

    Minimize.MouseButton1Click:Connect(function()
        self._open = not self._open
        self:change_visiblity(self._open)
    end)
    UserInputService.InputBegan:Connect(function(inp,proc)
        if inp.KeyCode ~= Enum.KeyCode.RightControl then return end
        self._open = not self._open
        self:change_visiblity(self._open)
    end)

    function self:load()
        local imgs={}
        for _,o in click:GetDescendants() do
            if o:IsA("ImageLabel") then table.insert(imgs,o) end
        end
        ContentProvider:PreloadAsync(imgs)
        self:_getDevice()
        if self._device=="Mobile" or self._device=="Unknown" then
            self:_getScale(); UIScale.Scale=self._scale
            workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
                self:_getScale(); UIScale.Scale=self._scale
            end)
        end
        Container.Visible = true
        AcrylicBlur.new(Container)
        self._loaded=true
    end

    function self:_updateTabs(activeTab)
        for _, obj in Tabs:GetChildren() do
            if obj.Name ~= "Tab" then continue end
            local isActive = obj == activeTab
            if isActive then
                local offset = obj.LayoutOrder * (0.113 / 1.3)
                TweenService:Create(Pin,TweenInfo.new(0.7,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{
                    Position=UDim2.fromScale(0.026, 0.135+offset)
                }):Play()
                TweenService:Create(obj,TweenInfo.new(0.5,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{
                    BackgroundTransparency=0.7
                }):Play()
                TweenService:Create(obj.TextLabel,TweenInfo.new(0.5,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{
                    TextTransparency=0.2, TextColor3=C.Accent
                }):Play()
                TweenService:Create(obj.TextLabel.UIGradient,TweenInfo.new(0.5,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{
                    Offset=Vector2.new(1,0)
                }):Play()
                TweenService:Create(obj.Icon,TweenInfo.new(3,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{
                    ImageTransparency=0.2, ImageColor3=C.Accent
                }):Play()
            else
                TweenService:Create(obj,TweenInfo.new(2,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{
                    BackgroundTransparency=1
                }):Play()
                TweenService:Create(obj.TextLabel,TweenInfo.new(2,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{
                    TextTransparency=0.7, TextColor3=C.White
                }):Play()
                TweenService:Create(obj.TextLabel.UIGradient,TweenInfo.new(0.5,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{
                    Offset=Vector2.new(0,0)
                }):Play()
                TweenService:Create(obj.Icon,TweenInfo.new(0.5,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{
                    ImageTransparency=0.8, ImageColor3=C.White
                }):Play()
            end
        end
        local titleObj = activeTab:FindFirstChild("TextLabel")
        if titleObj and titleObj.Text == "Settings" then
            showBar()
        else
            hideBar()
        end
    end

    function self:_updateSections(ls, rs)
        for _, o in Sections:GetChildren() do
            o.Visible = (o==ls or o==rs)
        end
    end

    function self:create_tab(title, icon)
        local TabManager = {}
        local firstTab = not Tabs:FindFirstChild("Tab")

        local fontParams=Instance.new("GetTextBoundsParams")
        fontParams.Text=title
        fontParams.Font=Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.SemiBold,Enum.FontStyle.Normal)
        fontParams.Size=13; fontParams.Width=10000
        local fontSize=TextService:GetTextBoundsAsync(fontParams)

        local Tab=Instance.new("TextButton")
        Tab.FontFace=Font.new("rbxasset://fonts/families/SourceSansPro.json",Enum.FontWeight.Regular,Enum.FontStyle.Normal)
        Tab.TextColor3=C.Border; Tab.BorderColor3=C.Border
        Tab.Text=""; Tab.AutoButtonColor=false; Tab.BackgroundTransparency=1
        Tab.Name="Tab"; Tab.Size=UDim2.fromOffset(SW,38)
        Tab.BorderSizePixel=0; Tab.TextSize=14
        Tab.BackgroundColor3=C.TabActive
        Tab.LayoutOrder=self._tab; Tab.Parent=Tabs
        mkCorner(5, Tab)

        local TabLbl=mkLabel(title,13,C.White,0.7,Enum.FontWeight.SemiBold,Tab)
        TabLbl.Name="TextLabel"; TabLbl.Size=UDim2.fromOffset(fontSize.X,16)
        TabLbl.AnchorPoint=Vector2.new(0,0.5); TabLbl.Position=UDim2.new(0.28,0,0.5,0)
        TabLbl.TextXAlignment=Enum.TextXAlignment.Left
        local TabGrad=Instance.new("UIGradient")
        TabGrad.Color=ColorSequence.new{
            ColorSequenceKeypoint.new(0,C.White),
            ColorSequenceKeypoint.new(0.7,C.Accent),
            ColorSequenceKeypoint.new(1,C.Border)
        }
        TabGrad.Parent=TabLbl

        local TabIcon=Instance.new("ImageLabel")
        TabIcon.ScaleType=Enum.ScaleType.Fit; TabIcon.ImageTransparency=0.8
        TabIcon.BorderColor3=C.Border; TabIcon.AnchorPoint=Vector2.new(0,0.5)
        TabIcon.BackgroundTransparency=1; TabIcon.Position=UDim2.new(0.1,0,0.5,0)
        TabIcon.Name="Icon"; TabIcon.Image=icon
        TabIcon.Size=UDim2.fromOffset(16,16); TabIcon.BorderSizePixel=0
        TabIcon.Parent=Tab

        local LeftSection=Instance.new("ScrollingFrame")
        LeftSection.Name="LeftSection"; LeftSection.AutomaticCanvasSize=Enum.AutomaticSize.Y
        LeftSection.ScrollBarThickness=3; LeftSection.ScrollBarImageColor3=C.Border
        LeftSection.Size=UDim2.fromOffset(SEC_W,445)
        LeftSection.Selectable=false; LeftSection.AnchorPoint=Vector2.new(0,0.5)
        LeftSection.ScrollBarImageTransparency=0.5; LeftSection.BackgroundTransparency=1
        LeftSection.Position=UDim2.new(0.2594326436519623,0,0.5,0)
        LeftSection.BorderSizePixel=0; LeftSection.CanvasSize=UDim2.new(0,0,0,0)
        LeftSection.ScrollingDirection=Enum.ScrollingDirection.Y
        LeftSection.Visible=false; LeftSection.Parent=Sections
        local LLL=Instance.new("UIListLayout")
        LLL.Padding=UDim.new(0,11); LLL.HorizontalAlignment=Enum.HorizontalAlignment.Center
        LLL.SortOrder=Enum.SortOrder.LayoutOrder; LLL.Parent=LeftSection
        local LLP=Instance.new("UIPadding"); LLP.PaddingTop=UDim.new(0,1); LLP.Parent=LeftSection

        local RightSection=Instance.new("ScrollingFrame")
        RightSection.Name="RightSection"; RightSection.AutomaticCanvasSize=Enum.AutomaticSize.Y
        RightSection.ScrollBarThickness=3; RightSection.ScrollBarImageColor3=C.Border
        RightSection.Size=UDim2.fromOffset(SEC_W,445)
        RightSection.Selectable=false; RightSection.AnchorPoint=Vector2.new(0,0.5)
        RightSection.ScrollBarImageTransparency=0.5; RightSection.BackgroundTransparency=1
        RightSection.Position=UDim2.new(0.6290000081062317,0,0.5,0)
        RightSection.BorderSizePixel=0; RightSection.CanvasSize=UDim2.new(0,0,0,0)
        RightSection.ScrollingDirection=Enum.ScrollingDirection.Y
        RightSection.Visible=false; RightSection.Parent=Sections
        local RLL=Instance.new("UIListLayout")
        RLL.Padding=UDim.new(0,11); RLL.HorizontalAlignment=Enum.HorizontalAlignment.Center
        RLL.SortOrder=Enum.SortOrder.LayoutOrder; RLL.Parent=RightSection
        local RLP=Instance.new("UIPadding"); RLP.PaddingTop=UDim.new(0,1); RLP.Parent=RightSection

        self._tab += 1

        if firstTab then
            self:_updateTabs(Tab); self:_updateSections(LeftSection, RightSection)
        end

        Tab.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then Library._blockDrag = true end
        end)
        Tab.MouseButton1Click:Connect(function()
            self:_updateTabs(Tab); self:_updateSections(LeftSection, RightSection)
        end)

        function TabManager:create_module(s)
            local MM = { _state=false, _size=0, _mult=0 }
            local sec = s.section=="right" and RightSection or LeftSection
            local loIdx = 0

            local Mod=Instance.new("Frame")
            Mod.ClipsDescendants=true; Mod.BorderColor3=C.Border
            Mod.BackgroundTransparency=0.2; Mod.BackgroundColor3=C.Panel
            Mod.Position=UDim2.new(0.004115226212888956,0,0,0)
            Mod.Name="Module"; Mod.Size=UDim2.fromOffset(MOD_W,93)
            Mod.BorderSizePixel=0; Mod.Parent=sec
            mkCorner(5, Mod)
            mkStroke(C.Border, 0.5, Mod)

            local ModList=Instance.new("UIListLayout")
            ModList.SortOrder=Enum.SortOrder.LayoutOrder; ModList.Parent=Mod

            local Hdr=Instance.new("TextButton")
            Hdr.FontFace=Font.new("rbxasset://fonts/families/SourceSansPro.json",Enum.FontWeight.Regular,Enum.FontStyle.Normal)
            Hdr.TextColor3=C.Border; Hdr.BorderColor3=C.Border
            Hdr.Text=""; Hdr.AutoButtonColor=false
            Hdr.BackgroundTransparency=1; Hdr.Name="Header"
            Hdr.Size=UDim2.fromOffset(MOD_W,93)
            Hdr.BorderSizePixel=0; Hdr.TextSize=14; Hdr.Parent=Mod

            local ModuleIcon=Instance.new("ImageLabel")
            ModuleIcon.ImageColor3=C.Accent; ModuleIcon.ScaleType=Enum.ScaleType.Fit
            ModuleIcon.ImageTransparency=0.699999988079071; ModuleIcon.BorderColor3=C.Border
            ModuleIcon.AnchorPoint=Vector2.new(0,0.5); ModuleIcon.Image="rbxassetid://79095934438045"
            ModuleIcon.BackgroundTransparency=1
            ModuleIcon.Position=UDim2.new(0.07100000232458115,0,0.8199999928474426,0)
            ModuleIcon.Name="Icon"; ModuleIcon.Size=UDim2.fromOffset(15,15)
            ModuleIcon.BorderSizePixel=0; ModuleIcon.Parent=Hdr

            local MName=mkLabel(s.title or "Module",13,C.Accent,0.2,Enum.FontWeight.SemiBold,Hdr)
            MName.Name="ModuleName"; MName.Size=UDim2.fromOffset(205,13)
            MName.AnchorPoint=Vector2.new(0,0.5)
            MName.Position=UDim2.new(0.0729999989271164,0,0.23999999463558197,0)
            MName.TextXAlignment=Enum.TextXAlignment.Left

            local MDesc=mkLabel(s.description or "",10,C.Accent,0.699999988079071,Enum.FontWeight.SemiBold,Hdr)
            MDesc.Name="Description"; MDesc.Size=UDim2.fromOffset(205,13)
            MDesc.AnchorPoint=Vector2.new(0,0.5)
            MDesc.Position=UDim2.new(0.0729999989271164,0,0.41999998688697815,0)
            MDesc.TextXAlignment=Enum.TextXAlignment.Left

            local Tog=Instance.new("Frame")
            Tog.Name="Toggle"; Tog.BackgroundTransparency=0.699999988079071
            Tog.Position=UDim2.new(0.8199999928474426,0,0.7570000290870667,0)
            Tog.BorderColor3=C.Border; Tog.Size=UDim2.fromOffset(25,12)
            Tog.BorderSizePixel=0; Tog.BackgroundColor3=C.Toggle; Tog.Parent=Hdr
            mkCorner(99, Tog)

            local Circ=Instance.new("Frame")
            Circ.BorderColor3=C.Border; Circ.AnchorPoint=Vector2.new(0,0.5)
            Circ.BackgroundTransparency=0.1
            Circ.Position=UDim2.new(0,1,0.5,0); Circ.Name="Circle"
            Circ.Size=UDim2.fromOffset(10,10); Circ.BorderSizePixel=0
            Circ.BackgroundColor3=C.Toggle; Circ.Parent=Tog
            mkCorner(99, Circ)

            local KbFrame=Instance.new("Frame")
            KbFrame.Name="Keybind"; KbFrame.BackgroundTransparency=0.699999988079071
            KbFrame.Position=UDim2.new(0.15000000596046448,0,0.7350000143051147,0)
            KbFrame.BorderColor3=C.Border; KbFrame.Size=UDim2.fromOffset(33,15)
            KbFrame.BorderSizePixel=0; KbFrame.BackgroundColor3=C.Accent; KbFrame.Parent=Hdr
            mkCorner(3, KbFrame)

            local KbLbl=mkLabel("None",10,C.White,0,Enum.FontWeight.SemiBold,KbFrame)
            KbLbl.Name="KbLabel"; KbLbl.AnchorPoint=Vector2.new(0.5,0.5)
            KbLbl.Size=UDim2.fromOffset(25,13); KbLbl.Position=UDim2.fromScale(0.5,0.5)
            KbLbl.TextXAlignment=Enum.TextXAlignment.Left

            local HDivL=Instance.new("Frame")
            HDivL.BorderColor3=C.Border; HDivL.AnchorPoint=Vector2.new(0.5,0)
            HDivL.BackgroundTransparency=0.5
            HDivL.Position=UDim2.new(0.5,0,0.6200000047683716,0)
            HDivL.Name="Divider"; HDivL.Size=UDim2.fromOffset(MOD_W,1)
            HDivL.BorderSizePixel=0; HDivL.BackgroundColor3=C.Border; HDivL.Parent=Hdr

            local Opts=Instance.new("Frame")
            Opts.Name="Options"; Opts.BackgroundTransparency=1
            Opts.Position=UDim2.new(0,0,1,0)
            Opts.BorderColor3=C.Border; Opts.Size=UDim2.fromOffset(MOD_W,8)
            Opts.BorderSizePixel=0; Opts.Parent=Mod
            local OptPad=Instance.new("UIPadding"); OptPad.PaddingTop=UDim.new(0,8); OptPad.Parent=Opts
            local OptList=Instance.new("UIListLayout")
            OptList.Padding=UDim.new(0,5); OptList.HorizontalAlignment=Enum.HorizontalAlignment.Center
            OptList.SortOrder=Enum.SortOrder.LayoutOrder; OptList.Parent=Opts

            function MM:change_state(v)
                self._state=v
                if v then
                    TweenService:Create(Mod,TweenInfo.new(0.5,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{
                        Size=UDim2.fromOffset(MOD_W,93+self._size+self._mult)
                    }):Play()
                    TweenService:Create(Circ,TweenInfo.new(0.5,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{
                        BackgroundColor3=C.ToggleOn, Position=UDim2.new(1,-11,0.5,0)
                    }):Play()
                else
                    TweenService:Create(Mod,TweenInfo.new(0.5,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{
                        Size=UDim2.fromOffset(MOD_W,93)
                    }):Play()
                    TweenService:Create(Circ,TweenInfo.new(0.5,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{
                        BackgroundColor3=C.Toggle, Position=UDim2.new(0,1,0.5,0)
                    }):Play()
                end
                Library._config._flags[s.flag]=v
                Cfg:save(game.GameId,Library._config)
                s.callback(v)
            end

            local _pick=false; local _dt=nil
            local function stopDots() if _dt then task.cancel(_dt); _dt=nil end end
            local function startDots()
                stopDots(); _dt=task.spawn(function()
                    local d={".","..","..."}; local i=1
                    while _pick do
                        local dot=d[i]
                        KbLbl.Text=dot
                        local fp2=Instance.new("GetTextBoundsParams"); fp2.Text=dot; fp2.Size=10; fp2.Width=10000
                        fp2.Font=Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.Bold)
                        local fs2=TextService:GetTextBoundsAsync(fp2)
                        KbFrame.Size=UDim2.fromOffset(fs2.X+6,15); KbLbl.Size=UDim2.fromOffset(fs2.X,13)
                        i=i%3+1; task.wait(0.42)
                    end
                end)
            end
            local function applyKbLabel(short)
                KbLbl.Text=short
                local fp=Instance.new("GetTextBoundsParams"); fp.Text=short; fp.Size=10; fp.Width=10000
                fp.Font=Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.Bold)
                local fs=TextService:GetTextBoundsAsync(fp)
                KbFrame.Size=UDim2.fromOffset(fs.X+6,15); KbLbl.Size=UDim2.fromOffset(fs.X,13)
            end
            function MM:connectKb()
                Connections:disconnect(s.flag.."_kb")
                if not Library._config._keybinds[s.flag] then return end
                Connections[s.flag.."_kb"]=UserInputService.InputBegan:Connect(function(inp,proc)
                    if proc then return end
                    if tostring(inp.KeyCode)~=Library._config._keybinds[s.flag] then return end
                    self:change_state(not self._state)
                end)
            end
            KbFrame.InputBegan:Connect(function(inp)
                if inp.UserInputType~=Enum.UserInputType.MouseButton1 or _pick then return end
                Library._blockDrag = true
                _pick=true; Library._choosing_keybind=true; startDots()
                local conn; local clickCount = 0; local clickTimer = nil
                local function finishKeybind(kb)
                    if conn then conn:Disconnect() end
                    if clickTimer then task.cancel(clickTimer) end
                    stopDots(); _pick=false; Library._choosing_keybind=false
                    if kb then
                        local ks=tostring(kb.KeyCode)
                        Library._config._keybinds[s.flag]=ks
                        Cfg:save(game.GameId,Library._config)
                        applyKbLabel(ks:gsub("Enum%.KeyCode%.",""))
                        MM:connectKb()
                    end
                end
                conn=UserInputService.InputBegan:Connect(function(kb)
                    if kb.UserInputType==Enum.UserInputType.Keyboard then
                        finishKeybind(kb)
                    elseif kb.UserInputType==Enum.UserInputType.MouseButton1 or (UserInputService.TouchEnabled and kb.UserInputType==Enum.UserInputType.Touch) then
                        clickCount = clickCount + 1
                        if clickTimer then task.cancel(clickTimer) end
                        if clickCount >= 2 then
                            clickCount = 0
                            Library._config._keybinds[s.flag]=nil
                            Cfg:save(game.GameId,Library._config)
                            applyKbLabel("None")
                            MM:connectKb()
                            finishKeybind(nil)
                        else
                            clickTimer=task.delay(0.5,function()
                                clickCount=0
                                clickTimer=nil
                            end)
                        end
                    end
                end)
            end)

            if Library._config._keybinds[s.flag] then
                applyKbLabel(tostring(Library._config._keybinds[s.flag]):gsub("Enum%.KeyCode%.",""))
                MM:connectKb()
            end

            Hdr.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then Library._blockDrag = true end
            end)
            Hdr.MouseButton1Click:Connect(function() MM:change_state(not MM._state) end)

            local function grow(px)
                if MM._size==0 then MM._size=11 end
                MM._size += px
                Opts.Size=UDim2.fromOffset(MOD_W, MM._size)
                if MM._state then Mod.Size=UDim2.fromOffset(MOD_W, 93+MM._size+MM._mult) end
            end

            function MM:create_separator(s2)
                loIdx+=1; grow(20)
                local SF=Instance.new("Frame")
                SF.Name="Separator"; SF.BackgroundTransparency=1
                SF.Size=UDim2.fromOffset(EL_W,14); SF.BorderSizePixel=0
                SF.LayoutOrder=loIdx; SF.Parent=Opts

                local SLine=Instance.new("Frame")
                SLine.AnchorPoint=Vector2.new(0,0.5); SLine.Position=UDim2.fromScale(0,0.5)
                SLine.Size=UDim2.fromOffset(EL_W,1)
                SLine.BackgroundColor3=C.Border; SLine.BackgroundTransparency=0.3
                SLine.BorderSizePixel=0; SLine.Parent=SF

                local SLbl=mkLabel(s2.title or "",9,C.Accent,0.35,Enum.FontWeight.Bold,SF)
                SLbl.Size=UDim2.new(0,0,0,14); SLbl.AutomaticSize=Enum.AutomaticSize.X
                SLbl.AnchorPoint=Vector2.new(0.5,0.5); SLbl.Position=UDim2.fromScale(0.5,0.5)
                SLbl.TextXAlignment=Enum.TextXAlignment.Center
                SLbl.BackgroundColor3=C.Panel; SLbl.BackgroundTransparency=0
                local p=Instance.new("UIPadding")
                p.PaddingLeft=UDim.new(0,6); p.PaddingRight=UDim.new(0,6); p.Parent=SLbl
            end

            function MM:create_textbox(s2)
                loIdx+=1; grow(30)
                local TBM={_value=s2.value or ""}

                local Wrap=Instance.new("Frame")
                Wrap.Name="Textbox"; Wrap.BackgroundTransparency=1
                Wrap.Size=UDim2.fromOffset(EL_W,24); Wrap.BorderSizePixel=0
                Wrap.LayoutOrder=loIdx; Wrap.Parent=Opts

                local IB=Instance.new("TextBox")
                IB.Name="Input"; IB.PlaceholderText=s2.placeholder or "Type here..."
                IB.Text=s2.value or ""; IB.TextSize=11
                IB.TextColor3=C.TextPrimary; IB.TextTransparency=0
                IB.PlaceholderColor3=Color3.fromRGB(75, 75, 75)
                IB.FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.SemiBold,Enum.FontStyle.Normal)
                IB.BackgroundColor3=C.BG2; IB.BackgroundTransparency=0.1
                IB.BorderSizePixel=0; IB.ClearTextOnFocus=false
                IB.Size=UDim2.fromOffset(EL_W,24); IB.TextXAlignment=Enum.TextXAlignment.Left
                IB.Parent=Wrap
                mkCorner(5,IB)
                local IBS=mkStroke(C.Border,0.6,IB)
                local IBP=Instance.new("UIPadding"); IBP.PaddingLeft=UDim.new(0,8); IBP.PaddingRight=UDim.new(0,6); IBP.Parent=IB

                IB.InputBegan:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 then Library._blockDrag = true end
                end)
                IB.Focused:Connect(function()
                    TweenService:Create(IBS,TweenInfo.new(0.18),{Transparency=0,Color=C.AccentDim}):Play()
                    TweenService:Create(IB,TweenInfo.new(0.18),{BackgroundTransparency=0}):Play()
                end)
                IB.FocusLost:Connect(function(enter)
                    TweenService:Create(IBS,TweenInfo.new(0.18),{Transparency=0.6,Color=C.Border}):Play()
                    TweenService:Create(IB,TweenInfo.new(0.18),{BackgroundTransparency=0.1}):Play()
                    TBM._value=IB.Text
                    Library._config._flags[s2.flag]=TBM._value
                    Cfg:save(game.GameId,Library._config)
                    if s2.callback then s2.callback(TBM._value,enter) end
                end)
                if Library:_flagType(s2.flag,"string") then
                    IB.Text=Library._config._flags[s2.flag]; TBM._value=IB.Text
                end
                return TBM
            end

            function MM:create_checkbox(s2)
                loIdx+=1; grow(20)
                local CM={_state=false}

                local CB=Instance.new("TextButton")
                CB.FontFace=Font.new("rbxasset://fonts/families/SourceSansPro.json",Enum.FontWeight.Regular,Enum.FontStyle.Normal)
                CB.TextColor3=C.Border; CB.BorderColor3=C.Border
                CB.Text=""; CB.AutoButtonColor=false; CB.BackgroundTransparency=1
                CB.Name="Checkbox"; CB.Size=UDim2.fromOffset(EL_W,15)
                CB.BorderSizePixel=0; CB.TextSize=14
                CB.LayoutOrder=loIdx; CB.Parent=Opts

                local CLbl=mkLabel(s2.title or "Checkbox",11,C.White,0.2,Enum.FontWeight.SemiBold,CB)
                CLbl.Size=UDim2.fromOffset(142,13); CLbl.AnchorPoint=Vector2.new(0,0.5)
                CLbl.Position=UDim2.fromScale(0,0.5); CLbl.TextXAlignment=Enum.TextXAlignment.Left

                local Box=Instance.new("Frame")
                Box.BorderColor3=C.Border; Box.AnchorPoint=Vector2.new(1,0.5)
                Box.BackgroundTransparency=0.9; Box.Position=UDim2.fromScale(1,0.5)
                Box.Name="Box"; Box.Size=UDim2.fromOffset(15,15)
                Box.BorderSizePixel=0; Box.BackgroundColor3=C.Accent; Box.Parent=CB
                mkCorner(4, Box)

                local Fill=Instance.new("Frame")
                Fill.AnchorPoint=Vector2.new(0.5,0.5); Fill.BackgroundTransparency=0.4
                Fill.Position=UDim2.fromScale(0.5,0.5); Fill.BorderColor3=C.Border
                Fill.Name="Fill"; Fill.BorderSizePixel=0
                Fill.BackgroundColor3=C.Accent; Fill.Size=UDim2.fromOffset(0,0); Fill.Parent=Box
                mkCorner(3, Fill)

                function CM:change_state(v)
                    self._state=v
                    if v then
                        TweenService:Create(Box,TweenInfo.new(0.5,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{BackgroundTransparency=0.7}):Play()
                        TweenService:Create(Fill,TweenInfo.new(0.5,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{Size=UDim2.fromOffset(9,9)}):Play()
                    else
                        TweenService:Create(Box,TweenInfo.new(0.5,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{BackgroundTransparency=0.9}):Play()
                        TweenService:Create(Fill,TweenInfo.new(0.5,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{Size=UDim2.fromOffset(0,0)}):Play()
                    end
                    Library._config._flags[s2.flag]=v
                    Cfg:save(game.GameId,Library._config); s2.callback(v)
                end
                if Library:_flagType(s2.flag,"boolean") then CM:change_state(Library._config._flags[s2.flag]) end
                CB.InputBegan:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 then Library._blockDrag = true end
                end)
                CB.MouseButton1Click:Connect(function() CM:change_state(not CM._state) end)
                return CM
            end

            function MM:create_slider(s2)
                loIdx+=1; grow(27)
                local SM={}

                local SL=Instance.new("TextButton")
                SL.FontFace=Font.new("rbxasset://fonts/families/SourceSansPro.json",Enum.FontWeight.Regular,Enum.FontStyle.Normal)
                SL.TextSize=14; SL.TextColor3=C.Border; SL.BorderColor3=C.Border
                SL.Text=""; SL.AutoButtonColor=false; SL.BackgroundTransparency=1
                SL.Name="Slider"; SL.Size=UDim2.fromOffset(EL_W,22)
                SL.BorderSizePixel=0; SL.LayoutOrder=loIdx; SL.Parent=Opts

                local SLbl=mkLabel(s2.title,11,C.White,0.2,Enum.FontWeight.SemiBold,SL)
                SLbl.Size=UDim2.fromOffset(153,13); SLbl.Position=UDim2.new(0,0,0.05,0)
                SLbl.TextXAlignment=Enum.TextXAlignment.Left

                local SVLbl=mkLabel("50",10,C.White,0.2,Enum.FontWeight.SemiBold,SL)
                SVLbl.Name="Value"; SVLbl.Size=UDim2.fromOffset(42,13)
                SVLbl.AnchorPoint=Vector2.new(1,0); SVLbl.Position=UDim2.fromScale(1,0)
                SVLbl.TextXAlignment=Enum.TextXAlignment.Right

                local Track=Instance.new("Frame")
                Track.BorderColor3=C.Border; Track.AnchorPoint=Vector2.new(0.5,1)
                Track.BackgroundTransparency=0.899999976158142
                Track.Position=UDim2.new(0.5,0,0.949999988079071,0)
                Track.Name="Drag"; Track.Size=UDim2.fromOffset(EL_W,4)
                Track.BorderSizePixel=0; Track.BackgroundColor3=C.Accent; Track.Parent=SL
                mkCorner(99,Track)

                local SFill=Instance.new("Frame")
                SFill.BorderColor3=C.Border; SFill.AnchorPoint=Vector2.new(0,0.5)
                SFill.BackgroundTransparency=0.5; SFill.Position=UDim2.fromScale(0,0.5)
                SFill.Name="Fill"; SFill.Size=UDim2.fromOffset(103,4)
                SFill.BorderSizePixel=0; SFill.BackgroundColor3=C.Accent; SFill.Parent=Track
                mkCorner(3, SFill)
                local SFG=Instance.new("UIGradient")
                SFG.Color=ColorSequence.new{
                    ColorSequenceKeypoint.new(0,C.White),
                    ColorSequenceKeypoint.new(1,C.Border)
                }
                SFG.Parent=SFill

                local SDot=Instance.new("Frame")
                SDot.AnchorPoint=Vector2.new(1,0.5); SDot.Position=UDim2.fromScale(1,0.5)
                SDot.Size=UDim2.fromOffset(6,6); SDot.BackgroundColor3=C.White
                SDot.BorderSizePixel=0; SDot.Parent=SFill; mkCorner(99,SDot)

                function SM:set(pct)
                    local rnd=s2.round_number and math.floor(pct) or math.floor(pct*10)/10
                    local norm=(pct-s2.minimum_value)/(s2.maximum_value-s2.minimum_value)
                    local sw=math.clamp(norm,0.02,1)*Track.Size.X.Offset
                    local clamped=math.clamp(rnd,s2.minimum_value,s2.maximum_value)
                    Library._config._flags[s2.flag]=clamped; SVLbl.Text=tostring(clamped)
                    TweenService:Create(SFill,TweenInfo.new(0.5,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{
                        Size=UDim2.fromOffset(sw,Track.Size.Y.Offset)
                    }):Play()
                    s2.callback(clamped)
                end
                SL.InputBegan:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 then Library._blockDrag = true end
                end)
                SL.MouseButton1Down:Connect(function()
                    SM:set(s2.minimum_value+(s2.maximum_value-s2.minimum_value)*((mouse.X-Track.AbsolutePosition.X)/Track.Size.X.Offset))
                    Connections["sl_m_"..s2.flag]=mouse.Move:Connect(function()
                        SM:set(s2.minimum_value+(s2.maximum_value-s2.minimum_value)*((mouse.X-Track.AbsolutePosition.X)/Track.Size.X.Offset))
                    end)
                    Connections["sl_u_"..s2.flag]=UserInputService.InputEnded:Connect(function(inp)
                        if inp.UserInputType~=Enum.UserInputType.MouseButton1 then return end
                        Connections:disconnect("sl_m_"..s2.flag); Connections:disconnect("sl_u_"..s2.flag)
                        Cfg:save(game.GameId,Library._config)
                    end)
                end)
                if Library:_flagType(s2.flag,"number") then SM:set(Library._config._flags[s2.flag])
                else SM:set(s2.value) end
                return SM
            end

            function MM:create_dropdown(s2)
                loIdx+=1; grow(44)
                local DM={_open=false,_listH=0}
                if not Library._config._flags[s2.flag] then Library._config._flags[s2.flag]={} end

                local DDWrap=Instance.new("TextButton")
                DDWrap.FontFace=Font.new("rbxasset://fonts/families/SourceSansPro.json",Enum.FontWeight.Regular,Enum.FontStyle.Normal)
                DDWrap.TextColor3=C.Border; DDWrap.BorderColor3=C.Border
                DDWrap.Text=""; DDWrap.AutoButtonColor=false; DDWrap.BackgroundTransparency=1
                DDWrap.Name="Dropdown"; DDWrap.Size=UDim2.fromOffset(EL_W,39)
                DDWrap.BorderSizePixel=0; DDWrap.TextSize=14
                DDWrap.LayoutOrder=loIdx; DDWrap.Parent=Opts

                local DDTitle=mkLabel(s2.title,11,C.White,0.2,Enum.FontWeight.SemiBold,DDWrap)
                DDTitle.Size=UDim2.fromOffset(EL_W,13); DDTitle.TextXAlignment=Enum.TextXAlignment.Left

                local DDBox=Instance.new("Frame")
                DDBox.ClipsDescendants=true; DDBox.BorderColor3=C.Border
                DDBox.AnchorPoint=Vector2.new(0.5,0); DDBox.BackgroundTransparency=0.9
                DDBox.Position=UDim2.new(0.5,0,1.2,0); DDBox.Name="Box"
                DDBox.Size=UDim2.fromOffset(EL_W,22); DDBox.BorderSizePixel=0
                DDBox.BackgroundColor3=C.Accent; DDBox.Parent=DDTitle
                mkCorner(4, DDBox)

                local DDBH=Instance.new("Frame")
                DDBH.BorderColor3=C.Border; DDBH.AnchorPoint=Vector2.new(0.5,0)
                DDBH.BackgroundTransparency=1; DDBH.Position=UDim2.fromScale(0.5,0)
                DDBH.Name="Header"; DDBH.Size=UDim2.fromOffset(EL_W,22)
                DDBH.BorderSizePixel=0; DDBH.Parent=DDBox

                local DDCur=mkLabel("",10,C.White,0.2,Enum.FontWeight.SemiBold,DDBH)
                DDCur.Name="CurrentOption"; DDCur.Size=UDim2.fromOffset(161,13)
                DDCur.AnchorPoint=Vector2.new(0,0.5); DDCur.Position=UDim2.new(0.05,0,0.5,0)
                DDCur.TextXAlignment=Enum.TextXAlignment.Left

                local DDArr=Instance.new("ImageLabel")
                DDArr.BorderColor3=C.Border; DDArr.AnchorPoint=Vector2.new(0,0.5)
                DDArr.Image="rbxassetid://84232453189324"; DDArr.BackgroundTransparency=1
                DDArr.Position=UDim2.new(0.91,0,0.5,0); DDArr.Name="Arrow"
                DDArr.Size=UDim2.fromOffset(8,8); DDArr.BorderSizePixel=0; DDArr.Parent=DDBH

                local DDOpts=Instance.new("ScrollingFrame")
                DDOpts.ScrollBarImageColor3=C.Border; DDOpts.Active=true
                DDOpts.ScrollBarImageTransparency=1; DDOpts.AutomaticCanvasSize=Enum.AutomaticSize.XY
                DDOpts.ScrollBarThickness=0; DDOpts.Name="Options"
                DDOpts.Size=UDim2.fromOffset(EL_W,0); DDOpts.BackgroundTransparency=1
                DDOpts.Position=UDim2.fromScale(0,1); DDOpts.CanvasSize=UDim2.new(0,0,0.5,0)
                DDOpts.BorderSizePixel=0; DDOpts.Parent=DDBox
                local DDList=Instance.new("UIListLayout"); DDList.SortOrder=Enum.SortOrder.LayoutOrder; DDList.Parent=DDOpts
                local DDPad=Instance.new("UIPadding"); DDPad.PaddingTop=UDim.new(0,-1); DDPad.PaddingLeft=UDim.new(0,10); DDPad.Parent=DDOpts
                local DDList2=Instance.new("UIListLayout"); DDList2.SortOrder=Enum.SortOrder.LayoutOrder; DDList2.Parent=DDBox

                function DM:update(opt)
                    DDCur.Text=(typeof(opt)=="string" and opt) or opt.Name
                    for _,o in DDOpts:GetChildren() do
                        if o.Name=="Option" then o.TextTransparency=o.Text==DDCur.Text and 0.2 or 0.6 end
                    end
                    Library._config._flags[s2.flag]=opt
                    Cfg:save(game.GameId,Library._config); s2.callback(opt)
                end
                function DM:toggle()
                    self._open=not self._open
                    if self._open then
                        MM._mult+=self._listH
                        TweenService:Create(Mod,TweenInfo.new(0.5,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{Size=UDim2.fromOffset(MOD_W,93+MM._size+MM._mult)}):Play()
                        TweenService:Create(DDWrap,TweenInfo.new(0.5,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{Size=UDim2.fromOffset(EL_W,39+self._listH)}):Play()
                        TweenService:Create(DDBox,TweenInfo.new(0.5,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{Size=UDim2.fromOffset(EL_W,22+self._listH)}):Play()
                        TweenService:Create(DDArr,TweenInfo.new(0.5,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{Rotation=180}):Play()
                    else
                        MM._mult-=self._listH
                        TweenService:Create(Mod,TweenInfo.new(0.5,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{Size=UDim2.fromOffset(MOD_W,93+MM._size+MM._mult)}):Play()
                        TweenService:Create(DDWrap,TweenInfo.new(0.5,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{Size=UDim2.fromOffset(EL_W,39)}):Play()
                        TweenService:Create(DDBox,TweenInfo.new(0.5,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{Size=UDim2.fromOffset(EL_W,22)}):Play()
                        TweenService:Create(DDArr,TweenInfo.new(0.5,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{Rotation=0}):Play()
                    end
                end

                DM._listH=3
                for idx,val in s2.options do
                    local optTxt=(typeof(val)=="string" and val) or val.Name
                    local Opt=Instance.new("TextButton")
                    Opt.FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.SemiBold,Enum.FontStyle.Normal)
                    Opt.Active=false; Opt.TextTransparency=0.6; Opt.AnchorPoint=Vector2.new(0,0.5)
                    Opt.TextSize=10; Opt.Size=UDim2.fromOffset(186,16)
                    Opt.TextColor3=C.White; Opt.BorderColor3=C.Border; Opt.Text=optTxt
                    Opt.AutoButtonColor=false; Opt.Name="Option"; Opt.BackgroundTransparency=1
                    Opt.TextXAlignment=Enum.TextXAlignment.Left; Opt.Selectable=false
                    Opt.BorderSizePixel=0; Opt.LayoutOrder=idx; Opt.Parent=DDOpts
                    Opt.InputBegan:Connect(function(inp)
                        if inp.UserInputType == Enum.UserInputType.MouseButton1 then Library._blockDrag = true end
                    end)
                    Opt.MouseButton1Click:Connect(function() DM:update(val) end)
                    if idx<=(s2.maximum_options or 999) then
                        DM._listH+=16; DDOpts.Size=UDim2.fromOffset(EL_W,DM._listH)
                    end
                end

                if Library:_flagType(s2.flag,"string") then DM:update(Library._config._flags[s2.flag])
                elseif #s2.options>0 then DM:update(s2.options[1]) end
                DDWrap.InputBegan:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 then Library._blockDrag = true end
                end)
                DDWrap.MouseButton1Click:Connect(function() DM:toggle() end)
                return DM
            end

            function MM:create_multi_dropdown(s2)
                loIdx+=1; grow(44)
                local MDM={_open=false,_listH=0,_sel={}}
                if not Library._config._flags[s2.flag] then Library._config._flags[s2.flag]={} end
                if typeof(Library._config._flags[s2.flag])=="table" then
                    for _,v in Library._config._flags[s2.flag] do MDM._sel[v]=true end
                end

                local MDWrap=Instance.new("TextButton")
                MDWrap.FontFace=Font.new("rbxasset://fonts/families/SourceSansPro.json",Enum.FontWeight.Regular,Enum.FontStyle.Normal)
                MDWrap.TextColor3=C.Border; MDWrap.BorderColor3=C.Border
                MDWrap.Text=""; MDWrap.AutoButtonColor=false; MDWrap.BackgroundTransparency=1
                MDWrap.Name="MultiDropdown"; MDWrap.Size=UDim2.fromOffset(EL_W,39)
                MDWrap.BorderSizePixel=0; MDWrap.TextSize=14
                MDWrap.LayoutOrder=loIdx; MDWrap.Parent=Opts

                local MDTitle=mkLabel(s2.title,11,C.White,0.2,Enum.FontWeight.SemiBold,MDWrap)
                MDTitle.Size=UDim2.fromOffset(EL_W,13); MDTitle.TextXAlignment=Enum.TextXAlignment.Left

                local MDBox=Instance.new("Frame")
                MDBox.ClipsDescendants=true; MDBox.BorderColor3=C.Border
                MDBox.AnchorPoint=Vector2.new(0.5,0); MDBox.BackgroundTransparency=0.9
                MDBox.Position=UDim2.new(0.5,0,1.2,0); MDBox.Name="Box"
                MDBox.Size=UDim2.fromOffset(EL_W,22); MDBox.BorderSizePixel=0
                MDBox.BackgroundColor3=C.Accent; MDBox.Parent=MDTitle
                mkCorner(4, MDBox)

                local MDBH=Instance.new("Frame")
                MDBH.BorderColor3=C.Border; MDBH.AnchorPoint=Vector2.new(0.5,0)
                MDBH.BackgroundTransparency=1; MDBH.Position=UDim2.fromScale(0.5,0)
                MDBH.Name="Header"; MDBH.Size=UDim2.fromOffset(EL_W,22)
                MDBH.BorderSizePixel=0; MDBH.Parent=MDBox

                local MDSum=mkLabel("None selected",10,C.White,0.2,Enum.FontWeight.SemiBold,MDBH)
                MDSum.Name="Summary"; MDSum.Size=UDim2.fromOffset(161,13)
                MDSum.AnchorPoint=Vector2.new(0,0.5); MDSum.Position=UDim2.new(0.05,0,0.5,0)
                MDSum.TextXAlignment=Enum.TextXAlignment.Left

                local MDArr=Instance.new("ImageLabel")
                MDArr.BorderColor3=C.Border; MDArr.AnchorPoint=Vector2.new(0,0.5)
                MDArr.Image="rbxassetid://84232453189324"; MDArr.BackgroundTransparency=1
                MDArr.Position=UDim2.new(0.91,0,0.5,0); MDArr.Name="Arrow"
                MDArr.Size=UDim2.fromOffset(8,8); MDArr.BorderSizePixel=0; MDArr.Parent=MDBH

                local MDOpts=Instance.new("ScrollingFrame")
                MDOpts.ScrollBarImageColor3=C.Border; MDOpts.Active=true
                MDOpts.ScrollBarImageTransparency=1; MDOpts.AutomaticCanvasSize=Enum.AutomaticSize.XY
                MDOpts.ScrollBarThickness=0; MDOpts.Name="Options"
                MDOpts.Size=UDim2.fromOffset(EL_W,0); MDOpts.BackgroundTransparency=1
                MDOpts.Position=UDim2.fromScale(0,1); MDOpts.CanvasSize=UDim2.new(0,0,0.5,0)
                MDOpts.BorderSizePixel=0; MDOpts.Parent=MDBox
                local MDList=Instance.new("UIListLayout"); MDList.SortOrder=Enum.SortOrder.LayoutOrder; MDList.Parent=MDOpts
                local MDPad=Instance.new("UIPadding"); MDPad.PaddingLeft=UDim.new(0,8); MDPad.Parent=MDOpts
                local MDList2=Instance.new("UIListLayout"); MDList2.SortOrder=Enum.SortOrder.LayoutOrder; MDList2.Parent=MDBox

                local function refreshSummary()
                    local keys={}
                    for k,v in MDM._sel do if v then table.insert(keys,k) end end
                    table.sort(keys)
                    if #keys==0 then MDSum.Text="None selected"
                    elseif #keys==1 then MDSum.Text=keys[1]
                    else MDSum.Text=keys[1].." +"..tostring(#keys-1).." more" end
                end
                local function persist()
                    local arr={} for k,v in MDM._sel do if v then table.insert(arr,k) end end
                    Library._config._flags[s2.flag]=arr
                    Cfg:save(game.GameId,Library._config); s2.callback(arr)
                end

                function MDM:toggle()
                    self._open=not self._open
                    if self._open then
                        MM._mult+=self._listH
                        TweenService:Create(Mod,TweenInfo.new(0.5,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{Size=UDim2.fromOffset(MOD_W,93+MM._size+MM._mult)}):Play()
                        TweenService:Create(MDWrap,TweenInfo.new(0.5,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{Size=UDim2.fromOffset(EL_W,39+self._listH)}):Play()
                        TweenService:Create(MDBox,TweenInfo.new(0.5,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{Size=UDim2.fromOffset(EL_W,22+self._listH)}):Play()
                        TweenService:Create(MDArr,TweenInfo.new(0.5,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{Rotation=180}):Play()
                    else
                        MM._mult-=self._listH
                        TweenService:Create(Mod,TweenInfo.new(0.5,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{Size=UDim2.fromOffset(MOD_W,93+MM._size+MM._mult)}):Play()
                        TweenService:Create(MDWrap,TweenInfo.new(0.5,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{Size=UDim2.fromOffset(EL_W,39)}):Play()
                        TweenService:Create(MDBox,TweenInfo.new(0.5,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{Size=UDim2.fromOffset(EL_W,22)}):Play()
                        TweenService:Create(MDArr,TweenInfo.new(0.5,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{Rotation=0}):Play()
                    end
                end

                MDM._listH=3
                for idx,val in s2.options do
                    local optStr=(typeof(val)=="string" and val) or val.Name
                    local Row=Instance.new("Frame")
                    Row.Name="OptionRow"; Row.Size=UDim2.fromOffset(EL_W-14,18)
                    Row.BackgroundTransparency=1; Row.BorderSizePixel=0
                    Row.LayoutOrder=idx; Row.Parent=MDOpts

                    local MinCB=Instance.new("Frame")
                    MinCB.Size=UDim2.fromOffset(11,11)
                    MinCB.AnchorPoint=Vector2.new(0,0.5)
                    MinCB.Position=UDim2.fromOffset(0,9)
                    MinCB.BackgroundColor3=C.AccentDim; MinCB.BackgroundTransparency=0.76
                    MinCB.BorderSizePixel=0; MinCB.Parent=Row; mkCorner(3,MinCB)

                    local MinFill=Instance.new("Frame")
                    MinFill.AnchorPoint=Vector2.new(0.5,0.5); MinFill.Position=UDim2.fromScale(0.5,0.5)
                    MinFill.Size=MDM._sel[optStr] and UDim2.fromOffset(6,6) or UDim2.fromOffset(0,0)
                    MinFill.BackgroundColor3=C.Accent; MinFill.BackgroundTransparency=0.05
                    MinFill.BorderSizePixel=0; MinFill.Parent=MinCB; mkCorner(2,MinFill)

                    local OptLbl=mkLabel(optStr,10,C.White,MDM._sel[optStr] and 0.05 or 0.5,Enum.FontWeight.SemiBold,Row)
                    OptLbl.Size=UDim2.new(1,-16,0,14); OptLbl.AnchorPoint=Vector2.new(0,0.5)
                    OptLbl.Position=UDim2.new(0,16,0.5,0); OptLbl.TextXAlignment=Enum.TextXAlignment.Left

                    local RBtn=Instance.new("TextButton")
                    RBtn.Text=""; RBtn.AutoButtonColor=false; RBtn.BackgroundTransparency=1
                    RBtn.Size=UDim2.fromScale(1,1); RBtn.BorderSizePixel=0; RBtn.Parent=Row
                    RBtn.InputBegan:Connect(function(inp)
                        if inp.UserInputType == Enum.UserInputType.MouseButton1 then Library._blockDrag = true end
                    end)
                    RBtn.MouseButton1Click:Connect(function()
                        MDM._sel[optStr]=not MDM._sel[optStr]
                        local sel=MDM._sel[optStr]
                        TweenService:Create(MinFill,TweenInfo.new(0.22,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{Size=sel and UDim2.fromOffset(6,6) or UDim2.fromOffset(0,0)}):Play()
                        TweenService:Create(MinCB,TweenInfo.new(0.22,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{BackgroundTransparency=sel and 0.48 or 0.76}):Play()
                        OptLbl.TextTransparency=sel and 0.05 or 0.5
                        refreshSummary(); persist()
                    end)
                    if idx<=(s2.maximum_options or 999) then
                        MDM._listH+=18; MDOpts.Size=UDim2.fromOffset(EL_W,MDM._listH)
                    end
                end
                refreshSummary()
                MDWrap.InputBegan:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 then Library._blockDrag = true end
                end)
                MDWrap.MouseButton1Click:Connect(function() MDM:toggle() end)
                return MDM
            end

            function MM:create_button(s2)
                loIdx+=1; grow(27)
                local BtnWrap=Instance.new("TextButton")
                BtnWrap.Text=""; BtnWrap.AutoButtonColor=false; BtnWrap.BackgroundTransparency=1
                BtnWrap.Size=UDim2.fromOffset(EL_W,22); BtnWrap.BorderSizePixel=0
                BtnWrap.LayoutOrder=loIdx; BtnWrap.Parent=Opts

                local BtnFrame=Instance.new("Frame")
                BtnFrame.Size=UDim2.fromOffset(EL_W,22); BtnFrame.BorderSizePixel=0
                BtnFrame.BackgroundColor3=C.Panel; BtnFrame.BackgroundTransparency=0.3
                BtnFrame.Parent=BtnWrap
                mkCorner(5, BtnFrame)
                mkStroke(C.Border, 0.5, BtnFrame)

                local BtnLbl=Instance.new("TextLabel")
                BtnLbl.Text=s2.title or "Button"; BtnLbl.TextSize=11
                BtnLbl.TextColor3=C.White; BtnLbl.TextTransparency=0.2
                BtnLbl.FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.SemiBold,Enum.FontStyle.Normal)
                BtnLbl.BackgroundTransparency=1; BtnLbl.BorderSizePixel=0
                BtnLbl.Size=UDim2.fromScale(1,1); BtnLbl.TextXAlignment=Enum.TextXAlignment.Center
                BtnLbl.Parent=BtnFrame

                local function btnFade(col)
                    TweenService:Create(BtnFrame,TweenInfo.new(0.15,Enum.EasingStyle.Linear),{BackgroundColor3=col}):Play()
                end
                BtnWrap.InputBegan:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 then Library._blockDrag = true end
                end)
                BtnWrap.MouseEnter:Connect(function() btnFade(Color3.fromRGB(32,32,32)) end)
                BtnWrap.MouseLeave:Connect(function() btnFade(C.Panel) end)
                BtnWrap.MouseButton1Down:Connect(function() btnFade(Color3.fromRGB(14,14,14)) end)
                BtnWrap.MouseButton1Up:Connect(function() btnFade(Color3.fromRGB(32,32,32)) end)
                BtnWrap.MouseButton1Click:Connect(function()
                    if s2.callback then s2.callback() end
                end)
                return BtnWrap
            end

            return MM
        end

        return TabManager
    end

    Library._config = Cfg:load(game.GameId)
    Library._config._flags = {}
    Library._config._keybinds = {}

    local _notifStack = {}
    local _NOTIF_W = 240
    local _NOTIF_H = 58
    local _NOTIF_GAP = 6
    local _NOTIF_MARGIN_R = 18
    local _NOTIF_START_Y = 18
    local _NOTIF_DURATION = 3.5

    local NotifRootGui = Instance.new("ScreenGui")
    NotifRootGui.Name="ClawriteNotifs"; NotifRootGui.ResetOnSpawn=false
    NotifRootGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
    NotifRootGui.DisplayOrder=100; NotifRootGui.Parent=CoreGui

    local function repositionNotifs()
        for idx, entry in _notifStack do
            local targetY = _NOTIF_START_Y + (idx-1)*(_NOTIF_H+_NOTIF_GAP)
            TweenService:Create(entry.box,TweenInfo.new(0.35,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{
                Position=UDim2.new(1,-(_NOTIF_W+_NOTIF_MARGIN_R),0,targetY)
            }):Play()
        end
    end

    function self:notify(title, subtitle)
        local NBox=Instance.new("Frame")
        NBox.Name="Notif"; NBox.AnchorPoint=Vector2.new(0,0)
        NBox.Size=UDim2.fromOffset(_NOTIF_W,_NOTIF_H)
        NBox.Position=UDim2.new(1,20,0,_NOTIF_START_Y)
        NBox.BackgroundColor3=Color3.fromRGB(16,16,16)
        NBox.BackgroundTransparency=0.04
        NBox.BorderSizePixel=0; NBox.ClipsDescendants=false
        NBox.Parent=NotifRootGui
        mkCorner(8, NBox)
        mkStroke(Color3.fromRGB(55,55,55), 0.3, NBox)

        local NAccent=Instance.new("Frame")
        NAccent.Size=UDim2.fromOffset(2,_NOTIF_H-20)
        NAccent.AnchorPoint=Vector2.new(0,0.5)
        NAccent.Position=UDim2.new(0,8,0.5,0)
        NAccent.BorderSizePixel=0
        NAccent.BackgroundColor3=C.Accent
        NAccent.BackgroundTransparency=0.2
        NAccent.Parent=NBox; mkCorner(99,NAccent)

        local NTitle=Instance.new("TextLabel")
        NTitle.Text=title or "Notification"; NTitle.TextSize=11
        NTitle.TextColor3=C.Accent; NTitle.TextTransparency=0
        NTitle.FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.Bold,Enum.FontStyle.Normal)
        NTitle.BackgroundTransparency=1; NTitle.BorderSizePixel=0
        NTitle.Size=UDim2.new(1,-22,0,14)
        NTitle.Position=UDim2.fromOffset(18,10)
        NTitle.TextXAlignment=Enum.TextXAlignment.Left; NTitle.Parent=NBox

        local NSub=Instance.new("TextLabel")
        NSub.Text=subtitle or ""; NSub.TextSize=9
        NSub.TextColor3=Color3.fromRGB(140,140,140); NSub.TextTransparency=0
        NSub.FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.Regular,Enum.FontStyle.Normal)
        NSub.BackgroundTransparency=1; NSub.BorderSizePixel=0
        NSub.Size=UDim2.new(1,-22,0,11)
        NSub.Position=UDim2.fromOffset(18,26)
        NSub.TextXAlignment=Enum.TextXAlignment.Left; NSub.TextWrapped=true; NSub.Parent=NBox

        local TimerTrack=Instance.new("Frame")
        TimerTrack.Size=UDim2.new(1,-16,0,1)
        TimerTrack.AnchorPoint=Vector2.new(0.5,1)
        TimerTrack.Position=UDim2.new(0.5,0,1,-6)
        TimerTrack.BorderSizePixel=0
        TimerTrack.BackgroundColor3=Color3.fromRGB(40,40,40)
        TimerTrack.BackgroundTransparency=0
        TimerTrack.Parent=NBox; mkCorner(99,TimerTrack)

        local TimerFill=Instance.new("Frame")
        TimerFill.Size=UDim2.fromScale(1,1)
        TimerFill.AnchorPoint=Vector2.new(0,0.5)
        TimerFill.Position=UDim2.fromScale(0,0.5)
        TimerFill.BorderSizePixel=0
        TimerFill.BackgroundColor3=Color3.fromRGB(160,160,160)
        TimerFill.BackgroundTransparency=0.3
        TimerFill.Parent=TimerTrack; mkCorner(99,TimerFill)

        local entry = {box=NBox}
        table.insert(_notifStack, 1, entry)
        repositionNotifs()

        TweenService:Create(TimerFill,TweenInfo.new(_NOTIF_DURATION,Enum.EasingStyle.Linear),{
            Size=UDim2.fromScale(0,1)
        }):Play()

        task.delay(_NOTIF_DURATION, function()
            for i,e in _notifStack do
                if e==entry then table.remove(_notifStack,i); break end
            end
            TweenService:Create(NBox,TweenInfo.new(0.28,Enum.EasingStyle.Quint,Enum.EasingDirection.In),{
                Position=UDim2.new(1,20,0,NBox.Position.Y.Offset)
            }):Play()
            repositionNotifs()
            task.delay(0.3, function() Debris:AddItem(NBox,0) end)
        end)
    end

    return self
end

-- ============================================================
-- USAGE: Initialize the library and call load() when ready
-- ============================================================
local main = Library.new("YourUIName")
repeat task.wait() until game:IsLoaded()

-- Add your tabs, modules, and elements here

main:load()
