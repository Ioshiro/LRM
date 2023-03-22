
function addLine(UI)
    if not UI then
        return
    end

    --if height == nil then
    --    height = 50
    --end

    UI:addEmpty()
    UI:nextLine()
end

function addConditionUI(item, window, uiName, uiName2)

    if not item or not window then
        return
    end

    if not item.age and not item.usedDelta then
        window:addText(uiName, getText("UI_item_Condition"), _, "Left")
        window:setLineHeightPercent(0.04)
        window:nextLine()

        window:addProgressBar(uiName2, item.condition, 0, 100)
        window[uiName2]:setBorder(true)

        window[uiName2]:setMarginPixel(10, 1)
        window:nextLine()
        addLine(window)

    end
end

function addUsedDeltaUI(item, window, uiName, uiName2)
    if not item or not window then
        return
    end

    if item.usedDelta then
        window:addText(uiName, getText("UI_Item_Delta"), _, "Left")
        window:setLineHeightPercent(0.04)
        window:nextLine()

        window:addProgressBar(uiName2, math.floor(item.usedDelta * 100), 0, 100)
        window[uiName2]:setBorder(true)
        window[uiName2]:setMarginPixel(10, 1)

        window:nextLine()
        addLine(window)
    end


end

function addAgeUI(item, window, uiName, uiName2, uiName3)

    if item.age then

        local ageStep, ageProgress, stepText = getAge(item)

        --local stepText = ""
        --local ageValue
        --local lastAge = item.age + getGameTime():getWorldAgeHours() - item.curAge
        --if lastAge < item.offAge then
        --    ageValue = item.offAge - lastAge
        --    stepText = getText("UI_item_NewAge", string.format("%1.1f", ageValue))
        --elseif lastAge < item.offAgeMax then
        --    ageValue = item.offAgeMax - lastAge
        --    stepText = getText("UI_item_OffAge", string.format("%1.1f", ageValue))
        --else
        --    ageValue = 0
        --    stepText = getText("UI_item_OffAgeMax")
        --end


        window:addText("", getText("UI_Item_HungChange"), _, "Center")
        window:addText("HungValue", string.format("%1.1f", item.hungerChange * 100.0), "MainMenu2", "Left")
        if item.hungChange < 0 then
            window["HungValue"]:setColor(1, 0, 1, 0)
        else
            window["HungValue"]:setColor(1, 1, 0, 0)
        end
        window:addText("", getText("UI_Item_ThirstChange"), _, "Center")
        window:addText("ThirstValue", string.format("%1.1f", item.thirstChange * 100.0), "MainMenu2", "Left")
        if item.thirstChange < 0 then
            window["ThirstValue"]:setColor(1, 0, 1, 0)
        else
            window["ThirstValue"]:setColor(1, 1, 0, 0)
        end

        window:setLineHeightPercent(0.04)
        window:nextLine()
        --addLine(window)

        window:addText(uiName, getText("UI_item_Age"), _, "Left")
        window[uiName]:setMarginHorizontal(20)
        window:nextLine()
        window:addText(uiName2, stepText, "Large", "Left")
        if ageStep == 0 then
            window[uiName2]:setColor(1, 0, 1, 0)
        elseif ageStep == 1 then
            window[uiName2]:setColor(1, 1, 0.5, 0)
        elseif ageStep == 2 then
            window[uiName2]:setColor(1, 1, 0, 0)
        end

        window[uiName2]:setMarginHorizontal(20)
        window:setLineHeightPercent(0.04)
        window:nextLine()
        --addLine(window)

        window:addProgressBar(uiName3, ageProgress, 0, 100)
        window[uiName3]:setBorder(true)
        window[uiName3]:setMarginPixel(10, 1)
        window:nextLine()

        addLine(window)
        --window:addEmpty()
        --window:nextLine()

    end

end
