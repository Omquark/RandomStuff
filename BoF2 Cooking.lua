--This script will tell you what item you will cook without actually needing to waste items.
--There is always a chance for a charcoal, so save before the cook. If you get a charcoal, try again
--There may be some cases which are not covered by this script, in which case, the item received
--will not be what is shown, or a charcoal. If you consistently get charcoals and shouldn;t,
--hte script is wrong and needs to covoer this use case

function Run()
  local recipeIndexBase = 0xC3F998; --Where the recipes start in the ROM
  local ingredientBase = 0x7E1CCD;  --The ingredients in the RAM
  local recipeIndexSize = 0x6F;     --How many recipes are in the recipe list
  local resultItemSlot = 0x01; --Used to get the item slot to read the item name
  local resultItemBaseAddress = 0xC3F95E; --The the result item lookup
  local itemBaseAddress = 0xC70000; --The base address of the items

  local itemName = ""; --Used to show the item name

  local currentRecipeResult; --The current recipe we will create by cooking

  local i = recipeIndexBase + recipeIndexSize;
  --Special condition for a GoldBar
  if memory.readbyte(0x7E1CD0 >= 0x60) then
    currentRecipeResult = 0x39;
  end
  
  --Loop until we find a recipe which matches the conditions, all values in the ROM must be
  -- less or equal to the RAM AND neither must be 0 ONLY when the other is not
  while i >= recipeIndexBase and currentRecipeResult do
    local foundRecipe = true;
    for j = 0, 3 do
      --This is a negative condition, must be ROM < RAM and ROM == 0 XOR RAM == 0
      if memory.readbyte(ingredientBase + 3 - j) < memory.readbyte(i - j) or
          (memory.readbyte(ingredientBase + 3 - j) == 0 and memory.readbyte(i - j) ~= 0) or
          (memory.readbyte(ingredientBase + 3 - j) ~= 0 and memory.readbyte(i - j) == 0)
      then
        foundRecipe = false;
        break;
      end
    end
    if foundRecipe == true then
      --We found a recipe, so prepare the next step
      break;
    end
    i = i - 4;
  end

  --Divide the result by 4 and round down
  currentRecipeResult = math.floor((i - recipeIndexBase) / 0x04);
  while true do
    --One item always give s a charcoal
    if memory.readbyte(0X7E1CDD) <= 0x01 then --If one item is cooked
      resultItemSlot = 0x33;
      break;
    end
    local itemSlot = memory.readbyte(resultItemBaseAddress + resultItemSlot)
    --We loop through to see if the table is the same as when we found, and break when we do
    if itemSlot == currentRecipeResult then
      break;
    end
    --A hard limit. Going beyone this would result in getting unpredictable items
    if resultItemSlot >= 0x39 then
      resultItemSlot = 0x33;
      break;
    end
    resultItemSlot = resultItemSlot + 1;
  end

  --Now get the item name
  for j = 0, 7 do
    if memory.readbyte(itemBaseAddress + (resultItemSlot * 0x10) + j) == 0 then break end
    itemName = itemName .. string.char(memory.readbyte(itemBaseAddress + (resultItemSlot * 0x10) + j));
  end
  --And print
  gui.text(0, 0, "You will cook " .. itemName);
end

emu.registerbefore(Run); --Register the function to run before emmulating
