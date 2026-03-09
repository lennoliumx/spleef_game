local repStor = game:GetService("ReplicatedStorage")



------------------------------------------------------------------------------------------------------------------------------------------------------
-- round system

local inRound = game.ReplicatedStorage.InRound
local Status = game.ReplicatedStorage.Status

local ArenaSpawns = workspace.ArenaSpawns:GetChildren()
local LobbySpawns = workspace.LobbySpawns:GetChildren()

local intermission = 120
local roundLength = 60

local functions = require(game.ReplicatedStorage.functions)

----------------
--This is only for when the server is initially starting, so the players can still be fetched after the main script has run already without the players having to be there, because they join after the main script has been executed, so they can't be fetched by the main system.
game.Players.PlayerAdded:Connect(function(player: Player)
	players = game.Players:GetChildren()
	local playerJoined = player
	
end)
---------------

--------------------------------------------------------------------------------------------------------------------------------------------------------
--DataStore

----------------------------------------------------------------------------
--loading
local dataStoreService = game:GetService("DataStoreService")
local dataStore = dataStoreService:GetDataStore("254")

local loaded = {}


local function characterAdded(player)
	local tool = player.Equipped.Shovel:FindFirstChildWhichIsA("StringValue").Value

	if not player.Backpack:FindFirstChild(tool) then
		local equippedTool = game.ReplicatedStorage.Shovels:FindFirstChild(tool)
		local clone = equippedTool:Clone()
		clone.Parent = player.Backpack
	end
end


game.Players.PlayerAdded:Connect(function(player)
	local success, value = pcall(dataStore.GetAsync, dataStore, player.UserId)
	if success == false then player:Kick("Couldn't load data!, "..value) return end



	local data = value or {}

	for _, folder in game.ReplicatedStorage.PlayerData:GetChildren() do
		local subData = data[folder.Name] or {}

		local clone = folder:Clone()

		for _, child in clone:GetChildren() do
			if child:IsA("Folder") then
				for i, thing in child:GetChildren() do
					if value then
						thing.Value = subData[child.Name][thing.Name] or subData[child.Name][i]
					else
						thing.Value = thing.Value
					end
				end
			else
				child.Value = subData[child.Name] or child.Value
			end
		end

		clone.Parent = player
		---------------------------------------------------------------------------------

		-- Load items in posession, for the shop to show the "owned" text
		if folder.Name == "Inventory" then	
			--print(subData)

			if subData.Powerups then
				for i, powerup in subData["Powerups"] do
					if not player.Inventory.Powerups:FindFirstChild(powerup) then
						local toolvalue = Instance.new("StringValue")
						toolvalue.Parent = player.Inventory.Powerups
						toolvalue.Name = powerup
						toolvalue.Value = powerup
					end
				end
			end
			if subData.Tools then
				for i, tool in subData["Tools"] do
					if not player.Inventory.Tools:FindFirstChild(tool) then
						local toolvalue = Instance.new("StringValue")
						toolvalue.Parent = player.Inventory.Tools
						toolvalue.Name = tool
						toolvalue.Value = tool
					end
				end
			end
		end
	end

	if player.Character then
		characterAdded(player)
	end
	player.CharacterAdded:Connect(function()
		characterAdded(player)
	end)

	loaded[player] = true
end)

----------------------------------------------------------------------------
--saving
game.Players.PlayerRemoving:Connect(function(player)
	if loaded[player] == nil then return end

	local data = {}

	-- save

	for _, ExampleFolder in game.ReplicatedStorage.PlayerData:GetChildren() do
		local subData = {}
		for _, child in player[ExampleFolder.Name]:GetChildren() do
			if child:IsA("Folder") then
				subData[child.Name] = {}
				for _, item in child:GetChildren() do
					table.insert(subData[child.Name],item.Value)
				end
			else
				subData[child.Name] = child.Value
			end
		end
		data[ExampleFolder.Name] = subData
		player[ExampleFolder.Name]:Destroy()
	end

	local success, data = pcall(dataStore.SetAsync, dataStore, player.UserId, data)
	loaded[player] = nil
end)

game:BindToClose(function()
	while next(loaded) ~= nil do
		wait()
	end
end)
--------------------------------------------------------------------------------------------------------------------------------------------------------


----------------------------------------------------------------------------
--below:
	-- upon round status changing:
		-- teleport players
		-- handle voting system on round end
		-- function definition for each round functionality
		-- set up maps on server startup

