--!strict
local Config = require(game.ReplicatedStorage.ThrowTickets.Config)
local S = require(script.Parent.Style)
local Preview = require(script.Parent.CarPreview)
local View = {}

local function createRow(list: ScrollingFrame, car: any, onAction: (string, string) -> ())
 local frame = Instance.new("Frame")
 frame.Name = car.Id
 frame.Size = UDim2.new(1, 0, 0, 104)
 frame.BackgroundColor3 = Color3.new(1, 1, 1)
 frame.BorderSizePixel = 0
 frame.Parent = list
 S.corner(frame, 18)
 S.stroke(frame, 2)
 local shade = S.gradient(frame, Color3.new(1, 1, 1), S.INK)

 local icon = Instance.new("Frame")
 icon.Name = "Icon"
 icon.Size = UDim2.fromOffset(76, 76)
 icon.Position = UDim2.fromOffset(8, 14)
 icon.BackgroundTransparency = .78
 icon.BackgroundColor3 = S.INK
 icon.Parent = frame
 S.corner(icon, 14)
 Preview.mount(icon, car)

 local function label(name: string, size: number, y: number): TextLabel
  local text = S.text(frame, name, "", size, UDim2.fromOffset(94, y), UDim2.new(1, -191, 0, 22))
  text.TextTruncate = Enum.TextTruncate.AtEnd
  return text
 end
 local name = label("Name", 19, 6)
 local rarity = label("Rarity", 14, 28)
 local traits = label("Traits", 13, 49)
 local income = label("Income", 19, 73)
 income.TextColor3 = Color3.fromHex("B2FFAD")

 local action = S.button(frame, "Action", "", UDim2.fromOffset(82, 44), UDim2.new(1, -90, 0, 5))
 action.TextSize = 15
 S.gradient(action, Color3.fromHex("8CF27C"), Color3.fromHex("22B24A"))
 local sell = S.button(frame, "Sell", "SELL", UDim2.fromOffset(82, 44), UDim2.new(1, -90, 0, 55))
 sell.TextSize = 16
 S.gradient(sell, Color3.fromHex("FF86CF"), Color3.fromHex("E2338C"))

 local current = car
 action.Activated:Connect(function()
  onAction(if current.Slot > 0 then "Remove" else "Equip", current.Id)
 end)
 sell.Activated:Connect(function() onAction("Sell", current.Id) end)

 return {
  frame = frame,
  update = function(nextCar: any, order: number)
   current = nextCar
   frame.LayoutOrder = order
   local tier = Config.Rarities[nextCar.Rarity]
   local color = tier.Color
   shade.Color = ColorSequence.new(color:Lerp(Color3.new(1, 1, 1), .12), color:Lerp(S.INK, .54))
   name.Text = nextCar.Name
   rarity.Text = tier.Name:upper()
   traits.Text = tostring(nextCar.Variant or "Normal") .. "  •  " .. tostring(nextCar.Size or "Normal")
   income.Text = "$" .. nextCar.Income .. "/s"
   action.Text = if nextCar.Slot > 0 then "PICK UP" else "PLACE"
  end,
 }
end

