require "ISUI/ISCollapsableWindow"

ISItemManageUI = ISCollapsableWindow:derive("ISItemManageUI");

function ISItemManageUI:initialise()
    ISCollapsableWindow.initialise(self);
end

function ISItemManageUI:prerender()
    self:drawRect(0, self:titleBarHeight(), self.width, self.height-self:titleBarHeight(), 1, 0, 0, 0);
    ISCollapsableWindow.prerender(self);

    if self.prerenderFunc then
        self.prerenderFunc(self);
    end

    if self.isSubUI and not self.parentUI.isUIVisible then
        self:close();
    end
end

function ISItemManageUI:addLineToMatrices(isLastLine)
    local i = self.lineAct;
    local nbElemWidthForce = 0;
    local widthLeft = self.pxlW;
    self.elemW[i] = {};
    self.elemX[i] = {};
    local nbElement = self.lineColumnCount[i]; -- Number of element in the line
    local w = math.floor(self.pxlW / nbElement); -- Size of element

    for j=1,self.lineColumnCount[i] do -- Check if an element got this width force
        if self.matriceLayout[i][j].isWidthForce then 
            nbElemWidthForce = nbElemWidthForce + 1;
            widthLeft = widthLeft - self.matriceLayout[i][j].pxlW;
        end
    end

    for j=1,self.lineColumnCount[i] do -- For every column in line
        if nbElemWidthForce ~= 0 or self.forceColumnWidht ~= {} then
            if widthLeft < 1 then
                print("UI API - ERROR : At line ".. i .." of the UI " .. self:getTitle() .. ". Width set to element wider that the window width.");
            end
            local nbElementLeft = nbElement - nbElemWidthForce;
            local w = math.floor(widthLeft / nbElementLeft); -- Size of element
            local elem = self.matriceLayout[i][j];

            -- Set size of element
            if elem.isWidthForce then -- Id the element get this width force
                self.elemW[i][j] = elem.pxlW;
            elseif self.forceColumnWidht[j] ~= nil then -- If width of the column is set
                self.elemW[i][j] = self.forceColumnWidht[j];
            else
                self.elemW[i][j] = w;
            end

            -- Set x position of element
            if j == 1 then 
                self.elemX[i][j] = 0;
            else
                self.elemX[i][j] = self.elemX[i][j-1] + self.elemW[i][j-1]; -- set position
            end
        else
            self.elemW[i][j] = w; -- set size
            self.elemX[i][j] = w * (j-1); -- set position
        end
    end

     -- Set size of last element to the border in case pixel is lost with math.floor
    if self.lineColumnCount[i] > 0 and not self.matriceLayout[i][self.lineColumnCount[i]].isImage then
        self.elemW[i][self.lineColumnCount[i]] = self.pxlW - self.elemX[i][self.lineColumnCount[i]];
    elseif self.lineColumnCount[i] > 0 and self.matriceLayout[i][self.lineColumnCount[i]].isImage then
        self:setWidthPixel(self.elemX[i][self.lineColumnCount[i]] + self.elemW[i][self.lineColumnCount[i]])
    elseif not isLastLine then
        print("UI API - ERROR : LINE " .. i .." WITHOUT ELEMENT")
    end
end


function ISItemManageUI:setElementsPositionAndSize()
    for index, value in ipairs(self.noNameElements) do
        value:setPositionAndSize()
    end
    for index, value in pairs(self.namedElements) do
        value:setPositionAndSize()
    end
end

function ISItemManageUI:setBorderToAllElements(v)
    for index, value in ipairs(self.noNameElements) do
        value:setBorder(v)
    end
    for index, value in pairs(self.namedElements) do
        value:setBorder(v)
    end
end

