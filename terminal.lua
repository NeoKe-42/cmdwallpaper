-- Wallpaper Engine Scene Lua - Terminal-style system info + media display

local json = require("rapidjson")
local SYS_FILE = "system_info.json"

local display  = thisScene:getObjectByName("display")
local lastSys  = 0
local cached   = {}
local song     = { title = nil, artist = nil, album = nil, pos = 0, dur = 0, start = 0 }
local eqLevels = {}
for i = 1, 64 do eqLevels[i] = 0 end

-- =========== Audio callback ===========
function onAudioData(levels)
	if levels then
		for i = 1, #levels do eqLevels[i] = levels[i] or 0 end
	end
end
thisScene:registerAudioDataCallback("onAudioData")

-- =========== Helpers ===========
local function fm(gb)
	if gb >= 1000 then return string.format("%.1f TB", gb/1024) end
	return string.format("%.1f GiB", gb)
end

local function pbar(pct, w, cR, cG, cB)
	w = w or 25
	local fill = math.floor(math.min(100, math.max(0, pct)) / 100 * w + 0.5)
	local s = ""
	for i = 1, fill do s = s .. "█" end
	return s, w - fill
end

local function fmtTime(sec)
	sec = math.max(0, math.floor(tonumber(sec) or 0))
	return string.format("%d:%02d", math.floor(sec/60), sec%60)
end

local function esc(s)
	return (s or ""):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
end

-- =========== System info reader ===========
local function readSys()
	local f = io.open(SYS_FILE, "r")
	if not f then return nil end
	local c = f:read("*all")
	f:close()
	local ok, d = pcall(function() return json.decode(c) end)
	if ok then return d end
	return nil
end

-- =========== EQ band ===========
local function eqBand(label, a, b)
	local sum, cnt = 0, 0
	for i = a, b do sum = sum + (eqLevels[i] or 0); cnt = cnt + 1 end
	local lvl = cnt > 0 and math.min(100, (sum/cnt)*100) or 0
	local fill, empty = pbar(lvl, 14)
	return string.format("%-5s %s%s %3d%%", label, fill, string.rep("█", empty), math.floor(lvl))
end

-- =========== Media info ===========
local function getMedia()
	-- Wallpaper Engine's media info API
	local ok, info = pcall(function()
		return thisScene:getMediaInfo()
	end)
	if ok and info then return info end
	return nil
end

-- =========== Build display ===========
local function build(d, now, media)
	local lines = {}
	local s = d or cached

	-- Title bar
	local u = "?"
	local h = "?"
	if s.system then u = s.system.username or "?"; h = s.system.hostname or "?" end
	lines[#lines+1] = string.format("● ● ●  %s@%s:~/", u, h)

	-- Time
	local t = os.date("*t", now)
	local dayPct = (t.hour*3600 + t.min*60 + t.sec) / 86400 * 100
	local tbFill, tbEmpty = pbar(dayPct, 20)
	lines[#lines+1] = string.format("%s | %s%s %5.1f%% | %s",
		os.date("%H:%M:%S", now),
		tbFill, string.rep("█", tbEmpty),
		dayPct,
		os.date("%Y-%m-%d %a", now))

	-- System info
	if s.system then
		lines[#lines+1] = string.format("user      ~ %s", esc(s.system.username or "?"))
		lines[#lines+1] = string.format("host      ~ %s", esc(s.system.hostname or "?"))
	end
	lines[#lines+1] = string.rep("─", 42)

	if s.os then
		lines[#lines+1] = string.format("os        ~ %s %s (%s)",
			esc(s.os.name or "?"), esc(s.os.version or ""), esc(s.os.architecture or ""))
	end
	if s.cpu then
		local cn = esc(s.cpu.name or "?")
		lines[#lines+1] = string.format("cpu       ~ %s", cn)
		lines[#lines+1] = string.format("            %d C / %d T @ %d MHz",
			s.cpu.cores or 0, s.cpu.threads or 0, s.cpu.frequency_mhz or 0)
	end
	if s.gpu and #s.gpu > 0 then
		lines[#lines+1] = string.format("gpu       ~ %s", esc(s.gpu[1]))
	end
	if s.memory then
		local mFill, mEmpty = pbar(s.memory.percent or 0, 28)
		lines[#lines+1] = string.format("ram       ~ %s / %s (%d%%)",
			fm(s.memory.used_gb), fm(s.memory.total_gb), s.memory.percent or 0)
		lines[#lines+1] = "            " .. mFill .. string.rep("█", mEmpty)
	end
	lines[#lines+1] = string.rep("─", 42)

	if s.disk then
		for letter, disk in pairs(s.disk) do
			local l = letter:gsub(":", "")
			local dFill, dEmpty = pbar(disk.percent or 0, 28)
			lines[#lines+1] = string.format("disk %s   ~ %s / %s (%d%%)",
				l, fm(disk.used_gb), fm(disk.total_gb), disk.percent or 0)
			lines[#lines+1] = "            " .. dFill .. string.rep("█", dEmpty)
		end
	end

	if s.network and s.network.ipv4 then
		lines[#lines+1] = string.format("ip        ~ %s (%s)",
			esc(s.network.ipv4), esc(s.network.interface or ""))
	end
	if s.motherboard then
		lines[#lines+1] = string.format("mb        ~ %s", esc(s.motherboard))
	end

	-- Audio EQ
	lines[#lines+1] = string.rep("─", 42)
	lines[#lines+1] = eqBand("BASS",  1,  8)
	lines[#lines+1] = eqBand("MID",   9, 32)
	lines[#lines+1] = eqBand("TREB", 33, 64)

	-- Now Playing
	lines[#lines+1] = string.rep("─", 42)
	if media and media.title then
		if song.title ~= media.title then
			song.title = media.title
			song.artist = media.artist
			song.album = media.album
			song.dur = tonumber(media.duration) or 0
			song.start = os.clock()
		end
		local elapsed = os.clock() - song.start
		local posStr = fmtTime(elapsed)
		local durStr = song.dur > 0 and ("/ " .. fmtTime(song.dur)) or ""
		local progFill, progEmpty = "", ""
		if song.dur > 0 then
			local pct = math.min(100, elapsed / song.dur * 100)
			progFill, progEmpty = pbar(pct, 18)
		end
		lines[#lines+1] = string.format("np        ~ %s %s %s%s",
			posStr, progFill, string.rep("█", progEmpty), durStr)
		lines[#lines+1] = string.format("            %s", esc(media.title or "?"))
		lines[#lines+1] = string.format("            %s", esc(media.artist or "?"))
		if media.album and #media.album > 0 then
			lines[#lines+1] = string.format("            [%s]", esc(media.album))
		end
	else
		song.title = nil
		lines[#lines+1] = "np        ~ No media"
	end

	-- Footer
	lines[#lines+1] = string.rep("─", 42)
	lines[#lines+1] = string.format("updated %s", os.date("%H:%M:%S", now))

	return table.concat(lines, "\n")
end

-- =========== Frame update ===========
function update()
	local now = os.time()

	if now - lastSys >= 2 then
		lastSys = now
		local d = readSys()
		if d then cached = d end
	end

	local media = getMedia()
	local text = build(cached, os.time(), media)
	display:setText(text)
end
