-- ==========================================
-- 🎯 VVIP MODS (ANTI-GM/MOD + RPM + NO RELOAD)
-- (UPDATED: Custom Config Save, Load, & Reset System)
-- ==========================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local ScriptContext = game:GetService("ScriptContext")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- AUTO BYPASS ANTI-CHEAT
-- ==========================================
task.spawn(function()
    pcall(function()
        if setreadonly then
            pcall(function() setreadonly(getrenv(), false); setreadonly(getreg(), false); setreadonly(getgc(), false) end)
        end
        if make_writeable then pcall(function() make_writeable(getreg()) end) end
        if detour_function then detour_function = function(...) return true end end
        if getconnections then
            pcall(function() for _, connection in ipairs(getconnections(ScriptContext.Error)) do connection:Disable() end end)
        end
        if getcallingscript then pcall(function() getcallingscript = function() return nil end end) end
        for _, tableName in ipairs({"_G", "shared"}) do
            pcall(function()
                local target = getgenv()[tableName]
                if target and type(target) == "table" then
                    for key, _ in pairs(target) do
                        local strKey = tostring(key):lower()
                        if strKey:find("signature") or strKey:find("checksum") or strKey:find("hash") then target[key] = nil end
                    end
                end
            end)
        end
        for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
            if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
                local name = remote.Name:lower()
                if name:find("handshake") or name:find("validate") or name:find("verify") or name:find("integrity") or name:find("anti") then
                    pcall(function()
                        if remote:IsA("RemoteEvent") then remote.FireServer = function(...) return true end
                        elseif remote:IsA("RemoteFunction") then remote.InvokeServer = function(...) return true end end
                    end)
                end
            end
        end
    end)
end)

local Camera = workspace.CurrentCamera
if Camera.ViewportSize.Y > Camera.ViewportSize.X then
    repeat task.wait(0.5) until Camera.ViewportSize.X > Camera.ViewportSize.Y
    task.wait(1)
end

-- ==========================================
-- LOAD UI RAYFIELD
-- ==========================================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "🎯 VVIP MODS",
   LoadingTitle = "Memuat Cheat...",
   LoadingSubtitle = "Save & Load Config Aktif!",

   ConfigurationSaving = {
      Enabled = false
   },

   Keybind = Enum.KeyCode.LeftControl,

   KeySystem = true,

   KeySettings = {
      Title = "🎯 VVIP MODS",
      Subtitle = "Sistem Verifikasi",
      Note = "Masukkan key yang benar untuk melanjutkan",
      FileName = "VVIPKey",
      SaveKey = true,
      GrabKeyFromSite = false,

      Key = {
         "VVIP2025"
      }
   }
})

Rayfield:Notify({
    Title = "🛡️ Update Aktif",
    Content = "Sistem Save/Reset Konfigurasi telah ditambahkan.",
    Duration = 4,
    Image = 4483362458
})

-- ==========================================
-- VARIABEL SISTEM
-- ==========================================
local MainTab   = Window:CreateTab("🚀 Main Features", 4483362458)
local PlayerTab = Window:CreateTab("🏃 Player Hacks", 4483362458)
local GunTab    = Window:CreateTab("🔫 Gun Mods", 4483362458)
local ConfigTab = Window:CreateTab("💾 Config & Save", 4483362458)

local AimbotAktif = false
local AimbotMode = "POV Kamera (FOV)" 
local AimTargetMode = "Head" 
local AimbotSmoothness = 15

local ESPAktif = false
local FFAModeAktif = false
local SpeedAktif, JumpAktif = false, false
local AntiFallDamageAktif = false
local CustomSpeed, CustomJump = 50, 100
local GunModsAktif = false
local CustomFireRate = 800
local AntiAdminAktif = false 

-- Variabel FOV UI (Presisi dengan IgnoreGuiInset)
local ShowFOV = false
local FOVRadius = 150
local FOVGui, FOVFrame

