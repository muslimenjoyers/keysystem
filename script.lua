--[[
    ================================================================
    [ SCRIPT INFORMATION ]
    Project: Custom Script
    Author: OYB
    YouTube: https://youtube.com/@vvipmods-official?si=Jzp6hfSVZq5xITPm
    
    [ TERMS AND CONDITIONS ]
    - You ARE allowed to use and modify this script for your own games.
    - You ARE NOT allowed to re-upload, redistribute, or claim 
      ownership of this script.
    - Removing or altering these credits is strictly prohibited.
    
    Copyright (c) 2026 OYB. All rights reserved.
    ================================================================
]]

-- ⚠️ IMPORTANT: Put this code at the VERY TOP of your Main Script (before obfuscating) ⚠️

local ProtectionConfig = {
    -- 🔴 CRITICAL: This MUST exactly match the 'Secret' value in your Key System's Config!
    -- If your Key System has: Secret = "Test"
    -- Then this must also be: SecretKey = "Test"
    SecretKey = "1234",
    
    -- The name of your Hub (shown in the kick message if they try to bypass)
    HubName = "VVIP MODS"
}

-- Anti-Bypass Logic: Checks if the Key System successfully set the global variable
if not _G[ProtectionConfig.SecretKey] then
    local player = game:GetService("Players").LocalPlayer
    if player then
        player:Kick("\n🛡️ Unauthorized Execution 🛡️\n\nPlease use the official Key System to run " .. ProtectionConfig.HubName)
    end
    return -- Stops the rest of the script from loading!
end

-------------------------------------------------------------------------------
-- 👇 YOUR MAIN SCRIPT CODE STARTS HERE 👇
-------------------------------------------------------------------------------

print(ProtectionConfig.HubName .. " Loaded Successfully!")

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

-- ==========================================
-- KONFIGURASI API (diambil dari script.lua)
-- ==========================================

local API_URL = "https://api-vvipmods.com/api/v5/roblox"

-- Body request yang dikirim ke API:
-- {
--     "member_key": "KEY_USER",
--     "serial": "DEVICE_ID"
-- }

local API_KEY_FIELD = "member_key"
local API_DEVICE_FIELD = "serial"

-- Secret token sesuai PHP:
-- md5($member_key . $serial . 'VVIPMODS')

local TOKEN_SECRET = "VVIPMODS"

-- ==========================================
-- PURE LUA MD5 FALLBACK (diambil dari script.lua)
-- ==========================================

