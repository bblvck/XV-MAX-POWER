const SUPABASE_URL='https://gdfyommhhydzyhjepian.supabase.co';
const SUPABASE_KEY='sb_publishable_eA8rpGzAfRAQ14iHRj97eQ_s7h94j-G';
const days=['Lunes','Martes','Miércoles','Jueves','Viernes','Sábado','Domingo'];
const mealNames=['Desayuno','Comida','Cena','Snacks','Batido'];
const mealIcons={Desayuno:'☀️',Comida:'🍽️',Cena:'🌙',Snacks:'🥜',Batido:'🥤',Merienda:'🍎'};
const weekData=[
 {name:'Semana 1',start:55.95,end:56.35,calories:[2259,1718,2149,1998,2346,2722,2323],targets:[2273,1746,2081,1916,2270,2107,2306],protein:[128.9,115.4,133,122.4,150.5,109.2,137.3],fat:[59.1,29.8,63.3,58.5,47.5,117.7,59.5],carbs:[290,244.7,253.6,246,313.9,273.7,287.7],meals:[[501,899,520,208,131],[275,770,395,0,278],[428,781,830,110,0],[306,815,334,416,127],[427,789,773,213,144],[503,2050,169,0,0],[473,993,399,350,108]]},
 {name:'Semana 2',start:56.35,end:56.85,calories:[2169,2546,2061,2304,2861,2352,2549],targets:[2098,2010,1937,2264,1931,2276,2193],protein:[112.9,144.1,117.7,138.6,172.2,117,137.3],fat:[45.2,78,71.7,50.8,96.2,61.2,90.9],carbs:[334.1,307.7,215.9,311.3,297.8,319.8,292.9],meals:[[362,879,704,224,0],[383,1046,761,356,0],[319,1312,194,236,0],[394,1134,565,211,0],[434,958,1400,69,0],[565,934,553,300,0],[549,1285,463,252,0]]},
 {name:'Semana 3',start:55.65,end:56.45,calories:[2007,2057,2290,2088,2528,2576,2555],targets:[2080,2080,2080,2080,2080,2080,2080],protein:[116.4,107.4,116.8,108.2,151.7,145.6,147.6],fat:[38.1,55.8,50.5,44.6,61.9,63.8,63.1],carbs:[301,266.8,338.8,319.9,343.2,318.3,330.5],meals:[[420,1072,213,312,0],[762,1034,261,0,0],[537,917,680,156,0],[579,746,432,331,0],[526,1135,519,348,0],[654,1111,487,324,0],[584,1101,531,339,0]]},
 {name:'Semana 4',start:56.45,end:null,calories:[2166,2159,2089,3801,2600,2350,2480],targets:[2416,2416,2416,2416,2416,2416,2416],protein:[107,108.1,134.3,169,141.7,132.5,148.4],fat:[68.9,61.5,47.5,110.2,65.5,61.3,63.5],carbs:[278.6,282.2,272.8,472.1,349.8,300.6,334.4],meals:[[518,942,253,353,100],[335,995,327,502,0],[373,828,398,490,0],[445,1274,1214,434,0],[518,1074,570,438,0],[536,991,430,393,0],[548,1110,484,338,0]]}
];

let currentUser=null, accessToken=null, isAdmin=false;
let settings={weight:56.45,height:165,age:26,activity:1.2,surplus:150};
let foods=[];
let logs={};
let selectedView='dashboard',selectedWeek=0,selectedDate=todayISO();
let loaded=false, dirty=false;

function todayISO(){return new Date().toISOString().slice(0,10)}
function fmt(n,d=0){return Number(n||0).toLocaleString('es-ES',{maximumFractionDigits:d})}
function dateLabel(iso){return new Date(iso+'T12:00:00').toLocaleDateString('es-ES',{weekday:'long',day:'numeric',month:'long'})}
function target(){return Math.round((10*settings.weight+6.25*settings.height-5*settings.age+5)*settings.activity+settings.surplus)}
function tmb(){return Math.round(10*settings.weight+6.25*settings.height-5*settings.age+5)}
function tdee(){return Math.round(tmb()*settings.activity)}
function dayIndex(){return(new Date(selectedDate+'T12:00:00').getDay()+6)%7}
function userInitial(){return (currentUser?.user_metadata?.name||currentUser?.email||'?')[0].toUpperCase()}