function ISItemManageUI:new(pctX, pctY, pctW)
    local x = getCore():getScreenWidth() * pctX;
    local y = getCore():getScreenHeight() * pctY;
    local w = getCore():getScreenWidth() * pctW;
    local o = {};
    o = ISCollapsableWindow:new(x, y, w, 1);
    setmetatable(o, self);
    self.__index = self;

    o:setHeight(o:titleBarHeight());

    -- Position
    o.pctX = pctX;
    o.pctY = pctY;
    o.pxlX = o.pctX * getCore():getScreenWidth();
    o.pxlY = o.pctY * getCore():getScreenHeight();

    --Size
    o.pctW = pctW;
    o.pxlW = o.pctW * getCore():getScreenWidth();

    -- My stuff
    o.noNameElements = {}; -- List of elements with no name
    o.namedElements = {}; -- List of elements with name
    o.lineAct = 1; -- Actual line of the UI
    o.elemY = {}; -- y position for each line
    o.elemH = {}; -- height for each line
    o.elemW = {};
    o.elemX = {};
    o.lineColumnCount = {}; -- Number of columns in a line
    o.columnAct = 0; -- Actual columns of the UI
    o.yAct = o:titleBarHeight(); -- Actual position
    o.forceColumnWidht = {};
    o.deltaY = 0;
    o.lineHaveImages = false;
    o.isUIVisible = true;
    o.defaultLineHeight = getTextManager():getFontHeight(UIFont.Small) + 4;
    o.matriceLayout = {} -- Matrice of the layout, like that matriceLayout[line][column]
    table.insert(o.elemY, o.yAct);
    table.insert(o.lineColumnCount, 0);

    -- ISCollapsableWindow stuff
    o.resizable = false;
    o.drawFrame = true;
    return o;
end


-- Toggle

function ISItemManageUI:open()
    if not self.isUIVisible then
        self:setVisible(true);
        self.isUIVisible = true;
    end
end

function ISItemManageUI:close()
    if self.isUIVisible then
        self:setVisible(false);
        self.isUIVisible = false;
    end
end

function ISItemManageUI:toggle()
    if self.isUIVisible then
        self:setVisible(false);
        self.isUIVisible = false;
    else
        self:setVisible(true);
        self.isUIVisible = true;
    end
end


function ISItemManageUI:isVisible()
    return self.isUIVisible
end


-- Line and column

function ISItemManageUI:nextLine()
    self:addLineToMatrices();
        
    self.columnAct = 0;
    if self.lineHaveImages and not self.lineHeightForce then
        self.lineHaveImages = false;
        for index, value in ipairs(self.matriceLayout[self.lineAct]) do
            if value.isImage then
                if self.deltaY < self.elemW[value.line][value.column] * value.ratio then self.deltaY = self.elemW[value.line][value.column] * value.ratio
                else self.elemW[value.line][value.column] = self.deltaY / value.ratio;
                end
            end
        end
        for index, value in ipairs(self.matriceLayout[self.lineAct]) do
            if value.isImage then
                if self.deltaY < self.elemW[value.line][value.column] * value.ratio then self.deltaY = self.elemW[value.line][value.column] * value.ratio
                else self.elemW[value.line][value.column] = self.deltaY / value.ratio;
                end
            end
        end
    end
    
    self.lineHeightForce = false;
    self.lineAct = self.lineAct + 1;
    self.yAct = self.yAct + self.deltaY;
    table.insert(self.elemH, self.deltaY);
    self.deltaY = 0;
    table.insert(self.elemY, self.yAct);
    table.insert(self.lineColumnCount, 0);
end

function ISItemManageUI:initAndAddToTable(newE, name)
    newE:initialise();
    newE:instantiate();
    self:addChild(newE);

    if name and self[name] ~= nil then 
        print("UI API - ERROR : element name '" .. name .. "' is already a variable name. Change it !")
    end

    if name == "" or not name then
        table.insert(self.noNameElements, newE);
    else
        self.namedElements[name] = newE;
        self[name] = newE;
    end

    if not self.matriceLayout[self.lineAct] then self.matriceLayout[self.lineAct] = {} end
    self.matriceLayout[self.lineAct][self.columnAct] = newE;
end

function ISItemManageUI:setLineHeightPercent(pctH)
    self.deltaY = pctH * getCore():getScreenHeight();
    self.lineHeightForce = true;
end

function ISItemManageUI:setLineHeightPixel(pxlH)
    self.deltaY = pxlH;
    self.lineHeightForce = true;
end

function ISItemManageUI:setColumnWidthPercent(column, pctW)
    self.forceColumnWidht[column] = pctW * getCore():getScreenWidth();
