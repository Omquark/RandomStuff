function Run()
  local cookValues;
  local cookIndex = 0xC3FA07;
  local currentCookedItemIndex = 0x00;
  local cookItemBase = 0xC3F95E;
  local currentItem = 0x00;
  local itemName = "";

  cookValues = {};
  cookValues[0] = memory.readbyte(0X7E1CCD);
  cookValues[1] = memory.readbyte(0X7E1CCE);
  cookValues[2] = memory.readbyte(0X7E1CCF);
  cookValues[3] = memory.readbyte(0X7E1CD0);

  for i = 1, 0x1B do
    for j = 0, 3 do
      local test = string.format("%04X", memory.readbyte(cookIndex - (i * 0x04) - j));
      gui.text(0, j * 8, test);
      test = string.format("%04X", cookIndex - (i * 0x04) - j);
      gui.text(0, (j * 8) + 32, test);
      if cookValues[j] >= memory.readbyte(cookIndex - (i * 0x04) - j) then
        currentCookedItemIndex = i;
        -- local test = string.format("%04X", memory.readbyte(cookIndex - (i * 0x04) - j));
        local test = string.format("%04X", currentCookedItemIndex);
        gui.text(0, 72, test);
        break;
      end
    end
  end

  for i = 0, 0x1B do
    if memory.readbyte(cookItemBase) == currentCookedItemIndex then
      currentItem = i;
    end
  end
  if currentItem == 0x00 then
    currentItem = 0x33;
  end

  for i = 0, 8 do
    if memory.readbyte(0xC70000 + i) == 0x00 then
      break;
    end
    itemName = itemName .. string.char(memory.readbyte(0xC70000 + i));
  end
  -- gui.text(0, 0, itemName);
end


emu.registerbefore(Run);