// ── Supabase REST helper ──
function sb(path,opts={}){
  const token=accessToken||SUPABASE_KEY;
  return fetch(`${SUPABASE_URL}/rest/v1/${path}`,{
    ...opts,
    headers:{apikey:SUPABASE_KEY,Authorization:`Bearer ${token}`,'Content-Type':'application/json',...opts.headers}
  }).then(r=>{if(!r.ok){console.error('SB:',path,r.status);return[]}return r.json()}).catch(e=>{console.error('SB:',path,e);return[]});
}

// ── Auth ──
async function signUp(email,password,name){
  const r=await fetch(`${SUPABASE_URL}/auth/v1/signup`,{
    method:'POST',headers:{apikey:SUPABASE_KEY,'Content-Type':'application/json'},
    body:JSON.stringify({email,password,data:{name}})
  });
  const d=await r.json();
  if(d.error)throw new Error(d.error_description||d.msg||'Error al registrar');
  return d;
}

async function signIn(email,password){
  const r=await fetch(`${SUPABASE_URL}/auth/v1/token?grant_type=password`,{
    method:'POST',headers:{apikey:SUPABASE_KEY,'Content-Type':'application/json'},
    body:JSON.stringify({email,password})
  });
  const d=await r.json();
  if(d.error)throw new Error(d.error_description||d.msg||'Credenciales incorrectas');
  return d;
}

async function refreshSession(refreshToken){
  const r=await fetch(`${SUPABASE_URL}/auth/v1/token?grant_type=refresh_token`,{
    method:'POST',headers:{apikey:SUPABASE_KEY,'Content-Type':'application/json'},
    body:JSON.stringify({refresh_token:refreshToken})
  });
  const d=await r.json();
  if(d.error)throw new Error('Session expired');
  return d;
}

async function signOut(){
  try{
    if(accessToken)await fetch(`${SUPABASE_URL}/auth/v1/logout`,{method:'POST',headers:{apikey:SUPABASE_KEY,Authorization:`Bearer ${accessToken}`}});
  }catch(e){}
  currentUser=null;accessToken=null;isAdmin=false;
  localStorage.removeItem('jc_refresh');
  showAuth();
}

function setSession(data){
  currentUser=data.user;
  accessToken=data.access_token;
  isAdmin=!!(currentUser?.user_metadata?.role==='admin');
  localStorage.setItem('jc_refresh',data.refresh_token);
}

function showAuth(){
  document.getElementById('authScreen').style.display='flex';
  document.getElementById('appMain').style.display='none';
  document.getElementById('avatarBtn').textContent='?';
}

function showApp(){
  document.getElementById('authScreen').style.display='none';
  document.getElementById('appMain').style.display='';
  selectedView='dashboard';
  const name=currentUser?.user_metadata?.name||currentUser?.email||'';
  document.getElementById('avatarBtn').textContent=userInitial();
  document.getElementById('appTitle').textContent=isAdmin?'JAVI CHEATS · Admin':'JAVI CHEATS';
  document.getElementById('todayGreeting').textContent=`Hola, ${name}`;
  document.querySelectorAll('.admin-nav').forEach(b=>b.classList.toggle('visible',isAdmin));
  render();
}

// ── Data loading ──
async function loadData(){
  loaded=false;
  try{
    const [sRes,fRes,lRes]=await Promise.all([
      sb(`settings?user_id=eq.${currentUser.id}`),
      sb('foods?order=created_at.desc'),
      sb(`logs?user_id=eq.${currentUser.id}&order=date`)
    ]);
    if(sRes[0])settings={weight:sRes[0].weight,height:sRes[0].height,age:sRes[0].age,activity:sRes[0].activity,surplus:sRes[0].surplus};
    foods=fRes||[];
    logs={};
    (lRes||[]).forEach(l=>{logs[l.date]={meals:l.meals,user_id:l.user_id}});
    try{
      const pRes=await sb(`profiles?id=eq.${currentUser.id}&select=display_name`);
      if(pRes[0]&&pRes[0].display_name){
        currentUser.user_metadata={...currentUser.user_metadata,name:pRes[0].display_name};
      }
    }catch(e){}
  }catch(e){console.error('loadData error:',e)}
  loaded=true;
  render();
}