pcall(function()
    local TargetParent = (gethui and gethui()) or game:GetService("CoreGui")
    FOVGui = Instance.new("ScreenGui")
    FOVGui.Name = "Universal_FOV_System"
    FOVGui.Parent = TargetParent
    FOVGui.IgnoreGuiInset = true
    
    FOVFrame = Instance.new("Frame")
    FOVFrame.Parent = FOVGui
    FOVFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    FOVFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    FOVFrame.Size = UDim2.new(0, FOVRadius * 2, 0, FOVRadius * 2)
    FOVFrame.BackgroundTransparency = 1
    FOVFrame.Visible = false
    
    local FOVStroke = Instance.new("UIStroke")
    FOVStroke.Parent = FOVFrame
    FOVStroke.Color = Color3.fromRGB(255, 255, 255)
    FOVStroke.Thickness = 1.5
    FOVStroke.Transparency = 0.5
    
    local FOVCorner = Instance.new("UICorner")
    FOVCorner.Parent = FOVFrame
    FOVCorner.CornerRadius = UDim.new(1, 0)
end)

==========================================
-- 🛡️ LOGIKA ANTI-GM/MOD (WARNING POPUP ONLY)
-- ==========================================
local function CheckIfAdmin(p)
    if p == LocalPlayer then return false end
    local nameRaw = string.upper(p.Name .. " " .. p.DisplayName)
    if string.find(nameRaw, "%[GM%]") or string.find(nameRaw, "%[MOD%]") or string.find(nameRaw, "GAME MASTER") or string.find(nameRaw, "MODERATOR") or string.find(nameRaw, "DEWAKASAPUTRA") or string.find(nameRaw, "DEWA PROJECT") then return true end
    local ls = p:FindFirstChild("leaderstats")
    if ls then
        for _, stat in pairs(ls:GetChildren()) do
            local statValue = string.upper(tostring(stat.Value))
            if statValue == "GM" or statValue == "MOD" or statValue == "GAME MASTER" or statValue == "MODERATOR" then return true end
        end
    end
    return false
end

local function SendAdminWarning(p)
    Rayfield:Notify({
        Title = "⚠️ GM TERDETEKSI!",
        Content = "Admin/Moderator ["..p.Name.."] ada di room ini! Hati-hati.",
        Duration = 8,
        Image = 4483362458
    })
end

Players.PlayerAdded:Connect(function(p)
    if AntiAdminAktif then task.wait(1); if CheckIfAdmin(p) then SendAdminWarning(p) end end
end)

task.spawn(function()
    while task.wait(5) do
        if AntiAdminAktif then
            for _, p in pairs(Players:GetPlayers()) do if CheckIfAdmin(p) then SendAdminWarning(p) end end
        end
    end
end)

-- ==========================================
-- 1. MENU MAIN FEATURES
-- ==========================================
Toggles.ESP = MainTab:CreateToggle({ Name = "👁️ Enemy ESP (Melihat Musuh)", CurrentValue = false, Flag = "ESPToggle", Callback = function(Value) ESPAktif = Value end })

-- ==========================================
-- 💾 MENU CONFIG & SAVE SYSTEM
-- ==========================================
local ConfigFileName = "LiteHack_Config.json"

local function SaveSettings()
    local settings = {
        AntiAdmin = AntiAdminAktif, Aimbot = AimbotAktif, AimbotMode = AimbotMode, AimTargetMode = AimTargetMode,
        AimbotSmoothness = AimbotSmoothness, ShowFOV = ShowFOV, FOVRadius = FOVRadius, ESPAktif = ESPAktif,
        AntiFallDamageAktif = AntiFallDamageAktif, SpeedAktif = SpeedAktif, CustomSpeed = CustomSpeed,
        JumpAktif = JumpAktif, CustomJump = CustomJump, GunModsAktif = GunModsAktif, CustomFireRate = CustomFireRate
    }
    if writefile then
        pcall(function()
            local json = HttpService:JSONEncode(settings)
            writefile(ConfigFileName, json)
        end)
        return true
    end
    return false