end

function ISItemManageUI:setColumnWidthPixel(column, pxlW)
    self.forceColumnWidht[column] = pxlW;
end

function ISItemManageUI:nextColumn()
     -- Not use by user
     -- Add a column
     self.lineColumnCount[self.lineAct] = self.lineColumnCount[self.lineAct] + 1;
     self.columnAct = self.columnAct + 1;
end

function ISItemManageUI:saveLayout()
    self:nextLine();
    self:setHeight(self.yAct);
    self:setElementsPositionAndSize();

    -- Remove collapse button
    self.collapseButton:setVisible(false);
    self.pinButton:setVisible(false);

    self:addToUIManager();
    self:setResizable(true);
    self:setInCenterOfScreen();
end

function ISItemManageUI:isSubUIOf(parent)
    self.isSubUI = true;
    self.parentUI = parent;
end


-- Elements

function ISItemManageUI:addEmpty(name, nb, pctW, pxlW)
    if not nb then nb = 1 end
    if nb == 1 then
        self:nextColumn();
        local newE = MyISSimpleEmpty:new(self);
        if name and name ~= "" then 
            self:initAndAddToTable(newE, name);
        else
            self:initAndAddToTable(newE, "");
        end

        if pctW then
            newE:setWidthPercent(pctW);
        elseif pxlW then
            newE:setWidthPixel(pxlW);
        end
    else
        for i=1,nb do
            self:nextColumn();
            local newE = MyISSimpleEmpty:new(self);
            if name and name ~= "" then 
                self:initAndAddToTable(newE, name .. i);
            else
                self:initAndAddToTable(newE, "");
            end

            if pctW then
                newE:setWidthPercent(pctW);
            elseif pxlW then
                newE:setWidthPixel(pxlW);
            end
        end
    end

    -- Add to yAct
    local deltaY = self.defaultLineHeight;
    if self.deltaY < deltaY then self.deltaY = deltaY end
end

function ISItemManageUI:addText(name, txt, font, position)
    self:nextColumn();
    
     -- Create element
    local newE = MyISSimpleText:new(self, txt, font, position);
    self:initAndAddToTable(newE, name);

    -- Add to yAct
    local deltaY = self.defaultLineHeight;
    if self.deltaY < deltaY then self.deltaY = deltaY end
end

function ISItemManageUI:addProgressBar(name, value, min, max)
    self:nextColumn();
    
     -- Create element
    local newE = MyISSimpleProgressBar:new(self, value, min, max);
    self:initAndAddToTable(newE, name);

    -- Add to yAct
    local deltaY = self.defaultLineHeight;
    if self.deltaY < deltaY then self.deltaY = deltaY end
end

function ISItemManageUI:addRichText(name, text)
    self:nextColumn();
    
    -- Create element
    local newE = MyISSimpleRichText:new(self, text);
    self:initAndAddToTable(newE, name);

   -- Add to yAct
   local deltaY = self.defaultLineHeight * 8;
   if self.deltaY < deltaY then self.deltaY = deltaY end
end

function ISItemManageUI:addButton(name, text, func)
    self:nextColumn();
    
     -- Create element
    local newE = MyISSimpleButton:new(self, text, func);
    self:initAndAddToTable(newE, name);

    -- Add to yAct
    local deltaY = self.defaultLineHeight;
    if self.deltaY < deltaY then self.deltaY = deltaY end
end

function ISItemManageUI:addTickBox(name)
    self:nextColumn();
    
     -- Create element
    local newE = MyISSimpleTickBox:new(self);
    self:initAndAddToTable(newE, name);

    -- Add to yAct
    local deltaY = self.defaultLineHeight;
    if self.deltaY < deltaY then self.deltaY = deltaY end
end

function ISItemManageUI:addEntry(name, text, isNumber)
    self:nextColumn();
    
     -- Create element
    local newE = MyISSimpleEntry:new(self, text, isNumber);
    self:initAndAddToTable(newE, name);

    -- Add to yAct
    local deltaY = self.defaultLineHeight;
    if self.deltaY < deltaY then self.deltaY = deltaY end
end