async function init(){
  const saved=localStorage.getItem('jc_refresh');
  if(saved){
    try{
      const d=await refreshSession(saved);
      setSession(d);
      showApp();
      await loadData();
      return;
    }catch(e){localStorage.removeItem('jc_refresh')}
  }
  showAuth();
}

// ── Log helpers ──
function getLog(){
  if(!logs[selectedDate]){
    const w=weekData[selectedWeek],di=dayIndex(),m=w.meals[di]||[0,0,0,0,0];
    logs[selectedDate]={meals:mealNames.map((name,i)=>({name,kcal:m[i]||0,p:Math.round((w.protein[di]||0)*(i===1?.42:.15)),f:Math.round((w.fat[di]||0)*(i===1?.45:.14)),c:Math.round((w.carbs[di]||0)*(i===1?.42:.15))})),user_id:currentUser.id};
  }
  return logs[selectedDate];
}

function totals(log=getLog()){
  return log.meals.reduce((a,m)=>({kcal:a.kcal+Number(m.kcal||0),p:a.p+Number(m.p||0),f:a.f+Number(m.f||0),c:a.c+Number(m.c||0)}),{kcal:0,p:0,f:0,c:0});
}

// ── Save ──
async function saveLog(){
  const log=logs[selectedDate];
  if(!log)return;
  await fetch(`${SUPABASE_URL}/rest/v1/logs?user_id=eq.${currentUser.id}&date=eq.${selectedDate}`,{
    method:'POST',
    headers:{apikey:SUPABASE_KEY,Authorization:`Bearer ${accessToken}`,'Content-Type':'application/json','Prefer':'resolution=merge-duplicates'},
    body:JSON.stringify({user_id:currentUser.id,date:selectedDate,meals:log.meals})
  });
}

async function saveSettings(){
  await fetch(`${SUPABASE_URL}/rest/v1/settings?user_id=eq.${currentUser.id}`,{
    method:'POST',
    headers:{apikey:SUPABASE_KEY,Authorization:`Bearer ${accessToken}`,'Content-Type':'application/json','Prefer':'resolution=merge-duplicates'},
    body:JSON.stringify({user_id:currentUser.id,weight:settings.weight,height:settings.height,age:settings.age,activity:settings.activity,surplus:settings.surplus,updated_at:new Date().toISOString()})
  });
}

async function saveFood(food){
  await fetch(`${SUPABASE_URL}/rest/v1/foods`,{
    method:'POST',
    headers:{apikey:SUPABASE_KEY,Authorization:`Bearer ${accessToken}`,'Content-Type':'application/json'},
    body:JSON.stringify({...food,user_id:currentUser.id})
  });
}

// ── Render ──
function render(){try{if(!loaded)return;renderNav();renderDashboard();renderLog();renderFoods();renderHistory();renderSettings();if(isAdmin)renderAdmin()}catch(e){console.error('render error:',e)}}
function renderNav(){document.querySelectorAll('.view').forEach(v=>v.classList.toggle('active-view',v.id===selectedView));document.querySelectorAll('.nav-item').forEach(b=>b.classList.toggle('active',b.dataset.nav===selectedView))}