end

local function LoadSettings()
    if isfile and readfile and isfile(ConfigFileName) then
        local success, json = pcall(function() return readfile(ConfigFileName) end)
        if success and json then
            local settings = HttpService:JSONDecode(json)
            -- Apply Settings ke UI
            if settings.AntiAdmin ~= nil then Toggles.AntiAdmin:Set(settings.AntiAdmin) end
            if settings.Aimbot ~= nil then Toggles.Aimbot:Set(settings.Aimbot) end
            if settings.AimbotMode ~= nil then Dropdowns.AimbotMode:Set({settings.AimbotMode}) end
            if settings.AimTargetMode ~= nil then Dropdowns.AimTarget:Set({settings.AimTargetMode}) end
            if settings.AimbotSmoothness ~= nil then Sliders.Smoothness:Set(settings.AimbotSmoothness) end
            if settings.ShowFOV ~= nil then Toggles.FOV:Set(settings.ShowFOV) end
            if settings.FOVRadius ~= nil then Sliders.FOV:Set(settings.FOVRadius) end
            if settings.ESPAktif ~= nil then Toggles.ESP:Set(settings.ESPAktif) end
            if settings.AntiFallDamageAktif ~= nil then Toggles.AntiFall:Set(settings.AntiFallDamageAktif) end
            if settings.SpeedAktif ~= nil then Toggles.Speed:Set(settings.SpeedAktif) end
            if settings.CustomSpeed ~= nil then Sliders.Speed:Set(settings.CustomSpeed) end
            if settings.JumpAktif ~= nil then Toggles.Jump:Set(settings.JumpAktif) end
            if settings.CustomJump ~= nil then Sliders.Jump:Set(settings.CustomJump) end
            if settings.GunModsAktif ~= nil then Toggles.GunMods:Set(settings.GunModsAktif) end
            if settings.CustomFireRate ~= nil then Sliders.FireRate:Set(settings.CustomFireRate) end
            return true
        end
    end
    return false
end

ConfigTab:CreateLabel("💡 Simpan settinganmu agar tidak perlu ngatur ulang saat pindah room.")
ConfigTab:CreateButton({
    Name = "💾 Save Konfigurasi",
    Callback = function()
        if SaveSettings() then Rayfield:Notify({Title = "✅ Tersimpan", Content = "Semua settingan berhasil disimpan di perangkatmu!", Duration = 3})
        else Rayfield:Notify({Title = "❌ Gagal", Content = "Eksekutor kamu tidak mendukung fitur Save.", Duration = 3}) end
    end
})

ConfigTab:CreateButton({
    Name = "📂 Load Konfigurasi",
    Callback = function()
        if LoadSettings() then Rayfield:Notify({Title = "✅ Berhasil", Content = "Settingan lama berhasil dimuat!", Duration = 3})
        else Rayfield:Notify({Title = "⚠️ Info", Content = "Kamu belum punya file Save sebelumnya.", Duration = 3}) end
    end
})

ConfigTab:CreateButton({
    Name = "🔄 Reset Semua ke Default",
    Callback = function()
        Toggles.AntiAdmin:Set(false)
        Toggles.Aimbot:Set(false)
        Dropdowns.AimbotMode:Set({"POV Kamera (FOV)"})
        Dropdowns.AimTarget:Set({"Head"})
        Sliders.Smoothness:Set(15)
        Toggles.FOV:Set(false)
        Sliders.FOV:Set(150)
        Toggles.ESP:Set(false)
        Toggles.AntiFall:Set(false)
        Toggles.Speed:Set(false)
        Sliders.Speed:Set(50)
        Toggles.Jump:Set(false)
        Sliders.Jump:Set(100)
        Toggles.GunMods:Set(false)
        Sliders.FireRate:Set(800)
        Rayfield:Notify({Title = "🔄 Di-Reset", Content = "Semua fitur telah dikembalikan ke awal (Mati).", Duration = 3})
    end
})

