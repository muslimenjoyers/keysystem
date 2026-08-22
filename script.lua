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

--==================================================
-- VVIP MODS
-- CUSTOM GUI + AIM + ESP + VISUAL + CONFIG
-- ROBLOX STUDIO / GAME MILIK SENDIRI
--==================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

-- buat bypass
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ScriptContext = game:GetService("ScriptContext")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

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

--==================================================
-- CONFIGURATION
--==================================================

local GUI_NAME = "VVIPModsGUI"
local GUI_TITLE = "VVIP MODS"
local LOGO_ID = "rbxassetid://88882153085886"

local ICON_SIZE = 32
local EDGE_OFFSET = 45

local CONFIG_NAME = "VVIPMods_Config.json"

--==================================================
-- REMOVE OLD GUI
--==================================================

local OldGui = PlayerGui:FindFirstChild(GUI_NAME)

if OldGui then
	OldGui:Destroy()
end

--==================================================
-- SCREEN GUI
--==================================================

local ScreenGui = Instance.new("ScreenGui")

ScreenGui.Name = GUI_NAME
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

ScreenGui.Parent = PlayerGui

--==================================================
-- STATE
--==================================================

--==================================================
-- SAVED TELEPORT LOCATIONS
-- Synced from script lama11.txt
--==================================================

local SavedLocations = {}

local State = {

	-- AIM
	Aimbot = false,
	AimbotMode = "POV Kamera (FOV)",
	AimTarget = "Head",
	Smoothness = 15,
	ShowFOV = false,
	FOVRadius = 150,

	-- ESP
Distance360 = false,
NameDistance = false,

-- ESP TEAM / ENEMY
ESPTeam = false,
ESPEnemy = false,

-- VISUAL
Chams = false,
ChamsTeam = false,
ChamsEnemy = false,

Box = false,
Skeleton = false,
Tracer = false,
Health = false,

-- STYLE ESP (synced from script lama10.txt)
BoxStyle = "Corner Box",
TracerOrigin = "Top",
NameStyle = "Username",
Target = "All",

	-- PLAYER
	NoFallDamage = false,
	TPTeam = "Pilih Teman",
	TPEnemy = "Pilih Musuh",
	Speed = false,
	SpeedValue = 50,
	Jump = false,
	JumpValue = 100,
	Fly = false,
	FlySpeed = 50,
	Noclip = false,

	-- TELEPORT
	TeleportToolAktif = false,

	-- AUTO MACRO
	AutoMacro = false,

	-- CONFIG
	AutoLoad = false,
}

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



--==================================================
-- AUTO MACRO
-- Synced from script lama7.txt
-- Flow:
--   Shotgun/Sniper -> M-7 -> same weapon
-- Trigger:
--   Tool.Activated
-- Safe guards:
--   Character token, humanoid health, timeout, duplicate-run lock
--==================================================

local AutoMacroBusy = false
local AutoMacroCharacterToken = 0

local AutoMacroConnectedTools = {}
local AutoMacroCharacterConnection = nil
local AutoMacroBackpackAdded = nil
local AutoMacroBackpackRemoved = nil

local AUTO_MACRO_SWAP_TOOL = "M-7"

local AUTO_MACRO_TO_M7_DELAY = 0.05
local AUTO_MACRO_BACK_DELAY = 0.05

local AUTO_MACRO_TOOL_TIMEOUT = 5
local AUTO_MACRO_CHECK_INTERVAL = 0.05

local AUTO_MACRO_WEAPONS = {
	["870MCS"] = true,
	["870MCS W"] = true,
	["870MCS SILVER"] = true,

	["M1887"] = true,
	["M1887 W"] = true,
	["M1887 SILVER"] = true,
	["M1887 LIONHEART"] = true,
	["M1887 BRAZUCA"] = true,
	["M1887 PBNC5"] = true,

	["SPAS15"] = true,
	["SPAS15 BLUE DIAMOND"] = true,

	["ZOMBIE SLAYER"] = true,

	["SSG69"] = true,

	["CHEYTAC M200"] = true,
	["CHEYTAC M200 BLUE DIAMOND"] = true,
	["CHEYTAC M200 TURKEY"] = true,
	["CHEYTAC M200 BRAZUCA"] = true,
	["CHEYTAC M200 DEMONIC"] = true,
	["CHEYTAC M200 PBNC5"] = true,

	["TACTILITE T2"] = true,
	["TACTILITE T2 BLUE DIAMOND"] = true,
	["TACTILITE T2 GREEN"] = true,
	["TACTILITE T2 PEJUANG"] = true,

	["PGM HECATE2"] = true,

	["L115A1"] = true,
	["L115A1 E-SPORT"] = true,
	["BB L115A1 DRAGON"] = true,
}

local function AutoMacroDebug(...)
	print("[VVIP MODS][AUTO MACRO]", ...)
end

local function AutoMacroGetBackpack()
	local Backpack = LocalPlayer:FindFirstChildOfClass("Backpack")

	if Backpack then
		return Backpack
	end

	return LocalPlayer:WaitForChild("Backpack", 10)
end

local function AutoMacroIsTool(Tool)
	return Tool
		and Tool:IsA("Tool")
		and Tool.Parent ~= nil
end

local function AutoMacroFindTool(Name)
	local Character = LocalPlayer.Character

	if Character then
		local Tool = Character:FindFirstChild(Name)

		if AutoMacroIsTool(Tool) then
			return Tool
		end
	end

	local Backpack = AutoMacroGetBackpack()

	if Backpack then
		local Tool = Backpack:FindFirstChild(Name)

		if AutoMacroIsTool(Tool) then
			return Tool
		end
	end

	return nil
end

local function AutoMacroWaitForTool(
	Name,
	ExpectedCharacter,
	ExpectedToken,
	Timeout
)
	local Start = os.clock()
	Timeout = Timeout or AUTO_MACRO_TOOL_TIMEOUT

	while os.clock() - Start < Timeout do
		if not State.AutoMacro then
			return nil
		end

		if ExpectedCharacter
			and LocalPlayer.Character ~= ExpectedCharacter then
			return nil
		end

		if ExpectedToken ~= AutoMacroCharacterToken then
			return nil
		end

		local Tool = AutoMacroFindTool(Name)

		if Tool then
			return Tool
		end

		task.wait(AUTO_MACRO_CHECK_INTERVAL)
	end

	return nil
end

local function AutoMacroEquipTool(
	Tool,
	ExpectedCharacter,
	ExpectedToken
)
	if not AutoMacroIsTool(Tool) then
		return false
	end

	if not State.AutoMacro then
		return false
	end

	if LocalPlayer.Character ~= ExpectedCharacter then
		return false
	end

	if ExpectedToken ~= AutoMacroCharacterToken then
		return false
	end

	local Humanoid =
		ExpectedCharacter:FindFirstChildOfClass("Humanoid")

	if not Humanoid then
		return false
	end

	if Humanoid.Health <= 0 then
		return false
	end

	local Backpack = AutoMacroGetBackpack()

	if not Backpack then
		return false
	end

	if Tool.Parent ~= ExpectedCharacter
		and Tool.Parent ~= Backpack then
		return false
	end

	if Tool.Parent == ExpectedCharacter then
		return true
	end

	Humanoid:EquipTool(Tool)

	for _ = 1, 50 do
		task.wait(0.02)

		if not State.AutoMacro then
			return false
		end

		if LocalPlayer.Character ~= ExpectedCharacter then
			return false
		end

		if ExpectedToken ~= AutoMacroCharacterToken then
			return false
		end

		if Tool.Parent == ExpectedCharacter then
			return true
		end
	end

	return Tool.Parent == ExpectedCharacter
end

local function RunAutoMacro(Weapon)
	if not State.AutoMacro then
		return
	end

	if AutoMacroBusy then
		return
	end

	if not AutoMacroIsTool(Weapon) then
		return
	end

	if not AUTO_MACRO_WEAPONS[Weapon.Name] then
		return
	end

	local Character = LocalPlayer.Character

	if not Character then
		return
	end

	-- Hanya berjalan ketika weapon sedang equipped.
	if Weapon.Parent ~= Character then
		return
	end

	local Humanoid =
		Character:FindFirstChildOfClass("Humanoid")

	if not Humanoid then
		return
	end

	if Humanoid.Health <= 0 then
		return
	end

	local MyCharacter = Character
	local MyToken = AutoMacroCharacterToken
	local WeaponName = Weapon.Name

	AutoMacroBusy = true

	AutoMacroDebug("START:", WeaponName)

	task.spawn(function()
		local function IsValid()
			return State.AutoMacro
				and MyToken == AutoMacroCharacterToken
				and LocalPlayer.Character == MyCharacter
				and MyCharacter.Parent ~= nil
				and Humanoid.Health > 0
		end

		--==================================================
		-- WEAPON -> M-7
		--==================================================

		task.wait(AUTO_MACRO_TO_M7_DELAY)

		if not IsValid() then
			AutoMacroBusy = false
			return
		end

		local M7 =
			AutoMacroWaitForTool(
				AUTO_MACRO_SWAP_TOOL,
				MyCharacter,
				MyToken,
				AUTO_MACRO_TOOL_TIMEOUT
			)

		if not M7 then
			warn("[VVIP MODS][AUTO MACRO] M-7 tidak ditemukan")
			AutoMacroBusy = false
			return
		end

		if not AutoMacroEquipTool(
			M7,
			MyCharacter,
			MyToken
		) then
			warn("[VVIP MODS][AUTO MACRO] Gagal equip M-7")
			AutoMacroBusy = false
			return
		end

		AutoMacroDebug("WEAPON -> M-7")

		--==================================================
		-- M-7 -> WEAPON
		--==================================================

		task.wait(AUTO_MACRO_BACK_DELAY)

		if not IsValid() then
			AutoMacroBusy = false
			return
		end

		local CurrentWeapon =
			AutoMacroWaitForTool(
				WeaponName,
				MyCharacter,
				MyToken,
				AUTO_MACRO_TOOL_TIMEOUT
			)

		if not CurrentWeapon then
			warn(
				"[VVIP MODS][AUTO MACRO] Weapon tidak ditemukan:",
				WeaponName
			)
			AutoMacroBusy = false
			return
		end

		if not AutoMacroEquipTool(
			CurrentWeapon,
			MyCharacter,
			MyToken
		) then
			warn("[VVIP MODS][AUTO MACRO] Gagal kembali ke weapon")
			AutoMacroBusy = false
			return
		end

		AutoMacroDebug("M-7 ->", WeaponName)

		AutoMacroBusy = false
		AutoMacroDebug("SELESAI")
	end)
end

local function AutoMacroDisconnectTool(Tool)
	local Connection = AutoMacroConnectedTools[Tool]

	if Connection then
		Connection:Disconnect()
		AutoMacroConnectedTools[Tool] = nil
	end
end

local function AutoMacroDisconnectAllTools()
	for Tool, Connection in pairs(AutoMacroConnectedTools) do
		if Connection then
			Connection:Disconnect()
		end

		AutoMacroConnectedTools[Tool] = nil
	end
end

local function AutoMacroConnectWeapon(Tool)
	if not Tool then
		return
	end

	if not Tool:IsA("Tool") then
		return
	end

	if not AUTO_MACRO_WEAPONS[Tool.Name] then
		return
	end

	if AutoMacroConnectedTools[Tool] then
		return
	end

	AutoMacroConnectedTools[Tool] =
		Tool.Activated:Connect(function()
			if not State.AutoMacro then
				return
			end

			if Tool.Parent ~= LocalPlayer.Character then
				return
			end

			-- Jalankan setelah Activated selesai.
			task.defer(function()
				if not State.AutoMacro then
					return
				end

				if Tool.Parent == LocalPlayer.Character then
					RunAutoMacro(Tool)
				end
			end)
		end)

	AutoMacroDebug("CONNECTED:", Tool.Name)
end

local function AutoMacroScanTools()
	if not State.AutoMacro then
		return
	end

	local Character = LocalPlayer.Character

	if Character then
		for _, Child in ipairs(Character:GetChildren()) do
			if Child:IsA("Tool")
				and AUTO_MACRO_WEAPONS[Child.Name] then
				AutoMacroConnectWeapon(Child)
			end
		end
	end

	local Backpack = AutoMacroGetBackpack()

	if Backpack then
		for _, Child in ipairs(Backpack:GetChildren()) do
			if Child:IsA("Tool")
				and AUTO_MACRO_WEAPONS[Child.Name] then
				AutoMacroConnectWeapon(Child)
			end
		end
	end

	for Tool in pairs(AutoMacroConnectedTools) do
		if not Tool.Parent then
			AutoMacroDisconnectTool(Tool)
		elseif not AUTO_MACRO_WEAPONS[Tool.Name] then
			AutoMacroDisconnectTool(Tool)
		end
	end
end

local function AutoMacroWatchBackpack(Backpack)
	if AutoMacroBackpackAdded then
		AutoMacroBackpackAdded:Disconnect()
		AutoMacroBackpackAdded = nil
	end

	if AutoMacroBackpackRemoved then
		AutoMacroBackpackRemoved:Disconnect()
		AutoMacroBackpackRemoved = nil
	end

	if not Backpack then
		return
	end

	AutoMacroBackpackAdded =
		Backpack.ChildAdded:Connect(function(Child)
			if Child:IsA("Tool") then
				task.defer(function()
					AutoMacroConnectWeapon(Child)
					AutoMacroScanTools()
				end)
			end
		end)

	AutoMacroBackpackRemoved =
		Backpack.ChildRemoved:Connect(function(Child)
			if Child:IsA("Tool") then
				task.defer(AutoMacroScanTools)
			end
		end)

	AutoMacroScanTools()
end

local function AutoMacroWatchCharacter(Character)
	if AutoMacroCharacterConnection then
		AutoMacroCharacterConnection:Disconnect()
		AutoMacroCharacterConnection = nil
	end

	if not Character then
		return
	end

	AutoMacroCharacterConnection =
		Character.ChildAdded:Connect(function(Child)
			if Child:IsA("Tool") then
				task.defer(function()
					AutoMacroConnectWeapon(Child)
					AutoMacroScanTools()
				end)
			end
		end)

	AutoMacroScanTools()