function renderDashboard(){
  const t=totals(),pct=Math.min(100,Math.round(t.kcal/target()*100));
  const name=currentUser?.user_metadata?.name||currentUser?.email||'';
  document.getElementById('todayGreeting').textContent=name?`Hola, ${name}`:'Vamos a por el objetivo.';
  document.getElementById('todayDate').textContent=dateLabel(selectedDate);
  document.getElementById('dashCalories').textContent=fmt(t.kcal);
  document.getElementById('dashTarget').textContent=fmt(target());
  document.getElementById('dashProtein').textContent=fmt(t.p,1);
  document.getElementById('dashSurplus').textContent=(t.kcal-target()>=0?'+':'')+fmt(t.kcal-target());
  document.getElementById('ringValue').textContent=pct+'%';
  document.getElementById('calorieRing').style.background=`conic-gradient(var(--accent) ${pct*3.6}deg,rgba(255,255,255,0.08) ${pct*3.6}deg)`;
  document.getElementById('mealSummary').innerHTML=getLog().meals.map(m=>`<div class="meal-row"><div class="meal-icon">${mealIcons[m.name]||'🍴'}</div><div class="meal-copy"><strong>${m.name}</strong><span>${fmt(m.p,1)} g proteína · ${fmt(m.c,1)} g hidratos</span></div><div class="meal-kcal">${fmt(m.kcal)} kcal</div></div>`).join('');
  const weights=weekData.filter(w=>w.end).map(w=>w.end),cw=weights.at(-1)||settings.weight;
  document.getElementById('currentWeight').textContent=fmt(cw,2)+' kg';
  document.getElementById('weightDelta').textContent=weights.length>1?`${fmt(weights.at(-1)-weights.at(-2),2)} kg desde la semana anterior`:'Añade tu peso final';
  const sl=document.getElementById('weightSparkline');
  if(sl&&weights.length){const mn=Math.min(...weights),mx=Math.max(...weights),range=mx-mn||1;sl.innerHTML=weights.map(v=>`<div class="spark-bar" style="height:${Math.max(10,((v-mn)/range)*100)}%"></div>`).join('')}
}

function renderLog(){
  document.getElementById('datePicker').value=selectedDate;
  document.getElementById('logTarget').textContent=fmt(target())+' kcal';
  document.getElementById('mealEditor').innerHTML=getLog().meals.map((m,i)=>`<div class="editor-row"><div class="meal-icon">${mealIcons[m.name]||'🍴'}</div><div class="editor-fields"><label>${m.name}<input data-meal="${i}" data-key="name" value="${m.name}"></label><label>kcal<input type="number" data-meal="${i}" data-key="kcal" value="${m.kcal||0}"></label><label>prot. g<input type="number" step=".1" data-meal="${i}" data-key="p" value="${m.p||0}"></label><label>grasa g<input type="number" step=".1" data-meal="${i}" data-key="f" value="${m.f||0}"></label><label>HC g<input type="number" step=".1" data-meal="${i}" data-key="c" value="${m.c||0}"></label></div></div>`).join('');
  const t=totals();
  document.getElementById('macroBars').innerHTML=[['Proteínas',t.p,120,'protein'],['Grasas',t.f,55,'fat'],['Hidratos',t.c,320,'carbs']].map(x=>`<div class="macro-line"><span>${x[0]}</span><div class="track"><div class="fill ${x[3]}" style="width:${Math.min(100,x[1]/x[2]*100)}%"></div></div><em>${fmt(x[1],1)} g</em></div>`).join('');
  updateSaveBtn();
}

function updateSaveBtn(){
  const btn=document.getElementById('saveLogBtn');
  if(btn)btn.classList.toggle('dirty',dirty);
}

function renderFoods(){
  const q=(document.getElementById('foodSearch')?.value||'').toLowerCase();
  document.getElementById('foodList').innerHTML=foods.filter(f=>(f.name+f.brand).toLowerCase().includes(q)).map(f=>`<div class="food-row"><div class="food-badge">${f.icon||'🥗'}</div><div><strong>${f.name}</strong><span>${f.brand} · P ${fmt(f.p,1)} g · G ${fmt(f.f,1)} g · HC ${fmt(f.c,1)} g</span></div><div class="food-kcal">${fmt(f.kcal)}<small> kcal</small></div></div>`).join('')||'<div class="notice"><strong>No hay resultados</strong><p>Prueba con otro nombre.</p></div>';
}