local function PureLuaMD5(message)
    if not bit32 then
        return nil
    end

    local bit = bit32
    local band = bit.band
    local bor = bit.bor
    local bxor = bit.bxor
    local bnot = bit.bnot
    local lrotate = bit.lrotate
    local rshift = bit.rshift

    local MOD = 4294967296

    local function add32(...)
        local sum = 0
        local args = {...}

        for i = 1, #args do
            sum = (sum + args[i]) % MOD
        end

        return sum
    end

    local function leWord(n)
        local b1 = band(n, 255)
        local b2 = band(rshift(n, 8), 255)
        local b3 = band(rshift(n, 16), 255)
        local b4 = band(rshift(n, 24), 255)

        return string.char(b1, b2, b3, b4)
    end

    local function wordToHex(n)
        local b1 = band(n, 255)
        local b2 = band(rshift(n, 8), 255)
        local b3 = band(rshift(n, 16), 255)
        local b4 = band(rshift(n, 24), 255)

        return string.format("%02x%02x%02x%02x", b1, b2, b3, b4)
    end

    local originalLength = #message
    local bitLength = originalLength * 8

    message = message .. string.char(128)

    while (#message % 64) ~= 56 do
        message = message .. string.char(0)
    end

    local lowBits = bitLength % MOD
    local highBits = math.floor(bitLength / MOD)

    message = message .. leWord(lowBits) .. leWord(highBits)

    local s = {
        7, 12, 17, 22,
        7, 12, 17, 22,
        7, 12, 17, 22,
        7, 12, 17, 22,

        5, 9, 14, 20,
        5, 9, 14, 20,
        5, 9, 14, 20,
        5, 9, 14, 20,

        4, 11, 16, 23,
        4, 11, 16, 23,
        4, 11, 16, 23,
        4, 11, 16, 23,

        6, 10, 15, 21,
        6, 10, 15, 21,
        6, 10, 15, 21,
        6, 10, 15, 21
    }

    local K = {}

    for i = 1, 64 do
        K[i] = math.floor(math.abs(math.sin(i)) * MOD)
    end

    local a0 = 0x67452301
    local b0 = 0xefcdab89
    local c0 = 0x98badcfe
    local d0 = 0x10325476

    for chunkStart = 1, #message, 64 do
        local M = {}

        for i = 0, 15 do
            local index = chunkStart + (i * 4)
            local b1, b2, b3, b4 = string.byte(message, index, index + 3)

            M[i] =
                (b1 or 0) +
                ((b2 or 0) * 256) +
                ((b3 or 0) * 65536) +
                ((b4 or 0) * 16777216)
        end

        local A = a0
        local B = b0
        local C = c0
        local D = d0

        for i = 0, 63 do
            local F
            local g

            if i <= 15 then
                F = bor(band(B, C), band(bnot(B), D))
                g = i
            elseif i <= 31 then
                F = bor(band(D, B), band(bnot(D), C))
                g = (5 * i + 1) % 16
            elseif i <= 47 then
                F = bxor(B, C, D)
                g = (3 * i + 5) % 16
            else
                F = bxor(C, bor(B, bnot(D)))
                g = (7 * i) % 16
            end

            F = add32(F, A, K[i + 1], M[g])

            A = D
            D = C
            C = B
            B = add32(B, lrotate(F, s[i + 1]))
        end

        a0 = add32(a0, A)
        b0 = add32(b0, B)
        c0 = add32(c0, C)
        d0 = add32(d0, D)
    end

    return wordToHex(a0) .. wordToHex(b0) .. wordToHex(c0) .. wordToHex(d0)
end

-- ==========================================
-- GENERATE MD5 (diambil dari script.lua)
-- ==========================================

local function GenerateMD5(text)
    text = tostring(text)

    local result = nil

    pcall(function()
        if crypt and crypt.hash then
            result = crypt.hash(text, "md5")
        end
    end)

    if result and type(result) == "string" and #result >= 32 then
        return string.lower(result)
    end

    pcall(function()
        if crypt and crypt.hash then
            result = crypt.hash("md5", text)
        end
    end)

    if result and type(result) == "string" and #result >= 32 then
        return string.lower(result)
    end

    pcall(function()
        if syn and syn.crypt and syn.crypt.hash then
            result = syn.crypt.hash(text, "md5")
        end
    end)

    if result and type(result) == "string" and #result >= 32 then
        return string.lower(result)
    end

    pcall(function()
        if hash then
            result = hash("md5", text)
        end
    end)

    if result and type(result) == "string" and #result >= 32 then
        return string.lower(result)
    end

    pcall(function()
        if hash then
            result = hash(text, "md5")
        end
    end)

    if result and type(result) == "string" and #result >= 32 then
        return string.lower(result)
    end

    result = PureLuaMD5(text)

    if result and type(result) == "string" and #result >= 32 then
        return string.lower(result)
    end

    return nil
end

-- ==========================================
-- DEVICE ID / HWID (diambil dari script.lua)
-- ==========================================

local function GetDeviceId()
    local deviceId = nil

    pcall(function()
        if typeof(gethwid) == "function" then
            deviceId = gethwid()
        elseif typeof(get_hwid) == "function" then
            deviceId = get_hwid()
        end
    end)

    if not deviceId or deviceId == "" then
        deviceId = tostring(LocalPlayer.UserId)
    end

    return tostring(deviceId)
end

-- ==========================================
-- HTTP REQUEST WRAPPER (diambil dari script.lua)
-- ==========================================

local function SendHttpRequest(options)
    if syn and syn.request then
        return syn.request(options)
    elseif http and http.request then
        return http.request(options)
    elseif request then
        return request(options)
    elseif http_request then
        return http_request(options)
    else
        return HttpService:RequestAsync(options)
    end
end

-- ==========================================
-- VALIDASI TOKEN DARI API (diambil dari script.lua)
-- ==========================================

local function ValidateApiToken(memberKey, serial, apiToken)
    if not memberKey or memberKey == "" then
        return false, "Member key kosong."
    end

    if not serial or serial == "" then
        return false, "Serial/device kosong."
    end

    if not apiToken or apiToken == "" then
        return false, "Token API kosong."
    end

    local rawToken = tostring(memberKey) .. tostring(serial) .. TOKEN_SECRET
    local generatedToken = GenerateMD5(rawToken)

    if not generatedToken then
        return false, "Gagal generate MD5 token."
    end

    generatedToken = string.lower(tostring(generatedToken))
    apiToken = string.lower(tostring(apiToken))

    if generatedToken == apiToken then
        return true, "Token valid."
    end

    return false, "Token tidak cocok."
end

-- ==========================================
-- VALIDASI KEY KE API (diambil dari script.lua)
-- ==========================================

local function VerifyKey(inputKey)
    if not inputKey or inputKey == "" then
        return false, "Key tidak boleh kosong.", nil
    end

    local deviceId = GetDeviceId()

    local payload = {}
    payload[API_KEY_FIELD] = tostring(inputKey)
    payload[API_DEVICE_FIELD] = tostring(deviceId)

    local success, result = pcall(function()
        return SendHttpRequest({
            Url = API_URL,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = HttpService:JSONEncode(payload)
        })
    end)

    if not success then
        return false, "Gagal menghubungi API.", nil
    end

    if not result then
        return false, "Response API kosong.", nil
    end

    local statusCode = result.StatusCode or result.status_code or result.Status or 0
    local body = result.Body or result.body or ""

    local requestSuccess = false

    if result.Success == true then
        requestSuccess = true
    elseif tonumber(statusCode) and tonumber(statusCode) >= 200 and tonumber(statusCode) < 300 then
        requestSuccess = true
    end

    if not requestSuccess then
        return false, "HTTP Error: " .. tostring(statusCode), nil
    end

    if body == "" then
        return false, "Body API kosong.", nil
    end

    local decoded = nil
    local decodeSuccess = pcall(function()
        decoded = HttpService:JSONDecode(body)
    end)

    if not decodeSuccess or type(decoded) ~= "table" then
        return false, "Format JSON API tidak valid.", nil
    end

    -- Response sukses:
    -- {
    --     "status": true,
    --     "data": {
    --         "token": "...",
    --         "rng": 1783530307,
    --         "expired": "...",
    --         "EXPR": "...",
    --         "registrator": "Muslim"
    --     }
    -- }

    if decoded.status == true then
        local data = decoded.data

        if not data or type(data) ~= "table" then
            return false, "Data API tidak ditemukan.", nil
        end

        if not data.token then
            return false, "Token API tidak ditemukan.", nil
        end

        local tokenValid, tokenMessage = ValidateApiToken(inputKey, deviceId, data.token)

        if not tokenValid then
            return false, tokenMessage, nil
        end

        return true, "Login berhasil.", data
    end

    -- Response gagal:
    -- {
    --     "status": false,
    --     "reason": "DEVICE IS NOT CORRECT"
    -- }

    return false, decoded.reason or "Key tidak valid.", nil
end

-- ==========================================
-- VARIABEL LOGIN (diambil dari script.lua)
-- ==========================================

local UserKey = ""
local LoggedIn = false

local SavedToken = nil
local SavedRng = nil
local SavedExpired = nil
local SavedRegistrator = nil

-- ==========================================
-- VARIABEL SISTEM (window & tab fitur dibuat setelah login sukses)
-- ==========================================
local Window
local MainTab, PlayerTab, GunTab, ConfigTab
local FeatureTabsCreated = false

-- ==========================================
-- BUKA WINDOW FITUR (menutup window login lebih dulu)
-- ==========================================

local function OpenFeatureWindow()
    if FeatureTabsCreated then
        return
    end
    FeatureTabsCreated = true

    -- Tutup window Login sepenuhnya sebelum window Fitur dibuka
    pcall(function()
        Rayfield:Destroy()
    end)

    -- Muat instance Rayfield baru khusus untuk window Fitur
    Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

    Window = Rayfield:CreateWindow({
        Name = "🎯 VVIP MODS",
        LoadingTitle = "Memuat Cheat...",
        LoadingSubtitle = "Save & Load Config Aktif!",

        ConfigurationSaving = {
            Enabled = false
        },

        Keybind = Enum.KeyCode.LeftControl,

        KeySystem = false
    })

    Rayfield:Notify({
        Title = "🛡️ Update Aktif",
        Content = "Sistem Save/Reset Konfigurasi telah ditambahkan.",
        Duration = 4,
        Image = 4483362458
    })

    MainTab   = Window:CreateTab("🚀 Main Features", 4483362458)
    PlayerTab = Window:CreateTab("🏃 Player Hacks", 4483362458)
    GunTab    = Window:CreateTab("🔫 Gun Mods", 4483362458)
    ConfigTab = Window:CreateTab("💾 Config & Save", 4483362458)
    
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
    
    -- ==========================================
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
-- WADAH ELEMEN UI (Biar Gampang di-Reset/Save)
-- ==========================================
local Toggles = {}
local Sliders = {}
local Dropdowns = {}

-- ==========================================
-- 1. MENU MAIN FEATURES
-- ==========================================
Toggles.AntiAdmin = MainTab:CreateToggle({ Name = "🚨 Peringatan Admin (Popup Warning)", CurrentValue = false, Flag = "AntiAdminToggle", Callback = function(Value) AntiAdminAktif = Value end })
Toggles.Aimbot = MainTab:CreateToggle({ Name = "🎯 Aktifkan Auto Aim", CurrentValue = false, Flag = "AimbotToggle", Callback = function(Value) AimbotAktif = Value end })
Dropdowns.AimbotMode = MainTab:CreateDropdown({ Name = "⚙️ Mode Aimbot", Options = {"POV Kamera (FOV)", "360° (Brutal)"}, CurrentOption = "POV Kamera (FOV)", MultipleOptions = false, Flag = "AimbotModeList", Callback = function(Option) AimbotMode = Option[1] end })
Dropdowns.AimTarget = MainTab:CreateDropdown({ Name = "🎯 Target Bagian Tubuh", Options = {"Head", "Body"}, CurrentOption = "Head", MultipleOptions = false, Flag = "AimTarget", Callback = function(Option) AimTargetMode = Option[1] end })
Sliders.Smoothness = MainTab:CreateSlider({ Name = "🧲 Kelengketan Aim POV (Smoothness)", Range = {1, 100}, Increment = 1, Suffix = "%", CurrentValue = 15, Flag = "SmoothSlider", Callback = function(Value) AimbotSmoothness = Value end })
Toggles.FOV = MainTab:CreateToggle({ Name = "⭕ Tampilkan Lingkaran FOV", CurrentValue = false, Flag = "FOVTOGGLE", Callback = function(Value) ShowFOV = Value end })
Sliders.FOV = MainTab:CreateSlider({ Name = "📏 Lebar Lingkaran FOV", Range = {10, 600}, Increment = 5, Suffix = " Px", CurrentValue = 150, Flag = "FOVSlider", Callback = function(Value) FOVRadius = Value end })
Toggles.ESP = MainTab:CreateToggle({ Name = "👁️ Enemy ESP (Melihat Musuh)", CurrentValue = false, Flag = "ESPToggle", Callback = function(Value) ESPAktif = Value end })

-- ==========================================
-- 2. MENU PLAYER HACKS
-- ==========================================
Toggles.AntiFall = PlayerTab:CreateToggle({ Name = "🛡️ No Fall Damage", CurrentValue = false, Flag = "AntiFallToggle", Callback = function(Value) AntiFallDamageAktif = Value end })
Toggles.Speed = PlayerTab:CreateToggle({ Name = "⚡ Kecepatan Lari", CurrentValue = false, Flag = "SpeedToggle", Callback = function(Value) SpeedAktif = Value; if not Value and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.WalkSpeed = 16 end end })
Sliders.Speed = PlayerTab:CreateSlider({ Name = "⚙️ Set Speed", Range = {16, 250}, Increment = 1, Suffix = " Spd", CurrentValue = 50, Flag = "SpeedSlider", Callback = function(Value) CustomSpeed = Value end })
Toggles.Jump = PlayerTab:CreateToggle({ Name = "🚀 Lompat Tinggi", CurrentValue = false, Flag = "JumpToggle", Callback = function(Value) JumpAktif = Value; if not Value and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.UseJumpPower = true; LocalPlayer.Character.Humanoid.JumpPower = 50 end end })
Sliders.Jump = PlayerTab:CreateSlider({ Name = "⚙️ Set Power", Range = {50, 250}, Increment = 1, Suffix = " Pwr", CurrentValue = 100, Flag = "JumpSlider", Callback = function(Value) CustomJump = Value end })

-- ==========================================
-- 3. MENU GUN MODS
-- ==========================================
Toggles.GunMods = GunTab:CreateToggle({ Name = "🔫 Gun Mods", CurrentValue = false, Flag = "GunModsToggle", Callback = function(Value) GunModsAktif = Value end })
Sliders.FireRate = GunTab:CreateSlider({ Name = "⚡ RPM Fire Rate", Range = {400, 2500}, Increment = 50, Suffix = " RPM", CurrentValue = 800, Flag = "FireRateSlider", Callback = function(Value) CustomFireRate = Value end })

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

-- ==========================================
-- 🎯 LOGIKA AIMBOT (SMART FALLBACK + 360/POV)
-- ==========================================
local LockedTarget = nil

local function IsVisible(targetPart)
    if not targetPart then return false end
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    local rayResult = workspace:Raycast(Camera.CFrame.Position, (targetPart.Position - Camera.CFrame.Position).Unit * 5000, rayParams)
    return rayResult and rayResult.Instance:IsDescendantOf(targetPart.Parent) or false
end

local function GetDynamicTargetPart(char)
    if not char then return nil end
    local head = char:FindFirstChild("Head")
    local body = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("UpperTorso")
    if AimTargetMode == "Head" then
        if head and IsVisible(head) then return head end
        if body and IsVisible(body) then return body end
        return head or body
    elseif AimTargetMode == "Body" then
        if body and IsVisible(body) then return body end
        if head and IsVisible(head) then return head end 
        return body or head
    end
    return char:FindFirstChild("HumanoidRootPart")
end

local function GetNewTarget3D()
    local closest, shortestDist = nil, math.huge
    for _, item in pairs(ValidEntities) do
        local hum = item:FindFirstChildOfClass("Humanoid")
        if item.Parent and hum and hum.Health > 0 and IsEnemy(item) and not item:FindFirstChildOfClass("ForceField") then
            local targetPart = GetDynamicTargetPart(item)
            if targetPart and IsVisible(targetPart) then
                local dist = (Camera.CFrame.Position - targetPart.Position).Magnitude
                if dist < shortestDist then shortestDist = dist; closest = item end
            end
        end
    end
    return closest
end

local function GetClosestEnemy2D()
    local closest, shortestDist = nil, FOVRadius 
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    for _, item in pairs(ValidEntities) do
        local hum = item:FindFirstChildOfClass("Humanoid")
        if item.Parent and hum and hum.Health > 0 and IsEnemy(item) and not item:FindFirstChildOfClass("ForceField") then
            local targetPart = GetDynamicTargetPart(item)
            if targetPart and IsVisible(targetPart) then
                local pos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                if onScreen then
                    local dist = (center - Vector2.new(pos.X, pos.Y)).Magnitude
                    if dist < shortestDist then shortestDist = dist; closest = item end
                end
            end
        end
    end
    return closest
end

RunService.RenderStepped:Connect(function()
    if FOVFrame then
        FOVFrame.Size = UDim2.new(0, FOVRadius * 2, 0, FOVRadius * 2)
        FOVFrame.Visible = ShowFOV and AimbotAktif and (AimbotMode == "POV Kamera (FOV)")
    end

    if AimbotAktif then
        local targetValid = false
        local partToAim = nil

        if LockedTarget and LockedTarget.Parent then
            local hum = LockedTarget:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 and IsEnemy(LockedTarget) and not LockedTarget:FindFirstChildOfClass("ForceField") then
                partToAim = GetDynamicTargetPart(LockedTarget)
                if partToAim and IsVisible(partToAim) then
                    if AimbotMode == "POV Kamera (FOV)" then
                        local pos, onScreen = Camera:WorldToViewportPoint(partToAim.Position)
                        local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                        local dist = (center - Vector2.new(pos.X, pos.Y)).Magnitude
                        if onScreen and dist <= FOVRadius then
                            targetValid = true
                        end
                    else
                        targetValid = true
                    end
                end
            end
        end
        
        if not targetValid then
            if AimbotMode == "360° (Brutal)" then LockedTarget = GetNewTarget3D()
            elseif AimbotMode == "POV Kamera (FOV)" then LockedTarget = GetClosestEnemy2D() end
            if LockedTarget then partToAim = GetDynamicTargetPart(LockedTarget) end
        end
        
        if LockedTarget and partToAim then
            if AimbotMode == "360° (Brutal)" then
                Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, partToAim.Position)
            else
                local smoothFactor = AimbotSmoothness / 100
                Camera.CFrame = Camera.CFrame:Lerp(CFrame.lookAt(Camera.CFrame.Position, partToAim.Position), smoothFactor)
            end
        end
    else
        LockedTarget = nil
    end
end)

