------------------------------------------------------------------------
-- Disable Reset
------------------------------------------------------------------------
wait(1)
local StarterGui = game:GetService("StarterGui")
StarterGui:SetCore("ResetButtonCallback", false)

local player = game.Players.LocalPlayer

local test = player.Character:FindFirstChild("Humanoid").RigType
------------------------------------------------------------------------



--------------------------------------------------------------------------------------------------------------------------------------------------------
-- Voting system
--------------------------------------------------------------------------------------------------------------------------------------------------------

----------------------
local functions = require(game.ReplicatedStorage.functions)

local player = game.Players.LocalPlayer
local FolderForVotingButtons = player:WaitForChild("PlayerGui"):WaitForChild("Voting"):WaitForChild("Frame"):WaitForChild("Choices")

----------------------
-- Voting system
----------------------
---> Update vote count on gui <---

--on Vote click update vote count
game.ReplicatedStorage.Voted.OnClientEvent:Connect(function()
	functions.CountVotes(FolderForVotingButtons)
end)

--reset votres on round status changed
game.ReplicatedStorage.InRound.Changed:Connect(function()
	functions.CountVotes(FolderForVotingButtons)
end)

--------------------

--> Setup the different vote Options in the GUI

local SetOption = game.ReplicatedStorage:WaitForChild("SetOption")
SetOption.OnClientEvent:Connect(function(pickedMap: Instance, i: number) 
	--= ClientEvent after round change
	functions.SetupVotingGUIForPickedMap(FolderForVotingButtons, pickedMap, i)
end)


functions.VoteOnClick(FolderForVotingButtons)

--------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------| SHOP |---------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------
local workspace = game:GetService("Workspace")
local shop = script.Parent.Parent.PlayerGui.Shop

local character = game.Players.LocalPlayer.Character
local player = game.Players.LocalPlayer
local debounce = false



-----------------------------------------------------------------------
--close 

shop.MainFrame.Close.Activated:Connect(function()
	shop.Enabled = false
end)

-- If the shop is open when the game starts

local inRoundVar = game.ReplicatedStorage.InRound
inRoundVar.Changed:Connect(function()

	if inRoundVar.Value == true and shop.Enabled == true then
		shop.Enabled = false
	end

end)

--------------------
--open per proxPrompt
local shopkeepersFolder = workspace:FindFirstChild("Shopkeepeers"):GetChildren()
for _, obj in shopkeepersFolder do
	
	local proximityPrompt = obj:FindFirstChild("eg"):FindFirstChild("ProximityPrompt")
	
	proximityPrompt.Triggered:Connect(function()
		shop.Enabled = true
	end)
	
end
--------------------

local mainFrame = shop.MainFrame
local sideBar = shop.SideBar
local itemCategorySelectionBar: Frame = shop.MainFrame.ItemCategorySelectionBar
local selectionButtonsForItemsCategories = itemCategorySelectionBar.ItemCategories:GetChildren()
local BarForButtoneffectsAfterSelection = itemCategorySelectionBar.BarForButtoneffectsAfterSelection
local infoSection = shop.SideBar:WaitForChild("InfoSection")
local scrollingFrameMenu = mainFrame.ScrollingFrameMenu

local powerupsMenu = mainFrame.ScrollingFrameMenu.Powerups
local shovelsMenu = mainFrame.ScrollingFrameMenu.Shovels

---------------------------------------------------------------------------------------------------------------------------------------------
-- Changing category view in shop
for _, shopCategoryButton in selectionButtonsForItemsCategories do --place textbutton activation logiic, and effects in every category button

	shopCategoryButton.Activated:Connect(function() --on textbutton activated

		-----------------------------------------------------
		-- change the "currently slected" effect
		local CurrentlySelectedBar = BarForButtoneffectsAfterSelection.CurrentlySelectedBar
		CurrentlySelectedBar:TweenPosition(BarForButtoneffectsAfterSelection:FindFirstChild(shopCategoryButton.Name).Position,"Out","Quart",0.3)
		-----------------------------------------------------

		--find the current shown category and disable it, after clicking another category button
		------------------------------------------------------------------------------------------
		for _, shopCategory in mainFrame.ScrollingFrameMenu:GetChildren() do 
			if shopCategory.Visible == true and shopCategoryButton.Name ~= shopCategory.Name then --find out what (old) category is still visible, after clicking a new cat button
				shopCategory.Visible = false
				infoSection.Visible = false
				
				--remove item shown in info part
				local thingDisplayed = infoSection.Item:FindFirstChild("itemPic") or infoSection.Item:FindFirstChild("ViewportFrame")
				if thingDisplayed then
					thingDisplayed:Destroy()
				end
			end
		end
		------------------------------------------------------------------------------------------

		-- make the newly selected category (current button pressed) visible
		local selection = mainFrame.ScrollingFrameMenu:FindFirstChild(shopCategoryButton.Name)
		selection.Visible = true
	end)

	----------------------------------------------------------------------
	-- mouse hover effects
	shopCategoryButton.MouseEnter:Connect(function()
		local hoverBar = BarForButtoneffectsAfterSelection:FindFirstChild(shopCategoryButton.Name)
		hoverBar.BackgroundTransparency = 0
	end)
	shopCategoryButton.MouseLeave:Connect(function()
		local hoverBar = BarForButtoneffectsAfterSelection:FindFirstChild(shopCategoryButton.Name)
		hoverBar.BackgroundTransparency = 1
	end)
	----------------------------------------------------------------------