function renderHistory(){
  const select=document.getElementById('weekSelect');
  select.innerHTML=weekData.map((w,i)=>`<option value="${i}">${w.name}</option>`).join('');
  select.value=selectedWeek;
  const w=weekData[selectedWeek];
  document.getElementById('historyStart').textContent=fmt(w.start,2)+' kg';
  document.getElementById('historyEnd').textContent=w.end?fmt(w.end,2)+' kg':'Pendiente';
  document.getElementById('historyChange').textContent=w.end?`${w.end-w.start>=0?'+':''}${fmt(w.end-w.start,2)} kg`:'—';
  const max=Math.max(...w.calories,...w.targets);
  document.getElementById('calorieChart').innerHTML=w.calories.map((v,i)=>`<div class="bar-group"><div class="bar consumed" style="height:${v/max*100}%"></div><div class="bar target" style="height:${w.targets[i]/max*100}%"></div><span class="bar-label">${days[i].slice(0,2)}</span></div>`).join('');
  const avg=k=>w[k].reduce((a,b)=>a+b,0)/7;
  document.getElementById('weekMacros').innerHTML=[['Proteínas',avg('protein')],['Grasas',avg('fat')],['Hidratos',avg('carbs')]].map(x=>`<div><span>${x[0]}</span><strong>${fmt(x[1],1)} g</strong></div>`).join('');
}

function renderSettings(){
  const f=document.getElementById('settingsForm');
  if(f.elements.weight)f.elements.weight.value=settings.weight;
  if(f.elements.height)f.elements.height.value=settings.height;
  if(f.elements.age)f.elements.age.value=settings.age;
  if(f.elements.activity){
    const sel=f.elements.activity;
    const val=String(settings.activity);
    if([...sel.options].some(o=>o.value===val))sel.value=val;
    else{const opt=document.createElement('option');opt.value=val;opt.textContent=val+' — Personalizado';sel.add(opt);sel.value=val}
  }
  if(f.elements.surplus)f.elements.surplus.value=settings.surplus;
  document.getElementById('settingsTMB').textContent=fmt(tmb())+' kcal';
  document.getElementById('settingsTDEE').textContent=fmt(tdee())+' kcal';
  document.getElementById('settingsTarget').textContent=fmt(target())+' kcal';
  const pf=document.getElementById('profileForm');
  if(pf&&pf.elements.displayName)pf.elements.displayName.value=currentUser?.user_metadata?.name||'';
}

// ── Admin panel ──
let adminData={profiles:[],settings:[],logs:[]};

async function loadAdminData(){
  const [profiles,settingsList,logsList]=await Promise.all([
    sb('profiles?select=id,display_name,created_at&order=created_at.desc'),
    sb('settings?select=*'),
    sb('logs?select=user_id,date,meals&order=user_id,date')
  ]);
  adminData={profiles:profiles||[],settings:settingsList||[],logs:logsList||[]};
}

async function renderAdmin(){
  await loadAdminData();
  const list=document.getElementById('adminUserList');
  const detail=document.getElementById('adminDetail');
  if(!list)return;
  detail.style.display='none';
  list.style.display='';

  if(!adminData.profiles.length){
    list.innerHTML='<div class="admin-empty"><strong>No hay usuarios</strong><p>Espera a que se registren usuarios.</p></div>';
    return;
  }

  const today=todayISO();
  list.innerHTML=adminData.profiles.map(p=>{
    const s=adminData.settings.find(s=>s.user_id===p.id)||{};
    const todayLog=adminData.logs.find(l=>l.user_id===p.id&&l.date===today);
    const todayCal=todayLog?(todayLog.meals||[]).reduce((a,m)=>a+Number(m.kcal||0),0):0;
    const initial=(p.display_name||p.id.slice(0,8))[0].toUpperCase();
    return `<div class="admin-user-card" data-uid="${p.id}">
      <div class="admin-avatar">${initial}</div>
      <div class="admin-user-info">
        <strong>${p.display_name||'Sin nombre'}</strong>
        <span>Registro: ${new Date(p.created_at).toLocaleDateString('es-ES')}</span>
      </div>
      <div class="admin-user-stats">
        <div class="admin-stat"><span>Hoy</span><strong>${fmt(todayCal)}</strong></div>
        <div class="admin-stat"><span>Peso</span><strong>${s.weight?fmt(s.weight,2)+' kg':'—'}</strong></div>
      </div>
    </div>`;
  }).join('');

  list.querySelectorAll('.admin-user-card').forEach(card=>{
    card.addEventListener('click',()=>showAdminDetail(card.dataset.uid));
  });
}