end

local function AutoMacroInitializeCharacter(Character)
	if not Character then
		return
	end

	AutoMacroCharacterToken += 1
	AutoMacroBusy = false

	local Humanoid =
		Character:WaitForChild("Humanoid", 10)

	if not Humanoid then
		return
	end

	AutoMacroWatchBackpack(
		LocalPlayer:FindFirstChildOfClass("Backpack")
			or LocalPlayer:WaitForChild("Backpack", 10)
	)

	AutoMacroWatchCharacter(Character)

	task.spawn(function()
		for _ = 1, 50 do
			if LocalPlayer.Character ~= Character then
				return
			end

			AutoMacroScanTools()
			task.wait(0.1)
		end
	end)
end

LocalPlayer.CharacterAdded:Connect(function(Character)
	AutoMacroInitializeCharacter(Character)
end)

if LocalPlayer.Character then
	task.spawn(function()
		AutoMacroInitializeCharacter(LocalPlayer.Character)
	end)
end

task.spawn(function()
	local LastBackpack = nil

	while LocalPlayer.Parent do
		local Backpack = LocalPlayer:FindFirstChildOfClass("Backpack")

		if Backpack ~= LastBackpack then
			LastBackpack = Backpack

			if Backpack then
				AutoMacroWatchBackpack(Backpack)
			end
		end

		AutoMacroScanTools()
		task.wait(0.25)
	end
end)


--==================================================
-- PLAYER FEATURE RUNTIME
-- Synced from the old Player Hacks section
--==================================================

local BodyVelocity = nil
local BodyGyro = nil

local function StopFly()
	if BodyVelocity then
		BodyVelocity:Destroy()
		BodyVelocity = nil
	end

	if BodyGyro then
		BodyGyro:Destroy()
		BodyGyro = nil
	end

	local Character = LocalPlayer.Character
	local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")

	if Humanoid then
		Humanoid.PlatformStand = false
		Humanoid.AutoRotate = true
	end
end

local function ApplyPlayerState()
	local Character = LocalPlayer.Character
	local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")

	if not Humanoid then
		return
	end

	if State.Speed then
		Humanoid.WalkSpeed = State.SpeedValue
	else
		Humanoid.WalkSpeed = 16
	end

	if State.Jump then
		Humanoid.UseJumpPower = true
		Humanoid.JumpPower = State.JumpValue
	else
		Humanoid.UseJumpPower = true
		Humanoid.JumpPower = 50
	end

	if not State.Fly then
		StopFly()
	end
end

LocalPlayer.CharacterAdded:Connect(function(Character)
	task.wait(0.25)
	ApplyPlayerState()
end)

--==================================================
-- FLY INPUT
--==================================================

local FlyKeys = {
	Forward = false,
	Backward = false,
	Left = false,
	Right = false,
	Up = false,
	Down = false
}

UserInputService.InputBegan:Connect(function(Input, GameProcessed)

	if GameProcessed then
		return
	end

	if Input.KeyCode == Enum.KeyCode.W then
		FlyKeys.Forward = true

	elseif Input.KeyCode == Enum.KeyCode.S then
		FlyKeys.Backward = true

	elseif Input.KeyCode == Enum.KeyCode.A then
		FlyKeys.Left = true

	elseif Input.KeyCode == Enum.KeyCode.D then
		FlyKeys.Right = true

	elseif Input.KeyCode == Enum.KeyCode.Space then
		FlyKeys.Up = true

	elseif Input.KeyCode == Enum.KeyCode.LeftControl then
		FlyKeys.Down = true
	end
end)

UserInputService.InputEnded:Connect(function(Input)

	if Input.KeyCode == Enum.KeyCode.W then
		FlyKeys.Forward = false

	elseif Input.KeyCode == Enum.KeyCode.S then
		FlyKeys.Backward = false

	elseif Input.KeyCode == Enum.KeyCode.A then
		FlyKeys.Left = false

	elseif Input.KeyCode == Enum.KeyCode.D then
		FlyKeys.Right = false

	elseif Input.KeyCode == Enum.KeyCode.Space then
		FlyKeys.Up = false

	elseif Input.KeyCode == Enum.KeyCode.LeftControl then
		FlyKeys.Down = false
	end
end)

--==================================================
-- MOBILE FLY JOYSTICK + UP DOWN
--==================================================

local FlyJoystick = Instance.new("Frame")
FlyJoystick.Name = "FlyJoystick"
FlyJoystick.Size = UDim2.fromOffset(120,120)
FlyJoystick.Position = UDim2.new(0,20,1,-140)
FlyJoystick.BackgroundColor3 = Color3.fromRGB(0,0,0)
FlyJoystick.BackgroundTransparency = 0.4
FlyJoystick.Visible = false
FlyJoystick.ZIndex = 300
FlyJoystick.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(1,0)
Corner.Parent = FlyJoystick

local Stick = Instance.new("Frame")
Stick.Name = "Stick"
Stick.Size = UDim2.fromOffset(50,50)
Stick.Position = UDim2.new(0.5,-25,0.5,-25)
Stick.AnchorPoint = Vector2.new(0.5,0.5)
Stick.BackgroundColor3 = Color3.fromRGB(255,255,255)
Stick.BackgroundTransparency = 0.2
Stick.ZIndex = 301
Stick.Parent = FlyJoystick

local StickCorner = Instance.new("UICorner")
StickCorner.CornerRadius = UDim.new(1,0)
StickCorner.Parent = Stick

-- Tombol Naik Turun
local FlyUpBtn = Instance.new("TextButton")
FlyUpBtn.Size = UDim2.fromOffset(55,55)
FlyUpBtn.Position = UDim2.new(1,-70,1,-140)
FlyUpBtn.Text = "▲"
FlyUpBtn.Font = Enum.Font.GothamBold
FlyUpBtn.TextSize = 24
FlyUpBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
FlyUpBtn.TextColor3 = Color3.fromRGB(255,255,255)
FlyUpBtn.ZIndex = 300
FlyUpBtn.Visible = false -- TAMBAH INI
FlyUpBtn.Parent = ScreenGui
Instance.new("UICorner", FlyUpBtn)

local FlyDownBtn = Instance.new("TextButton")
FlyDownBtn.Size = UDim2.fromOffset(55,55)
FlyDownBtn.Position = UDim2.new(1,-70,1,-80)
FlyDownBtn.Text = "▼"
FlyDownBtn.Font = Enum.Font.GothamBold
FlyDownBtn.TextSize = 24
FlyDownBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
FlyDownBtn.TextColor3 = Color3.fromRGB(255,255,255)
FlyDownBtn.ZIndex = 300
FlyDownBtn.Visible = false -- TAMBAH INI
FlyDownBtn.Parent = ScreenGui
Instance.new("UICorner", FlyDownBtn)

-- Variabel joystick
local JoystickActive = false
local JoystickStartPos = Vector2.new(0,0)
local JoystickCurrentPos = Vector2.new(0,0)
local JOYSTICK_RADIUS = 50

FlyJoystick.InputBegan:Connect(function(Input)
	if Input.UserInputType == Enum.UserInputType.Touch then
		JoystickActive = true
		JoystickStartPos = Input.Position
	end
end)

FlyJoystick.InputChanged:Connect(function(Input)
	if JoystickActive and Input.UserInputType == Enum.UserInputType.Touch then
		JoystickCurrentPos = Input.Position
		local Delta = JoystickCurrentPos - JoystickStartPos
		local Distance = math.min(Delta.Magnitude, JOYSTICK_RADIUS)
		local Direction = Delta.Unit
		Stick.Position = UDim2.new(0.5, Direction.X * Distance, 0.5, Direction.Y * Distance)
	end
end)

FlyJoystick.InputEnded:Connect(function(Input)
	if Input.UserInputType == Enum.UserInputType.Touch then
		JoystickActive = false
		Stick.Position = UDim2.new(0.5,-25,0.5,-25)
	end
end)

-- Tombol Up Down
FlyUpBtn.InputBegan:Connect(function(Input) if Input.UserInputType == Enum.UserInputType.Touch then FlyKeys.Up = true end end)
FlyUpBtn.InputEnded:Connect(function(Input) if Input.UserInputType == Enum.UserInputType.Touch then FlyKeys.Up = false end end)
FlyDownBtn.InputBegan:Connect(function(Input) if Input.UserInputType == Enum.UserInputType.Touch then FlyKeys.Down = true end end)
FlyDownBtn.InputEnded:Connect(function(Input) if Input.UserInputType == Enum.UserInputType.Touch then FlyKeys.Down = false end end)

--==================================================
-- COLORS
--==================================================

local COLORS = {

	Background = Color3.fromRGB(20,20,20),
	Header = Color3.fromRGB(28,28,28),
	Control = Color3.fromRGB(40,40,40),

	Text = Color3.fromRGB(255,255,255),
	SubText = Color3.fromRGB(180,180,180),

	Accent = Color3.fromRGB(50,255,50),
	Off = Color3.fromRGB(255,50,50),

	Border = Color3.fromRGB(70,70,70),

	Enemy = Color3.fromRGB(255,50,50),
	Ally = Color3.fromRGB(50,255,50),
}

--==================================================
-- MAIN FRAME
--==================================================

local MainFrame = Instance.new("Frame")

MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.fromOffset(300,390)

MainFrame.Position = UDim2.new(
	0.5,
	-150,
	0.5,
	-195
)

MainFrame.BackgroundColor3 = COLORS.Background
MainFrame.BorderSizePixel = 0
MainFrame.ZIndex = 100
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0,12)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Thickness = 1
MainStroke.Color = COLORS.Border
MainStroke.Transparency = 0.2
MainStroke.Parent = MainFrame

--==================================================
-- HEADER
--==================================================

local Header = Instance.new("Frame")

Header.Name = "Header"
Header.Size = UDim2.new(1,0,0,42)

Header.BackgroundColor3 = COLORS.Header
Header.BorderSizePixel = 0
Header.ZIndex = 101
Header.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0,12)
HeaderCorner.Parent = Header

--==================================================
-- TITLE
--==================================================

local Title = Instance.new("TextLabel")

Title.Size = UDim2.new(1,-80,1,0)
Title.Position = UDim2.fromOffset(15,0)

Title.BackgroundTransparency = 1
Title.Text = GUI_TITLE
Title.TextColor3 = COLORS.Text

Title.Font = Enum.Font.GothamBold
Title.TextSize = 15
Title.TextXAlignment = Enum.TextXAlignment.Left

Title.ZIndex = 102
Title.Parent = Header

--==================================================
-- MINIMIZE
--==================================================

local MinimizeButton = Instance.new("TextButton")

MinimizeButton.Name = "MinimizeButton"
MinimizeButton.Size = UDim2.fromOffset(32,32)
MinimizeButton.Position = UDim2.new(1,-68,0,5)

MinimizeButton.BackgroundColor3 = COLORS.Control
MinimizeButton.BorderSizePixel = 0

MinimizeButton.Text = "—"
MinimizeButton.TextColor3 = COLORS.Text
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.TextSize = 18

MinimizeButton.ZIndex = 103
MinimizeButton.Parent = Header

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0,8)
MinCorner.Parent = MinimizeButton

--==================================================
-- CLOSE
--==================================================

local CloseButton = Instance.new("TextButton")

CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.fromOffset(32,32)
CloseButton.Position = UDim2.new(1,-34,0,5)

CloseButton.BackgroundColor3 = COLORS.Control
CloseButton.BorderSizePixel = 0

CloseButton.Text = "×"
CloseButton.TextColor3 = COLORS.Text
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 18

CloseButton.ZIndex = 103
CloseButton.Parent = Header

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0,8)
CloseCorner.Parent = CloseButton

--==================================================
-- OPEN LOGO
--==================================================

local OpenButton = Instance.new("ImageButton")

OpenButton.Name = "OpenButton"
OpenButton.Size = UDim2.fromOffset(55,55)

OpenButton.Position = UDim2.new(
	0.5,
	-27,
	0.5,
	-27
)

OpenButton.BackgroundTransparency = 1
OpenButton.BorderSizePixel = 0

OpenButton.Image = LOGO_ID
OpenButton.ScaleType = Enum.ScaleType.Fit

OpenButton.Visible = false
OpenButton.ZIndex = 200
OpenButton.Parent = ScreenGui

--==================================================
-- LOGIN KEY / AUTHENTICATION
-- Synced from script lama6.txt
--==================================================

local UserKey = ""
local LoggedIn = false
local SavedToken = nil
local SavedRng = nil
local SavedExpired = nil
local SavedRegistrator = nil

-- Hide the feature GUI until authentication succeeds.
MainFrame.Visible = false
OpenButton.Visible = false

local LoginGui = Instance.new("ScreenGui")
LoginGui.Name = "VVIPModsLogin"
LoginGui.ResetOnSpawn = false
LoginGui.IgnoreGuiInset = true
LoginGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
LoginGui.Parent = PlayerGui

local LoginFrame = Instance.new("Frame")
LoginFrame.Size = UDim2.fromOffset(320, 220)
LoginFrame.Position = UDim2.new(0.5, -160, 0.5, -110)
LoginFrame.BackgroundColor3 = COLORS.Background
LoginFrame.BorderSizePixel = 0
LoginFrame.ZIndex = 500
LoginFrame.Parent = LoginGui
Instance.new("UICorner", LoginFrame).CornerRadius = UDim.new(0, 12)

local LoginStroke = Instance.new("UIStroke")
LoginStroke.Color = COLORS.Border
LoginStroke.Thickness = 1
LoginStroke.Parent = LoginFrame

local LoginTitle = Instance.new("TextLabel")
LoginTitle.Size = UDim2.new(1, -24, 0, 35)
LoginTitle.Position = UDim2.fromOffset(12, 10)
LoginTitle.BackgroundTransparency = 1
LoginTitle.Text = "🔑 VVIP MODS | LOGIN"
LoginTitle.TextColor3 = COLORS.Text
LoginTitle.Font = Enum.Font.GothamBold
LoginTitle.TextSize = 15
LoginTitle.ZIndex = 501
LoginTitle.Parent = LoginFrame