function ISItemManageUI:addComboBox(name, items)
    self:nextColumn();
    
     -- Create element
    local newE = MyISSimpleComboBox:new(self, items);
    self:initAndAddToTable(newE, name);

    -- Add to yAct
    local deltaY = self.defaultLineHeight * 1.5;
    if self.deltaY < deltaY then self.deltaY = deltaY end
end

function ISItemManageUI:addScrollList(name, items)
    self:nextColumn();
    
     -- Create element
    local newE = MyISSimpleScrollingListBox:new(self, items);
    newE.isScrollList = true;
    self:initAndAddToTable(newE, name);

    -- Add to yAct
    local deltaY = self.defaultLineHeight * 8;
    if self.deltaY < deltaY then self.deltaY = deltaY end
end

function ISItemManageUI:addImage(name, path)
    self:nextColumn();
    self.lineHaveImages = true;
    
    -- Create element
   local newE = MyISSimpleImage:new(self, path);
   self:initAndAddToTable(newE, name);

   -- Add to yAct
   local deltaY = self.defaultLineHeight;
   if self.deltaY < deltaY then self.deltaY = deltaY end
end

function ISItemManageUI:addImageButton(name, path, func)
    self:nextColumn();
    self.lineHaveImages = true;
    
     -- Create element
    local newE = MyISSimpleImageButton:new(self, path, func);
    self:initAndAddToTable(newE, name);

    -- Add to yAct
    local deltaY = self.defaultLineHeight;
    if self.deltaY < deltaY then self.deltaY = deltaY end
end


-- Position and size

function ISItemManageUI:setPositionPercent(pctX, pctY)
    self.pctX = pctX;
    self.pctY = pctY;
    self.pxlX = pctX * getCore():getScreenWidth();
    self.pxlY = pctY * getCore():getScreenHeight();
    self:setX(self.pxlX);
    self:setY(self.pxlY);
end

function ISItemManageUI:setPositionPixel(pxlX, pxlY)
    self.pxlX = pxlX;
    self.pxlY = pxlY;
    self.pctX = pxlX / getCore():getScreenWidth();
    self.pctY = pxlY / getCore():getScreenHeight();
    self:setX(self.pxlX);
    self:setY(self.pxlY);
end

function ISItemManageUI:setXPercent(pctX)
    self.pctX = pctX;
    self.pxlX = pctX * getCore():getScreenWidth();
    self:setX(self.pxlX);
end

function ISItemManageUI:setXPixel(pxlX)
    self.pxlX = pxlX;
    self.pctX = pxlX / getCore():getScreenWidth();
    self:setX(self.pxlX);
end

function ISItemManageUI:setYPercent(pctY)
    self.pctY = pctY;
    self.pxlY = pctY * getCore():getScreenHeight();
    self:setX(self.pxlY);
end

function ISItemManageUI:setYPixel(pxlY)
    self.pxlY = pxlY;
    self.pctY = pxlY / getCore():getScreenHeight();
    self:setX(self.pxlY);
end

function ISItemManageUI:setWidthPercent(pctW)
    self.pctW = pctW;
    self.pxlW = pctW * getCore():getScreenWidth();
    self:setWidth(self.pxlW);
end

function ISItemManageUI:setWidthPixel(pxlW)
    self.pctW = pxlW / getCore():getScreenWidth();
    self.pxlW = pxlW;
    self:setWidth(self.pxlW);
end

function ISItemManageUI:setInCenterOfScreen()
    self.pxlX = (getCore():getScreenWidth() - self:getWidth()) / 2 ;
    self.pxlY = (getCore():getScreenHeight() - self:getHeight()) / 2;
    self.pctX = self.pxlX / getCore():getScreenWidth();
    self.pctY = self.pxlY / getCore():getScreenHeight();
    self:setX(self.pxlX);
    self:setY(self.pxlY);
end

function ISItemManageUI:setDefaultLineHeightPercent(pctH)
    self.defaultLineHeight = pctH * getCore():getScreenHeight();
end

function ISItemManageUI:setDefaultLineHeightPixel(pxlH)
    self.defaultLineHeight = pxlH;
end

function ISItemManageUI:getDefaultLineHeightPercent()
    return self.defaultLineHeight / getCore():getScreenHeight();