function showAdminDetail(uid){
  const p=adminData.profiles.find(p=>p.id===uid);
  const s=adminData.settings.find(s=>s.user_id===uid)||{};
  const userLogs=adminData.logs.filter(l=>l.user_id===uid).sort((a,b)=>b.date.localeCompare(a.date)).slice(0,14);
  const initial=(p?.display_name||uid.slice(0,8))[0].toUpperCase();

  const userSettings={weight:s.weight||56,height:s.height||165,age:s.age||26,activity:s.activity||1.2,surplus:s.surplus||150};
  const tdee=Math.round((10*userSettings.weight+6.25*userSettings.height-5*userSettings.age+5)*userSettings.activity+userSettings.surplus);

  const last7=userLogs.slice(0,7);
  const avgCal=last7.length?Math.round(last7.reduce((a,l)=>a+(l.meals||[]).reduce((s,m)=>s+Number(m.kcal||0),0),0)/last7.length):0;
  const avgProt=last7.length?+(last7.reduce((a,l)=>a+(l.meals||[]).reduce((s,m)=>s+Number(m.p||0),0),0)/last7.length).toFixed(1):0;

  document.getElementById('adminUserList').style.display='none';
  const detail=document.getElementById('adminDetail');
  detail.style.display='';

  document.getElementById('adminDetailContent').innerHTML=`
    <div class="admin-detail-header">
      <div class="admin-detail-avatar">${initial}</div>
      <div class="admin-detail-info">
        <strong>${p?.display_name||'Sin nombre'}</strong>
        <span>${p?.id?.slice(0,8)}… · Registro ${new Date(p?.created_at).toLocaleDateString('es-ES')}</span>
      </div>
    </div>
    <div class="admin-detail-stats">
      <article class="metric-card"><span>Objetivo</span><strong>${fmt(tdee)}</strong><small>kcal/día</small></article>
      <article class="metric-card"><span>Media 7d</span><strong>${fmt(avgCal)}</strong><small>kcal</small></article>
      <article class="metric-card"><span>Prot. media</span><strong>${fmt(avgProt,1)}</strong><small>g</small></article>
    </div>
    <div class="section-heading compact"><div><p class="eyebrow">Últimos registros</p><h2>Diario</h2></div></div>
    ${userLogs.length?userLogs.map(l=>{
      const cal=(l.meals||[]).reduce((a,m)=>a+Number(m.kcal||0),0);
      const prot=(l.meals||[]).reduce((a,m)=>a+Number(m.p||0),0);
      const pct=Math.min(100,Math.round(cal/tdee*100));
      return `<div class="admin-week-row">
        <span>${new Date(l.date+'T12:00:00').toLocaleDateString('es-ES',{weekday:'short',day:'numeric',month:'short'})}</span>
        <strong>${fmt(cal)} kcal · ${fmt(prot,1)}g prot · ${pct}%</strong>
      </div>`;
    }).join(''):'<div class="admin-empty"><p>Sin registros recientes</p></div>'}
  `;
}

// ── Toast ──
function toast(msg){const el=document.getElementById('toast');el.textContent=msg;el.classList.add('show');setTimeout(()=>el.classList.remove('show'),1800)}

// ── Event listeners ──
document.addEventListener('click',e=>{
  const nav=e.target.closest('[data-nav]');
  if(nav){
    selectedView=nav.dataset.nav;
    render();
    window.scrollTo({top:0,behavior:'smooth'});
  }
});

