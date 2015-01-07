--Moonlet
--Lua/MoonScript experimental modules for audio livecoding
--Written by Elihu Garret, Mexico,2015

require "gen"
require "allen"
--globals
math.randomseed(os.clock())
random = math.random --a[random(#a)] usage example
sleep = proAudio.sleep
--locals
local wrap = coroutine.wrap
local yield = coroutine.yield
local soundPlay = proAudio.soundPlay
local fromFile = proAudio.sampleFromFile
local insert = table.insert
--Load your samples
local dir = "../Samples/"
local kic = fromFile(dir.."kick.ogg")
local sna = fromFile(dir.."snare.ogg") 
local ope = fromFile(dir.."openhat.ogg")
local hat = fromFile(dir.."hat.ogg")
local rob = fromFile(dir.."robot.ogg") 
local vel = fromFile(dir.."velcro.ogg")
local iro = fromFile(dir.."iron.ogg")
local exh = fromFile(dir.."exhale.ogg")
local air = fromFile(dir.."air.ogg")
local ice = fromFile(dir.."ice.ogg")
local kit = fromFile(dir.."kitkick.ogg")
local met = fromFile(dir.."metal.ogg")
local tin = fromFile(dir.."tin.ogg")
local tam = fromFile(dir.."tam.ogg")
local mar = fromFile(dir.."mar.ogg")
local cab = fromFile(dir.."cab.ogg")
local req = fromFile(dir.."req.ogg")
local pan = fromFile(dir.."pan.ogg")
local woo = fromFile(dir.."woo.ogg")
local snap = fromFile(dir.."sna.ogg")
local bank = {
  x = kic,
  o = sna,
  ['*'] = hat,
  ['-'] = ope,
  ['&'] = rob,
  ['#'] = vel,
  ['+'] = iro,
  ['$'] = exh,
  ['@'] = air,
  ['%'] = ice,
  ['~'] = kit,
  ['°'] = met,
  [';'] = tin,
  A = tam,
  B = mar,
  C = cab,
  D = req,
  E = pan,
  F = woo,
  G = snap,
  [' '] = function (dur) play(1,vR(1,1,1,1),1,dur,0,0) end,
}
----
-- isTable
local function isTable(t)
  return type(t) == 'table'
end
----
-- Each
local function each(list, f, ...)
  if not isTable(list) then return end
  for index,value in pairs(list) do
    f(index,value,...)
  end
end
----
--Relative tempo
function t(bpm)
 local x=30/bpm
  return x
end
----
--Like SC .clear
function clear(time)
 local destroy = proAudio.destroy
 sleep(time)
 destroy()
 os.exit()
end
----
-- .ogg player  [proAudioRt can't handle high quality .wav files]
function sample(tipo)
  tipo.disparity = tipo.disparity or 0
  tipo.pitch = tipo.pitch or 0.5 
  local direc = "../Samples/Sounds/"
  local sample = fromFile(direc..tipo.file..".ogg")
  sonido = soundPlay(sample,tipo.L,tipo.R,tipo.disparity,tipo.pitch)
end
----
--Like choose() for "valid" characters
function choose2()
 local samples = {'A','B','C','D','E','F','G','#','$','%','&','+','~','°','@',';'}
 local choose = random(#samples)
 return samples[choose] 
end
----
-- Shuffle
function shuffle(list)
   local shuffled = {}
  each(list,function(index,value)
              local randPos = math.floor(math.random()*index)+1
              shuffled[index] = shuffled[randPos]
              shuffled[randPos] = value
              end)
  return shuffled
end
----
-- Range
function range(...)
  local arg = {...}
  local start,stop,step
  if #arg==0 then return {}
  elseif #arg==1 then stop,start,step = arg[1],0,1
  elseif #arg==2 then start,stop,step = arg[1],arg[2],1
  elseif #arg == 3 then start,stop,step = arg[1],arg[2],arg[3]
  end
  if (step and step==0) then return {} end
  local ranged = {}
  local steps = math.max(math.floor((stop-start)/step),0)
  for i=1,steps do ranged[#ranged+1] = start+step*i end
  if #ranged>0 then insert(ranged,1,start) end
  return ranged
end
----
--String to array of chars method
sound = {}
function string.sound(self,var)
  local tabla = {}
  for char in self:gmatch('.') do insert(tabla,char) end  
  return var == 'r' and shuffle(tabla) or #tabla>0 and tabla or nil 
end
----
--Pseudorandom string generator
 function RSG(str,pattern,s, l)
          tble = str:gsub(' ',pattern)
       local char = tble/rand(#tble)
              pass = {}
        local size = math.random(s,l) 
        for z = 1,size do
              local   case = math.random(1,2) 
               local a = math.random(1,#char) 
                if case == 1 then
                        x=string.lower(char[a]) 
                elseif case == 2 then
                        x=chos()  
                end
        table.insert(pass, x) 
        end
        return(table.concat(pass,' ')) 
end
----
--Sequencer
function rpattern(patrones,tono,dino,temp,vol1,vol2,dis,pit)
  pit = pit or 0.5
  dis = dis or 0
  for i, v in ipairs(patrones) do
    if type(bank[v]) == "function" then bank[v](temp)
      elseif type(bank[v]) == "nil" then play(tono,dino,v,temp,vol1/10,vol2/10,dis)
      else soundPlay(bank[v],vol1,vol2,dis,pit)
    end
  end
end
----
seq = {}
--Sequencer + coroutines
function seq.c(var)
  local x
  var.scale = var.scale or 24
  var.scale2 = var.scale2 or 24
  var.gen = var.gen or vR(1,1,100,1,1)
  var.gen2 = var.gen2 or vR(1,1,100,1,1)
  var.speed = var.speed or 120
  var.speed2 = var.speed2 or var.speed 
  var.L = var.L or 0.2
  var.L2 = var.L2 or var.L
  var.R = var.R or 0.2
  var.R2 = var.R2 or var.R
  
  local par = wrap(function (patrones,tono,dino,temp,vol1,vol2,dis,pit)
    while true do
      rpattern(patrones,tono,dino,temp,vol1,vol2,dis,pit)
      yield()
    end
  end
)
  local arp = wrap(function (patrones,tono,dino,temp,vol1,vol2,dis,pit)
    while true do
      rpattern(patrones,tono,dino,temp,vol1,vol2,dis,pit)
      yield()
    end
  end
)
  if #var.pattern >= #var.pattern2 then x = #var.pattern else x = #var.pattern2 end
  for i = 1,x do
    par(var.pattern,var.scale,var.gen,t(var.speed),var.L,var.R,var.disparity,var.pitch)
    arp(var.pattern2,var.scale2,var.gen2,t(var.speed2),var.L2,var.L2,var.disparity2,var.pitch2)
  end
end

--Non-linear sequencing
function seq.d(arg)
--[[lenght, every, variationPattern,shift1,dinoVar,tempo,volL,volR,loop--]]
  arg.scale2 = arg.scale2 or 24
  arg.scale = arg.scale or 24
  arg.shift = arg.shift or 0
  arg.shift2 = arg.shift2 or 0
  arg.gen = arg.gen or vR(1,1,100,1,1) 
  arg.gen2 = arg.gen2 or vR(1,1,100,1,1) 
  arg.speed = arg.speed or 120 --tempo
  arg.speed2 = arg.speed2 or arg.speed
  arg.R = arg.R or 0.2
  arg.L = arg.L or 0.2
  arg.lenght = arg.lenght or 1
  arg.every = arg.every or 1

  for q = 0, arg.lenght do
    for i = 0, arg.every do
      if i == arg.every then rpattern(arg.pattern2,arg.scale2+q*(arg.shift2),
                                  arg.gen2,t(arg.speed2),arg.R,arg.L,arg.disparity2,arg.pitch2) 
      elseif i < arg.every then rpattern(arg.pattern,arg.scale+q*(arg.shift),
                                  arg.gen,t(arg.speed),arg.R,arg.L,arg.disparity,arg.pitch)
      end
    end
  end
end