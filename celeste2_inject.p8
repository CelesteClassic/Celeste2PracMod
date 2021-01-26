pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
menuitem(1,"practice mod",function()
  -- define room, checkpt pairs
  rooms={
    {1,nil,"1-1"},
    {2,nil,"2-1"},
    {3,nil,"3-1"},
    {3,2900,"3-2"},
    {4,nil,"4-1"},
    {4,4290,"4-2"},
    {4,2274,"4-3"},
    {4,1011,"4-4"},
    {4,4340,"4-5"},
    {4,3202,"4-6"},
    {5,nil,"5-1"},
    {5,1867,"5-2"},
    {6,nil,"6-1"},
    {6,1659,"6-2"},
    {6,1828,"6-3"},
    {6,1854,"6-4"},
    {7,nil,"7-1"},
    {7,1624,"7-2"},
    {7,2162,"7-3"},
    {8,nil,"8-1"}
  }

  -- current room
  rm_index=1

  -- override update
  __update=_update
  function _update()
    -- reset fruits etc
    collected,berry_count,death_count={},0,0
    -- scroll through levels
    for i=0,1 do
      if btnp(i,1) then
        reset_frame_count(0)
        rm_index=clamp(rm_index+2*i-1,1,#rooms)
        goto_level(rooms[rm_index][1])
      end
    end
    -- timer
    if buffer_time>0 then
      buffer_time-=1
      return
    end
    if level_time and level_time<9999 then
      level_time+=1
    end
    __update()
  end

  -- override init (skip title screen)
  __init=_init
  function _init()
    __init()
    goto_level(rm_index)
  end

  -- override next_level (loop level)
  function next_level()
    reset_frame_count(level_time)
    goto_level(level_index)
  end

  -- override restart_level (remove intros, buffer window)
  _restart_level=restart_level
  function restart_level()
    level_intro,level_checkpoint=0,rooms[rm_index][2]
    _restart_level()
    buffer_time=5
  end

  -- stuff draw_time
  function draw_time() end

  -- timer management
  function reset_frame_count(last)
    last_time,level_time=last,nil
  end

  -- override player.init (start timer)
  _player_init=player.init
  function player.init(self)
    level_time=0
    _player_init(self)
  end

  -- override player.die (freeze timer)
  _player_die=player.die
  function player.die(self)
    reset_frame_count(level_time)
    _player_die(self)
  end

  -- draw button
  function draw_button(x,y,b)
    rectfill(camera_x+x,camera_y+y,camera_x+x+2,camera_y+y+2,btn(b) and 7 or 1)
  end

  -- override draw (practice hud)
  __draw=_draw
  function _draw()
    __draw()
    -- level title
    rectfill(camera_x+2,camera_y+2,camera_x+14,camera_y+8,0)
    ?rooms[rm_index][3],camera_x+3,camera_y+3,10
    -- draw frame counter
    rectfill(camera_x+16,camera_y+2,camera_x+32,camera_y+8,0)
    local t=level_time and level_time or last_time
    ?sub('000',1,4-#tostr(t)),camera_x+17,camera_y+3,1
    ?t,camera_x+33-4*#tostr(t),camera_y+3,7
    -- draw input display
    rectfill(camera_x+34,camera_y+2,camera_x+55,camera_y+10,0)
    draw_button(44,7,0) -- l
    draw_button(52,7,1) -- r
    draw_button(48,3,2) -- u
    draw_button(48,7,3) -- d
    draw_button(35,7,4) -- z
    draw_button(39,7,5) -- x
  end

  -- reinitialize
  _init()

  -- remove menu item
  menuitem(1)
end)
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