local LoginInfo = Instance.new("TextLabel")
LoginInfo.Size = UDim2.new(1, -24, 0, 34)
LoginInfo.Position = UDim2.fromOffset(12, 45)
LoginInfo.BackgroundTransparency = 1
LoginInfo.Text = "Masukkan key VVIP kamu untuk membuka menu."
LoginInfo.TextColor3 = COLORS.SubText
LoginInfo.Font = Enum.Font.Gotham
LoginInfo.TextSize = 10
LoginInfo.TextWrapped = true
LoginInfo.ZIndex = 501
LoginInfo.Parent = LoginFrame

local KeyBox = Instance.new("TextBox")
KeyBox.Size = UDim2.new(1, -24, 0, 38)
KeyBox.Position = UDim2.fromOffset(12, 86)
KeyBox.BackgroundColor3 = COLORS.Control
KeyBox.BorderSizePixel = 0
KeyBox.PlaceholderText = "Masukkan Key"
KeyBox.PlaceholderColor3 = COLORS.SubText
KeyBox.Text = ""
KeyBox.TextColor3 = COLORS.Text
KeyBox.Font = Enum.Font.Gotham
KeyBox.TextSize = 11
KeyBox.ClearTextOnFocus = false
KeyBox.ZIndex = 501
KeyBox.Parent = LoginFrame
Instance.new("UICorner", KeyBox).CornerRadius = UDim.new(0, 8)

local LoginButton = Instance.new("TextButton")
LoginButton.Size = UDim2.new(1, -24, 0, 38)
LoginButton.Position = UDim2.fromOffset(12, 132)
LoginButton.BackgroundColor3 = COLORS.Accent
LoginButton.BorderSizePixel = 0
LoginButton.Text = "🔓 LOGIN"
LoginButton.TextColor3 = Color3.fromRGB(0,0,0)
LoginButton.Font = Enum.Font.GothamBold
LoginButton.TextSize = 11
LoginButton.ZIndex = 501
LoginButton.Parent = LoginFrame
Instance.new("UICorner", LoginButton).CornerRadius = UDim.new(0, 8)

local LoginStatus = Instance.new("TextLabel")
LoginStatus.Size = UDim2.new(1, -24, 0, 32)
LoginStatus.Position = UDim2.fromOffset(12, 178)
LoginStatus.BackgroundTransparency = 1
LoginStatus.Text = ""
LoginStatus.TextColor3 = COLORS.SubText
LoginStatus.Font = Enum.Font.Gotham
LoginStatus.TextSize = 10
LoginStatus.TextWrapped = true
LoginStatus.ZIndex = 501
LoginStatus.Parent = LoginFrame

local function SetLoginStatus(text, success)
    LoginStatus.Text = tostring(text)
    LoginStatus.TextColor3 = success and COLORS.Accent or COLORS.Off
end

LoginButton.Activated:Connect(function()
    if LoggedIn then
        return
    end

    UserKey = tostring(KeyBox.Text or "")

    if UserKey == "" then
        SetLoginStatus("❌ Key tidak boleh kosong.", false)
        return
    end

    LoginButton.Text = "⏳ MEMERIKSA..."
    LoginButton.Active = false
    SetLoginStatus("Sedang memvalidasi key ke server...", true)

    task.spawn(function()
        local valid, message, data = VerifyKey(UserKey)

        if valid then
            LoggedIn = true
            SavedToken = data and data.token or nil
            SavedRng = data and data.rng or nil
            SavedExpired = data and (data.expired or data.EXPR) or nil
            SavedRegistrator = data and data.registrator or nil

            SetLoginStatus(
                "✅ Login berhasil" ..
                (SavedRegistrator and (" | Registrator: " .. tostring(SavedRegistrator)) or ""),
                true
            )

            task.wait(0.75)

            LoginGui:Destroy()
            MainFrame.Visible = true
        else
            LoggedIn = false
            SetLoginStatus("❌ " .. tostring(message), false)
            LoginButton.Text = "🔓 LOGIN"
            LoginButton.Active = true
        end
    end)
end)




--==================================================
-- LOGO DRAG
--==================================================

local LogoDragging = false
local LogoDragStart
local LogoStartPosition

OpenButton.InputBegan:Connect(function(Input)

	if Input.UserInputType == Enum.UserInputType.MouseButton1
		or Input.UserInputType == Enum.UserInputType.Touch then

		LogoDragging = true
		LogoDragStart = Input.Position
		LogoStartPosition = OpenButton.Position
	end

end)

UserInputService.InputChanged:Connect(function(Input)

	if not LogoDragging then
		return
	end

	if Input.UserInputType ~= Enum.UserInputType.MouseMovement
		and Input.UserInputType ~= Enum.UserInputType.Touch then
		return
	end

	local Delta = Input.Position - LogoDragStart

	OpenButton.Position = UDim2.new(
		LogoStartPosition.X.Scale,
		LogoStartPosition.X.Offset + Delta.X,

		LogoStartPosition.Y.Scale,
		LogoStartPosition.Y.Offset + Delta.Y
	)

end)

UserInputService.InputEnded:Connect(function(Input)

	if Input.UserInputType == Enum.UserInputType.MouseButton1
		or Input.UserInputType == Enum.UserInputType.Touch then

		LogoDragging = false
	end

end)

--==================================================
-- TAB BAR
--==================================================

local TabButtons = Instance.new("Frame")

TabButtons.Size = UDim2.new(1,-20,0,30)
TabButtons.Position = UDim2.fromOffset(10,47)
TabButtons.BackgroundTransparency = 1
TabButtons.Parent = MainFrame

local TabLayout = Instance.new("UIListLayout")

TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.Padding = UDim.new(0,5)
TabLayout.Parent = TabButtons

--==================================================
-- PAGES
--==================================================

local Pages = Instance.new("Frame")

Pages.Size = UDim2.new(1,-20,1,-87)
Pages.Position = UDim2.fromOffset(10,82)
Pages.BackgroundTransparency = 1
Pages.Parent = MainFrame

--==================================================
-- TAB SYSTEM
--==================================================

local TabData = {}
local CurrentTab = nil

local function CreateTab(Name)

	local Button = Instance.new("TextButton")
Button.Size = UDim2.new(0.2,-4,1,0) -- 0.2 = 20% x 5 tab = 100% pas
Button.BackgroundColor3 = COLORS.Control
Button.Text = Name
Button.TextColor3 = COLORS.Text
Button.Font = Enum.Font.GothamBold
Button.TextSize = 11
Button.ZIndex = 103
Button.Parent = TabButtons
Instance.new("UICorner", Button).CornerRadius = UDim.new(0,8)

	local Page = Instance.new("ScrollingFrame")

	Page.Size = UDim2.new(1,0,1,0)

	Page.BackgroundTransparency = 1
	Page.BorderSizePixel = 0

	Page.ScrollBarThickness = 4
	Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
	Page.CanvasSize = UDim2.fromOffset(0,0)

	Page.Visible = false
	Page.ZIndex = 101
	Page.Parent = Pages

	local PageLayout = Instance.new("UIListLayout")

	PageLayout.Padding = UDim.new(0,5)
	PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
	PageLayout.Parent = Page

	TabData[Name] = {
		Button = Button,
		Page = Page
	}

	Button.Activated:Connect(function()

		if CurrentTab then
			CurrentTab.Page.Visible = false
			CurrentTab.Button.BackgroundColor3 = COLORS.Control
		end

		CurrentTab = TabData[Name]

		CurrentTab.Page.Visible = true
		CurrentTab.Button.BackgroundColor3 = COLORS.Accent

	end)

	return Page
end

--==================================================
-- SECTION
--==================================================

local function CreateSection(Text, Parent, DefaultOpen)

	local Folder = Instance.new("Frame")

	Folder.Size = UDim2.new(1,0,0,32)
	Folder.BackgroundTransparency = 1
	Folder.ZIndex = 102
	Folder.Parent = Parent

	local Button = Instance.new("TextButton")

	Button.Size = UDim2.new(1,0,0,32)

	Button.BackgroundColor3 = COLORS.Header
	Button.Text = ""

	Button.ZIndex = 103
	Button.Parent = Folder

	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(0,8)
	Corner.Parent = Button

	local Label = Instance.new("TextLabel")

	Label.Size = UDim2.new(1,-35,1,0)
	Label.Position = UDim2.fromOffset(12,0)

	Label.BackgroundTransparency = 1
	Label.Text = Text

	Label.TextColor3 = COLORS.Accent
	Label.Font = Enum.Font.GothamBold
	Label.TextSize = 12
	Label.TextXAlignment = Enum.TextXAlignment.Left

	Label.ZIndex = 104
	Label.Parent = Button

	local Arrow = Instance.new("TextLabel")

	Arrow.Size = UDim2.fromOffset(20,20)
	Arrow.Position = UDim2.new(1,-25,0.5,-10)

	Arrow.BackgroundTransparency = 1
	Arrow.Text = "▶"
	Arrow.TextColor3 = COLORS.Text

	Arrow.Font = Enum.Font.GothamBold
	Arrow.TextSize = 14

	Arrow.ZIndex = 104
	Arrow.Parent = Button

	local ContentFolder = Instance.new("Frame")

	ContentFolder.Size = UDim2.new(1,0,0,0)
	ContentFolder.Position = UDim2.fromOffset(0,32)

	ContentFolder.BackgroundTransparency = 1
	ContentFolder.Visible = false

	ContentFolder.ZIndex = 102
	ContentFolder.Parent = Folder

	local FolderLayout = Instance.new("UIListLayout")

	FolderLayout.Padding = UDim.new(0,3)
	FolderLayout.Parent = ContentFolder

	local Open = DefaultOpen == true

	local function UpdateSize()

		if Open then

			local Height =
				FolderLayout.AbsoluteContentSize.Y

			ContentFolder.Size =
				UDim2.new(1,0,0,Height)

			Folder.Size =
				UDim2.new(1,0,0,32 + Height)

		else

			Folder.Size =
				UDim2.new(1,0,0,32)
		end
	end

	FolderLayout:GetPropertyChangedSignal(
		"AbsoluteContentSize"
	):Connect(UpdateSize)

	Button.Activated:Connect(function()

		Open = not Open

		ContentFolder.Visible = Open
		Arrow.Text = Open and "▼" or "▶"

		UpdateSize()

	end)

	ContentFolder.Visible = Open
	Arrow.Text = Open and "▼" or "▶"
	UpdateSize()

	return ContentFolder
end

--==================================================
-- TOGGLES
--==================================================

local ToggleObjects = {}

local function CreateToggle(Name, Key, Parent)

	local Button = Instance.new("TextButton")

	Button.Size = UDim2.new(1,0,0,40)

	Button.BackgroundColor3 = COLORS.Control
	Button.Text = ""
	Button.AutoButtonColor = false

	Button.ZIndex = 102
	Button.Parent = Parent

	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(0,8)
	Corner.Parent = Button

	local Label = Instance.new("TextLabel")

	Label.Size = UDim2.new(1,-75,1,0)
	Label.Position = UDim2.fromOffset(12,0)

	Label.BackgroundTransparency = 1
	Label.Text = Name

	Label.TextColor3 = COLORS.Text
	Label.Font = Enum.Font.GothamMedium
	Label.TextSize = 12
	Label.TextXAlignment = Enum.TextXAlignment.Left

	Label.ZIndex = 103
	Label.Parent = Button

	local Status = Instance.new("TextLabel")

	Status.Size = UDim2.fromOffset(55,26)
	Status.Position = UDim2.new(1,-62,0.5,-13)

	Status.Font = Enum.Font.GothamBold
	Status.TextSize = 11

	Status.ZIndex = 103
	Status.Parent = Button

	local StatusCorner = Instance.new("UICorner")
	StatusCorner.CornerRadius = UDim.new(0,7)
	StatusCorner.Parent = Status

	local function Refresh()

		if State[Key] then

			Status.Text = "ON"
			Status.TextColor3 = Color3.fromRGB(0,0,0)
			Status.BackgroundColor3 = COLORS.Accent

		else

			Status.Text = "OFF"
			Status.TextColor3 = COLORS.Text
			Status.BackgroundColor3 = COLORS.Off

		end

	end

	Button.Activated:Connect(function()

	State[Key] = not State[Key]

	if Key == "Fly" then
	FlyJoystick.Visible = State.Fly
	FlyUpBtn.Visible = State.Fly
	FlyDownBtn.Visible = State.Fly
	GuiService.TouchControlsEnabled = not State.Fly -- MATIIN JOYSTICK DEFAULT
	if not State.Fly then
		for FlyKey in pairs(FlyKeys) do FlyKeys[FlyKey] = false end
	JoystickActive = false
	end
end

	if Key == "Speed"
		or Key == "Jump"
		or Key == "Fly" then

		ApplyPlayerState()

	end

	Refresh()

end)

	ToggleObjects[Key] = {
		Refresh = Refresh
	}

	Refresh()

	return Button
end

--==================================================
-- BUTTON
--==================================================

local function CreateButton(Name, Parent, Callback)
	local Button = Instance.new("TextButton")
	Button.Size = UDim2.new(1,0,0,40)
	Button.BackgroundColor3 = COLORS.Control
	Button.Text = Name
	Button.TextColor3 = COLORS.Text
	Button.Font = Enum.Font.GothamBold
	Button.TextSize = 11
	Button.AutoButtonColor = true
	Button.ZIndex = 103
	Button.Parent = Parent
	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(0,8)
	Corner.Parent = Button
	Button.Activated:Connect(function() if Callback then Callback() end end)
	return Button
end


--==================================================
-- DROPDOWN
--==================================================

local DropdownObjects = {}