function View.mount(parent: Instance, onAction: (string, string) -> ()): any
 local gui = Instance.new("ScreenGui")
 gui.Name = "MyCars"
 gui.ResetOnSpawn = false
 gui.DisplayOrder = 35
 gui.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets
 gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
 gui.Parent = parent

 local dim = Instance.new("TextButton")
 dim.Name = "Dim"
 dim.Size = UDim2.fromScale(1, 1)
 dim.Text = ""
 dim.BackgroundColor3 = S.INK
 dim.BackgroundTransparency = .3
 dim.Parent = gui

 local panel = Instance.new("Frame")
 panel.Name = "Window"
 panel.AnchorPoint = Vector2.new(.5, .5)
 panel.Position = UDim2.fromScale(.5, .5)
 panel.BackgroundColor3 = Color3.new(1, 1, 1)
 panel.BorderSizePixel = 0
 panel.Active = true
 panel.Parent = gui
 S.corner(panel, 28)
 S.stroke(panel, 4)
 S.gradient(panel, Color3.fromHex("2F7BF2"), Color3.fromHex("16348F"))

 local title = S.text(panel, "Title", "MY CARS", 30, UDim2.fromOffset(20, 6), UDim2.new(1, -96, 0, 44))
 local close = S.button(panel, "Close", "X", UDim2.fromOffset(44, 44), UDim2.new(1, -55, 0, 8))
 S.gradient(close, Color3.fromHex("FF6B6B"), Color3.fromHex("E0202F"))

 local list = Instance.new("ScrollingFrame")
 list.Name = "Cars"
 list.Position = UDim2.fromOffset(12, 56)
 list.Size = UDim2.new(1, -24, 1, -114)
 list.BackgroundTransparency = 1
 list.BorderSizePixel = 0
 list.ScrollBarThickness = 5
 list.ScrollingDirection = Enum.ScrollingDirection.Y
 list.AutomaticCanvasSize = Enum.AutomaticSize.Y
 list.CanvasSize = UDim2.new()
 list.Parent = panel
 local layout = Instance.new("UIListLayout")
 layout.Padding = UDim.new(0, 8)
 layout.SortOrder = Enum.SortOrder.LayoutOrder
 layout.Parent = list
 local padding = Instance.new("UIPadding")
 padding.PaddingLeft = UDim.new(0, 4)
 padding.PaddingRight = UDim.new(0, 10)
 padding.PaddingTop = UDim.new(0, 4)
 padding.PaddingBottom = UDim.new(0, 4)
 padding.Parent = list

 local function heading(name: string, order: number): TextLabel
  local text = S.text(list, name, "", 17, UDim2.new(), UDim2.new(1, 0, 0, 28))
  text.LayoutOrder = order
  text.TextColor3 = Color3.fromHex("FFD24A")
  return text
 end
 local parkedHeader = heading("Parked", 0)
 local backpackHeader = heading("Backpack", 1000)
 local empty = S.text(list, "Empty", "Catch a car on the throw pad!", 17, UDim2.new(), UDim2.new(1, 0, 0, 42))
 empty.LayoutOrder = 1001
 empty.TextXAlignment = Enum.TextXAlignment.Center

 local best = S.button(panel, "EquipBest", "EQUIP BEST", UDim2.new(1, -36, 0, 44), UDim2.new(0, 18, 1, -52))
 best.TextSize = 22
 S.gradient(best, Color3.fromHex("FFF4A0"), Color3.fromHex("FFD24A"))

 local confirm = Instance.new("TextButton")
 confirm.Name = "ConfirmSale"
 confirm.Size = UDim2.fromScale(1, 1)
 confirm.BackgroundColor3 = S.INK
 confirm.BackgroundTransparency = .2
 confirm.AutoButtonColor = false
 confirm.Text = ""
 confirm.ZIndex = 5
 confirm.Parent = panel
 S.corner(confirm, 28)

 local card = Instance.new("Frame")
 card.Name = "QuestionCard"
 card.AnchorPoint = Vector2.new(.5, .5)
 card.Position = UDim2.fromScale(.5, .5)
 card.Size = UDim2.new(.86, 0, 0, 124)
 card.BackgroundColor3 = Color3.fromHex("16348F")
 card.BorderSizePixel = 0
 card.Active = true
 card.Parent = confirm
 S.corner(card, 20)
 S.stroke(card, 3)
 local question = S.text(card, "Question", "", 18, UDim2.fromOffset(12, 6), UDim2.new(1, -24, 0, 54))
 question.TextWrapped = true
 question.TextXAlignment = Enum.TextXAlignment.Center
 local yes = S.button(card, "Yes", "YES", UDim2.new(.5, -18, 0, 44), UDim2.new(0, 12, 1, -56))
 local no = S.button(card, "No", "NO", UDim2.new(.5, -18, 0, 44), UDim2.new(.5, 6, 1, -56))
 S.gradient(yes, Color3.fromHex("FF86CF"), Color3.fromHex("E2338C"))
 S.gradient(no, Color3.fromHex("74E6FF"), Color3.fromHex("1E95F0"))

 local rows = {}
 local saleId: string? = nil
 local function clearSale()
  saleId = nil
  confirm.Visible = false
 end
 local function open(value: boolean)
  gui.Enabled = value
  gui:SetAttribute("Open", value)
  clearSale()
 end
 local function resize()
  panel.Size = UDim2.fromOffset(math.min(720, gui.AbsoluteSize.X - 28), math.min(570, gui.AbsoluteSize.Y - 20))
  title.TextSize = if gui.AbsoluteSize.X < 600 then 26 else 30
 end
 gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(resize)
 resize()
 close.Activated:Connect(function() open(false) end)
 dim.Activated:Connect(function() open(false) end)
 best.Activated:Connect(function() onAction("EquipBest", "") end)
 no.Activated:Connect(clearSale)
 yes.Activated:Connect(function()
  local id = saleId
  clearSale()
  if id then onAction("ConfirmSell", id) end
 end)
 open(false)

 return {
  gui = gui,
  open = open,
  isOpen = function() return gui.Enabled end,
  confirm = function(car: any, price: number)
   if not gui.Enabled then return end
   saleId = car.Id
   question.Text = "Sell " .. car.Name .. " for $" .. price .. "?"
   confirm.Visible = true
  end,
  render = function(cars: {any}, inventory: number, capacity: number?)
   local retained = {}
   local parked = 0
   for i, car in cars do
    local inPlot = car.Slot > 0
    if inPlot then parked += 1 end
    retained[car.Id] = true
    local row = rows[car.Id]
    if not row then
     row = createRow(list, car, onAction)
     rows[car.Id] = row
    end
    row.update(car, if inPlot then i else 1000 + i)
   end
   parkedHeader.Text = string.format("PARKED %d/%d", parked, capacity or Config.ParkingSlots)
   backpackHeader.Text = string.format("BACKPACK %d", inventory)
   empty.Visible = #cars == 0
   for id, row in rows do
    if not retained[id] then
     row.frame:Destroy()
     rows[id] = nil
    end
   end
   if saleId and not retained[saleId] then clearSale() end
  end,
 }
end

return View