-- ==========================================
-- LOGIKA FISIKA & GUN MODS
-- ==========================================
pcall(function() local mt = getrawmetatable(game); if mt and mt.__index then local oldIndex = mt.__index; setreadonly(mt, false); mt.__index = newcclosure(function(t, k) if not checkcaller() and t:IsA("BasePart") and tostring(k) == "CanCollide" then return true end; return oldIndex(t, k) end); setreadonly(mt, true) end end)

RunService.Stepped:Connect(function()
    if LocalPlayer.Character then
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
        if hrp and AntiFallDamageAktif and hrp.Velocity.Y < -40 then local hit = workspace:Raycast(hrp.Position, Vector3.new(0, -20, 0), RaycastParams.new()); if hit then hrp.Velocity = Vector3.new(hrp.Velocity.X, -10, hrp.Velocity.Z) end end
        if hum then if SpeedAktif then hum.WalkSpeed = CustomSpeed end; if JumpAktif then hum.UseJumpPower = true; hum.JumpPower = CustomJump end end
    end
end)

RunService.RenderStepped:Connect(function()
    if not GunModsAktif then return end
    if LocalPlayer.Character then
        for _, tool in pairs(LocalPlayer.Character:GetChildren()) do
            if tool:IsA("Tool") or tool:IsA("Model") then pcall(function() local function SetSafe(attr, value) if tool:GetAttribute(attr) ~= nil and tool:GetAttribute(attr) ~= value then tool:SetAttribute(attr, value) end end; SetSafe("TotalAmmo", 999999999); SetSafe("NewMax", 999999999); SetSafe("magazineSize", 999999999); SetSafe("_ammo", 999999999); SetSafe("spread", 0); SetSafe("recoilMax", 0); SetSafe("recoilMin", 0); SetSafe("reloadTime", 0.05); SetSafe("rateOfFire", CustomFireRate) end) end
        end
    end
end)

