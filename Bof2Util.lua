function Run()
	local last_press = {};
	local last_rng = 0;
	local lock_rng = false;
	local inc_rng = false;
	local text_timer = 0;
	local message;

	while (true) do
		gui.text(0, 216, "M - Display menu");
		local cur_press = input.get();

		if text_timer > 0 then
			text_timer = text_timer - 1;
			gui.text(0, 8, message);
		end

		if cur_press["W"] and not last_press["W"] then
			message = ("locking rng");
			text_timer = 90;
			last_rng = memory.readword(0x8100D6);
			lock_rng = true;
			last_press = cur_press;
		elseif cur_press["S"] and not last_press["S"] then
			text_timer = 90;
			message = ("unlocking rng");
			last_rng = memory.readword(0x8100D6);
			lock_rng = false;
			last_press = cur_press;
		elseif cur_press["A"] and not last_press["A"] then
			text_timer = 90;
			message = ("incrementing rng");
			last_rng = memory.readword(0x8100D6);
			inc_rng = true;
			lock_rng = true;
			last_press = cur_press;
		elseif cur_press["M"] and not last_press["M"] then
			DisplayOptions();
		end



		if last_press["A"] and not cur_press["A"] then
			last_press = {};
		end

		if lock_rng then
			if not inc_rng then
				memory.writeword(0x8100D6, last_rng);
			else
				inc_rng = false;
			end
		end

		gui.text(0, 16, "step_counter");
		gui.text(52, 16, string.format("%02X", memory.readbyte(0x7E12DC)));

		emu.frameadvance();

		GenerateRNG();
		DisplayMobGrid();
	end
end

function GenerateRNG()
	local rng_val = string.format("%04X", memory.readword(0x8100D6));
	gui.text(0, 0, rng_val);
end

function DisplayOptions()
	gui.text(0, 208, "W - Lock RNG");
	gui.text(0, 200, "S - Unlock RNG");
	gui.text(0, 192, "A - Increment RNG");
end

function DisplayMobGrid()
	local gridX;
	local gridY;
	local gridOffset;
	local mouldPtr;
	local mouldPtrTable;
	local monsterTable;
	local monsterPtrTable;
	local monsterNameTable;

	if (memory.readbyte(0x7E0C99) == 0x00) then
		gridX = math.floor((memory.readbyte(0x7E0D39) / 16));
		gridY = math.floor((memory.readbyte(0x7E0D3B) / 16)) * 16;
		gridOffset = gridY + gridX;
		mouldPtr = 0;
		mouldPtrTable = {};
		monsterTable = {};
		monsterPtrTable = {};
		monsterNameTable = "";

		mouldPtr = memory.readbyte(0xC55460 + gridOffset) * 8;

		for i = 0, 7 do --Cycle through the moulds
			mouldPtrTable[i] = memory.readbyte(0xC55660 + mouldPtr + i);
			monsterTable[i] = (0xC57DF0 + (mouldPtrTable[i] * 7));

			for j = 1, 6, 1 do --Cycle through monster moulds
				monsterNameTable = "";
				monsterPtrTable[i * 6 + j] = 0xC59000 + memory.readbyte(monsterTable[i] + j) * 32;
				for k = 0, 7, 1 do --Cycle through enemy names
					if monsterPtrTable[i * 6 + j] >= 0xC5AFE0 or memory.readbyte(monsterPtrTable[i * 6 + j] + k) == 0x00 then
						break;
					end
					monsterNameTable = monsterNameTable .. string.char(memory.readbyte(monsterPtrTable[i * 6 + j] + k));
				end
				if i < 4 then
					gui.text(40 * i, (j * 8) + 64, monsterNameTable);
				else
					gui.text(40 * (i - 4), (j * 8) + 112, monsterNameTable);
				end
			end
		end
	else
		mouldPtrTable = {};
		monsterTable = {};
		monsterPtrTable = {};
		monsterNameTable = "";

		gridOffset = memory.readword(0x7E0C99);
		if (gridOffset > 0x80) then
			gridOffset = gridOffset - 0x0110;
		end
		gridOffset = gridOffset - 0x20;

		mouldPtr = gridOffset * 8;

		for i = 0, 7 do --Cycle through the moulds
			mouldPtrTable[i] = memory.readbyte(0xC55CC0 + mouldPtr + i);
			monsterTable[i] = (0xC57DF0 + (mouldPtrTable[i] * 7));

			for j = 1, 6, 1 do --Cycle through monster moulds
				monsterNameTable = "";
				monsterPtrTable[i * 6 + j] = 0xC59000 + memory.readbyte(monsterTable[i] + j) * 32;
				for k = 0, 7, 1 do --Cycle through enemy names
					if monsterPtrTable[i * 6 + j] >= 0xC5AFE0 or memory.readbyte(monsterPtrTable[i * 6 + j] + k) == 0x00 then
						break;
					end
					monsterNameTable = monsterNameTable .. string.char(memory.readbyte(monsterPtrTable[i * 6 + j] + k));
				end
				if i < 4 then
					gui.text(40 * i, (j * 8) + 64, monsterNameTable);
				else
					gui.text(40 * (i - 4), (j * 8) + 112, monsterNameTable);
				end
			end
		end
	end
end

Run();