local function CreateDropdown(Name, Key, Options, Parent)

	local Holder = Instance.new("Frame")

	Holder.Size = UDim2.new(1,0,0,55)
	Holder.BackgroundTransparency = 1
	Holder.Parent = Parent

	local Label = Instance.new("TextLabel")

	Label.Size = UDim2.new(1,0,0,20)

	Label.BackgroundTransparency = 1
	Label.Text = Name

	Label.TextColor3 = COLORS.Text
	Label.Font = Enum.Font.GothamMedium
	Label.TextSize = 11

	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Parent = Holder

	local Button = Instance.new("TextButton")

	Button.Size = UDim2.new(1,0,0,32)
	Button.Position = UDim2.fromOffset(0,21)

	Button.BackgroundColor3 = COLORS.Control
	Button.TextColor3 = COLORS.Text

	Button.Font = Enum.Font.GothamMedium
	Button.TextSize = 11

	Button.Parent = Holder

	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(0,8)
	Corner.Parent = Button

	--==================================================
	-- FIND CURRENT OPTION
	--==================================================

	local Index = 1

	local function FindOptionIndex(Value)

		for i, Option in ipairs(Options) do

			if Option == Value then
				return i
			end

		end

		return nil
	end

	--==================================================
	-- REFRESH
	--==================================================

	local function Refresh()

		local FoundIndex =
			FindOptionIndex(State[Key])

		-- Jika value dari config/reset tidak valid,
		-- gunakan option pertama.
		if not FoundIndex then

			Index = 1
			State[Key] = Options[Index]

		else

			Index = FoundIndex

		end

		Button.Text =
			tostring(State[Key])

	end

	--==================================================
	-- CLICK
	--==================================================

	Button.Activated:Connect(function()

		Index += 1

		if Index > #Options then
			Index = 1
		end

		State[Key] =
			Options[Index]

		Refresh()


	end)

	--==================================================
	-- REGISTER
	--==================================================

	local function SetOptions(NewOptions)
		if type(NewOptions) ~= "table" or #NewOptions == 0 then return end
		Options = NewOptions
		Index = 1
		State[Key] = Options[1]
		Refresh()
	end

	DropdownObjects[Key] = {
		Refresh = Refresh,
		SetOptions = SetOptions
	}

	-- Initial refresh
	Refresh()

	return Holder
end

--==================================================
-- SLIDER
--==================================================

local SliderObjects = {}

local function CreateSlider(Name, Key, Min, Max, Parent)

	local Holder = Instance.new("Frame")

	Holder.Size = UDim2.new(1,0,0,55)
	Holder.BackgroundTransparency = 1
	Holder.Parent = Parent

	local Label = Instance.new("TextLabel")

	Label.Size = UDim2.new(1,-50,0,20)

	Label.BackgroundTransparency = 1
	Label.TextColor3 = COLORS.Text

	Label.Font = Enum.Font.GothamMedium
	Label.TextSize = 11

	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Parent = Holder

	local ValueLabel = Instance.new("TextLabel")

	ValueLabel.Size = UDim2.fromOffset(50,20)
	ValueLabel.Position = UDim2.new(1,-50,0,0)

	ValueLabel.BackgroundTransparency = 1
	ValueLabel.TextColor3 = COLORS.Accent

	ValueLabel.Font = Enum.Font.GothamBold
	ValueLabel.TextSize = 11

	ValueLabel.Parent = Holder

	local Bar = Instance.new("Frame")

	Bar.Size = UDim2.new(1,0,0,8)
	Bar.Position = UDim2.fromOffset(0,30)

	Bar.BackgroundColor3 = COLORS.Control
	Bar.BorderSizePixel = 0

	Bar.Parent = Holder

	local BarCorner = Instance.new("UICorner")
	BarCorner.CornerRadius = UDim.new(1,0)
	BarCorner.Parent = Bar

	local Fill = Instance.new("Frame")

	Fill.BackgroundColor3 = COLORS.Accent
	Fill.BorderSizePixel = 0

	Fill.Size = UDim2.new(0,0,1,0)
	Fill.Parent = Bar

	local FillCorner = Instance.new("UICorner")
	FillCorner.CornerRadius = UDim.new(1,0)
	FillCorner.Parent = Fill

	local DraggingSlider = false

	local function SetValue(Value)

		Value = math.clamp(Value,Min,Max)

		State[Key] = math.floor(Value)

		if Key == "SpeedValue" or Key == "JumpValue" then
			ApplyPlayerState()
		end

		local Alpha =
			(State[Key] - Min) /
			(Max - Min)

		Fill.Size =
			UDim2.new(Alpha,0,1,0)

		Label.Text = Name
		ValueLabel.Text = tostring(State[Key])

	end

	local function Update(Input)

		local Relative =
			(Input.Position.X - Bar.AbsolutePosition.X) /
			Bar.AbsoluteSize.X

		Relative = math.clamp(Relative,0,1)

		SetValue(
			Min + (Max-Min) * Relative
		)

	end

	Bar.InputBegan:Connect(function(Input)

		if Input.UserInputType == Enum.UserInputType.MouseButton1
			or Input.UserInputType == Enum.UserInputType.Touch then

			DraggingSlider = true
			Update(Input)

		end

	end)

	UserInputService.InputChanged:Connect(function(Input)

		if not DraggingSlider then
			return
		end

		if Input.UserInputType == Enum.UserInputType.MouseMovement
			or Input.UserInputType == Enum.UserInputType.Touch then

			Update(Input)

		end

	end)

	UserInputService.InputEnded:Connect(function(Input)

		if Input.UserInputType == Enum.UserInputType.MouseButton1
			or Input.UserInputType == Enum.UserInputType.Touch then

			DraggingSlider = false

		end

	end)

	SliderObjects[Key] = {
		Set = SetValue
	}

	SetValue(State[Key])

	return Holder
end

--==================================================
-- TABS
--==================================================

local ESPPage = CreateTab("ESP")
local VISUALPage = CreateTab("VISUAL")
local AIMPage = CreateTab("AIM")
local PLAYERPage = CreateTab("PLAYER")
local MISCPage = CreateTab("MISC")

--==================================================
-- ESP TAB
--==================================================

local ESPFolder =
	CreateSection("👁️ ESP FEATURES", ESPPage)
	
CreateToggle(
	"🟢 ESP TEAM",
	"ESPTeam",
	ESPFolder
)

CreateToggle(
	"🔴 ESP MUSUH",
	"ESPEnemy",
	ESPFolder
)

CreateToggle(
	"360° Distance",
	"Distance360",
	ESPFolder
)

CreateToggle(
	"📝 Name + Distance",
	"NameDistance",
	ESPFolder
)

--==================================================
-- VISUAL TAB
--==================================================

local VisualFolder =
	CreateSection("🎨 VISUAL FEATURES", VISUALPage)

-- CreateToggle("🔴 Enable Chams", "Chams", VisualFolder)

-- CreateToggle("🟢 Chams TEAM", "ChamsTeam", VisualFolder)

-- CreateToggle("🔴 Chams MUSUH", "ChamsEnemy", VisualFolder)

CreateToggle(
	"⬜ Box",
	"Box",
	VisualFolder
)

CreateToggle(
	"🦴 Skeleton",
	"Skeleton",
	VisualFolder
)

CreateToggle(
	"📍 Tracer",
	"Tracer",
	VisualFolder
)

CreateToggle(
	"❤️ Health Bar",
	"Health",
	VisualFolder
)
 
--==================================================
-- STYLE ESP (synced from script lama10.txt)
--==================================================

CreateDropdown(
	"📦 Box Style",
	"BoxStyle",
	{"Box","Corner Box","3D Box"},
	VisualFolder
)

CreateDropdown(
	"📍 Tracer Origin",
	"TracerOrigin",
	{"Bottom","Center","Top"},
	VisualFolder
)

CreateDropdown(
	"📝 Name Style",
	"NameStyle",
	{"Display Name","Username","Name + Username","Hide"},
	VisualFolder
)

CreateDropdown(
	"🎯 ESP Target",
	"Target",
	{"All","Enemy","Team"},
	VisualFolder
)

--==================================================
-- AIM TAB
--==================================================

local AimFolder =
	CreateSection("🎯 AIM FEATURES", AIMPage)

CreateToggle(
	"🎯 Aktifkan Auto Aim",
	"Aimbot",
	AimFolder
)

CreateDropdown(
	"⚙️ Mode Aimbot",
	"AimbotMode",
	{
		"POV Kamera (FOV)",
		"360° (Brutal)"
	},
	AimFolder
)

CreateDropdown(
	"🎯 Target Bagian Tubuh",
	"AimTarget",
	{
		"Head",
		"Body"
	},
	AimFolder
)

CreateSlider(
	"🧲 Smoothness",
	"Smoothness",
	1,
	100,
	AimFolder
)

CreateToggle(
	"⭕ Tampilkan Lingkaran FOV",
	"ShowFOV",
	AimFolder
)

CreateSlider(
	"📏 FOV Radius",
	"FOVRadius",
	10,
	600,
	AimFolder
)

--==================================================
-- PLAYER TAB
--==================================================

local PlayerFolder =
	CreateSection("🏃 PLAYER FEATURES", PLAYERPage)

CreateToggle(
	"🛡️ No Fall Damage",
	"NoFallDamage",
	PlayerFolder
)

CreateToggle(
	"⚡ Kecepatan Lari",
	"Speed",
	PlayerFolder
)

CreateSlider(
	"⚙️ Set Speed",
	"SpeedValue",
	16,
	250,
	PlayerFolder
)

CreateToggle(
	"🚀 Lompat Tinggi",
	"Jump",
	PlayerFolder
)

CreateSlider(
	"⚙️ Set Jump Power",
	"JumpValue",
	50,
	250,
	PlayerFolder
)

CreateToggle(
	"🪽 Fly Mode",
	"Fly",
	PlayerFolder
)

CreateSlider(
	"⚙️ Kecepatan Fly",
	"FlySpeed",
	10,
	300,
	PlayerFolder
)

CreateToggle(
	"👻 Noclip",
	"Noclip",
	PlayerFolder
)

CreateToggle(
	"🔄 Auto Macro",
	"AutoMacro",
	PlayerFolder
)

--==================================================
-- TELEPORT
-- Synced from script lama.txt.
--==================================================

local TeleportFolder = CreateSection("📍 TELEPORT KE PLAYER", PLAYERPage)
local Mouse = LocalPlayer:GetMouse()

local function NotifyTeleport(Text)
	local Notice = Instance.new("TextLabel")
	Notice.Size = UDim2.fromOffset(260,38)
	Notice.Position = UDim2.new(0.5,-130,0,55)
	Notice.BackgroundColor3 = COLORS.Header
	Notice.TextColor3 = COLORS.Text
	Notice.Text = Text
	Notice.Font = Enum.Font.GothamBold
	Notice.TextSize = 11
	Notice.ZIndex = 500
	Notice.Parent = ScreenGui
	Instance.new("UICorner", Notice).CornerRadius = UDim.new(0,8)
	task.delay(2,function() if Notice and Notice.Parent then Notice:Destroy() end end)
end

local function TPToPlayer(TargetName, DefaultName)
	if not TargetName or TargetName == DefaultName then
		NotifyTeleport("⚠️ Pilih player terlebih dahulu")
		return
	end

	local TargetPlayer = Players:FindFirstChild(TargetName)
	local Character = LocalPlayer.Character
	local TargetCharacter = TargetPlayer and TargetPlayer.Character
	local HRP = Character and Character:FindFirstChild("HumanoidRootPart")
	local TargetHRP = TargetCharacter and TargetCharacter:FindFirstChild("HumanoidRootPart")

	if not HRP then
		NotifyTeleport("❌ Karakter kamu belum siap")
		return
	end
	if not TargetPlayer or not TargetHRP then
		NotifyTeleport("❌ Player tidak ditemukan / karakter belum siap")
		return
	end

	Character:PivotTo(TargetHRP.CFrame * CFrame.new(0,3,0))
	NotifyTeleport("✅ Teleport ke " .. TargetPlayer.Name)
end

CreateDropdown("💙 TP Ke Tim", "TPTeam", {"Pilih Teman"}, TeleportFolder)
CreateButton("🚀 TP Ke Tim Sekarang", TeleportFolder, function()
	TPToPlayer(State.TPTeam, "Pilih Teman")
end)

CreateDropdown("❤️ TP Ke Musuh", "TPEnemy", {"Pilih Musuh"}, TeleportFolder)
CreateButton("🚀 TP Ke Musuh Sekarang", TeleportFolder, function()
	TPToPlayer(State.TPEnemy, "Pilih Musuh")
end)

CreateButton("📍 TP Ke Posisi Mouse", TeleportFolder, function()
	local Character = LocalPlayer.Character
	local HRP = Character and Character:FindFirstChild("HumanoidRootPart")
	if not HRP then NotifyTeleport("❌ Karakter belum siap"); return end
	local Hit = Mouse.Hit
	if Hit then
		Character:PivotTo(CFrame.new(Hit.Position + Vector3.new(0,3,0)))
		NotifyTeleport("✅ Teleport ke posisi mouse")
	else
		NotifyTeleport("⚠️ Posisi mouse tidak tersedia")
	end
end)

--==================================================
-- SAVED LOCATIONS TELEPORT
-- Synced from script lama11.txt
--==================================================

local TeleportFolder2 = CreateSection("📍 TELEPORT KE LOKASI TERSIMPAN", PLAYERPage)

local SavedLocationNameBox = Instance.new("TextBox")
SavedLocationNameBox.Name = "SavedLocationNameBox"
SavedLocationNameBox.Size = UDim2.new(1, 0, 0, 42)
SavedLocationNameBox.BackgroundColor3 = COLORS.Control
SavedLocationNameBox.TextColor3 = COLORS.Text
SavedLocationNameBox.PlaceholderColor3 = COLORS.SubText
SavedLocationNameBox.PlaceholderText = "Nama lokasi..."
SavedLocationNameBox.Text = ""
SavedLocationNameBox.TextSize = 12
SavedLocationNameBox.Font = Enum.Font.Gotham
SavedLocationNameBox.ClearTextOnFocus = false
SavedLocationNameBox.ZIndex = 103
SavedLocationNameBox.Parent = TeleportFolder2

local SavedLocationNameCorner = Instance.new("UICorner")
SavedLocationNameCorner.CornerRadius = UDim.new(0, 8)
SavedLocationNameCorner.Parent = SavedLocationNameBox

