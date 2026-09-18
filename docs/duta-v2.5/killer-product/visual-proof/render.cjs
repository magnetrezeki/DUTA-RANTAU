const path=require('path'),fs=require('fs');
const root=process.env.DUTA_RUNTIME_MODULES;
if(!root)throw Error('Set DUTA_RUNTIME_MODULES to the bundled node_modules path');
const {chromium}=require(path.join(root,'playwright'));
const sharp=require(path.join(root,'sharp'));
(async()=>{
 const dir=path.join(__dirname,'renders');fs.mkdirSync(dir,{recursive:true});
 const browser=await chromium.launch({executablePath:'C:/Program Files (x86)/Microsoft/Edge/Application/msedge.exe',headless:true});
 const names=['01-landing-desktop','02-landing-mobile','03-today','04-ask','05-jaga-diri','06-auth'];
 const checks=[];
 for(let i=0;i<names.length;i++){
 const viewport=i===0?{width:1440,height:900}:{width:390,height:844};
 const page=await browser.newPage({viewport,deviceScaleFactor:1});
 await page.route('http**/*',r=>r.abort());
 await page.goto('file:///'+path.join(__dirname,names[i]+'.html').replaceAll('\\','/'));
 await page.screenshot({path:path.join(dir,names[i]+'.png')});
 await page.screenshot({path:path.join(dir,names[i]+'-full.png'),fullPage:true});
 checks.push({screen:names[i],...await page.evaluate(()=>({width:innerWidth,scrollWidth:document.documentElement.scrollWidth,height:document.documentElement.scrollHeight,imagesReady:[...document.images].every(i=>i.complete&&i.naturalWidth>0)}))});
 if(i===3){
 for(const [key,label] of [['mendengar','MENDENGAR'],['memahami','MEMAHAMI'],['mencari-sumber','MENCARI SUMBER']]){
 await page.evaluate(label=>{document.querySelector('.rail').innerHTML='<span class="dot"></span>'+label+' · simulasi';document.querySelector('.answer').innerHTML='<h3>'+label.charAt(0)+label.slice(1).toLowerCase()+'…</h3><p class="mini">Pertanyaan Anda tetap terlihat. Anda bisa membatalkan dan melanjutkan dengan teks.</p><a class="button secondary" href="04-ask.html">Batalkan</a>';},label);
 await page.screenshot({path:path.join(dir,'04-state-'+key+'.png')});
 }
 }
 await page.close();
 }
 const tiles=[];
 tiles.push({input:await sharp(path.join(dir,names[0]+'.png')).resize(960,600).toBuffer(),left:40,top:100});
 for(let i=1;i<6;i++)tiles.push({input:await sharp(path.join(dir,names[i]+'.png')).resize(312,675).toBuffer(),left:40+(i-1)*340,top:800});
 const labels=Buffer.from(`<svg width="1780" height="1540"><rect width="1780" height="1540" fill="#eae7df"/><style>text{font-family:Segoe UI,sans-serif;fill:#172e35}</style><text x="40" y="52" font-size="28">DUTA RANTAU / TEMAN DI RANTAU</text><text x="1050" y="160" font-size="24">KPP-03A.1 · Founder visual proof</text><text x="1050" y="204" font-size="18">Temporary AI photograph · isolated prototypes</text><text x="1050" y="240" font-size="18">Awaiting founder review</text><text x="40" y="750" font-size="18">01 Public landing · desktop 1440 × 900</text>${['02 Landing','03 Today','04 Ask DUTA','05 Jaga Diri','06 Auth'].map((n,i)=>`<text x="${40+i*340}" y="785" font-size="18">${n} · 390 × 844</text>`).join('')}</svg>`);
 await sharp(labels).composite(tiles).png().toFile(path.join(dir,'contact-sheet.png'));
 fs.writeFileSync(path.join(dir,'checks.json'),JSON.stringify(checks,null,2));
 await browser.close();console.log(JSON.stringify(checks));
})();
