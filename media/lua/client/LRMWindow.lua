-- Classe ui di  base per la gestione della finestra di trading (TODO controllare se viene usata e incaso spostarla in client/UI)
LRMWindow = ISCollapsableWindow:derive("LRMWindow");
LRMWindow.compassLines = {}
function LRMWindow:initialise()
	ISCollapsableWindow.initialise(self);
end

function LRMWindow:new(x, y, width, height)
	local o = {};
	o = ISCollapsableWindow:new(x, y, width, height);
	setmetatable(o, self);
	self.__index = self;
	o.title = "Trading Post Inventory";
	o.pin = false;
	o:noBackground();
	return o;
end

function LRMWindow:setText(newText)
	LRMWindow.HomeWindow.text = newText;
	LRMWindow.HomeWindow:paginate();
end


function LRMWindow:createChildren()
	ISCollapsableWindow.createChildren(self);
	self.HomeWindow = ISRichTextPanel:new(0, 16, 375, 455);
	self.HomeWindow:initialise();
	self.HomeWindow.autosetheight = false
	self.HomeWindow:ignoreHeightChange()
	self:addChild(self.HomeWindow)
end

function LRMWindowCreate()
	LRMWindow = LRMWindow:new(35, 250, 375, 455)
	LRMWindow:addToUIManager();
	LRMWindow:setVisible(false);
	LRMWindow.pin = true;
	LRMWindow.resizable = true
end

Events.OnGameStart.Add(LRMWindowCreate);