task.wait(0.5) --the function must not run before the player hasn't fully joined yet inorder for the gui to be setup properly
functions.Pick3MapsForVoting()


game.ReplicatedStorage.InRound.Changed:Connect(function()

	
	if inRound.Value == true then
		----------------------------------------------------------------------------------
		-- PLAYER TELEPORTATION (TO ARENA)
		local function Teleport_Players_On_In_Round_True()
			
			
			for i = 1, #ArenaSpawns - 1 do -- fisher-yates shuffle
				local r = math.random(i,#ArenaSpawns)
				ArenaSpawns[i], ArenaSpawns[r] = ArenaSpawns[r], ArenaSpawns[i]
			end


			for i, plr in pairs(players) do

				local SpawnNumber = i
				plr.character.HumanoidRootPart.CFrame = ArenaSpawns[SpawnNumber].CFrame
				plr.character.Parent = workspace.inRound
			end
			
		end
		
		Teleport_Players_On_In_Round_True()
		
		----------------------------------------------------------------------------------
		
		local function Remove_Current_Placed_Map()

			local CurrentMap = workspace:FindFirstChild("CurrentMap"):FindFirstChildOfClass("Model")
			if CurrentMap then
				CurrentMap.Parent = game.ReplicatedStorage.AllMaps

				for _, plate in CurrentMap:GetChildren() do
					if plate:IsA("Part") then
						plate.Transparency = 0
						plate.CanCollide = true

						for _, debounce in plate:GetChildren() do
							debounce:Destroy()
						end

					end
				end
			end

		end	
		Remove_Current_Placed_Map()



		local function Evaluate_Voting_Results_And_Place_Map()

			local maps = game.ReplicatedStorage.PossibleMaps:GetChildren()

			local Choice1Votes = maps[1]:FindFirstChild("Votes"):GetChildren()
			local Choice2Votes = maps[2]:FindFirstChild("Votes"):GetChildren()
			local Choice3Votes = maps[3]:FindFirstChild("Votes"):GetChildren()


			if #Choice1Votes > #Choice2Votes and #Choice1Votes > #Choice3Votes then

				local choosenMap = maps[1]
				choosenMap.Parent = workspace:FindFirstChild("CurrentMap")
				choosenMap:PivotTo(workspace:FindFirstChild("Determinator").CFrame)

				for _, votes in pairs(Choice1Votes) do
					votes:Destroy()
				end

			elseif #Choice2Votes > #Choice1Votes and #Choice2Votes > #Choice3Votes then

				local choosenMap = maps[2]
				choosenMap.Parent = workspace:FindFirstChild("CurrentMap")
				choosenMap:PivotTo(workspace:FindFirstChild("Determinator").CFrame)

				for _, votes in pairs(Choice2Votes) do
					votes:Destroy()
				end

			elseif #Choice3Votes > #Choice1Votes and #Choice3Votes > #Choice2Votes then

				local choosenMap = maps[3]
				choosenMap.Parent = workspace:FindFirstChild("CurrentMap")
				choosenMap:PivotTo(workspace:FindFirstChild("Determinator").CFrame)

				for _, votes in pairs(Choice3Votes) do
					votes:Destroy()
				end


			elseif #Choice1Votes == #Choice2Votes and #Choice1Votes == #Choice3Votes then

				local randNumber = math.random(1, #maps)
				local choosenMap = maps[randNumber]

				choosenMap.Parent = workspace:FindFirstChild("CurrentMap")
				choosenMap:PivotTo(workspace:FindFirstChild("Determinator").CFrame)

			end
		end
		Evaluate_Voting_Results_And_Place_Map()



		local function removeVotesFromPossibleMapsInVotingAndReParentMaps()
			--remove votes from the remaining maps that werent voted and then put them in allMaps
			for _, map in pairs(game.ReplicatedStorage.PossibleMaps:GetChildren()) do
				for _, vote in pairs(map:FindFirstChild("Votes"):GetChildren()) do
					vote:Destroy()
				end
				map.Parent = game.ReplicatedStorage.AllMaps
			end

		end
		removeVotesFromPossibleMapsInVotingAndReParentMaps()
		----------------------------------------------------------------------------------
		

	elseif inRound.Value == false then
		
		----------------------------------------------------------------------------------	
		-- PLAYER TELEPORTATION (TO LOBBY)
		local function Teleport_Players_On_In_Round_False()
			charsInRound = game.Workspace.inRound:GetChildren() 
			for i, char in pairs(charsInRound) do

				local SpawnNumber = math.random(1,#LobbySpawns)
				char.HumanoidRootPart.CFrame = LobbySpawns[SpawnNumber].CFrame
				char.Parent = workspace
			end
		end
		Teleport_Players_On_In_Round_False()
		
		----------------------------------------------------------------------------------
		--Voting GUI SetUp
		
		--PICK MAPS
		
		functions.Pick3MapsForVoting()
	
	end
end)

--------------------------------------------------------------------------------------------------------------------------------------------------------


--------------------------------------------------------------------------------------------------------------------------------------------------------
--Voting system
--------------------------------------------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------

function AlreadyVoted(plr)

	for _, Map in game.ReplicatedStorage.PossibleMaps:GetChildren() do

		playerVoteInMap = Map:FindFirstChild("Votes"):FindFirstChild(plr.Name)

		if playerVoteInMap then
			voted = true
			break
		else
			voted = false
		end
		
	end
	
	return table.pack(voted, playerVoteInMap)

end


function PlaceVote(mapVoted, plr)
	
	local votingFolderOfMapVoted = repStor:FindFirstChild("PossibleMaps"):FindFirstChild(mapVoted):FindFirstChild("Votes")
	local vote = Instance.new("BoolValue")
	vote.Name = plr.Name
	vote.Parent = votingFolderOfMapVoted
end


--> Place vote in the corresponding map folder after signal for click detection on vote button has been detected
game.ReplicatedStorage.Voted.OnServerEvent:Connect(function(plr, mapVoted: string)
	
	if AlreadyVoted(plr)[1] then
		AlreadyVoted(plr)[2]:Destroy()
		PlaceVote(mapVoted, plr)
	else
		PlaceVote(mapVoted, plr)
	end
		
	game.ReplicatedStorage.Voted:FireAllClients()--update vote count
			

end)


--------------------------------------------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------
--on shop buying --
----------------------------------------------------------------------------

debounce = false

game.ReplicatedStorage.Buy.OnServerEvent:Connect(function(player, item, price, itemtype)

	player.leaderstats.Points.Value -= price
	------------------------------------------------------------------------------------------
	-- Creating entry for data store
	
	local itemValue = Instance.new("StringValue")
	itemValue.Name = item
	itemValue.Value = item
	itemValue.Parent = player.Inventory:FindFirstChild(itemtype)



	-- When player doesn't have enough money

end)
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

game.ReplicatedStorage.onEquip.OnServerEvent:Connect(function(player, item, itemtype)

	--Todo: make it universal for the other items too

	if itemtype == "Shovels" then
		local toolValue = player.Equipped.Shovel:FindFirstChildWhichIsA("StringValue")
		toolValue.Name = item
		toolValue.Value = item

		-- Give player the tool
		local boughtItem = game.ReplicatedStorage.Shovels:FindFirstChild(item)
		local boughtItemClone = boughtItem:Clone()
		boughtItemClone.Parent = player.Backpack

	elseif itemtype == "Powerups" then
		local toolValue = player.Equipped.Powerups:FindFirstChildWhichIsA("StringValue")
		toolValue.Name = item
		toolValue.Value = item
	end




end)


--------------------------------------------------------------------------------------------------------------------------------------------------------

--below:
--round system

function round()

	while true do
		wait()
		charsInRound = game.Workspace.inRound:GetChildren()
		players = game.Players:GetChildren()

		----------------------------------------

		if inRound.Value == false then


			if #players >= 1 then

				for i = intermission, 0, -1 do
					wait(1)
					players = game.Players:GetChildren()

					Status.Value = "Game starting in "..tostring(i).." seconds!"

					if #players == 0 then
						Status.Value = "Not enough players!"
						break
					end

					if i == 0 then
						inRound.Value = true
					end
				end		

			elseif #players == 1 then
				wait(1)
				Status.Value = "Not enough players!"
			end

			----------------------------------------

		elseif inRound.Value == true then 

			for i = roundLength, 0, -1 do
				wait(1)
				charsInRound = game.Workspace.inRound:GetChildren()

				Status.Value = "Game ending in "..tostring(i).." seconds!"

				if i == 0 then
					Status.Value = "There is no winner!"
					wait(5)
					inRound.Value = false


				elseif #charsInRound == 1 then

					--------------

					local player = game.Players:GetPlayerFromCharacter(charsInRound[1])

					Status.Value = "The winner is "..tostring(charsInRound[1]).."!"
					wait(5)
					inRound.Value = false

					player.leaderstats.Points.Value += 20

					--------------
					break
				end


			end	
		end
	end
end
spawn(round)