document.getElementById('loginForm').addEventListener('submit',async e=>{
  e.preventDefault();
  const fd=new FormData(e.target);
  const errEl=document.getElementById('authError');
  errEl.textContent='';
  try{
    const d=await signIn(fd.get('email'),fd.get('password'));
    setSession(d);
    showApp();
    await loadData();
    toast('Sesión iniciada');
  }catch(err){errEl.textContent=err.message}
});

document.getElementById('registerForm').addEventListener('submit',async e=>{
  e.preventDefault();
  const fd=new FormData(e.target);
  const errEl=document.getElementById('authError');
  errEl.textContent='';
  try{
    const d=await signUp(fd.get('email'),fd.get('password'),fd.get('name'));
    if(d.user&&d.access_token){
      setSession(d);
      showApp();
      await loadData();
      toast('Cuenta creada — ¡bienvenido!');
    }else{
      errEl.textContent='Revisa tu email para confirmar la cuenta.';
    }
  }catch(err){errEl.textContent=err.message}
});

document.getElementById('logoutBtn').addEventListener('click',signOut);

document.getElementById('datePicker').addEventListener('change',e=>{selectedDate=e.target.value;dirty=false;render()});
document.getElementById('weekSelect').addEventListener('change',e=>{selectedWeek=Number(e.target.value);renderHistory()});
document.getElementById('foodSearch').addEventListener('input',renderFoods);

document.getElementById('mealEditor').addEventListener('input',e=>{
  const i=e.target.dataset.meal;if(i===undefined)return;
  const log=getLog();
  log.meals[i][e.target.dataset.key]=e.target.dataset.key==='name'?e.target.value:Number(e.target.value);
  dirty=true;
  const t=totals();
  document.getElementById('logTarget').textContent=fmt(target())+' kcal';
  document.getElementById('dashCalories').textContent=fmt(t.kcal);
  document.getElementById('dashProtein').textContent=fmt(t.p,1);
  document.getElementById('dashSurplus').textContent=(t.kcal-target()>=0?'+':'')+fmt(t.kcal-target());
  const pct=Math.min(100,Math.round(t.kcal/target()*100));
  document.getElementById('ringValue').textContent=pct+'%';
  document.getElementById('calorieRing').style.background=`conic-gradient(var(--accent) ${pct*3.6}deg,rgba(255,255,255,0.08) ${pct*3.6}deg)`;
  document.getElementById('macroBars').innerHTML=[['Proteínas',t.p,120,'protein'],['Grasas',t.f,55,'fat'],['Hidratos',t.c,320,'carbs']].map(x=>`<div class="macro-line"><span>${x[0]}</span><div class="track"><div class="fill ${x[3]}" style="width:${Math.min(100,x[1]/x[2]*100)}%"></div></div><em>${fmt(x[1],1)} g</em></div>`).join('');
  updateSaveBtn();
});

document.getElementById('saveLogBtn').addEventListener('click',async()=>{
  if(!dirty)return;
  const btn=document.getElementById('saveLogBtn');
  btn.textContent='Guardando...';btn.disabled=true;
  await saveLog();
  dirty=false;btn.textContent='Guardado ✓';btn.classList.remove('dirty');
  renderDashboard();
  setTimeout(()=>{btn.textContent='Guardar día';btn.disabled=false},1200);
  toast('Guardado en Supabase');
});

document.getElementById('addMeal').addEventListener('click',()=>{getLog().meals.push({name:'Merienda',kcal:0,p:0,f:0,c:0});dirty=true;renderLog();renderDashboard();toast('Comida añadida — recuerda guardar')});

document.getElementById('addFood').addEventListener('click',()=>{document.getElementById('foodModal').classList.add('open');document.getElementById('foodForm').reset();document.getElementById('foodForm').querySelector('[name=foodName]').focus()});
document.getElementById('closeFoodModal').addEventListener('click',()=>document.getElementById('foodModal').classList.remove('open'));
document.getElementById('foodModal').addEventListener('click',e=>{if(e.target===e.currentTarget)e.target.classList.remove('open')});
document.getElementById('foodForm').addEventListener('submit',async e=>{
  e.preventDefault();
  const fd=new FormData(e.target);
  const food={name:fd.get('foodName'),brand:fd.get('foodBrand')||'',kcal:Number(fd.get('foodKcal'))||0,p:Number(fd.get('foodP'))||0,f:Number(fd.get('foodF'))||0,c:Number(fd.get('foodC'))||0,icon:fd.get('foodIcon')||'🥗'};
  await saveFood(food);
  foods.unshift(food);
  renderFoods();
  document.getElementById('foodModal').classList.remove('open');
  toast('Alimento guardado en Supabase');
});