local SavedLocationNamePadding = Instance.new("UIPadding")
SavedLocationNamePadding.PaddingLeft = UDim.new(0, 12)
SavedLocationNamePadding.PaddingRight = UDim.new(0, 12)
SavedLocationNamePadding.Parent = SavedLocationNameBox

local RefreshSavedLocations

local SaveLocationButton =
	CreateButton(
		"💾 SAVE CURRENT LOCATION",
		TeleportFolder2,
		function()

			local Character = LocalPlayer.Character
			local HRP =
				Character
				and Character:FindFirstChild("HumanoidRootPart")

			if not Character or not HRP then
				NotifyTeleport("❌ Karakter belum siap")
				return
			end

			local LocationName =
				SavedLocationNameBox.Text

			if LocationName == "" then
				LocationName =
					"Location "
					.. (#SavedLocations + 1)
			end

			table.insert(
				SavedLocations,
				{
					Name = LocationName,
					Position = HRP.Position
				}
			)

			SavedLocationNameBox.Text = ""

			NotifyTeleport(
				"✅ Lokasi tersimpan: "
				.. LocationName
			)

			RefreshSavedLocations()
		end
	)

local SavedLocationList =
	Instance.new("ScrollingFrame")

SavedLocationList.Name =
	"SavedLocationList"

SavedLocationList.Size =
	UDim2.new(1, 0, 0, 180)

SavedLocationList.BackgroundColor3 =
	COLORS.Background

SavedLocationList.BackgroundTransparency =
	0.15

SavedLocationList.BorderSizePixel = 0

SavedLocationList.ScrollBarThickness = 4

SavedLocationList.ScrollBarImageColor3 =
	COLORS.Border

SavedLocationList.CanvasSize =
	UDim2.fromOffset(0, 0)

SavedLocationList.AutomaticCanvasSize =
	Enum.AutomaticSize.Y

SavedLocationList.ZIndex = 103
SavedLocationList.Parent =
	TeleportFolder2

local SavedLocationListCorner =
	Instance.new("UICorner")

SavedLocationListCorner.CornerRadius =
	UDim.new(0, 8)

SavedLocationListCorner.Parent =
	SavedLocationList

local SavedLocationListLayout =
	Instance.new("UIListLayout")

SavedLocationListLayout.Padding =
	UDim.new(0, 5)

SavedLocationListLayout.SortOrder =
	Enum.SortOrder.LayoutOrder

SavedLocationListLayout.Parent =
	SavedLocationList

local SavedLocationListPadding =
	Instance.new("UIPadding")

SavedLocationListPadding.PaddingTop =
	UDim.new(0, 6)

SavedLocationListPadding.PaddingBottom =
	UDim.new(0, 6)

SavedLocationListPadding.PaddingLeft =
	UDim.new(0, 6)

SavedLocationListPadding.PaddingRight =
	UDim.new(0, 6)

SavedLocationListPadding.Parent =
	SavedLocationList

local function TeleportToSavedLocation(Position)

	local Character =
		LocalPlayer.Character

	if not Character then
		NotifyTeleport(
			"❌ Karakter belum siap"
		)
		return
	end

	local HRP =
		Character:FindFirstChild(
			"HumanoidRootPart"
		)

	if not HRP then
		NotifyTeleport(
			"❌ HumanoidRootPart tidak ditemukan"
		)
		return
	end

	Character:PivotTo(
		CFrame.new(
			Position
			+ Vector3.new(0, 3, 0)
		)
	)

	NotifyTeleport(
		"✅ Teleport ke lokasi tersimpan"
	)
end

local function ClearSavedLocationList()

	for _, Child in
		ipairs(
			SavedLocationList:GetChildren()
		) do

		if Child:IsA("Frame") then
			Child:Destroy()
		end

	end

end

RefreshSavedLocations = function()

	ClearSavedLocationList()

	for Index, Location in
		ipairs(SavedLocations) do

		local Item =
			Instance.new("Frame")

		Item.Name =
			"SavedLocation_" .. Index

		Item.Size =
			UDim2.new(1, 0, 0, 44)

		Item.BackgroundColor3 =
			COLORS.Control

		Item.BorderSizePixel = 0
		Item.LayoutOrder = Index
		Item.ZIndex = 104
		Item.Parent =
			SavedLocationList

		local ItemCorner =
			Instance.new("UICorner")

		ItemCorner.CornerRadius =
			UDim.new(0, 7)

		ItemCorner.Parent = Item

		local TeleportButton =
			Instance.new("TextButton")

		TeleportButton.Name =
			"Teleport"

		TeleportButton.Size =
			UDim2.new(1, -50, 1, 0)

		TeleportButton.BackgroundTransparency =
			1

		TeleportButton.Text =
			"📍 " .. Location.Name

		TeleportButton.TextColor3 =
			COLORS.Text

		TeleportButton.TextSize = 11
		TeleportButton.Font =
			Enum.Font.GothamMedium

		TeleportButton.TextXAlignment =
			Enum.TextXAlignment.Left

		TeleportButton.ZIndex = 105
		TeleportButton.Parent = Item

		local ButtonPadding =
			Instance.new("UIPadding")

		ButtonPadding.PaddingLeft =
			UDim.new(0, 10)

		ButtonPadding.Parent =
			TeleportButton

		TeleportButton.Activated:Connect(
			function()

				TeleportToSavedLocation(
					Location.Position
				)

			end
		)

		local DeleteButton =
			Instance.new("TextButton")

		DeleteButton.Name = "Delete"

		DeleteButton.Size =
			UDim2.fromOffset(34, 34)

		DeleteButton.Position =
			UDim2.new(1, -39, 0.5, -17)

		DeleteButton.BackgroundColor3 =
			COLORS.Off

		DeleteButton.Text = "×"

		DeleteButton.TextColor3 =
			COLORS.Text

		DeleteButton.TextSize = 15
		DeleteButton.Font =
			Enum.Font.GothamBold

		DeleteButton.ZIndex = 106
		DeleteButton.Parent = Item

		local DeleteCorner =
			Instance.new("UICorner")

		DeleteCorner.CornerRadius =
			UDim.new(0, 7)

		DeleteCorner.Parent =
			DeleteButton

		DeleteButton.Activated:Connect(
			function()

				table.remove(
					SavedLocations,
					Index
				)

				RefreshSavedLocations()

			end
		)

	end

end

RefreshSavedLocations()

local function BuildTeleportLists()
	local TeamList = {"Pilih Teman"}
	local EnemyList = {"Pilih Musuh"}
	for _, Player in ipairs(Players:GetPlayers()) do
		if Player ~= LocalPlayer then
			if LocalPlayer.TeamColor == Player.TeamColor then
				table.insert(TeamList, Player.Name)
			else
				table.insert(EnemyList, Player.Name)
			end
		end
	end
	if DropdownObjects.TPTeam and DropdownObjects.TPTeam.SetOptions then
		DropdownObjects.TPTeam.SetOptions(TeamList)
	end
	if DropdownObjects.TPEnemy and DropdownObjects.TPEnemy.SetOptions then
		DropdownObjects.TPEnemy.SetOptions(EnemyList)
	end
end

BuildTeleportLists()
Players.PlayerAdded:Connect(function() task.wait(0.5); BuildTeleportLists() end)
Players.PlayerRemoving:Connect(function() task.defer(BuildTeleportLists) end)
LocalPlayer:GetPropertyChangedSignal("TeamColor"):Connect(BuildTeleportLists)
LocalPlayer:GetPropertyChangedSignal("Team"):Connect(BuildTeleportLists)

-- Apply side effects when UI state changes.

--==================================================
-- MISC TAB
--==================================================

local MiscFolder =
	CreateSection("💾 CONFIGURATION", MISCPage)

CreateToggle(
	"🔄 Auto Load Saat Start",
	"AutoLoad",
	MiscFolder
)

local InfoLabel = Instance.new("TextLabel")

InfoLabel.Size = UDim2.new(1,0,0,45)

InfoLabel.BackgroundTransparency = 1
InfoLabel.Text =
	"Setting tersimpan secara lokal.\nSave/Load membutuhkan API file environment."

InfoLabel.TextColor3 = COLORS.SubText
InfoLabel.Font = Enum.Font.Gotham
InfoLabel.TextSize = 10

InfoLabel.TextWrapped = true
InfoLabel.Parent = MiscFolder

--==================================================
-- CONFIG SAVE
--==================================================

local function SaveSettings()

	if not writefile then
		return false
	end

	local Settings = {

		Aimbot = State.Aimbot,
		AimbotMode = State.AimbotMode,
		AimTarget = State.AimTarget,

		Smoothness = State.Smoothness,
		ShowFOV = State.ShowFOV,
		FOVRadius = State.FOVRadius,
		
Distance360 = State.Distance360,
NameDistance = State.NameDistance,

ESPTeam = State.ESPTeam,
ESPEnemy = State.ESPEnemy,

Chams = State.Chams,
ChamsTeam = State.ChamsTeam,
ChamsEnemy = State.ChamsEnemy,

Box = State.Box,
Skeleton = State.Skeleton,
Tracer = State.Tracer,
Health = State.Health,
BoxStyle = State.BoxStyle,
TracerOrigin = State.TracerOrigin,
NameStyle = State.NameStyle,
Target = State.Target,

Speed = State.Speed,
SpeedValue = State.SpeedValue,

Jump = State.Jump,
JumpValue = State.JumpValue,

Fly = State.Fly,
FlySpeed = State.FlySpeed,

Noclip = State.Noclip,
NoFallDamage = State.NoFallDamage,

		AutoMacro = State.AutoMacro,

		AutoLoad = State.AutoLoad,
	}

	local Success = pcall(function()

		writefile(
			CONFIG_NAME,
			HttpService:JSONEncode(Settings)
		)

	end)

	return Success
end

--==================================================
-- CONFIG LOAD
--==================================================

local function LoadSettings()

	if not isfile or not readfile then
		return false
	end

	if not isfile(CONFIG_NAME) then
		return false
	end

	local Success, Settings = pcall(function()

		return HttpService:JSONDecode(
			readfile(CONFIG_NAME)
		)

	end)

	if not Success or not Settings then
		return false
	end

	for Key,Value in pairs(Settings) do

		if State[Key] ~= nil then
			State[Key] = Value
		end

	end

	-- Refresh toggles
	for Key,Object in pairs(ToggleObjects) do

		if Object.Refresh then
			Object.Refresh()
		end

	end

	-- Refresh dropdown
	for _,Object in pairs(DropdownObjects) do

		if Object.Refresh then
			Object.Refresh()
		end

	end

	-- Refresh sliders
	for Key,Object in pairs(SliderObjects) do

		if Object.Set and State[Key] then
			Object.Set(State[Key])
		end

	end

	return true
end

--==================================================
-- SAVE BUTTON
--==================================================

local SaveButton = Instance.new("TextButton")

SaveButton.Size = UDim2.new(1,0,0,40)

SaveButton.BackgroundColor3 = COLORS.Control
SaveButton.Text = "💾 SAVE CONFIGURATION"

SaveButton.TextColor3 = COLORS.Text
SaveButton.Font = Enum.Font.GothamBold
SaveButton.TextSize = 12

SaveButton.ZIndex = 103
SaveButton.Parent = MiscFolder

local SaveCorner = Instance.new("UICorner")
SaveCorner.CornerRadius = UDim.new(0,8)
SaveCorner.Parent = SaveButton

SaveButton.Activated:Connect(function()

	if SaveSettings() then

		SaveButton.Text = "✅ CONFIG SAVED"

		task.delay(2,function()

			if SaveButton then
				SaveButton.Text =
					"💾 SAVE CONFIGURATION"
			end

		end)

	else

		SaveButton.Text =
			"❌ SAVE API TIDAK TERSEDIA"

		task.delay(2,function()

			if SaveButton then
				SaveButton.Text =
					"💾 SAVE CONFIGURATION"
			end

		end)

	end

end)

--==================================================
-- LOAD BUTTON
--==================================================

local LoadButton = Instance.new("TextButton")

LoadButton.Size = UDim2.new(1,0,0,40)

LoadButton.BackgroundColor3 = COLORS.Control
LoadButton.Text = "📂 LOAD CONFIGURATION"

LoadButton.TextColor3 = COLORS.Text
LoadButton.Font = Enum.Font.GothamBold
LoadButton.TextSize = 12

LoadButton.ZIndex = 103
LoadButton.Parent = MiscFolder

local LoadCorner = Instance.new("UICorner")
LoadCorner.CornerRadius = UDim.new(0,8)
LoadCorner.Parent = LoadButton

LoadButton.Activated:Connect(function()

	if LoadSettings() then

		LoadButton.Text = "✅ CONFIG LOADED"

	else

		LoadButton.Text = "⚠️ CONFIG TIDAK DITEMUKAN"

	end

	task.delay(2,function()

		if LoadButton then
			LoadButton.Text =
				"📂 LOAD CONFIGURATION"
		end

	end)

end)

--==================================================
-- RESET BUTTON
--==================================================

local ResetButton = Instance.new("TextButton")

ResetButton.Size = UDim2.new(1,0,0,40)

ResetButton.BackgroundColor3 = COLORS.Control
ResetButton.Text = "🔄 RESET DEFAULT"

ResetButton.TextColor3 = COLORS.Text
ResetButton.Font = Enum.Font.GothamBold
ResetButton.TextSize = 12

ResetButton.ZIndex = 103
ResetButton.Parent = MiscFolder

local ResetCorner = Instance.new("UICorner")
ResetCorner.CornerRadius = UDim.new(0,8)
ResetCorner.Parent = ResetButton

ResetButton.Activated:Connect(function()

	State.Aimbot = false
	State.AimbotMode = "POV Kamera (FOV)"
	State.AimTarget = "Head"

	State.Smoothness = 15
	State.ShowFOV = false
	State.FOVRadius = 150

	State.Distance360 = false
	State.NameDistance = false
	
State.ESPTeam = true
State.ESPEnemy = true

State.Chams = false
State.ChamsTeam = true
State.ChamsEnemy = true

State.Box = false
State.Skeleton = false
State.Tracer = false
State.Health = false
State.BoxStyle = "Corner Box"
State.TracerOrigin = "Top"
State.NameStyle = "Username"
State.Target = "All"

-- PLAYER DEFAULT
State.NoFallDamage = false

State.Speed = false
State.SpeedValue = 50

State.Jump = false
State.JumpValue = 100

State.Fly = false
State.FlySpeed = 50

State.Noclip = false

	State.AutoMacro = true

	State.AutoLoad = false

	for _,Object in pairs(ToggleObjects) do

		Object.Refresh()

	end

	for Key,Object in pairs(DropdownObjects) do

		if Object.Refresh then
			Object.Refresh()
		end

	end

	for Key,Object in pairs(SliderObjects) do

		if Object.Set and State[Key] then
			Object.Set(State[Key])
		end

	end

end)

--==================================================
-- AUTO LOAD
--==================================================

task.delay(1,function()

	if State.AutoLoad then
		LoadSettings()
	end

end)

--==================================================
-- OPEN LOGO
--==================================================

OpenButton.Activated:Connect(function()

	MainFrame.Visible = true
	OpenButton.Visible = false

end)

--==================================================
-- DRAG MAIN - PC + MOBILE
--==================================================

local Dragging = false
local DragInput = nil
local DragStart = nil
local StartPosition = nil

local function UpdateMainDrag(Input)
	if not Dragging or not DragStart or not StartPosition then
		return
	end

	local Delta = Input.Position - DragStart

	MainFrame.Position = UDim2.new(
		StartPosition.X.Scale,
		StartPosition.X.Offset + Delta.X,

		StartPosition.Y.Scale,
		StartPosition.Y.Offset + Delta.Y
	)
end

Header.InputBegan:Connect(function(Input)

	if Input.UserInputType == Enum.UserInputType.MouseButton1
		or Input.UserInputType == Enum.UserInputType.Touch then

		Dragging = true
		DragStart = Input.Position
		StartPosition = MainFrame.Position

		if Input.UserInputType == Enum.UserInputType.Touch then
			DragInput = Input
		end

		Input.Changed:Connect(function()
			if Input.UserInputState == Enum.UserInputState.End then
				Dragging = false
				DragInput = nil
			end
		end)
	end
end)

Header.InputChanged:Connect(function(Input)

	if Input.UserInputType == Enum.UserInputType.MouseMovement
		or Input.UserInputType == Enum.UserInputType.Touch then

		DragInput = Input
	end
end)

UserInputService.InputChanged:Connect(function(Input)

	if not Dragging then
		return
	end

	if Input == DragInput
		or Input.UserInputType == Enum.UserInputType.MouseMovement then

		UpdateMainDrag(Input)
	end
end)

--==================================================
-- MINIMIZE
--==================================================

MinimizeButton.Activated:Connect(function()

	MainFrame.Visible = false
	OpenButton.Visible = true

end)

--==================================================
-- CLOSE
--==================================================

CloseButton.Activated:Connect(function()

	MainFrame.Visible = false
	OpenButton.Visible = false

end)

--==================================================
-- FOV SYSTEM
--==================================================

local FOVFrame = Instance.new("Frame")

FOVFrame.Name = "FOVCircle"

FOVFrame.AnchorPoint =
	Vector2.new(0.5,0.5)

FOVFrame.Position =
	UDim2.new(0.5,0,0.5,0)

FOVFrame.Size =
	UDim2.fromOffset(
		State.FOVRadius * 2,
		State.FOVRadius * 2
	)

FOVFrame.BackgroundTransparency = 1
FOVFrame.Visible = false

FOVFrame.ZIndex = 50
FOVFrame.Parent = ScreenGui

local FOVCorner = Instance.new("UICorner")

FOVCorner.CornerRadius =
	UDim.new(1,0)

FOVCorner.Parent = FOVFrame

local FOVStroke = Instance.new("UIStroke")

FOVStroke.Color =
	Color3.fromRGB(255,255,255)

FOVStroke.Thickness = 1.5
FOVStroke.Transparency = 0.5

FOVStroke.Parent = FOVFrame

--==================================================
-- AIM SYSTEM
--==================================================

local LockedTarget = nil

local function IsEnemy(Character)

	if not Character then
		return false
	end

	if Character == LocalPlayer.Character then
		return false
	end

	local Player =
		Players:GetPlayerFromCharacter(Character)

	if not Player then
		return false
	end

	local Humanoid =
		Character:FindFirstChildOfClass("Humanoid")

	if not Humanoid or Humanoid.Health <= 0 then
		return false
	end

	if LocalPlayer.Team
		and Player.Team
		and LocalPlayer.Team == Player.Team then

		return false
	end

	return true
end

--==================================================
-- TARGET PART
--==================================================

local function GetTargetPart(Character)

	if not Character then
		return nil
	end

	local Head =
		Character:FindFirstChild("Head")

	local Body =
		Character:FindFirstChild("HumanoidRootPart")
		or Character:FindFirstChild("UpperTorso")

	if State.AimTarget == "Head" then

		return Head or Body

	end

	return Body or Head
end

--==================================================
-- VISIBILITY
--==================================================

local function IsVisible(TargetPart)

	if not TargetPart then
		return false
	end

	local Origin =
		Camera.CFrame.Position

	local Direction =
		TargetPart.Position - Origin

	if Direction.Magnitude < 1 then
		return false
	end

	local Params =
		RaycastParams.new()

	Params.FilterType =
		Enum.RaycastFilterType.Exclude

	Params.FilterDescendantsInstances = {

		LocalPlayer.Character,
		Camera
	}

	local Result =
		workspace:Raycast(
			Origin,
			Direction,
			Params
		)

	if not Result then
		return true
	end

	return Result.Instance:IsDescendantOf(
		TargetPart.Parent
	)
end

--==================================================
-- CLOSEST 2D TARGET
--==================================================

local function GetClosestEnemy2D()

	local Closest = nil
	local Shortest = State.FOVRadius

	local Viewport =
		Camera.ViewportSize

	local Center =
		Vector2.new(
			Viewport.X / 2,
			Viewport.Y / 2
		)

	for _,Player in ipairs(
		Players:GetPlayers()
	) do

		if Player ~= LocalPlayer then

			local Character =
				Player.Character

			local Humanoid =
				Character
				and Character:FindFirstChildOfClass(
					"Humanoid"
				)

			if Character
				and Humanoid
				and Humanoid.Health > 0
				and IsEnemy(Character) then

				local Target =
					GetTargetPart(Character)

				if Target
					and IsVisible(Target) then

					local Position,OnScreen =
						Camera:WorldToViewportPoint(
							Target.Position
						)

					if OnScreen then

						local Distance =
							(
								Center
								-
								Vector2.new(
									Position.X,
									Position.Y
								)
							).Magnitude

						if Distance < Shortest then

							Shortest = Distance
							Closest = Character

						end

					end
				end
			end
		end
	end

	return Closest
end

--==================================================
-- CLOSEST 3D TARGET
--==================================================

local function GetClosestEnemy3D()

	local Closest = nil
	local Shortest = math.huge

	for _,Player in ipairs(
		Players:GetPlayers()
	) do

		if Player ~= LocalPlayer then

			local Character =
				Player.Character

			local Humanoid =
				Character
				and Character:FindFirstChildOfClass(
					"Humanoid"
				)

			if Character
				and Humanoid
				and Humanoid.Health > 0
				and IsEnemy(Character) then

				local Target =
					GetTargetPart(Character)

				if Target
					and IsVisible(Target) then

					local Distance =
						(
							Camera.CFrame.Position
							-
							Target.Position
						).Magnitude

					if Distance < Shortest then

						Shortest = Distance
						Closest = Character

					end

				end
			end
		end
	end

	return Closest
end

--==================================================
-- PLAYER ESP
--==================================================

local ESP = {}

--==================================================
-- TEAM COLOR
--==================================================

local function GetTeamColor(Player)

	if LocalPlayer.Team
		and Player.Team
		and LocalPlayer.Team == Player.Team then

		return COLORS.Ally
	end

	return COLORS.Enemy
end

--==================================================
-- TEAM / ENEMY CHECK
--==================================================

local function IsSameTeam(Player)

	if not Player then
		return false
	end

	if LocalPlayer.Team
		and Player.Team then

		return LocalPlayer.Team == Player.Team
	end

	return false
end

local function IsEnemyPlayer(Player)

	if not Player then
		return false
	end

	return not IsSameTeam(Player)
end

--==================================================
-- ESP ENABLE CHECK
--==================================================

local function IsESPEnabledForPlayer(Player)

	if IsSameTeam(Player) then

		return State.ESPTeam

	end

	return State.ESPEnemy
end

--==================================================
-- CHAMS ENABLE CHECK
--==================================================

local function IsChamsEnabledForPlayer(Player)

	if not State.Chams then
		return false
	end

	if IsSameTeam(Player) then

		return State.ChamsTeam

	end

	return State.ChamsEnemy
end

--==================================================
-- CHAMS
--==================================================

local function ApplyChams(Character,Color)

	if not Character then
		return
	end

	local Existing =
		Character:FindFirstChild(
			"VVIPMods_Chams"
		)

	if Existing then

		Existing.FillColor = Color
		Existing.OutlineColor = Color

		return
	end

	local Highlight =
		Instance.new("Highlight")

	Highlight.Name =
		"VVIPMods_Chams"

	Highlight.Adornee =
		Character

	Highlight.FillColor =
		Color

	Highlight.OutlineColor =
		Color

	Highlight.FillTransparency =
		0.5

	Highlight.OutlineTransparency =
		0

	Highlight.DepthMode =
		Enum.HighlightDepthMode.AlwaysOnTop

	Highlight.Parent =
		Character
end

local function RemoveChams(Character)

	if not Character then
		return
	end

	local Highlight =
		Character:FindFirstChild(
			"VVIPMods_Chams"
		)

	if Highlight then
		Highlight:Destroy()
	end
end

--==================================================
-- CREATE ESP
--==================================================

local function CreateESP(Player)

	if Player == LocalPlayer then
		return
	end

	if ESP[Player] then
		return
	end

	local Container =
		Instance.new("Frame")

	Container.Name =
		"ESP_" .. Player.Name

	Container.Size =
		UDim2.fromOffset(1,1)

	Container.BackgroundTransparency = 1
	Container.Visible = false

	Container.ZIndex = 10
	Container.Parent = ScreenGui

	-- ICON
	local Icon =
		Instance.new("ImageLabel")

	Icon.Name =
		"PlayerIcon"

	Icon.Size =
		UDim2.fromOffset(
			ICON_SIZE,
			ICON_SIZE
		)

	Icon.AnchorPoint =
		Vector2.new(0.5,0.5)

	Icon.BackgroundColor3 = Color3.fromRGB(0,0,0)
    Icon.BackgroundTransparency = 0

	Icon.Image =
		"https://www.roblox.com/headshot-thumbnail/image?userId="
		..Player.UserId
		.."&width=48&height=48&format=png"

	Icon.ZIndex = 60
	Icon.Parent = Container

	local IconCorner =
		Instance.new("UICorner")

	IconCorner.CornerRadius =
		UDim.new(1,0)

	IconCorner.Parent = Icon

	local Stroke =
		Instance.new("UIStroke")

	Stroke.Thickness = 2
	Stroke.Parent = Icon

	-- DISTANCE
	local Distance =
		Instance.new("TextLabel")

	Distance.Name =
		"Distance"

	Distance.Size =
		UDim2.fromOffset(80,18)

	Distance.AnchorPoint =
		Vector2.new(0.5,0)

	Distance.BackgroundTransparency = 1
	Distance.BorderSizePixel = 0

	Distance.Text =
		"[0m]"

	Distance.TextColor3 =
	COLORS.Text

    -- STROKE HITAM DISTANCE
    local DistanceStroke = Instance.new("UIStroke")
    DistanceStroke.Color = Color3.fromRGB(0,0,0)
    DistanceStroke.Thickness = 2
    DistanceStroke.Transparency = 0
    DistanceStroke.Parent = Distance

	Distance.Font =
		Enum.Font.GothamBold

	Distance.TextSize = 11

	Distance.Visible = false
	Distance.ZIndex = 20

	Distance.Parent =
		ScreenGui

	-- NAME
	local NameLabel =
		Instance.new("TextLabel")

	NameLabel.Size =
		UDim2.fromOffset(150,18)

	NameLabel.AnchorPoint =
		Vector2.new(0.5,1)

	NameLabel.BackgroundTransparency = 1

	NameLabel.Text =
		Player.Name

	NameLabel.TextColor3 =
		COLORS.Text
		
	-- STROKE HITAM NAME
    local NameStroke = Instance.new("UIStroke")
    NameStroke.Color = Color3.fromRGB(0,0,0)
    NameStroke.Thickness = 2
    NameStroke.Transparency = 0
    NameStroke.Parent = NameLabel

	NameLabel.Font =
		Enum.Font.GothamBold

	NameLabel.TextSize = 11

	NameLabel.Visible = false
	NameLabel.ZIndex = 11

	NameLabel.Parent =
		ScreenGui

	-- ARROW
	local Arrow =
		Instance.new("TextLabel")

	Arrow.Size =
		UDim2.fromOffset(20,20)

	Arrow.AnchorPoint =
		Vector2.new(0.5,0.5)

	Arrow.BackgroundTransparency = 1

	Arrow.Text = "▼"
	Arrow.TextColor3 =
		COLORS.Text

	Arrow.Font =
		Enum.Font.GothamBold

	Arrow.TextSize = 18

	Arrow.ZIndex = 12
	Arrow.Parent = Container

	-- SKELETON
	local Skeleton = {}
	for Index = 1,15 do
		local Line = Instance.new("Frame")
		Line.Name = "SkeletonLine" .. Index
		Line.AnchorPoint = Vector2.new(0.5,0.5)
		Line.BackgroundColor3 = COLORS.Enemy
		Line.BorderSizePixel = 0
		Line.Size = UDim2.fromOffset(0,2)
		Line.Visible = false
		Line.ZIndex = 55
		Line.Parent = ScreenGui
		Skeleton[Index] = Line
	end

	-- BOX
	local Box =
		Instance.new("Frame")

	Box.Name = "Box"

	Box.AnchorPoint =
		Vector2.new(0.5,0.5)

	Box.BackgroundTransparency = 1
	Box.BorderSizePixel = 0

	Box.Visible = false
	Box.ZIndex = 8

	Box.Parent =
		ScreenGui

	local BoxStroke =
	Instance.new("UIStroke")

    BoxStroke.Color = COLORS.Enemy
    BoxStroke.Thickness = 2
    BoxStroke.Transparency = 0
    BoxStroke.Parent = Box

	-- STYLE BOX LINES (Corner / 3D)
	local BoxCornerLines = {}
	for Index = 1,8 do
		local Line = Instance.new("Frame")
		Line.Name = "BoxCornerLine" .. Index
		Line.AnchorPoint = Vector2.new(0.5,0.5)
		Line.BackgroundColor3 = COLORS.Enemy
		Line.BorderSizePixel = 0
		Line.Size = UDim2.fromOffset(0,2)
		
		local Stroke = Instance.new("UIStroke")
        Stroke.Color = Color3.fromRGB(0,0,0)
        Stroke.Thickness = 1
        Stroke.Transparency = 0
        Stroke.Parent = Line
		
		Line.Visible = false
		Line.ZIndex = 9
		Line.Parent = ScreenGui
		BoxCornerLines[Index] = Line
	end

	local Box3DLines = {}
	for Index = 1,12 do
		local Line = Instance.new("Frame")
		Line.Name = "Box3DLine" .. Index
		Line.AnchorPoint = Vector2.new(0.5,0.5)
		Line.BackgroundColor3 = COLORS.Enemy
		Line.BorderSizePixel = 0
		Line.Size = UDim2.fromOffset(0,2)
		
		local Stroke = Instance.new("UIStroke")
        Stroke.Color = Color3.fromRGB(0,0,0)
        Stroke.Thickness = 1
        Stroke.Transparency = 0
        Stroke.Parent = Line
		
		Line.Visible = false
		Line.ZIndex = 9
		Line.Parent = ScreenGui
		Box3DLines[Index] = Line
	end

	-- TRACER
	local Tracer =
		Instance.new("Frame")

	Tracer.Name =
		"Tracer"

	Tracer.AnchorPoint =
		Vector2.new(0.5,0.5)

	Tracer.BackgroundColor3 =
		COLORS.Enemy

	Tracer.BorderSizePixel = 0

	Tracer.Visible = false

	Tracer.ZIndex = 50
	Tracer.Parent =
		ScreenGui

	-- HEALTH
	local HealthBack =
		Instance.new("Frame")

	HealthBack.Name =
		"HealthBack"

	HealthBack.BackgroundColor3 =
		Color3.fromRGB(30,30,30)

	HealthBack.BorderSizePixel = 0
	
	-- STROKE HITAM HEALTH
	local HealthStroke = Instance.new("UIStroke")
    HealthStroke.Color = Color3.fromRGB(0,0,0)
    HealthStroke.Thickness = 2
    HealthStroke.Transparency = 0
    HealthStroke.Parent = HealthBack

	HealthBack.Visible = false
	HealthBack.ZIndex = 9

	HealthBack.Parent =
		ScreenGui

	local HealthFill =
		Instance.new("Frame")

	HealthFill.Name =
		"HealthFill"

	HealthFill.BackgroundColor3 =
		COLORS.Accent

	HealthFill.BorderSizePixel = 0

	HealthFill.AnchorPoint =
		Vector2.new(0,1)

	HealthFill.Position =
		UDim2.new(0,0,1,0)

	HealthFill.Size =
		UDim2.new(1,0,1,0)

	HealthFill.ZIndex = 10
	HealthFill.Parent =
		HealthBack

	ESP[Player] = {

		Container = Container,
		Icon = Icon,

		Distance = Distance,
		Name = NameLabel,
		Arrow = Arrow,

		Skeleton = Skeleton,

		Box = Box,
		BoxStroke = BoxStroke,
		BoxCornerLines = BoxCornerLines,
		Box3DLines = Box3DLines,

		Tracer = Tracer,

		HealthBack = HealthBack,
		HealthFill = HealthFill,

		Stroke = Stroke,
	}
end

--==================================================
-- REMOVE ESP
--==================================================

local function RemoveESP(Player)

	local Data =
		ESP[Player]

	if not Data then
		return
	end

	if Player.Character then
		RemoveChams(
			Player.Character
		)
	end

	for _,Object in pairs(Data) do

		if typeof(Object) == "Instance"
			and Object ~= nil then

			pcall(function()
				Object:Destroy()
			end)

		end

	end

	ESP[Player] = nil
end

--==================================================
-- PLAYER EVENTS
--==================================================

for _,Player in ipairs(
	Players:GetPlayers()
) do

	CreateESP(Player)

end

Players.PlayerAdded:Connect(
	CreateESP
)

Players.PlayerRemoving:Connect(
	RemoveESP
)

--==================================================
-- TRACER
--==================================================

local function SetTracer(
	Frame,
	From,
	To,
	Color
)

	local Delta =
		To - From

	local Length =
		Delta.Magnitude

	if Length < 1 then

		Frame.Visible = false

		return
	end

	local MidPoint =
		(From + To) / 2

	Frame.Position =
		UDim2.fromOffset(
			MidPoint.X,
			MidPoint.Y
		)

	Frame.Size =
		UDim2.fromOffset(
			Length,
			2
		)

	Frame.Rotation =
		math.deg(
			math.atan2(
				Delta.Y,
				Delta.X
			)
		)

	Frame.BackgroundColor3 =
		Color

	Frame.Visible = true
end

--==================================================
-- SKELETON DRAWING
--==================================================

local function SetSkeletonLine(Line, From, To, Color)
	local Delta = To - From
	local Length = Delta.Magnitude
	if Length < 1 then Line.Visible = false return end
	Line.Position = UDim2.fromOffset((From.X + To.X) / 2, (From.Y + To.Y) / 2)
	Line.Size = UDim2.fromOffset(Length, 2)
	Line.Rotation = math.deg(math.atan2(Delta.Y, Delta.X))
	Line.BackgroundColor3 = Color
	Line.Visible = true
end

local function DrawSkeleton(Data, Character, Humanoid, Color)
	for _, Line in ipairs(Data.Skeleton) do Line.Visible = false end
	if not State.Skeleton or not Camera then return end
	local Connections
	if Humanoid.RigType == Enum.HumanoidRigType.R6 then
		Connections = {{"Head","Torso"},{"Torso","Left Arm"},{"Torso","Right Arm"},{"Torso","Left Leg"},{"Torso","Right Leg"}}
	else
		Connections = {{"Head","UpperTorso"},{"UpperTorso","LowerTorso"},{"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},{"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},{"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},{"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"}}
	end
	local Index = 1
	for _, Connection in ipairs(Connections) do
		local A = Character:FindFirstChild(Connection[1], true)
		local B = Character:FindFirstChild(Connection[2], true)
		if A and B and A:IsA("BasePart") and B:IsA("BasePart") then
			local SA = Camera:WorldToViewportPoint(A.Position)
			local SB = Camera:WorldToViewportPoint(B.Position)
			if SA.Z > 0 and SB.Z > 0 and Data.Skeleton[Index] then
				SetSkeletonLine(Data.Skeleton[Index], Vector2.new(SA.X,SA.Y), Vector2.new(SB.X,SB.Y), Color)
				Index += 1
			end
		end
	end
end

--==================================================
-- STYLE ESP DRAWING
--==================================================

local function HideBoxStyleLines(Data)
	for _,Line in ipairs(Data.BoxCornerLines or {}) do
		Line.Visible = false
	end
	for _,Line in ipairs(Data.Box3DLines or {}) do
		Line.Visible = false
	end
end

local function SetStyleLine(Line, From, To, Color)
	local Delta = To - From
	local Length = Delta.Magnitude
	if Length < 1 then
		Line.Visible = false
		return
	end
	Line.Position = UDim2.fromOffset((From.X + To.X)/2, (From.Y + To.Y)/2)
	Line.Size = UDim2.fromOffset(Length, 2)
	Line.Rotation = math.deg(math.atan2(Delta.Y, Delta.X))
	Line.BackgroundColor3 = Color
	Line.Visible = true
end

local function DrawStyleBox(Data, X, Y, Width, Height, Color)
	HideBoxStyleLines(Data)
	Data.Box.Visible = false

	if State.BoxStyle == "Corner Box" then
		local CW = math.max(8, math.floor(Width * 0.25))
		local CH = math.max(8, math.floor(Height * 0.20))
		local parts = {
			{Vector2.new(X,Y), Vector2.new(X+CW,Y)},
			{Vector2.new(X,Y), Vector2.new(X,Y+CH)},
			{Vector2.new(X+Width-CW,Y), Vector2.new(X+Width,Y)},
			{Vector2.new(X+Width,Y), Vector2.new(X+Width,Y+CH)},
			{Vector2.new(X,Y+Height-CH), Vector2.new(X,Y+Height)},
			{Vector2.new(X,Y+Height), Vector2.new(X+CW,Y+Height)},
			{Vector2.new(X+Width-CW,Y+Height), Vector2.new(X+Width,Y+Height)},
			{Vector2.new(X+Width,Y+Height-CH), Vector2.new(X+Width,Y+Height)},
		}
		for Index,Part in ipairs(parts) do
			SetStyleLine(Data.BoxCornerLines[Index], Part[1], Part[2], Color)
		end
		return
	end

	if State.BoxStyle == "3D Box" then
		local OX = math.clamp(Width * 0.18, 10, 32)
		local OY = math.clamp(Height * 0.10, 8, 28)
		local F = {
			Vector2.new(X,Y), Vector2.new(X+Width,Y),
			Vector2.new(X+Width,Y+Height), Vector2.new(X,Y+Height),
		}
		local B = {
			F[1] + Vector2.new(OX,-OY), F[2] + Vector2.new(OX,-OY),
			F[3] + Vector2.new(OX,-OY), F[4] + Vector2.new(OX,-OY),
		}
		local Edges = {
			{F[1],F[2]},{F[2],F[3]},{F[3],F[4]},{F[4],F[1]},
			{B[1],B[2]},{B[2],B[3]},{B[3],B[4]},{B[4],B[1]},
			{F[1],B[1]},{F[2],B[2]},{F[3],B[3]},{F[4],B[4]},
		}
		for Index,Edge in ipairs(Edges) do
			SetStyleLine(Data.Box3DLines[Index], Edge[1], Edge[2], Color)
		end
		return
	end

	-- BOX
	Data.Box.AnchorPoint = Vector2.new(0.5,0.5)
	Data.Box.Position = UDim2.fromOffset(X + Width/2, Y + Height/2)
	Data.Box.Size = UDim2.fromOffset(Width, Height)
	Data.Box.BackgroundTransparency = 1
	Data.BoxStroke.Color = Color
	Data.BoxStroke.Thickness = 2
	Data.BoxStroke.Transparency = 0
	Data.Box.Visible = true
end

--==================================================
-- MAIN RENDER
--==================================================

--==================================================
-- PLAYER RUNTIME LOOP
--==================================================

RunService.Stepped:Connect(function()

	local Character = LocalPlayer.Character
	local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
	local HRP = Character and Character:FindFirstChild("HumanoidRootPart")

	if not Character or not Humanoid or not HRP then
		return
	end

	--================================================
	-- SPEED
	--================================================

	if State.Speed then
		Humanoid.WalkSpeed = State.SpeedValue
	else
		Humanoid.WalkSpeed = 16
	end

	--================================================
	-- JUMP
	--================================================

	if State.Jump then
		Humanoid.UseJumpPower = true
		Humanoid.JumpPower = State.JumpValue
	else
		Humanoid.UseJumpPower = true
		Humanoid.JumpPower = 50
	end

	--================================================
	-- NO FALL DAMAGE
	--================================================

	if State.NoFallDamage
		and HRP.AssemblyLinearVelocity.Y < -40 then

		local Params = RaycastParams.new()
		Params.FilterType = Enum.RaycastFilterType.Exclude
		Params.FilterDescendantsInstances = {Character}

		local Hit = workspace:Raycast(
			HRP.Position,
			Vector3.new(0, -20, 0),
			Params
		)

		if Hit then
			local Velocity = HRP.AssemblyLinearVelocity

			HRP.AssemblyLinearVelocity = Vector3.new(
				Velocity.X,
				-10,
				Velocity.Z
			)
		end
	end

--================================================
-- FLY
--================================================
if State.Fly then
	local Character = LocalPlayer.Character
	local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
	local HRP = Character and Character:FindFirstChild("HumanoidRootPart")
	if not HRP or not Humanoid then return end

	Humanoid.PlatformStand = true
	Humanoid.AutoRotate = false

	if not BodyVelocity then
		BodyVelocity = Instance.new("BodyVelocity")
		BodyVelocity.Name = "VVIPMods_FlyVelocity"
		BodyVelocity.MaxForce = Vector3.new(400000, 400000, 400000)
		BodyVelocity.P = 1250
	BodyVelocity.Velocity = Vector3.zero
		BodyVelocity.Parent = HRP
	end

	if not BodyGyro then
	BodyGyro = Instance.new("BodyGyro")
	BodyGyro.Name = "VVIPMods_FlyGyro"
	BodyGyro.MaxTorque = Vector3.new(400000, 400000, 400000)
		BodyGyro.P = 3000
		BodyGyro.Parent = HRP
	end

	local CamCF = Camera.CFrame
	local Forward = CamCF.LookVector
	local Right = CamCF.RightVector
	
	local Move = Vector3.zero
	
	-- PC Input
	if FlyKeys.Forward then Move += Forward end
	if FlyKeys.Backward then Move -= Forward end
	if FlyKeys.Right then Move += Right end
	if FlyKeys.Left then Move -= Right end

	-- MOBILE JOYSTICK INPUT
	if JoystickActive then
		local Delta = JoystickCurrentPos - JoystickStartPos
		if Delta.Magnitude > 10 then -- deadzone
			local Direction2D = Delta.Unit
			Move += Forward * -Direction2D.Y -- geser atas = maju
			Move += Right * Direction2D.X -- geser samping = kanan/kiri
		end
	end

	-- Naik Turun
	if FlyKeys.Up then Move += Vector3.new(0,1,0) end
	if FlyKeys.Down then Move -= Vector3.new(0,1,0) end

	if Move.Magnitude > 0 then Move = Move.Unit end
	
	BodyVelocity.Velocity = Move * State.FlySpeed
	BodyGyro.CFrame = CFrame.new(HRP.Position, HRP.Position + Forward)

else
	if BodyVelocity or BodyGyro then
	StopFly()
	end
end

	--================================================
	-- NOCLIP
	--================================================

	for _, Object in ipairs(
		Character:GetDescendants()
	) do

		if Object:IsA("BasePart") then

			Object.CanCollide =
				not State.Noclip

		end

	end

end)

--==================================================
-- RENDER / AIM / ESP
--==================================================

RunService.RenderStepped:Connect(function()

	Camera =
		workspace.CurrentCamera

	if not Camera then
		return
	end

	--================================================
	-- FOV
	--================================================

	FOVFrame.Size =
		UDim2.fromOffset(
			State.FOVRadius * 2,
			State.FOVRadius * 2
		)

	FOVFrame.Visible =
		State.Aimbot
		and State.ShowFOV
		and State.AimbotMode ==
			"POV Kamera (FOV)"

	--================================================
	-- AIMBOT
	--================================================

	if State.Aimbot then

		local TargetValid = false
		local PartToAim = nil

		if LockedTarget
			and LockedTarget.Parent then

			local Humanoid =
				LockedTarget:
				FindFirstChildOfClass(
					"Humanoid"
				)

			if Humanoid
				and Humanoid.Health > 0
				and IsEnemy(
					LockedTarget
				) then

				PartToAim =
					GetTargetPart(
						LockedTarget
					)

				if PartToAim
					and IsVisible(
						PartToAim
					) then

					if State.AimbotMode ==
						"POV Kamera (FOV)" then

						local Position,OnScreen =
							Camera:
							WorldToViewportPoint(
								PartToAim.Position
							)

						local Center =
							Vector2.new(
								Camera.ViewportSize.X / 2,
								Camera.ViewportSize.Y / 2
							)

						local Distance =
							(
								Center
								-
								Vector2.new(
									Position.X,
									Position.Y
								)
							).Magnitude

						if OnScreen
							and Distance <= State.FOVRadius then

							TargetValid = true
						end

					else

						TargetValid = true

					end
				end
			end
		end

		if not TargetValid then

			if State.AimbotMode ==
				"360° (Brutal)" then

				LockedTarget =
					GetClosestEnemy3D()

			else

				LockedTarget =
					GetClosestEnemy2D()

			end

			if LockedTarget then

				PartToAim =
					GetTargetPart(
						LockedTarget
					)

			end
		end

		if LockedTarget
			and PartToAim then

			local TargetCFrame =
				CFrame.lookAt(
					Camera.CFrame.Position,
					PartToAim.Position
				)

			if State.AimbotMode ==
				"360° (Brutal)" then

				Camera.CFrame =
					TargetCFrame

			else

				local Smooth =
					math.clamp(
						State.Smoothness / 100,
						0.01,
						1
					)

				Camera.CFrame =
					Camera.CFrame:Lerp(
						TargetCFrame,
						Smooth
					)

			end
		end

	else

		LockedTarget = nil

	end

	--================================================
	-- ESP
	--================================================

	local Character =
		LocalPlayer.Character

	local MyHRP =
		Character
		and Character:
		FindFirstChild(
			"HumanoidRootPart"
		)

	if not MyHRP then

		for _,Data in pairs(ESP) do

			Data.Container.Visible = false
			Data.Tracer.Visible = false
			Data.Box.Visible = false
			HideBoxStyleLines(Data)
			Data.HealthBack.Visible = false
			Data.Name.Visible = false
			Data.Distance.Visible = false
			for _, Line in ipairs(Data.Skeleton) do Line.Visible = false end

		end

		return
	end

	local Viewport =
		Camera.ViewportSize

	local Center =
		Vector2.new(
			Viewport.X / 2,
			Viewport.Y / 2
		)

	local GuiInset =
		GuiService:GetGuiInset()

	for Player,Data in pairs(ESP) do

		local TargetCharacter =
			Player.Character

		local HRP =
			TargetCharacter
			and TargetCharacter:
			FindFirstChild(
				"HumanoidRootPart"
			)

		local Humanoid =
			TargetCharacter
			and TargetCharacter:
			FindFirstChildOfClass(
				"Humanoid"
			)

		if not HRP
			or not Humanoid
			or Humanoid.Health <= 0 then

			Data.Container.Visible = false
			Data.Tracer.Visible = false
			Data.Box.Visible = false
			HideBoxStyleLines(Data)
			Data.Distance.Visible = false
			Data.Name.Visible = false
			Data.HealthBack.Visible = false
			for _, Line in ipairs(Data.Skeleton) do Line.Visible = false end

			if TargetCharacter then
				RemoveChams(TargetCharacter)
			end

			continue
		end
		
--================================================
-- ESP TEAM / ENEMY FILTER
--================================================

local ESPEnabled =
	IsESPEnabledForPlayer(Player)

if State.Target == "Enemy" then
	ESPEnabled = not (LocalPlayer.Team and Player.Team and LocalPlayer.Team == Player.Team)
elseif State.Target == "Team" then
	ESPEnabled = (LocalPlayer.Team and Player.Team and LocalPlayer.Team == Player.Team) == true
end

if not ESPEnabled then

	Data.Container.Visible = false
	Data.Tracer.Visible = false
	Data.Box.Visible = false
	Data.HealthBack.Visible = false
	Data.Name.Visible = false
	Data.Distance.Visible = false

	if TargetCharacter then
		RemoveChams(TargetCharacter)
	end

	continue
end

		local DistanceNum =
			math.floor(
				(
					HRP.Position
					-
					MyHRP.Position
				).Magnitude
			)

		local Color =
			GetTeamColor(Player)

		DrawSkeleton(Data, TargetCharacter, Humanoid, Color)

--================================================
-- CHAMS TEAM / ENEMY
--================================================

if IsChamsEnabledForPlayer(Player) then

	ApplyChams(
		TargetCharacter,
		Color
	)

else

	RemoveChams(
		TargetCharacter
	)

end

		--================================================
		-- SCREEN POSITION
		--================================================

		local ScreenPosition,
			OnScreen =
			Camera:
			WorldToViewportPoint(
				HRP.Position
			)

		local ValidScreen =
			ScreenPosition.Z > 0

		--================================================
		-- DEFAULT HIDE
		--================================================

		Data.Icon.Visible = false
		Data.Arrow.Visible = false
		Data.Name.Visible = false
		Data.Distance.Visible = false

		--================================================
		-- 360 DISTANCE
		--================================================

		if State.Distance360 then

			Data.Icon.Visible = true
			Data.Arrow.Visible = true
			Data.Container.Visible = true

			Data.Stroke.Color =
				Color

			local OffsetY = 0

			if State.NameDistance then
				OffsetY = 30
			end

			local TargetPos

			if OnScreen and ValidScreen then

				TargetPos =
					Vector2.new(
						ScreenPosition.X,
						ScreenPosition.Y - OffsetY
					)

				Data.Arrow.Rotation = 0

			else

				local Difference =
					HRP.Position
					-
					Camera.CFrame.Position

				if Difference.Magnitude > 0 then

					local Direction =
						Difference.Unit

					local X =
						Camera.CFrame.RightVector:
						Dot(Direction)

					local Y =
						Camera.CFrame.UpVector:
						Dot(Direction)

					local Dir2D =
						Vector2.new(X,Y)

					if Dir2D.Magnitude > 0 then

						Dir2D =
							Dir2D.Unit

						local W =
							Viewport.X * 0.5
							-
							EDGE_OFFSET

						local H =
							Viewport.Y * 0.5
							-
							EDGE_OFFSET

						local Scale =
							math.min(
								W / math.max(
									math.abs(
										Dir2D.X
									),
									0.001
								),

								H / math.max(
									math.abs(
										Dir2D.Y
									),
									0.001
								)
							)

						local XPos =
							math.clamp(
								Center.X
								+
								Dir2D.X * Scale,

								EDGE_OFFSET,
								Viewport.X -
								EDGE_OFFSET
							)

						local YPos =
							math.clamp(
								Center.Y
								-
								Dir2D.Y * Scale,

								EDGE_OFFSET
								+
								GuiInset.Y,

								Viewport.Y -
								EDGE_OFFSET
							)

						TargetPos =
							Vector2.new(
								XPos,
								YPos - OffsetY
							)

						Data.Arrow.Rotation =
							math.deg(
								math.atan2(
									-Dir2D.Y,
									Dir2D.X
								)
								+
								math.pi / 2
							)

					end
				end
			end

			if TargetPos then

				Data.Container.Position =
					UDim2.fromOffset(
						TargetPos.X,
						TargetPos.Y
					)

				Data.Icon.Position =
					UDim2.fromOffset(
						0,
						-45
					)

			end

		else

			Data.Container.Visible =
				State.NameDistance
				or State.Box
		end

		--================================================
		-- NAME + DISTANCE
		--================================================

		if State.NameDistance
			and State.NameStyle ~= "Hide"
			and OnScreen
			and ValidScreen then

			Data.Name.Visible = true

			if State.NameStyle == "Display Name" then
				Data.Name.Text = Player.DisplayName
			elseif State.NameStyle == "Name + Username" then
				Data.Name.Text = Player.DisplayName .. " (" .. Player.Name .. ")"
			else
				Data.Name.Text = Player.Name
			end

			Data.Name.TextColor3 =
				Color

			Data.Name.Position =
				UDim2.fromOffset(
					ScreenPosition.X,
					ScreenPosition.Y + 10
				)

			Data.Distance.Visible = true

			Data.Distance.Text =
				"[" ..
				DistanceNum ..
				"m]"

			Data.Distance.TextColor3 =
				Color

			Data.Distance.Position =
				UDim2.fromOffset(
					ScreenPosition.X,
					ScreenPosition.Y + 28
				)

		end

		--================================================
		-- BOX
		--================================================

		if State.Box
			and OnScreen
			and ValidScreen then

			local TopWorld =
				HRP.Position
				+
				Vector3.new(
					0,3,0
				)

			local BottomWorld =
				HRP.Position
				-
				Vector3.new(
					0,3.5,0
				)

			local Top2D =
				Camera:
				WorldToViewportPoint(
					TopWorld
				)

			local Bottom2D =
				Camera:
				WorldToViewportPoint(
					BottomWorld
				)

			if Top2D.Z > 0
				and Bottom2D.Z > 0 then

				local Height =
					math.max(
						math.abs(
							Top2D.Y
							-
							Bottom2D.Y
						),
						22
					)

				local Width =
					math.max(
						Height * 0.65,
						14
					)

				local BoxCenterX =
					(
						Top2D.X
						+
						Bottom2D.X
					) / 2

				local BoxCenterY =
					(
						Top2D.Y
						+
						Bottom2D.Y
					) / 2

				DrawStyleBox(
					Data,
					BoxCenterX - Width/2,
					BoxCenterY - Height/2,
					Width,
					Height,
					Color
				)

				if State.NameDistance then

					Data.Name.Position =
						UDim2.fromOffset(
							BoxCenterX,
							BoxCenterY
							-
							(Height / 2)
							-
							20
						)

					Data.Distance.Position =
						UDim2.fromOffset(
							BoxCenterX,
							BoxCenterY
							+
							(Height / 2)
							+
							3
						)

				end

				--================================================
				-- HEALTH
				--================================================

				if State.Health then

					local HealthPercent =
						math.clamp(
							Humanoid.Health
							/
							math.max(
								Humanoid.MaxHealth,
								1
							),

							0,
							1
						)

					Data.HealthBack.AnchorPoint =
						Vector2.new(
							0,
							0.5
						)

					Data.HealthBack.Position =
						UDim2.fromOffset(
							BoxCenterX
							+
							Width / 2
							+
							5,

							BoxCenterY
						)

					Data.HealthBack.Size =
						UDim2.fromOffset(
							4,
							Height
						)

					Data.HealthBack.Visible =
						true

					Data.HealthFill.Size =
						UDim2.new(
							1,
							0,
							HealthPercent,
							0
						)

					Data.HealthFill.BackgroundColor3 =
						Color3.new(
							1 -
							HealthPercent,

							HealthPercent,
							0
						)

				else

					Data.HealthBack.Visible =
						false

				end

			else

				Data.Box.Visible = false
				Data.HealthBack.Visible = false

			end

		else

			Data.Box.Visible = false
			HideBoxStyleLines(Data)
			Data.HealthBack.Visible = false

		end

		--================================================
-- TRACER
--================================================

if State.Tracer
    and OnScreen
    and ValidScreen then

    local From

    if State.TracerOrigin == "Bottom" then
        From = Vector2.new(Viewport.X / 2, Viewport.Y - 2)
    elseif State.TracerOrigin == "Center" then
        From = Vector2.new(Viewport.X / 2, Viewport.Y / 2)
    else
        From = Vector2.new(Viewport.X / 2, 2)
    end

    local To =
    Vector2.new(
        ScreenPosition.X,
        ScreenPosition.Y - 90
    )

    SetTracer(
        Data.Tracer,
        From,
        To,
        Color
    )

else

    Data.Tracer.Visible = false

end

	end

end)

--==================================================
-- DEFAULT TAB
--==================================================

CurrentTab =
	TabData["ESP"]

CurrentTab.Page.Visible = true
CurrentTab.Button.BackgroundColor3 =
	COLORS.Accent

--==================================================
-- STARTUP
--==================================================

print("====================================")
print("VVIP MODS GUI LOADED")
print("AIM + ESP + VISUAL + AUTO MACRO + CONFIG")
print("ROBLOX STUDIO / OWN GAME")
print("====================================")   