-- ==========================================
-- CACHE ENTITY & TEAM LOGIC
-- ==========================================
local ValidEntities = {}
task.spawn(function()
    while task.wait(0.5) do
        local currentList = {}
        for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer and p.Character then table.insert(currentList, p.Character) end end
        for _, obj in pairs(workspace:GetChildren()) do if obj:IsA("Model") and obj ~= LocalPlayer.Character and not Players:GetPlayerFromCharacter(obj) and obj:FindFirstChildOfClass("Humanoid") then table.insert(currentList, obj) end end
        ValidEntities = currentList
    end
end)

local function IsEnemy(model)
    if FFAModeAktif then return true end
    local plr = Players:GetPlayerFromCharacter(model)
    if plr and plr.TeamColor == LocalPlayer.TeamColor then return false end
    return true
end

-- ==========================================
-- 👁️ LOGIKA ESP (ORIGINAL)
-- ==========================================
local CoreGui = game:GetService("CoreGui")
local ESP_Folder = CoreGui:FindFirstChild("Universal_ESP_System") or Instance.new("Folder")
ESP_Folder.Name = "Universal_ESP_System"
ESP_Folder.Parent = CoreGui
local Active_ESP = {}

RunService.RenderStepped:Connect(function()
    if not ESPAktif then
        for _, data in pairs(Active_ESP) do
            data.Highlight.Enabled = false
            data.Gui.Enabled = false
        end
        return
    end
    local EntitiesInFrame = {}
    for _, model in pairs(ValidEntities) do
        local hum = model:FindFirstChildOfClass("Humanoid")
        local hrp = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Head") or model.PrimaryPart
        if model.Parent and hum and hum.Health > 0 and hrp and IsEnemy(model) then
            EntitiesInFrame[model] = true
            if not Active_ESP[model] then
                local esp_data = {}
                local hl = Instance.new("Highlight")
                hl.Name = "ESP_Highlight"
                hl.Adornee = model
                hl.FillTransparency = 0.5
                hl.OutlineTransparency = 0.1
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                hl.Parent = ESP_Folder
                esp_data.Highlight = hl

                local bgui = Instance.new("BillboardGui")
                bgui.Name = "ESP_Tag"
                bgui.Adornee = hrp
                bgui.AlwaysOnTop = true
                bgui.Size = UDim2.new(0, 200, 0, 50)
                bgui.ExtentsOffset = Vector3.new(0, 3, 0)
                bgui.Parent = ESP_Folder
                esp_data.Gui = bgui

                local txt = Instance.new("TextLabel")
                txt.Size = UDim2.new(1, 0, 1, 0)
                txt.BackgroundTransparency = 1
                txt.TextSize = 14
                txt.Font = Enum.Font.Code
                txt.TextStrokeTransparency = 0
                txt.TextColor3 = Color3.fromRGB(255, 255, 255)
                txt.Parent = bgui
                esp_data.TextLabel = txt

                Active_ESP[model] = esp_data
            end

            local data = Active_ESP[model]
            data.Highlight.Enabled = true
            data.Gui.Enabled = true

            local jarak = 0
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                jarak = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - hrp.Position).Magnitude)
            end

            local isShielded = model:FindFirstChildOfClass("ForceField")
            if isShielded then
                data.Highlight.FillColor = Color3.fromRGB(0, 0, 255)
            else
                data.Highlight.FillColor = Color3.fromRGB(255, 0, 0)
            end

            data.TextLabel.Text = (model.Name or "Bot") .. (isShielded and " [KEBAL]" or "") .. " [" .. jarak .. "m]"
            data.TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        end
    end
    for model, data in pairs(Active_ESP) do
        if not EntitiesInFrame[model] then
            data.Highlight:Destroy()
            data.Gui:Destroy()
            Active_ESP[model] = nil
        end
    end
end)
