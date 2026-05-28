--!strict

-- BloxstrapRPC SDK Module v1.2.0
-- Written by pizzaboxer (@xtremeguy2256) and Epix (@ElusiveEpix)
-- Types reflected from https://github.com/bloxstraplabs/bloxstrap/tree/main/Bloxstrap/Models/BloxstrapRPC
-- Further documentation is available at https://bloxstraplabs.com/wiki/developers/bloxstraprpc

local EncodingService = game:GetService("EncodingService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local BloxstrapRPC = {}

export type RichPresence = {
	details: string?,
	state: string?,
	timeStart: number?,
	timeEnd: number?,
	smallImage: RichPresenceImage?,
	largeImage: RichPresenceImage?,
}

export type RichPresenceImage = {
	assetId: number? | string?,
	hoverText: string?,
	clear: boolean?,
	reset: boolean?,
}

--[=[
	Create a persistent ScreenGui and ImageLabel for sending messages
]=]
local gui = Instance.new("ScreenGui")
gui.ResetOnSpawn = false
gui.Name = "BloxstrapRPC"
gui.Parent = (Players.LocalPlayer :: Player).PlayerGui
local img = Instance.new("ImageLabel")
img.Image = ""
img.Parent = gui

--[=[
	Removes any non-number characters from AssetId, useful if the developer is passing in a ID that is taken directly from Instances like Decals or ImageLabels that contain `rbxassetid` or a URL like `http://www.roblox.com/asset/?id=`.
]=]
function SanitiseAssetId(assetId: string | number?): number?
	if type(assetId) ~= "string" then
		return assetId
	end

	return tonumber(string.match(assetId, "%d+"))
end

--[=[
	Send a raw RPC message.
	Avoid using this, as every command available will have a dedicated function for it.
]=]
function BloxstrapRPC.SendMessage(command: string, data: any)
	local json = HttpService:JSONEncode({
		command = command,
		data = data,
	})
	
	local base64 = buffer.tostring(EncodingService:Base64Encode(buffer.fromstring(json)))
	
	img.Image = "rbxasset://textures/|.png?TIME="..tick().."&BLOXSTRAP_INFO="..base64
	
	--print("[BloxstrapRPC] " .. json) -- Old behaviour.
end

--[=[
	Change or reset the user's Rich Presence activity if they are running Bloxstrap with the option enabled.
]=]
function BloxstrapRPC.SetRichPresence(data: RichPresence)
	if data.timeStart ~= nil then
		data.timeStart = math.round(data.timeStart)
	end
	if data.timeEnd ~= nil then
		data.timeEnd = math.round(data.timeEnd)
	end

	if data.smallImage ~= nil then
		data.smallImage.assetId = SanitiseAssetId(data.smallImage.assetId)
	end
	if data.largeImage ~= nil then
		data.largeImage.assetId = SanitiseAssetId(data.largeImage.assetId)
	end

	BloxstrapRPC.SendMessage("SetRichPresence", data)
end

--[=[
	Set the launch data used for invite deeplinks
]=]
function BloxstrapRPC.SetLaunchData(data: string)
	BloxstrapRPC.SendMessage("SetLaunchData", data)
end

return BloxstrapRPC
