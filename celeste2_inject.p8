pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
menuitem(1,"practice mod",function()
  -- define rooms (level, checkpt, name)
  rm_data,rm_index={
    "1,?,0-1",
    "2,?,0-2",
    "3,?,1-1",
    "3,2900,1-1b",
    "4,?,2-1",
    "4,4290,2-1b",
    "4,2274,2-1c",
    "4,1011,2-1d",
    "4,4340,2-1e",
    "4,3202,2-1f",
    "5,?,3-1",
    "5,1867,3-1b",
    "6,?,3-2",
    "6,1659,3-2b",
    "6,1828,3-2c",
    "6,1858,3-2d",
    "7,?,3-3",
    "7,1624,3-3b",
    "7,2162,3-3c",
    "8,?,4-1"},1

  -- retrieve room data
  function get_rm_data(k)
    local data=split(rm_data[rm_index])[k]
    if k==2 then return tonum(data) else return data end
  end

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
        rm_index=clamp(rm_index+2*i-1,1,#rm_data)
        goto_level(get_rm_data(1))
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
    restart_level()--goto_level(level_index)
  end

  -- override restart_level (buffer window, load cached tiles)
  _restart_level=restart_level
  function restart_level()
    level_checkpoint,buffer_time,
    camera_x,camera_y,camera_target_x,camera_target_y,
    objects,infade,have_grapple,sfx_timer=
    get_rm_data(2),10,
    0,0,0,0,
    {},0,level_index>2,0
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

  -- override player.update (for checkpt mode)
  _player_update=player.update
  function player.update(self)
    _player_update(self)
    for o in all(objects) do
      if cp_mode and o.base==checkpoint and o.id~=get_rm_data(2) and self:overlaps(o) then
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
    rectfill(2,2,18,8,0)
    ?get_rm_data(3),3,3,10
    -- draw frame counter
    rectfill(20,2,36,8,0)
    local t=(buffer_time>0 or not level_time) and last_time or level_time
    ?sub('000',1,4-#tostr(t)),21,3,1
    ?t,37-4*#tostr(t),3,7
    -- draw input display
    rectfill(38,2,59,10,0)
    for b,x in pairs({48,56,52,52,39,43}) do
      local y=b==3 and 3 or 7
      rectfill(x,y,x+2,y+2,btn(b-1) and 7 or 1)
    end
    -- draw cp mode indicator
    rectfill(61,2,69,10,0)
    rectfill(62,3,62,9,cp_mode and 4 or 1)
    rectfill(63,3,68,6,cp_mode and 11 or 1)
    -- give cam back
    camera(camera_x,camera_y)
  end

  -- reinitialize
  game_start()
  goto_level(1)

  -- remove menu item
  menuitem(1)
end)
