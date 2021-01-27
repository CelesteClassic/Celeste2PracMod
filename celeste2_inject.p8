pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
menuitem(1,"practice mod",function()
  -- define rooms (level, checkpt, name)
  rooms,rm_index={
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
  },1

  -- override tile_at to use cached map
  function tile_at(x,y)
    return x<0 or y<0 or x>=level.width or y>=level.height and 0 or level.map[x+y*level.width]
  end

  -- cache map
  for l=1,8 do
    level=levels[l]
    level.map,level.tiles={},{}
    px9_decomp(0,0,0x1000+level.offset,function(x,y) return level.map[x+y*level.width] end, function(x,y,v) level.map[x+y*level.width]=v end)
    for i=0,level.width-1 do
      for j=0,level.height-1 do
        local t=types[tile_at(i,j)]
        if t then
          add(level.tiles,{t,i*8,j*8})
        end
      end
    end
  end

  -- override goto_level to not decompress map (and stuff level intros)
  function goto_level(index)
    level,level_index=levels[index],index
    if level_index==2 then psfx(17,8,16) end
    if current_music~=level.music and level.music then
      current_music=level.music
      music(level.music)
    end
    restart_level()
  end

  -- override update
  __update=_update
  function _update()
    -- reset fruits etc
    collected,berry_count,death_count={},0,0
    -- checkpt mode
    if btnp(2,1) then
      cp_mode=not cp_mode
    end
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

  -- override next_level (loop level)
  function next_level()
    reset_frame_count(level_time)
    goto_level(level_index)
  end

  -- override restart_level (buffer window, load cached tiles)
  _restart_level=restart_level
  function restart_level()
    level_checkpoint,buffer_time,
    camera_x,camera_y,camera_target_x,camera_target_y,
    objects,
    infade,have_grapple,sfx_timer=
    rooms[rm_index][2],10,
    0,0,0,0,
    {},
    0,level_index>2,0
    for o in all(level.tiles) do
      if not level_checkpoint or o[1]~=player then
        create(o[1],o[2],o[3])
      end
    end
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

  -- define checkpoint.update (for checkpt mode)
  function checkpoint.update(self)
    -- ideally check cp_mode out of the loop but tokens :(
    for o in all(objects) do
      if cp_mode and self.id~=rooms[rm_index][2] and o.base==player and self:overlaps(o) then
        next_level()
      end
    end
  end

  -- override draw (practice hud)
  __draw=_draw
  function _draw()
    __draw()
    -- nab camera
    camera()
    -- buffer window
    if buffer_time>0 then cls() end
    -- level title
    rectfill(2,2,14,8,0)
    ?rooms[rm_index][3],3,3,10
    -- draw frame counter
    rectfill(16,2,32,8,0)
    local t=(buffer_time>0 or not level_time) and last_time or level_time
    ?sub('000',1,4-#tostr(t)),17,3,1
    ?t,33-4*#tostr(t),3,7
    -- draw input display
    rectfill(34,2,55,10,0)
    for b,x in pairs({44,52,48,48,35,39}) do
      local y=b==3 and 3 or 7
      rectfill(x,y,x+2,y+2,btn(b-1) and 7 or 1)
    end
    -- draw cp mode indicator
    rectfill(57,2,65,10,0)
    rectfill(58,3,58,9,cp_mode and 4 or 1)
    rectfill(59,3,64,6,cp_mode and 11 or 1)
    -- give cam back
    camera(camera_x,camera_y)
  end

  -- reinitialize
  game_start()
  goto_level(1)

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
