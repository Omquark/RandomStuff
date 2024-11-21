function Run()
  local chosenShaman01 = 0x7E1CCF;    --Written to after picking the first shaman, is 0xFF if not picked
  local chosenShaman02 = 0x7E1CD0;    --Written to after picking the second shaman, is 0xFF if not picked
  local selectedShaman = 0x7E1CC7;    --The currently selected shaman index, when selecting on the menu
  local selectedCharacter = 0x7E1CAC; --The currently selected character
  local shamanIndexes = 0xC58A30;     --This is used to pull the index fr the shaman pair we have
  local shamanForm = 0xC58A61;        --This is where the shaman form data starts, this will be the new form or fail
  local shamanBonuses = 0xC58B09;     --This is used to determine the shaman bonuses
  local otherShamanIndex = 0xC1837A;  --Used to find the index of the shaman form

  local shamanPair;
  local selectedPairIndex;
  local shamanFormIndex;
  local currentBonuses;
  local currentCharacter;
  local bonus;
  local rawBonus;
  local actualBonus;

  --Fail if Bleu or Ryu
  if memory.readbyte(selectedCharacter) == 0x00 or memory.readbyte(selectedCharacter) == 0x08 then
    gui.text(0, 0, "Character cannot be united");
    return;
  end

  --If the second shaman is negative, the first shaman is never negative and defaults to 0x00
  if memory.readbyte(chosenShaman02) < 0x80 then
    local shaman1 = memory.readbyte(memory.readbyte(chosenShaman01) + otherShamanIndex);
    local shaman2 = memory.readbyte(memory.readbyte(chosenShaman02) + otherShamanIndex);
    shamanPair = bit.bor(shaman1, shaman2);
  else
    local shaman1 = memory.readbyte(memory.readbyte(chosenShaman01) + otherShamanIndex);
    shamanPair = shaman1;
  end

  --Find the selected pair of shamans, exactly as the game itself does
  selectedPairIndex = memory.readbyte(shamanIndexes + shamanPair) - 1;
  shamanFormIndex = memory.readbyte(memory.readbyte(selectedCharacter) * 21 + selectedPairIndex + shamanForm);

  --Pulled a 0x00, so the form will fail
  if shamanFormIndex == 0x00 then
    gui.text(0, 0, "Shaman form will fail");
    return;
  end

  --The location of the shaman bonuses. These are in sets of 0x08
  currentBonuses = shamanBonuses + (shamanFormIndex * 0x08)

  --Check whcih character is selected by checking the character byte
  for i = 0x7E51E6, 0x7E5E36, 0x40 do
    if memory.readbyte(i) == memory.readbyte(selectedCharacter) then
      currentCharacter = i - 6;
      break;
    end
  end


  --Print the bonuses
  --Offense Bonus
  bonus = memory.readbyte(currentBonuses + 0x00);
  --Find the raw bonus
  rawBonus = bonus * memory.readbyte(currentCharacter + 0x11);
  --And add to the current offense. Adding to raw strength calculates out wrong
  actualBonus = memory.readbyte(currentCharacter + 0x22) + (rawBonus / 0x100);
  gui.text(0, 0, "New Offense will be: " .. math.min(math.floor(actualBonus), 999));

  --Defense Bonus
  bonus = memory.readbyte(currentBonuses + 0x01);
  rawBonus = bonus * memory.readbyte(currentCharacter + 0x12);
  actualBonus = memory.readbyte(currentCharacter + 0x24) + (rawBonus / 0x100);
  gui.text(0, 8, "New Defense will be: " .. math.min(math.floor(actualBonus), 999));

  --Vigor Bonus
  bonus = memory.readbyte(currentBonuses + 0x02);
  --Vigor is 2 bytes
  rawBonus = bonus * memory.readbyte(currentCharacter + 0x13);
  rawBonus = rawBonus + (memory.readbyte(currentCharacter + 0x14) * 0x100);
  actualBonus = memory.readbyte(currentCharacter + 0x26) + (rawBonus / 0x100);
  gui.text(0, 16, "New Vigor will be: " .. math.min(math.floor(actualBonus), 511));

  --Wisdom bonus
  bonus = memory.readbyte(currentBonuses + 0x03);
  rawBonus = bonus * memory.readbyte(currentCharacter + 0x2C);
  actualBonus = memory.readbyte(currentCharacter + 0x28) + (rawBonus / 0x100);
  gui.text(0, 24, "New Wisdom will be: " .. math.min(math.floor(actualBonus), 255));

  --No luck bonus, but print it anyway
  bonus = memory.readbyte(currentBonuses + 0x04);
  rawBonus = bonus * memory.readbyte(currentCharacter + 0x2D);
  actualBonus = memory.readbyte(currentCharacter + 0x29) + (rawBonus / 0x100);
  gui.text(0, 32, "New Luck should be: " .. math.min(math.floor(actualBonus), 255) .. " This will have no effect");

  --New max AP
  bonus = memory.readbyte(currentBonuses + 0x05);
  rawBonus = bonus * memory.readbyte(currentCharacter + 0x0E);
  rawBonus = rawBonus + (memory.readbyte(currentCharacter + 0x0F) * 0x100);
  actualBonus = memory.readbyte(currentCharacter + 0x0E) + (rawBonus / 0x100);
  gui.text(0, 40, "New Max AP will be: " .. math.min(math.floor(actualBonus), 511));
end

emu.registerbefore(Run);