document.getElementById('settingsForm').addEventListener('submit',async e=>{
  e.preventDefault();
  settings.weight=Number(e.target.elements.weight.value)||0;
  settings.height=Number(e.target.elements.height.value)||0;
  settings.age=Number(e.target.elements.age.value)||0;
  settings.activity=Number(e.target.elements.activity.value)||1.2;
  settings.surplus=Number(e.target.elements.surplus.value)||0;
  try{await saveSettings();render();toast('Objetivos actualizados')}catch(err){console.error('saveSettings:',err);toast('Error al guardar')}
});

document.getElementById('settingsForm').addEventListener('input',e=>{
  const f=e.target.form;if(!f)return;
  const w=Number(f.elements.weight.value)||settings.weight;
  const h=Number(f.elements.height.value)||settings.height;
  const a=Number(f.elements.age.value)||settings.age;
  const act=Number(f.elements.activity.value)||1.2;
  const sur=Number(f.elements.surplus.value)||0;
  const bmr=Math.round(10*w+6.25*h-5*a+5);
  const total=Math.round(bmr*act);
  document.getElementById('settingsTMB').textContent=fmt(bmr)+' kcal';
  document.getElementById('settingsTDEE').textContent=fmt(total)+' kcal';
  document.getElementById('settingsTarget').textContent=fmt(total+sur)+' kcal';
});

document.getElementById('adminBack')?.addEventListener('click',()=>renderAdmin());

document.getElementById('profileForm').addEventListener('submit',async e=>{
  e.preventDefault();
  const name=e.target.elements.displayName.value.trim();
  if(!name){toast('Introduce un nombre');return}
  try{
    const r=await fetch(`${SUPABASE_URL}/auth/v1/user`,{
      method:'PUT',
      headers:{apikey:SUPABASE_KEY,Authorization:`Bearer ${accessToken}`,'Content-Type':'application/json'},
      body:JSON.stringify({data:{name}})
    });
    const d=await r.json();
    if(d.error)throw new Error(d.error_description||d.msg);
    currentUser=d;
    await sb('profiles',{method:'POST',headers:{'Prefer':'resolution=merge-duplicates'},body:JSON.stringify({id:currentUser.id,display_name:name})});
    document.getElementById('avatarBtn').textContent=userInitial();
    document.getElementById('todayGreeting').textContent=`Hola, ${name}`;
    toast('Nombre actualizado');
  }catch(err){toast(err.message)}
});

document.getElementById('passwordForm').addEventListener('submit',async e=>{
  e.preventDefault();
  const fd=new FormData(e.target);
  const errEl=document.getElementById('passwordError');
  errEl.textContent='';
  const pw=fd.get('newPassword');
  const pw2=fd.get('confirmPassword');
  if(pw!==pw2){errEl.textContent='Las contraseñas no coinciden';return}
  if(pw.length<6){errEl.textContent='Mínimo 6 caracteres';return}
  try{
    const r=await fetch(`${SUPABASE_URL}/auth/v1/user`,{
      method:'PUT',
      headers:{apikey:SUPABASE_KEY,Authorization:`Bearer ${accessToken}`,'Content-Type':'application/json'},
      body:JSON.stringify({password:pw})
    });
    const d=await r.json();
    if(d.error)throw new Error(d.error_description||d.msg||'Error al cambiar contraseña');
    e.target.reset();
    toast('Contraseña actualizada');
  }catch(err){errEl.textContent=err.message}
});

init().catch(e=>{console.error('init error:',e);showAuth()});
