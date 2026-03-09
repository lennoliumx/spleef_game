 local functions = {} 
 

function functions.Pick3MapsForVoting()
	for i = 1, 3, 1 do

		local AllMaps = game.ReplicatedStorage.AllMaps:GetChildren()
		local randNumber = math.random(1, #AllMaps)

		local pickedMap = AllMaps[randNumber]
		pickedMap.Parent = game.ReplicatedStorage.PossibleMaps

		--Client sided Voting Gui setup
		game.ReplicatedStorage:WaitForChild("SetOption"):FireAllClients(pickedMap, i) -- tell the GUI to set Up the map images in the voting gui // listening script: "GetVoteOptions"
	end
end

 
function functions.SetupVotingGUIForPickedMap(FolderForVotingButtons, pickedMap, i)
	
	local ImageId = pickedMap:FindFirstChild("ImageId").Value

	local currentGuiMapSlot = FolderForVotingButtons:FindFirstChild("Choice"..i)
	
	currentGuiMapSlot.Text = pickedMap.Name
	currentGuiMapSlot.ImageLabel.Image = "http://www.roblox.com/asset/?id="..(tostring(ImageId))


end


function functions.CountVotes(FolderForVotingButtons)
	
	for _ , Choice in FolderForVotingButtons:GetChildren() do
		local Votes = #game.ReplicatedStorage.PossibleMaps[Choice.Text].Votes:GetChildren() --count number of Votes
		Choice.TextLabel.Text = Votes
	end
	
end


function functions.VoteOnClick(FolderForVotingButtons)
	
	for _, button in FolderForVotingButtons:GetChildren() do
		button.MouseButton1Click:Connect(function()
			
			local mapVoted = button.Text
			game.ReplicatedStorage.Voted:FireServer(mapVoted) -- update Vote count
			
		end)
		
	end
	
end



function functions.MenuEffectsHandler(item, sideBar)
	
	local imageButton = item:FindFirstChild("ImageButton")
	-----------------------------------------------------------------------
	-- Change color on hover
	imageButton.MouseEnter:Connect(function()
		imageButton.Parent.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	end)
	imageButton.MouseLeave:Connect(function()
		imageButton.Parent.BackgroundColor3 = Color3.fromRGB(186, 186, 186)
	end)
	----------------------------------------------------------------------
	-- On selected
	imageButton.Activated:Connect(function()

		if sideBar.InfoSection.Item:FindFirstChild("ViewportFrame") then
			local displayItem = sideBar.InfoSection.Item:FindFirstChild("ViewportFrame")
			displayItem:Destroy()
		end
		sideBar.InfoSection.Visible = true
		-----------------------------------------------
		-- Rotating item image in large
		local DisplayClone = item.ViewportFrame:Clone()
		DisplayClone.Parent = sideBar.InfoSection.Item

		DisplayClone.Position = UDim2.new(0.009,0,0,0)
		DisplayClone.Size = UDim2.new(0.991,0,1,0)
		-----------------------------------------------
		-- Sidebar information
		local itemNameDisplay = sideBar.InfoSection.ItemName
		local itemPriceDisplay = sideBar.InfoSection.BuyNow.Price
		local itemDescriptionDisplay = sideBar.InfoSection.ItemDescription

		local ItemPrice = item.ItemPrice
		local ItemName = item.ItemName
		local description = item.Description

		itemNameDisplay.Text = ItemName.Text
		itemPriceDisplay.Text = ItemPrice.Text
		itemDescriptionDisplay.Text = description.Value

		-- If owned
		if item.Owned.Visible == true and item.Equipped.Visible ~= true then
			sideBar.InfoSection.BuyNow.TextLabel.Text = "Equip"
			sideBar.InfoSection.BuyNow.TextLabel.Position = UDim2.new(0.251,0,0,0)
			sideBar.InfoSection.BuyNow.Price.Text = ""
			sideBar.InfoSection.BuyNow.ImageLabel.Visible = false
			sideBar.InfoSection.BuyNow.BackgroundColor3 = Color3.fromRGB(18, 176, 76)
		elseif item.Owned.Visible == false then
			sideBar.InfoSection.BuyNow.TextLabel.Text = "Buy now"
			sideBar.InfoSection.BuyNow.TextLabel.Position = UDim2.new(0.017,0,0,0)
			itemPriceDisplay.Text = ItemPrice.Text
			sideBar.InfoSection.BuyNow.ImageLabel.Visible = true
			sideBar.InfoSection.BuyNow.BackgroundColor3 = Color3.fromRGB(18, 176, 76)
		elseif item.Equipped.Visible == true and item.Owned.Visible == true then 
			sideBar.InfoSection.BuyNow.TextLabel.Text = "Currently equipped"
			sideBar.InfoSection.BuyNow.TextLabel.Position = UDim2.new(0.251,0,0,0)
			sideBar.InfoSection.BuyNow.Price.Text = ""
			sideBar.InfoSection.BuyNow.ImageLabel.Visible = false
			sideBar.InfoSection.BuyNow.BackgroundColor3 = Color3.fromRGB(166, 166, 166)
		end

	end)
end




return functions