task.spawn(function() pcall(function() for _, v in pairs(getgc(true)) do if type(v) == "table" and rawget(v, "recoil") and type(v.recoil) == "function" then local oldRecoil; oldRecoil = hookfunction(v.recoil, function(...) if GunModsAktif then return end; return oldRecoil(...) end) end end end) end)
end

-- ==========================================
-- WINDOW LOGIN (window terpisah, hanya untuk verifikasi key)
-- ==========================================

local LoginWindow = Rayfield:CreateWindow({
    Name = "🎯 VVIP MODS | Login",
    LoadingTitle = "VVIP MODS",
    LoadingSubtitle = "Memuat sistem verifikasi...",

    ConfigurationSaving = {
        Enabled = false
    },

    KeySystem = false
})

local LoginTab = LoginWindow:CreateTab("🔑 Login", 4483362458)

LoginTab:CreateSection("Verifikasi Key")

LoginTab:CreateParagraph({
    Title = "🎯 Selamat Datang",
    Content = "Masukkan key VVIP kamu di bawah ini, lalu tekan Login untuk membuka menu fitur."
})

LoginTab:CreateDivider()

LoginTab:CreateInput({
    Name = "Masukkan Key",
    PlaceholderText = "Contoh: RBLX-123",
    RemoveTextAfterFocusLost = false,
    Ext = true, -- Layout label di atas, form di bawah (full width)
    Callback = function(Text)
        UserKey = tostring(Text)
    end
})

