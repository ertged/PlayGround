#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_DIR"
PORT="${PORT:-3000}"
OUTPUT_DIR="$PROJECT_DIR/dist"
METADATA_DIR="${OPENCODE_WEB_DIR:-/home/runner/work/_temp/omgithub-web}"

run() {
  /usr/bin/time -p "$@"
}

run mkdir -p "$OUTPUT_DIR" "$METADATA_DIR"

# Build supported project sources when present. Static sources are copied into
# dist so deployment always serves a self-contained directory within PROJECT_DIR.
if [[ -f "$PROJECT_DIR/package.json" ]]; then
  if [[ -f "$PROJECT_DIR/package-lock.json" ]]; then
    run npm ci --no-audit --no-fund
  else
    run npm install --no-audit --no-fund
  fi
  run npm run build
  if [[ ! -f "$OUTPUT_DIR/index.html" ]]; then
    echo "Build completed, but $OUTPUT_DIR/index.html was not produced." >&2
    exit 1
  fi
elif [[ -f "$PROJECT_DIR/index.html" ]]; then
  run cp "$PROJECT_DIR/index.html" "$OUTPUT_DIR/index.html"
  [[ ! -d "$PROJECT_DIR/assets" ]] || run cp -R "$PROJECT_DIR/assets" "$OUTPUT_DIR/assets"
elif [[ ! -f "$OUTPUT_DIR/index.html" ]]; then
  # The repository currently has no application source. Keep a self-contained,
  # playable cat-platformer build available until project source is supplied.
  run cat > "$OUTPUT_DIR/index.html" <<'HTML'
