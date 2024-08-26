--ixInventoryMove trap
do
	local function NetworkInventoryMove(receiver, invID, itemID, oldX, oldY, x, y)
		net.Start("ixInventoryMove")
			net.WriteUInt(invID, 32)
			net.WriteUInt(itemID, 32)
			net.WriteUInt(oldX, 6)
			net.WriteUInt(oldY, 6)
			net.WriteUInt(x, 6)
			net.WriteUInt(y, 6)
		net.Send(receiver)
	end

	net.Receive("ixInventoryMove", function(length, client)
		local oldX, oldY, x, y = net.ReadUInt(6), net.ReadUInt(6), net.ReadUInt(6), net.ReadUInt(6)
		local invID, newInvID = net.ReadUInt(32), net.ReadUInt(32)

		local character = client:GetCharacter()

		if (character) then
			local inventory = ix.item.inventories[invID]

			if (!inventory or inventory == nil) then
				inventory:Sync(client)
			end

			if ((inventory.owner and inventory.owner == character:GetID()) or inventory:OnCheckAccess(client)) then

			elseif ((!inventory.owner or (inventory.owner and inventory.owner == character:GetID())) or inventory:OnCheckAccess(client)) then
				return kouka.PermaBan(client, "Exploiter: IIM")
			end

			if ((inventory.owner and inventory.owner == character:GetID()) or inventory:OnCheckAccess(client)) then
				local item = inventory:GetItemAt(oldX, oldY)

				if (item) then
					if (newInvID and invID != newInvID) then
						local inventory2 = ix.item.inventories[newInvID]

						if (inventory2) then
							local bStatus, error = item:Transfer(newInvID, x, y, client)

							if (!bStatus) then
								NetworkInventoryMove(
									client, item.invID, item:GetID(), item.gridX, item.gridY, item.gridX, item.gridY
								)

								client:NotifyLocalized(error or "unknownError")
							end
						end

						return
					end

					if (inventory:CanItemFit(x, y, item.width, item.height, item)) then
						item.gridX = x
						item.gridY = y

						for x2 = 0, item.width - 1 do
							for y2 = 0, item.height - 1 do
								local previousX = inventory.slots[oldX + x2]

								if (previousX) then
									previousX[oldY + y2] = nil
								end
							end
						end

						for x2 = 0, item.width - 1 do
							for y2 = 0, item.height - 1 do
								inventory.slots[x + x2] = inventory.slots[x + x2] or {}
								inventory.slots[x + x2][y + y2] = item
							end
						end

						local receivers = inventory:GetReceivers()

						if (istable(receivers)) then
							local filtered = {}

							for _, v in ipairs(receivers) do
								if (v != client) then
									filtered[#filtered + 1] = v
								end
							end

							if (#filtered > 0) then
								NetworkInventoryMove(
									filtered, invID, item:GetID(), oldX, oldY, x, y
								)
							end
						end

						if (!inventory.noSave) then
							local query = mysql:Update("ix_items")
								query:Update("x", x)
								query:Update("y", y)
								query:Where("item_id", item.id)
							query:Execute()
						end
					else
						NetworkInventoryMove(
							client, item.invID, item:GetID(), item.gridX, item.gridY, item.gridX, item.gridY
						)
					end
				end
			else
				local item = inventory:GetItemAt(oldX, oldY)

				if (item) then
					NetworkInventoryMove(
						client, item.invID, item.invID, item:GetID(), item.gridX, item.gridY, item.gridX, item.gridY
					)
				end
			end
		end
	end)
end
----ixInventoryMove trap end
