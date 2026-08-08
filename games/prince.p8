pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
square_size = 20
padding = 5
top_left = 128/2 - square_size * 1.5
spacing = 2
cursor_padding = 2

empty = 5
green = 3
white = 7
yellow = 10
orange = 9

grid = {
	{empty, green, yellow},
	{orange, white, empty},
	{green, yellow, yellow},
}

color_actions = {
	yellow=shift_right,
	green=swap,
	white=noop,
	empty=noop,
}

selected = {x=1, y=1}

log_buff = {}
function log(x, c)
	if c == nil then
		c = white
	end
	log_buff[#log_buff+1]= {x=x, c=c}
end

function vec(x, y)
	return {x=x, y=y}
end

function rec(x1, y1, x2, y2)
	return {x1=x1, y1=y1, x2=x2, y2=y2}
end

function _update()
	if (btnp(⬅️)) then selected.x -= 1 end
	if (btnp(➡️)) then selected.x += 1 end
	if (btnp(⬆️)) then selected.y -= 1 end
	if (btnp(⬇️)) then selected.y += 1 end
	selected.x = (selected.x - 1) % 3 + 1
	selected.y = (selected.y - 1) % 3 + 1
	
	if (btnp(🅾️)) then
		c = grid[selected.y][selected.x]
		print(c)
		print(all(color_actions))
		for k,v in all(color_actions) do
			print(1)
		end
		color_actions[c](selected)
	end
end

function square_pos(x, y)
	local x1 = top_left - padding + (square_size + padding) * (x-1)
	local y1 = top_left - padding + (square_size + padding) * (y-1)
	return {
		x1=x1, y1=y1,
		x2=x1+square_size, y2=y1+square_size
	}
end

function draw_cursor()
	local s = square_pos(selected.x, selected.y)
	local len = square_size / 2 - spacing
	local x1=s.x1 - cursor_padding
	local y1=s.y1 - cursor_padding
	local x2=s.x2 + cursor_padding
	local y2=s.y2 + cursor_padding
	color(white)
	line(x1, y1, x1+len, y1)
	line(x1, y1, x1, y1+len)
	line(x2, y1, x2-len, y1)
	line(x2, y1, x2, y1+len)
	line(x1, y2, x1+len, y2)
	line(x1, y2, x1, y2-len)
	line(x2, y2, x2-len, y2)
	line(x2, y2, x2, y2-len)	
end

function draw_targets()
	local s1 = square_pos(1,1)
	local s2 = square_pos(3, 3)
	local s= {
		x1=s1.x1,
		y1=s1.y1,
		x2=s2.x2,
		y2=s2.y2,
	}
	if grid[3][3] == green then
		pal(6, green)
	end
	spr(1, s.x2 - 1, s.y2 - 1)
	pal()
	if grid[1][1] == green then
		pal(6, green)
	end
	spr(2, s.x1-7 + 1, s.y1-7 + 1)
	pal()
		if grid[1][3] == green then
		pal(6, green)
	end
	spr(2, s.x2 -1, s.y1-7 + 1, 1, 1, true)
	pal()
		if grid[3][1] == green then
		pal(6, green)
	end
	spr(1, s.x1-7 + 1, s.y2 - 1, 1, 1, true)
	pal()
end

function draw_log()
	for l in all(log_buff) do
		print(l.x, l.c)
	end
end

function _draw()
	cls()
	for y=1,3 do
		for x=1,3 do
			c = grid[y][x]
			r = square_pos(x, y)
			rectfill(r.x1, r.y1, r.x2, r.y2, c)						
		end
	end
	draw_cursor()
	draw_targets()
	draw_log()
end
	
-->8
function swap(p1, p2)
	local aux = grid[p1.y][p1.x]
	grid[p1.y][p1.x] = grid[p2.y][p2.x]
	grid[p2.y][p2.x] = aux
end
function noop(pos)
	
end

function shift_right(pos)
	local aux = grid[pos.y][3]
 grid[pos.y][3] = grid[pos.y][2]
	grid[pos.y][2] = grid[pos.y][1]
	grid[pos.y][1] = aux
end

function green_swap(pos)
	local p2 = {x=4-pos.x, y=4-pos.y}
	swap(pos, p2)
end

function go_up(pos)
	if pos.y > 1 then
		local p2 = {x=pos.x, y=pos.y-1}
		swap(pos, p2)
	end
end

color_actions = {
	[yellow]=shift_right,
	[green]=green_swap,
	[white]=noop,
	[orange]=go_up,
	[empty]=noop,
}
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000006000006660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000006600066666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000066600666600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000666600666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700066666000660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000006660000060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
