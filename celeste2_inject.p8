pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
menuitem(1,"practice mod",function()
  -- define rooms (level, checkpt, name, checkpt_num)
  rm_data,rm_index,cp_mode="\
    1,?,0-1,0,1,\
    2,?,0-2,0,1,\
    3,?,1-1,0,5,\
    3,1863,1-1b,1,5,\
    3,2900,1-1c,2,5,\
    3,2791,1-1d,3,5,\
    3,1671,1-1e,4,5,\
    4,?,2-1,0,12,\
    4,834,2-1b,1,12,\
    4,3501,2-1c,2,12,\
    4,2717,2-1d,3,12,\
    4,4290,2-1e,4,12,\
    4,3666,2-1f,5,12,\
    4,4194,2-1g,6,12,\
    4,2274,2-1h,7,12,\
    4,860,2-1i,8,12,\
    4,1011,2-1j,9,12,\
    4,4340,2-1k,10,12,\
    4,3202,2-1l,11,12,\
    5,?,3-1,0,2,\
    5,1867,3-1b,1,2,\
    6,?,3-2,0,5,\
    6,1659,3-2b,1,5,\
    6,1828,3-2c,2,5,\
    6,1854,3-2d,3,5,\
    6,1858,3-2e,4,5,\
    7,?,3-3,0,4,\
    7,1624,3-3b,1,4,\
    7,2162,3-3c,2,4,\
    7,2340,3-3d,3,4,\
    8,?,4-1,0,1",0,0

  -- retrieve room data
  function get_rm_data(k,rm)
    local data=split(rm_data)[5*(rm or rm_index)+k]
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
    px9_decomp(0,0,0x1000+level.offset,function(x,y) return level.map[x+y*level.width] end,function(x,y,v) level.map[x+y*level.width]=v end)
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
    music(-1) sfx(-1)
    level,level_index=levels[index],index
    if level_index==2 then psfx(17,8,16) end
    restart_level()
  end

  -- override restart_level (buffer window, load cached tiles)
  _restart_level=restart_level
  function restart_level()
    level_checkpoint,buffer_time,level_time,
    camera_x,camera_y,camera_target_x,camera_target_y,
    objects,infade,have_grapple,sfx_timer=
    get_rm_data(2),10,0,
    0,0,0,0,
    {},0,level_index>2,0
    foreach(level.tiles,function(o)
      if not level_checkpoint or o[1]~=player then
        create(o[1],o[2],o[3])
      end
    end)
  end

  -- override next_level (loop level)
  function next_level()
    reset_frame_count(level_time)
    restart_level()
  end

  -- stuff draw_time
  function draw_time() end

  -- timer management
  function reset_frame_count(last)
    last_time,level_time=last,nil
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
    foreach(objects,function(o)
      if o.base==checkpoint and cp_mode~=get_rm_data(4) and o.id==get_rm_data(2,rm_index-get_rm_data(4)+cp_mode) and self:overlaps(o) then
        next_level()
      end
    end)
  end

  -- override update
  __update=_update
  function _update()
    -- reset fruits etc
    collected,berry_count,death_count={},0,0
    -- checkpt mode
    if btnp(2,1) then
      cp_mode=(cp_mode+1)%get_rm_data(5)
    end
    -- scroll through levels
    for i=0,1 do
      if btnp(i,1) then
        local d=2*i-1
        reset_frame_count(0)
        rm_index=btn(4,1) and ({0,1,2,7,19,21,26,30})[mid(level_index+d,1,8)] or mid(rm_index+d,0,30)
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
    -- draw cp mode indicator
    local cp_valid=cp_mode>0 and cp_mode<get_rm_data(5)
    local cp_active=cp_valid and cp_mode~=get_rm_data(4)
    rectfill(20,2,30,8,0)
    rectfill(21,3,21,7,4)
    rectfill(22,3,25,5,11)
    ?cp_valid and chr(97+cp_mode) or "-",27,3,cp_active and 7 or 1
    -- draw frame counter
    rectfill(32,2,48,8,0)
    local t=(buffer_time>0 or not level_time) and last_time or level_time
    ?sub('000',1,4-#tostr(t)),33,3,1
    ?t,49-4*#tostr(t),3,7
    -- draw input display
    rectfill(50,2,71,10,0)
    for b,x in pairs({60,68,64,64,51,55}) do
      local y=b==3 and 3 or 7
      rectfill(x,y,x+2,y+2,btn(b-1) and 7 or 1)
    end
    -- give cam back
    camera(camera_x,camera_y)
  end

  -- reinitialize
  game_start()
  goto_level(1)

  -- remove menu item
  menuitem(1)
end)
