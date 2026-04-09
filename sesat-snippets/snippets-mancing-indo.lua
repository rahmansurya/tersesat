-- // jual ikan ke npc
local isSellingNow = false 

task.spawn(function()
    while running do
        task.wait(2) 
        
        pcall(function()
            if isSellingNow then return end
            
            local currentFish = getBackpackCount() or 0
            local maxBag = 50 
            local sellThreshold = 5
            local npcPos = Vector3.new(2631.24, 5.43, -918.35) 
            
            if FishCountLbl then
                FishCountLbl.Text = "Fish in Bag: " .. currentFish .. "/" .. maxBag
            end
            
            if currentMode ~= "OFF" and currentFish >= sellThreshold then
                isSellingNow = true
                
                if StatusLbl then 
                    StatusLbl.Text = "STATUS: BYPASS SELLING (ALL)..." 
                    StatusLbl.TextColor3 = Color3.fromRGB(0, 255, 255)
                end
                
                local char = player.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChild("Humanoid")
                
                if hrp and hum then
                    local oldPos = hrp.CFrame
                    
                    hum:UnequipTools()
                    task.wait(0.5)
                    
                    hrp.CFrame = CFrame.new(npcPos)
                    task.wait(2.5) 
                    
                    
                    pcall(function()
                        local preview = RS.Remotes.GetSellAllPreview:InvokeServer()
                        if preview and preview.count > 0 then
                            print("Server Confirm: " .. preview.count .. " ikan terdeteksi.")
                            task.wait(0.8)
                            
                           RS.Remotes.SellFish:FireServer("All")
                        else
                            print("Server Warning: nil.")
                        end
                    end)
                    
                    task.wait(1.5) 
                    
                    if getBackpackCount() == 0 then
                        if StatusLbl then StatusLbl.Text = "STATUS: SUCCESS! RETURNING..." end
                        task.wait(1)
                        hrp.CFrame = oldPos
                        task.wait(1)
                                             
                        local rod = player.Backpack:FindFirstChildOfClass("Tool")
                        if rod then hum:EquipTool(rod) end
                    else
                        RS.Remotes.SellFish:FireServer("All")
                        task.wait(1)
                        hrp.CFrame = oldPos
                    end
                end
                
                isSellingNow = false 
                
            elseif currentMode ~= "OFF" and not isCasting and not isSellingNow then
                local state = player:GetAttribute("State")
                if (state == "idle" or not state) and performCast then 
                    performCast() 
                end
            end
        end)
    end
end)
