local debounce = false
local debris = game:GetService("Debris")


game.ReplicatedStorage.InRound.Changed:Connect(function() --Turn on the Powerup gui after the round start
	if game.ReplicatedStorage.InRound.Value == true then
		wait(0.3)
		for _, character in workspace.inRound:GetChildren() do
			local player = game.Players:GetPlayerFromCharacter(character)			
			if player.Equipped.Powerups:FindFirstChildWhichIsA("StringValue").Value ~= "" then
				
				if player.Equipped.Powerups:FindFirstChildWhichIsA("Value").Value then
					player.PlayerGui.PowerupCooldown.Enabled = true
				end
				
			end
		end	
	end
end)

game.Workspace.inRound.ChildRemoved:Connect(function(instance)
	local player = game.Players:GetPlayerFromCharacter(instance)
	player.PlayerGui.PowerupCooldown.Enabled = false
end)


function onFired (player, Powerup)
	
	if Powerup == "Power Jump" then
		if debounce == false then
			debounce = true
			local vel = Instance.new("BodyVelocity")
			vel.Parent = player.Character.HumanoidRootPart
			vel.Velocity = Vector3.new(0,35,0)
			vel.MaxForce = Vector3.new(0,10000000000000000000000000,0)
			debris:AddItem(vel,0.5)
		end
		
	elseif Powerup == "Power Run" then
		if debounce == false then
			debounce = true
			player.Character.Humanoid.WalkSpeed = 25
			wait(3)
			player.Character.Humanoid.WalkSpeed = 16
		end
	end
end



game.ReplicatedStorage.Powerups.OnServerEvent:Connect(onFired)