<!doctype html>
<html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1,maximum-scale=1,user-scalable=no"><meta name="theme-color" content="#152c39"><title>Whisker Woods — Cat Platformer</title>
<style>
:root{color-scheme:dark;font-family:ui-rounded,"Trebuchet MS",system-ui,sans-serif;background:#142b38;color:#f7f4df}*{box-sizing:border-box}body{margin:0;min-height:100vh;background:radial-gradient(ellipse at 50% 0,#294959,#142b38 70%);display:flex;align-items:center;justify-content:center;padding:18px}.shell{width:min(1120px,100%)}header{display:flex;align-items:center;justify-content:space-between;margin:0 2px 12px;gap:12px}.brand{display:flex;align-items:center;gap:12px}.mark{width:48px;height:48px;border-radius:16px;background:#ffc75f;display:grid;place-items:center;font-size:30px;box-shadow:0 5px 0 #db9148}h1{font-size:clamp(19px,3vw,27px);margin:0;letter-spacing:-.04em}.tag{color:#abc6c7;font-size:12px;margin-top:3px}.hud{display:flex;align-items:center;gap:8px}.pill,.button{border:1px solid #47616b;background:#203d49;color:#f7f4df;border-radius:12px;padding:10px 13px;font-weight:750}.pill{min-width:82px;text-align:center}.button{cursor:pointer;transition:transform .12s,background .12s}.button:hover{background:#315665;transform:translateY(-1px)}.stage{position:relative;overflow:hidden;border:1px solid #52717a;border-radius:20px;background:#8dd3ca;box-shadow:0 22px 60px #06141c88}.canvas-wrap{position:relative;aspect-ratio:16/9;min-height:250px}canvas{display:block;width:100%;height:100%;touch-action:none}.overlay{position:absolute;inset:0;display:grid;place-items:center;background:linear-gradient(#142b3877,#142b3899);text-align:center;padding:24px}.overlay[hidden]{display:none}.card{width:min(400px,94%);border:1px solid #ffffff50;border-radius:22px;padding:25px;background:#193543eF;box-shadow:0 18px 55px #10253088}.card h2{margin:0 0 8px;font-size:clamp(25px,5vw,39px);letter-spacing:-.04em}.card p{color:#c6d9d3;line-height:1.55;margin:6px 0 18px}.primary{background:#ffc75f;color:#3b2b1d;border:0;padding:13px 22px;font-size:15px}.hint{display:flex;justify-content:space-between;gap:10px;padding:11px 3px 0;color:#a8c4c6;font-size:12px}.touch{display:none;justify-content:space-between;align-items:center;position:absolute;bottom:15px;left:15px;right:15px;pointer-events:none}.touchgroup{display:flex;gap:9px}.touch button{width:58px;height:58px;border:1px solid #ffffff70;border-radius:18px;background:#173643aa;color:white;font-size:23px;font-weight:bold;touch-action:none;pointer-events:auto;box-shadow:0 5px 12px #112c3866}.touch button:active{background:#ffc75f;color:#38271b}@media(max-width:680px){body{padding:10px}.mark{width:42px;height:42px}.hud{gap:5px}.pill,.button{padding:8px 9px;font-size:12px}.hint{font-size:10px}.touch{display:flex}.canvas-wrap{min-height:270px;aspect-ratio:4/3}}@media(max-height:520px) and (orientation:landscape){body{padding:5px}.canvas-wrap{aspect-ratio:16/8;min-height:200px}header{margin-bottom:5px}.hint{padding-top:5px}}
</style></head>
<body><main class="shell"><header><div class="brand"><div class="mark" aria-hidden="true">🐱</div><div><h1>Whisker Woods</h1><div class="tag">A tiny adventure through the treetops</div></div></div><div class="hud"><div class="pill" id="fish-count">🐟 0 / 8</div><div class="pill" id="lives">♥ ♥ ♥</div><button class="button" id="sound" aria-label="Toggle sound">♪</button><button class="button" id="pause">Ⅱ</button></div></header>
<section class="stage" aria-label="Cat platform game"><div class="canvas-wrap"><canvas id="game-canvas" width="960" height="540" aria-label="Game scene"></canvas><div class="overlay" id="overlay"><div class="card"><h2 id="headline">Ready, kitty?</h2><p id="message">Run, leap and gather all the golden fish. Watch for grumpy crows and the bramble below!</p><button class="button primary" id="play">Start adventure&nbsp; →</button></div></div><div class="touch"><div class="touchgroup"><button data-key="ArrowLeft" aria-label="Move left">←</button><button data-key="ArrowRight" aria-label="Move right">→</button></div><div class="touchgroup"><button data-key="Space" aria-label="Jump">↑</button></div></div></div></section><div class="hint"><span>← → / A D to run &nbsp;·&nbsp; SPACE / ↑ to jump &nbsp;·&nbsp; P to pause</span><span>Find the sunny sign to finish!</span></div></main>
<script>
(()=>{'use strict';const canvas=document.querySelector('#game-canvas'),ctx=canvas.getContext('2d'),overlay=document.querySelector('#overlay'),fishUI=document.querySelector('#fish-count'),livesUI=document.querySelector('#lives');const W=960,H=540,worldW=2500,gravity=.62;let keys=new Set(),game=null,raf=0,soundOn=false,ac=null;
const platforms=[{x:0,y:458,w:390},{x:460,y:408,w:145},{x:650,y:354,w:150},{x:850,y:423,w:210},{x:1120,y:370,w:155},{x:1330,y:316,w:155},{x:1540,y:402,w:220},{x:1815,y:350,w:150},{x:2010,y:420,w:490},{x:300,y:350,w:105},{x:965,y:300,w:100},{x:1670,y:295,w:90}];const fishSpots=[[130,410],[270,300],[520,360],[710,305],[925,370],[1175,322],[1380,266],[1595,353],[1855,300],[2130,370],[2280,370],[1000,255]];const enemySpots=[[565,376,510,610],[1010,391,870,1040],[1610,370,1570,1720],[2190,388,2070,2370]];
function fresh(){return{cat:{x:50,y:400,vx:0,vy:0,w:38,h:42,ground:false,face:1,inv:0},camera:0,fish:fishSpots.map(([x,y])=>({x,y,got:false})),enemies:enemySpots.map(([x,y,min,max],i)=>({x,y,min,max,dir:i%2?1:-1})),lives:3,checkpoint:50,started:false,paused:false,won:false,frame:0}}
function tone(freq=520,d=.08){if(!soundOn)return;try{ac??=new AudioContext();const o=ac.createOscillator(),g=ac.createGain();o.frequency.value=freq;o.type='sine';g.gain.setValueAtTime(.08,ac.currentTime);g.gain.exponentialRampToValueAtTime(.001,ac.currentTime+d);o.connect(g).connect(ac.destination);o.start();o.stop(ac.currentTime+d)}catch{}}
function start(){if(raf)cancelAnimationFrame(raf);game=fresh();game.started=true;overlay.hidden=true;keys.clear();loop()}
function show(title,text,button='Play again'){document.querySelector('#headline').textContent=title;document.querySelector('#message').textContent=text;document.querySelector('#play').textContent=button+'  →';overlay.hidden=false}
function end(win){game.started=false;show(win?'You did it, whiskers!':'A thorny tumble!',win?'The woods are safe, the fish are yours, and the sunbeam is waiting.':'No worries — every cat gets nine lives. Give it another go!',win?'Play again':'Try again');tone(win?780:180,.3)}
function jump(){const c=game?.cat;if(c&&c.ground&&game.started&&!game.paused){c.vy=-12.6;c.ground=false;tone(360)}}
function update(){const g=game,c=g.cat;g.frame++;if(c.inv>0)c.inv--;const left=keys.has('ArrowLeft')||keys.has('KeyA'),right=keys.has('ArrowRight')||keys.has('KeyD');if(left){c.vx-=.72;c.face=-1}if(right){c.vx+=.72;c.face=1}c.vx*=c.ground?.79:.92;c.vx=Math.max(-5,Math.min(5,c.vx));c.vy=Math.min(14,c.vy+gravity);c.x+=c.vx;c.y+=c.vy;c.x=Math.max(0,Math.min(worldW-c.w,c.x));c.ground=false;
for(const p of platforms){if(c.vy>=0&&c.x+c.w>p.x&&c.x<p.x+p.w&&c.y+c.h>=p.y&&c.y+c.h-c.vy<=p.y){c.y=p.y-c.h;c.vy=0;c.ground=true}}
if(c.y>H+100){hurt()};for(const f of g.fish){if(!f.got&&Math.hypot((c.x+c.w/2)-f.x,(c.y+c.h/2)-f.y)<34){f.got=true;tone(680,.12)}}for(const e of g.enemies){e.x+=e.dir*1.1;if(e.x<e.min||e.x>e.max)e.dir*=-1;if(c.inv===0&&Math.abs(c.x+c.w/2-e.x)<27&&Math.abs(c.y+c.h/2-e.y)<30){if(c.vy>1&&c.y+c.h<e.y+20){e.x=-999;c.vy=-8;tone(220)}else hurt()}}
if(c.x>1050&&g.checkpoint<1050)g.checkpoint=1065;if(c.x>2050&&g.checkpoint<2050)g.checkpoint=2060;g.camera=Math.max(0,Math.min(worldW-W,c.x-W*.36));fishUI.textContent='🐟 '+g.fish.filter(f=>f.got).length+' / 8';livesUI.textContent='♥ '.repeat(g.lives).trim()||'♡';if(c.x>2410){end(true)}}
function hurt(){const g=game;if(g.cat.inv>0)return;g.lives--;tone(150,.22);if(g.lives<=0){end(false);return}g.cat.x=g.checkpoint;g.cat.y=300;g.cat.vx=0;g.cat.vy=0;g.cat.inv=100}
function rr(x,y,w,h,r,color){ctx.fillStyle=color;ctx.beginPath();ctx.roundRect(x,y,w,h,r);ctx.fill()}
function draw(){const g=game;ctx.clearRect(0,0,W,H);const sky=ctx.createLinearGradient(0,0,0,H);sky.addColorStop(0,'#83d3cf');sky.addColorStop(1,'#e1e9b9');ctx.fillStyle=sky;ctx.fillRect(0,0,W,H);ctx.save();ctx.translate(-g.camera,0);
// layered hills and distant pines
for(let i=0;i<8;i++){const x=i*390-g.camera*.22;ctx.fillStyle=i%2?'#79bd9d':'#65ad91';ctx.beginPath();ctx.ellipse(x+170,430,245,190,0,0,Math.PI*2);ctx.fill()}for(let i=0;i<24;i++){let x=i*125;ctx.fillStyle=i%2?'#3c806d':'#478d75';ctx.beginPath();ctx.moveTo(x,390);ctx.lineTo(x+55,190+(i%3)*20);ctx.lineTo(x+110,390);ctx.fill();ctx.fillRect(x+48,365,14,92)}
// platforms
for(const p of platforms){rr(p.x,p.y+9,p.w,40,9,'#895d43');rr(p.x,p.y,p.w,19,9,'#49805d');rr(p.x,p.y,p.w,9,7,'#79b66b');for(let x=p.x+20;x<p.x+p.w-8;x+=36){ctx.fillStyle='#a5c878';ctx.beginPath();ctx.ellipse(x,p.y+2,8,2,-.2,0,Math.PI*2);ctx.fill()}}
// glowing fish
for(const f of g.fish){if(f.got)continue;ctx.save();ctx.translate(f.x,f.y+Math.sin(g.frame/12+f.x)*3);ctx.fillStyle='#ffcb59';ctx.beginPath();ctx.ellipse(0,0,13,9,0,0,Math.PI*2);ctx.fill();ctx.beginPath();ctx.moveTo(-11,0);ctx.lineTo(-20,-8);ctx.lineTo(-20,8);ctx.closePath();ctx.fill();ctx.fillStyle='#633e37';ctx.beginPath();ctx.arc(7,-2,1.5,0,7);ctx.fill();ctx.restore()}
// enemies, grumpy little crows
for(const e of g.enemies){if(e.x<0)continue;ctx.fillStyle='#293e51';ctx.beginPath();ctx.ellipse(e.x,e.y,18,14,0,0,Math.PI*2);ctx.fill();ctx.fillStyle='#e7ae54';ctx.beginPath();ctx.moveTo(e.x+12,e.y-2);ctx.lineTo(e.x+24,e.y+2);ctx.lineTo(e.x+12,e.y+6);ctx.fill();ctx.fillStyle='#fff';ctx.beginPath();ctx.arc(e.x+5,e.y-5,3,0,7);ctx.fill()}
// checkpoint sign and finish sunbeam
for(const [x,label,col] of [[1065,'SAVE','#ef936c'],[2060,'HOME','#f7bd54']]){ctx.fillStyle='#654c40';ctx.fillRect(x,330,7,90);rr(x-23,319,56,28,8,col);ctx.fillStyle='#fff7d4';ctx.font='bold 11px system-ui';ctx.textAlign='center';ctx.fillText(label,x+5,338)}ctx.fillStyle='#ffe39a';ctx.globalAlpha=.45;ctx.beginPath();ctx.ellipse(2440,310,55,120,0,0,7);ctx.fill();ctx.globalAlpha=1;
// cat
const c=g.cat;ctx.save();ctx.translate(c.x+c.w/2,c.y+c.h/2);ctx.scale(c.face,1);if(c.inv&&Math.floor(g.frame/5)%2)ctx.globalAlpha=.35;ctx.fillStyle='#db884d';ctx.beginPath();ctx.ellipse(0,4,19,19,0,0,7);ctx.fill();ctx.beginPath();ctx.moveTo(-15,-8);ctx.lineTo(-17,-26);ctx.lineTo(-3,-16);ctx.moveTo(15,-8);ctx.lineTo(17,-26);ctx.lineTo(3,-16);ctx.fill();ctx.fillStyle='#f8c987';ctx.beginPath();ctx.ellipse(1,8,11,10,0,0,7);ctx.fill();ctx.fillStyle='#fff5df';ctx.beginPath();ctx.ellipse(7,-2,4,5,0,0,7);ctx.fill();ctx.fillStyle='#27343a';ctx.beginPath();ctx.arc(8,-1,1.5,0,7);ctx.fill();ctx.beginPath();ctx.arc(-3,-1,1.5,0,7);ctx.fill();ctx.fillStyle='#ed8f8b';ctx.beginPath();ctx.arc(3,5,2.4,0,7);ctx.fill();ctx.strokeStyle='#a35f3c';ctx.lineWidth=4;ctx.beginPath();ctx.moveTo(-14,14);ctx.quadraticCurveTo(-25,13,-21,4);ctx.stroke();ctx.restore();ctx.restore();
// progress bar
rr(24,22,170,9,5,'#ffffff70');rr(24,22,Math.max(8,170*g.cat.x/worldW),9,5,'#fff0b0');ctx.fillStyle='#31545a';ctx.font='bold 12px system-ui';ctx.fillText('WOODLAND TRAIL',24,48)}
function loop(){if(!game?.started||game.paused)return;update();draw();raf=requestAnimationFrame(loop)}
document.querySelector('#play').addEventListener('click',()=>{if(game?.paused){game.paused=false;game.started=true;overlay.hidden=true;document.querySelector('#pause').textContent='Ⅱ';loop()}else start()});document.querySelector('#pause').addEventListener('click',()=>{if(!game?.started)return;game.paused=!game.paused;document.querySelector('#pause').textContent=game.paused?'▶':'Ⅱ';if(game.paused)show('Taking a breather?','Your adventure is paused. Tap resume when you are ready.','Resume');else{overlay.hidden=true;loop()}});document.querySelector('#sound').addEventListener('click',e=>{soundOn=!soundOn;e.currentTarget.textContent=soundOn?'♫':'♪';tone()});document.addEventListener('keydown',e=>{if(['ArrowLeft','ArrowRight','ArrowUp','Space'].includes(e.code))e.preventDefault();keys.add(e.code);if(['Space','ArrowUp','KeyW'].includes(e.code)&&!e.repeat)jump();if(e.code==='KeyP'&&!e.repeat)document.querySelector('#pause').click()});document.addEventListener('keyup',e=>keys.delete(e.code));for(const b of document.querySelectorAll('[data-key]')){const k=b.dataset.key;b.addEventListener('pointerdown',e=>{e.preventDefault();b.setPointerCapture(e.pointerId);keys.add(k);if(k==='Space')jump()});for(const ev of ['pointerup','pointercancel','lostpointercapture'])b.addEventListener(ev,()=>keys.delete(k))}document.addEventListener('visibilitychange',()=>{if(document.hidden&&game?.started&&!game.paused)document.querySelector('#pause').click()});game=fresh();draw();
})();
</script></body></html>
HTML
fi

run node -e 'const fs=require("node:fs");const path=require("node:path");const file=path.join(process.env.OPENCODE_WEB_DIR||"/home/runner/work/_temp/omgithub-web","deployment-output.json");fs.mkdirSync(path.dirname(file),{recursive:true});fs.writeFileSync(file,JSON.stringify({project:process.cwd(),directory:path.resolve("dist")}));'

# Keep the server in the foreground for the controller-owned tmux lifecycle.
run node -e '
const http=require("node:http"),fs=require("node:fs"),path=require("node:path");
const root=path.resolve("dist"),types={".html":"text/html; charset=utf-8",".js":"text/javascript; charset=utf-8",".css":"text/css; charset=utf-8",".json":"application/json",".svg":"image/svg+xml",".png":"image/png",".jpg":"image/jpeg",".webp":"image/webp"};
const server=http.createServer((req,res)=>{let pathname;try{pathname=decodeURIComponent(new URL(req.url,"http://localhost").pathname)}catch{res.writeHead(400).end("Bad request");return}let target=path.resolve(root,"."+pathname);if(target!==root&&!target.startsWith(root+path.sep)){res.writeHead(403).end("Forbidden");return}try{if(fs.statSync(target).isDirectory())target=path.join(target,"index.html");const body=fs.readFileSync(target);res.writeHead(200,{"Content-Type":types[path.extname(target)]||"application/octet-stream","Cache-Control":"no-cache"});res.end(body)}catch{try{res.writeHead(200,{"Content-Type":types[".html"]});res.end(fs.readFileSync(path.join(root,"index.html")))}catch{res.writeHead(404).end("Not found")}}});server.listen(Number(process.env.PORT||3000),"0.0.0.0",()=>console.log(`Serving ${root} on port ${process.env.PORT||3000}`));
'