end

function ISItemManageUI:getDefaultLineHeightPixel()
    return self.defaultLineHeight;
end


-- Key

function ISItemManageUI:setKeyMN (k)
    self.key = k;
end


-- Add function to prerender

function ISItemManageUI:addPrerenderFunction(k)
    self.prerenderFunc = k;
end


-- For collapse if click

function ISItemManageUI:setCollapse(v)
    if v then
        self.canCollapse = v;
        if self.pin then
            self.collapseButton:setVisible(true);
            self.pinButton:setVisible(false);
        else
            self.collapseButton:setVisible(false);
            self.pinButton:setVisible(true);
        end
    else
        self.collapseButton:setVisible(false);
        self.pinButton:setVisible(false);
        self.canCollapse = v;
    end
end

function ISItemManageUI:onMouseDownOutside(x, y) -- Add don't collapse if in subUI
    if((self:getMouseX() < 0 or self:getMouseY() < 0 or self:getMouseX() > self:getWidth() or self:getMouseY() > self:getHeight()) and not self.pin and self.canCollapse) then
        self.isCollapsed = true;
        self.wasCollapsed = true;
        self:setMaxDrawHeight(self:titleBarHeight());
        self.lastHeight = self:getHeight();
        if self.collapseBottom then
            self:setHeightAndParentHeight(self:titleBarHeight());
            self:setY(self:getY() + self.heightAbs - self:titleBarHeight())
        end
    end
end

function ISItemManageUI:isAdminChild()
    if not self.parentUI then return false end
    return self.parentUI:getTitle() == getText("UI_Page_Admin")
end

function ISItemManageUI:buildItemNameList(tables, filter, editable)
    local itemNames = {}
    local itemList = {}
    local scriptManager = getScriptManager()
    local price
    for k, v in pairs(tables) do
        local item = scriptManager:getItem(k)
        if item then 
            if filter == ""  then
                price = string.format("%1.2f", v)
                if not editable then
                    price = math.floor(v * 100)
                end
                table.insert(itemNames, getText("UI_List_Item2", price) .. string.format("%20s", "") .. string.format("%-80s", getText("UI_List_Item1", item:getDisplayName(), k)))
                table.insert(itemList, { k, v })
            elseif filter and string.contains(string.lower(item:getDisplayName()), string.lower(filter)) then
                price = string.format("%1.2f", v)
                if not editable then
                    price = math.floor(v * 100)
                end
                table.insert(itemNames, getText("UI_List_Item2", price) .. string.format("%20s", "") .. string.format("%-80s", getText("UI_List_Item1", item:getDisplayName(), k)))
                table.insert(itemList, { k, v })
            end
        end
    end
    return itemNames, itemList
end

function ISItemManageUI:filter()
    local filterText = string.trim(self["FilterItems"]:getInternalText())
    local itemNames, itemList = self:buildItemNameList(ItemValueTable, filterText, self:isAdminChild())
    if ItemManageUI["ItemList"] then
        ItemManageUI["ItemList"]:setItems(itemNames)
        ItemManageUI["ItemList"]:setOnMouseDownFunction(_, function(_, _)
            if isAdmin() and getPlayer():getAccessLevel() ~= "None" then
                local i = ItemManageUI["ItemList"].mouseoverselected
                print(i)
                toAdd = {}
                local j = 1
                for k,v in ipairs (itemList) do
                    if i == j then
                        local fullType = v[1]
                        toAdd[fullType] = 10
                        print(k)
                        print(v[1])
                    end
                    j = j + 1
                end
                LRM.UpdateOnServer(toAdd);
           end
        end)
    end
end


function ISItemManageUI:update()
  --  if not self.parent:getIsVisible() then return end
  if self["FilterItems"] ~= nil then
    local text = string.trim(self["FilterItems"]:getInternalText())
    if text ~= self.lastText then
        self:filter()
        self.lastText = text
    end
  end
end


function NewISItemManageUI()
    local ui = ISItemManageUI:new(0.4, 0.4, 0.2)
    ui:initialise();
    ui:instantiate();
    --table.insert(allUI, ui);
    return ui
end