LoginTab:CreateButton({
    Name = "🔓 Login",
    Callback = function()
        if LoggedIn then
            Rayfield:Notify({
                Title = "✅ Sudah Login",
                Content = "Anda sudah berhasil login.",
                Duration = 4,
                Image = 4483362458
            })
            return
        end

        Rayfield:Notify({
            Title = "⏳ Mengecek Key",
            Content = "Sedang memvalidasi key ke server...",
            Duration = 3,
            Image = 4483362458
        })

        local valid, message, data = VerifyKey(UserKey)

        if valid then
            LoggedIn = true

            SavedToken = data and data.token or nil
            SavedRng = data and data.rng or nil
            SavedExpired = data and (data.expired or data.EXPR) or nil
            SavedRegistrator = data and data.registrator or nil

            Rayfield:Notify({
                Title = "✅ Login Berhasil",
                Content = "Registrator: " .. tostring(SavedRegistrator or "-"),
                Duration = 4,
                Image = 4483362458
            })

            task.wait(1)
            OpenFeatureWindow()
        else
            LoggedIn = false

            Rayfield:Notify({
                Title = "❌ Login Gagal",
                Content = tostring(message),
                Duration = 5,
                Image = 4483362458
            })
        end
    end
})

LoginTab:CreateDivider()

LoginTab:CreateParagraph({
    Title = "ℹ️ Informasi",
    Content = "Key VVIP didapat dari admin/registrator resmi. Device ID kamu terkirim otomatis saat proses login."
})

