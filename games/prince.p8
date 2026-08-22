pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
square_size = 20
padding = 5
top_left = 128/2 - square_size * 1.5
spacing = 2
cursor_padding = 2

background = 6

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
input_method = "keyboard"
mouse_down_square = nil

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

function load_level()
	local p = get_puzzle(level)
	grid = p.grid
	goal = p.goal
end

function _init()
	poke(0x5f2d, 1)
	level = 0
	load_level()
end

function is_done()
	return (grid[1][1] == goal and
		grid[1][3] == goal and
		grid[3][1] == goal and
		grid[3][3] == goal)
end

function on_win()
	sfx(0)
	win = true
	win_start_time = time()
end

function square_in_pos(x, y)
	local found_x = nil
	local found_y = nil
	for i=1,3 do
		s=square_pos(i, 1)
		if x >= s.x1 and x <= s.x2 then
			found_x = i
			break
		end
	end
	for i=1,3 do
		s=square_pos(1, i)
		if y >= s.y1 and y <= s.y2 then
			found_y = i
			break
		end
	end
	if found_x and found_y then
		return {x=found_x, y=found_y}
	end
	return nil
end

function click_on(p)
	c = grid[p.y][p.x]
	color_actions[c](p)
end

function _update()
	m = {x=stat(32), y=stat(33),
						lrb=stat(34) & 1 == 1}
	if (btnp(⬅️)) then selected.x -= 1 end
	if (btnp(➡️)) then selected.x += 1 end
	if (btnp(⬆️)) then selected.y -= 1 end
	if (btnp(⬇️)) then selected.y += 1 end
	selected.x = (selected.x - 1) % 3 + 1
	selected.y = (selected.y - 1) % 3 + 1
	
	if (btnp(❎)) then on_win() end
	if (btnp(🅾️)) then
		mouse_down_square = vec(selected.x, selected.y)
		-- click_on(selected)
	end
	if not btn(🅾️) and mouse_down_square then
		click_on(mouse_down_square)
		mouse_down_square = nil
	end
	if m.lrb then
		local under_mouse = square_in_pos(m.x, m.y)
		if under_mouse then
			mouse_down_square = under_mouse
		end
	end
	if prev_mouse and mouse_down_square
	 and prev_mouse.lrb and not m.lrb then
		click_on(mouse_down_square)
		mouse_down_square = nil
	end
	if win and time() - win_start_time > 2 then
		win = false
		level += 1
		load_level()
	end
	
--	local under_mouse = square_in_pos(m.x, m.y)
--	if under_mouse then
--		selected = under_mouse
--	end
	
	if btnp(⬇️) then
		input_method = "keyboard"
	elseif prev_mouse != nil and
		 (m.x != prev_mouse.x or
		 	m.y != prev_mouse.y) then
		input_method = "mouse"
	end
	
	prev_mouse = m
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
	local orig = 5
	if grid[3][3] == goal then
		pal(orig, goal)
	end
	spr(1, s.x2 - 1, s.y2 - 1)
	pal()
	if grid[1][1] == goal then
		pal(orig, goal)
	end
	spr(2, s.x1-7 + 1, s.y1-7 + 1)
	pal()
		if grid[1][3] == goal then
		pal(orig, goal)
	end
	spr(2, s.x2 -1, s.y1-7 + 1, 1, 1, true)
	pal()
		if grid[3][1] == goal then
		pal(orig, goal)
	end
	spr(1, s.x1-7 + 1, s.y2 - 1, 1, 1, true)
	pal()
end

function draw_log()
	for l in all(log_buff) do
		print(l.x, l.c)
	end
end

function draw_win_modal()
	rect(40, 50, 88, 78, 11)
	rectfill(41, 51, 87, 77, 3)
	print("you win!", 48, 61, 7)
end

function draw_squares()
		for y=1,3 do
		for x=1,3 do
			c = grid[y][x]
			r = square_pos(x, y)
			bottom_shadow = true
			if mouse_down_square and
				mouse_down_square.x == x and
				mouse_down_square.y == y then
				r.y1 += 1
--				r.y2 += 1
				bottom_shadow = false
			end
			rectfill(r.x1, r.y1, r.x2, r.y2, c)						
 		if bottom_shadow then
--	 		line(r.x1, r.y2+1, r.x2, r.y2+1, 5)
	 		line(r.x2+1, r.y1+2, r.x2+1, r.y2, 1)
 		end

		end
	end
end

function draw_background()
	local s1 = square_pos(1,1)
	local s2 = square_pos(3, 3)
	rectfill(
		s1.x1 - 3,
		s1.y1 - 3,
		s2.x2 + 3,
		s2.y2 + 3,
		background
	)
end

function _draw()
	cls()
	draw_background()
	draw_squares()
	if input_method == "keyboard" then
 	draw_cursor()
	end
	draw_targets()
	draw_log()
	if win then 
		draw_win_modal()
	end

	if input_method == "mouse" then
		if square_in_pos(m.x, m.y) then
			spr(33, m.x-10, m.y-9, 2, 2)
		else
			spr(48, m.x-1, m.y-1)
		end
	end
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
-->8
-- sprite loading
function _level_sprite(i)
	local first_sprite = {x=0, y=8}
	return {x=first_sprite.x + 8*i, y=8}
end

function get_puzzle(i)
	local s = _level_sprite(i)
	local grid = {}
	for y=s.y,s.y+2 do
		grid[#grid+1] = {
			sget(s.x, y), sget(s.x+1,y),
			sget(s.x+2,y)
		}
	end
	local goal = sget(s.x + 4, s.y)
	return {grid=grid, goal=goal}
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000005000005550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000005500055555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000055500555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000555500555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700055555000550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000005550000050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
53a03000aa90a000e950000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
39300000a5a000009590000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a35000009a90000059e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000171000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01000000000000000171101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
17100000000000000171717100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
17710000000000001177777100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
17771000000000017177777100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
17777100000000001777777100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
17711000000000000117771000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01171000000000000017771000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000001110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
010100000000000000000000000016050190501d0502105010750107501275015750187501b7501f7502275025750287502b75031750347500000000000000000000000000000000000000000000000000000000