end
-----------------------------------------------------------------------------------------------------------------------------------------------


------------------------------------------------------------------------------------------------------------------------------------------------
-- Loading owned and equiped items into the shop
------------------------------------------------------------------------------------------------------------------------------------------------
-- Load owned things.

wait(0.1)
for _, itemSavingCategory in game.Players.LocalPlayer:WaitForChild("Inventory"):GetChildren() do
	for _, item in itemSavingCategory:GetChildren() do
		if item.Name == "Tools" then
			powerupsMenu.Items[item.Name].Owned.Visible = true
		elseif item.Name == "Powerups" then
			shovelsMenu.Items[item.Name].Owned.Visible = true
		end

	end
end


-- Load equipped things.
for _, itemSavingCategory in game.Players.LocalPlayer:WaitForChild("Equipped"):GetChildren() do
	for _, item in itemSavingCategory:GetChildren() do
		if itemSavingCategory.Name == "Shovel" then
			shovelsMenu.Items[item.Name].Equipped.Visible = true
		elseif itemSavingCategory.Name == "Powerups" then
			if item.Value ~= "" then
				powerupsMenu.items[item.Value].Equipped.Visible = true
			end

		end

	end
end
------------------------------------------------------------------------

-- | VISUAL GUI SCRIPTS FOR THE ITEMS IN THE SHOP |

for _, category in scrollingFrameMenu:GetChildren() do
	
	for _, item in category.Items:GetChildren() do
		
		functions.MenuEffectsHandler(item, sideBar)
		
	end
	
end

------------------------------------------------------------------------




infoSection.BuyNow.TextButton.Activated:Connect(function()
	local price = infoSection.BuyNow.Price.Text
	local item: string = infoSection.ItemName.Text
	local itemtype: string = scrollingFrameMenu:FindFirstChild(item, true).Parent.Name
	local scrollingFrameMenuTbl = scrollingFrameMenu:GetChildren()
	
	local ErrorNoMoney = infoSection.ErrorNoMoney
	local ErrorToolAlreadyBought = infoSection.ErrorToolAlreadyBought
	local ErrorToolEqiuppedAlr = infoSection.ErrorToolAlreadyEquipped
	

	local player = player
	local plrUsrId = player.UserId
	local character = player.Character
	local price = (tonumber(price))
	local points = player:FindFirstChild("leaderstats"):FindFirstChild("Points").Value



	-- If item not owned 
	if scrollingFrameMenu:FindFirstChild(item, true).Owned.Visible == false then
		
		--if player has enough money
		if points >= price and debounce == false then
			debounce = true
			local frameOfItemInShopMenu = scrollingFrameMenu[itemtype].Items:FindFirstChild(item)
			frameOfItemInShopMenu.Owned.Visble = true
			infoSection.BuyNow.TextLabel.Text = "Equip"
			infoSection.BuyNow.Price.Text = ""
			infoSection.BuyNow.ImageLabel.Visible = false
		
			game.ReplicatedStorage.Buy:FireServer(item, price, itemtype)

			debounce = false
			
			--when player doesnt have enough money
		elseif points <= price and debounce == false then
			
			debounce = true
				
			ErrorNoMoney.Visible = true
			task.wait(3)
			ErrorNoMoney.Visible = false
			
			debounce = false
			
		end
		


	else --If item owned then you can equip
		
		if itemtype == "Shovels" then
			if not character:FindFirstChild(item) and not player.Backpack:FindFirstChild(item) then

				-- Destroy currrent tools
				character:FindFirstChildWhichIsA("Tool"):Destroy()
				player.Backpack:FindFirstChildWhichIsA("Tool"):Destroy()

				-- Make current equipped entry, for when the player equipps another tool. Changing it for the server so it can be saved.
				game.ReplicatedStorage.onEquip:FireServer(item, itemtype)

			else  -- If the item is found in the player, then an error appears.
				if debounce == false then
					debounce = true

					ErrorToolEqiuppedAlr.Visible = true
					wait(1.5)
					ErrorToolEqiuppedAlr.Visible = false

					debounce = false
				end
			end
		end

		if itemtype == "Powerups" then

			if player.Equipped.Powerups:FindFirstChildWhichIsA("StringValue").Value == item then
				if debounce == false then
					debounce = true

					ErrorToolEqiuppedAlr.Visible = true
					wait(1.5)
					ErrorToolEqiuppedAlr.Visible = false

					debounce = false	
				end
			end

			-- Make current equipped entry, for when the player equipps another tool. Changing it for the server so it can be saved.
			game.ReplicatedStorage.onEquip:FireServer(item, itemtype)

		end

	end

end)
