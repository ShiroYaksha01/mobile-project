// seed.mjs — Seed script for Souvenir Collection
// Run: node seed.mjs
import http from 'http';

const API = 'http://127.0.0.1:5248/api';
const HEADERS = {
  'X-API-KEY': 'mobile-key123',
  'Content-Type': 'application/json',
};
let AUTH_HEADER = {}; // set after login

function req(method, path, body = null) {
  return new Promise((resolve, reject) => {
    const url = new URL(API + path);
    const options = {
      method,
      hostname: url.hostname,
      port: url.port,
      path: url.pathname + url.search,
      headers: { ...HEADERS, ...AUTH_HEADER },
    };
    const r = http.request(options, (res) => {
      let data = '';
      res.on('data', (chunk) => data += chunk);
      res.on('end', () => {
        try { resolve(JSON.parse(data)); }
        catch { resolve(data); }
      });
    });
    r.on('error', reject);
    if (body) r.write(JSON.stringify(body));
    r.end();
  });
}

const get = (path) => req('GET', path);
const post = (path, body) => req('POST', path, body);

async function main() {
  console.log('=== Seeding Souvenir Collection ===\n');

  // Step 1: Login
  console.log('--- Step 1: Login ---');
  const login = await post('/auth/login', {
    email: 'sokha@example.com',
    password: 'password123'
  });
  if (!login.success) {
    // Try register
    console.log('Login failed, trying register...');
    const reg = await post('/auth/register', {
      name: 'Sokha',
      email: 'sokha@example.com',
      password: 'password123',
      confirmPassword: 'password123',
      role: 'Customer'
    });
    console.log('Register:', reg.success ? 'OK' : 'FAILED');
  }
  const login2 = await post('/auth/login', {
    email: 'sokha@example.com',
    password: 'password123'
  });
  const token = login2.data?.accessToken || '';
  AUTH_HEADER['Authorization'] = `Bearer ${token}`;
  console.log('Logged in, token:', token.substring(0, 30) + '...');

  // Get user ID
  const me = await get('/auth/me');
  const USER_ID = me.data?.id || '';
  console.log('USER_ID:', USER_ID);

  // Step 2: Categories
  console.log('\n--- Step 2: Categories ---');
  const catNames = ['Textile', 'Silver', 'Wood', 'Ceramics', 'Jewelry'];
  const catIds = {};
  for (const name of catNames) {
    const r = await post('/categories', { name, image: '' });
    catIds[name] = r.data?.id || '';
    console.log(`  ${name}: ${catIds[name]}`);
  }

  // Step 3: Artisans
  console.log('\n--- Step 3: Artisans ---');
  const artisans = [
    { displayName:'Sokunthea Silk Weaver', region:'Siem Reap', craftType:'Textile',
      bio:'Third-generation silk weaver preserving traditional Khmer ikat patterns since 1985.',
      profilePhotoUrl:'https://images.unsplash.com/photo-1590736961830-e1a2b3c4d5e6?w=400',
      shopAddress:'Wat Damnak Village, Siem Reap', lat:13.3671, lng:103.8632 },
    { displayName:'Dara Silver Workshop', region:'Phnom Penh', craftType:'Silver',
      bio:'Master silversmith crafting intricate jewelry and ceremonial bowls with 99.9% pure Cambodian silver.',
      profilePhotoUrl:'https://images.unsplash.com/photo-1580870069867-74c5c1e4d9a7?w=400',
      shopAddress:'Russian Market Area, Phnom Penh', lat:11.5365, lng:104.9190 },
    { displayName:'Bunna Wood Carving', region:'Kampong Thom', craftType:'Wood',
      bio:'Hand-carved wooden sculptures inspired by Angkorian bas-reliefs and Buddhist teachings.',
      profilePhotoUrl:'https://images.unsplash.com/photo-1565193566173-7a0af2bf2306?w=400',
      shopAddress:'Sambor Village, Kampong Thom', lat:12.7116, lng:104.8891 },
    { displayName:'Maly Ceramic Studio', region:'Kampong Chhnang', craftType:'Ceramics',
      bio:'Hand-thrown pottery using locally sourced clay and traditional wood-fired kilns.',
      profilePhotoUrl:'https://images.unsplash.com/photo-1565193566173-7a0af2bf2306?w=400',
      shopAddress:'Andoung Snay Village, Kampong Chhnang', lat:12.2540, lng:104.6660 },
  ];
  const artIds = [];
  for (const a of artisans) {
    const r = await post('/artisans', a);
    artIds.push(r.data?.id || '');
    console.log(`  ${a.displayName}: ${artIds[artIds.length-1]}`);
  }

  // Step 4: Products
  console.log('\n--- Step 4: Products ---');
  const products = [
    { artisanId:artIds[0], categoryId:catIds['Textile'], name:'Handwoven Ikat Silk Scarf',
      description:'Luxurious handwoven scarf using traditional Khmer ikat techniques. Dyed with natural indigo and prohut bark. Each piece takes 3 weeks to complete.',
      price:45, stockQty:15, image:'https://images.unsplash.com/photo-1601924994987-69e26d50dc26?w=600', isAvailable:true },
    { artisanId:artIds[0], categoryId:catIds['Textile'], name:'Cotton Krama Scarf',
      description:'The iconic Cambodian krama — a multipurpose cotton scarf worn by Khmer people for centuries. Checkered pattern in red and white.',
      price:12, stockQty:50, image:'https://images.unsplash.com/photo-1558618666-fcd25c85f82e?w=600', isAvailable:true },
    { artisanId:artIds[1], categoryId:catIds['Silver'], name:'Silver Elephant Pendant',
      description:'Handcrafted 99.9% pure silver pendant depicting a walking elephant. Each detail is hand-chiseled by master artisan Dara.',
      price:68, stockQty:8, image:'https://images.unsplash.com/photo-1602751584552-8ba73aad10e1?w=600', isAvailable:true },
    { artisanId:artIds[1], categoryId:catIds['Jewelry'], name:'Apsara Silver Bracelet',
      description:'Intricate bracelet inspired by Apsara celestial dancers of Angkor Wat. Hand-engraved with floral motifs.',
      price:95, stockQty:5, image:'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=600', isAvailable:true },
    { artisanId:artIds[2], categoryId:catIds['Wood'], name:'Angkor Wat Wood Panel',
      description:'Hand-carved rosewood wall panel depicting the iconic Angkor Wat temple. Intricate bas-relief style carving on sustainably sourced wood.',
      price:150, stockQty:3, image:'https://images.unsplash.com/photo-1544027993-37dbfe43562a?w=600', isAvailable:true },
    { artisanId:artIds[2], categoryId:catIds['Wood'], name:'Buddha Face Wall Hanging',
      description:'Serene Buddha face carved from reclaimed mahogany. Finished with natural beeswax. Peaceful addition to any space.',
      price:85, stockQty:6, image:'https://images.unsplash.com/photo-1508182319732-8e0e2e7c78e3?w=600', isAvailable:true },
    { artisanId:artIds[3], categoryId:catIds['Ceramics'], name:'Khmer Lotus Tea Set',
      description:'Hand-thrown ceramic tea set with lotus petal design. Includes teapot and 4 cups. Fired in a traditional wood kiln.',
      price:72, stockQty:10, image:'https://images.unsplash.com/photo-1578749556568-bc2c40e68b61?w=600', isAvailable:true },
  ];
  const prodIds = [];
  for (const p of products) {
    const r = await post('/products', p);
    prodIds.push(r.data?.id || '');
    console.log(`  ${p.name}: ${prodIds[prodIds.length-1]}`);
  }

  // Step 5: Collections
  console.log('\n--- Step 5: Collections ---');
  const collections = [
    { title:'Angkor Collection', slug:'angkor-collection', type:'Featured',
      description:'Pieces inspired by the temples of Angkor — from sandstone hues to Apsara motifs. Each item carries the spirit of the Khmer Empire.',
      image:'https://images.unsplash.com/photo-1580618672591-ebc3f7a3b9cb?w=800' },
    { title:'Silk & Weave Heritage', slug:'silk-weave-heritage', type:'Textile',
      description:'Centuries-old weaving traditions from Cambodia rural provinces. Hand-dyed silks, cotton kramas, and ikat masterpieces.',
      image:'https://images.unsplash.com/photo-1544027993-37dbfe43562a?w=800' },
    { title:'Silver & Gold Craft', slug:'silver-gold-craft', type:'Jewelry',
      description:'Precious metalwork from Cambodia finest silversmiths. Necklaces, bracelets, ceremonial bowls, and decorative art.',
      image:'https://images.unsplash.com/photo-1602751584552-8ba73aad10e1?w=800' },
  ];
  const colIds = [];
  for (const c of collections) {
    const r = await post('/collections', c);
    colIds.push(r.data?.id || '');
    console.log(`  ${c.title}: ${colIds[colIds.length-1]}`);
  }

  // Step 6: Add Products to Collections
  console.log('\n--- Step 6: Link Products → Collections ---');
  const links = [
    [colIds[0], prodIds[4]], [colIds[0], prodIds[5]], // Angkor: wood panel, buddha
    [colIds[1], prodIds[0]], [colIds[1], prodIds[1]], // Silk: ikat scarf, krama
    [colIds[2], prodIds[2]], [colIds[2], prodIds[3]], // Silver: elephant, bracelet
  ];
  for (const [colId, prodId] of links) {
    await post(`/collections/${colId}/products?productId=${prodId}`);
    console.log(`  + Product ${prodId} → Collection ${colId}`);
  }

  // Step 7: Verify Artisans
  console.log('\n--- Step 7: Verify Artisans ---');
  for (const id of artIds) {
    await post(`/artisans/${id}/verify`);
    console.log(`  Verified: ${id}`);
  }

  // Step 8: Quiz
  console.log('\n--- Step 8: Quiz ---');
  const quizData = [
    { q:'What type of gift are you looking for?', order:1, answers:[
      { text:'Something to wear', tags:'textile,scarf,clothing' },
      { text:'Home decoration', tags:'wood,ceramics,decor' },
      { text:'Jewelry or accessory', tags:'silver,jewelry,pendant,bracelet' },
    ]},
    { q:'What is your budget?', order:2, answers:[
      { text:'Under $25', tags:'budget,scarf,krama' },
      { text:'$25–$100', tags:'mid,pendant,tea,bracelet' },
      { text:'Over $100', tags:'premium,panel,silver' },
    ]},
    { q:'Who is the gift for?', order:3, answers:[
      { text:'Family member', tags:'scarf,tea,traditional' },
      { text:'Friend', tags:'pendant,bracelet,silver' },
      { text:'Myself', tags:'panel,scarf,decor' },
    ]},
    { q:'What style do they prefer?', order:4, answers:[
      { text:'Traditional & cultural', tags:'silk,wood,krama,ikat' },
      { text:'Modern & minimalist', tags:'silver,ceramic,tea' },
      { text:'Bold & artistic', tags:'ikat,pendant,panel' },
    ]},
  ];
  for (const qd of quizData) {
    const qr = await post('/quiz', { questionText: qd.q, displayOrder: qd.order });
    const qId = qr.data?.id || '';
    console.log(`  Q${qd.order}: ${qId} — "${qd.q}"`);
    for (const a of qd.answers) {
      await post('/quiz/answer', { questionId: qId, answerText: a.text, tags: a.tags });
      console.log(`    Answer: ${a.text}`);
    }
  }

  // Step 9: Promotions
  console.log('\n--- Step 9: Promotions ---');
  const promos = [
    { title:'Welcome 15% Off', code:'WELCOME15', description:'New customer discount — 15% off your first purchase.',
      image:'', discountType:'Percentage', discount:15, usageLimit:100,
      startDate:'2026-06-01T00:00:00Z', endDate:'2026-12-31T23:59:59Z' },
    { title:'$10 Off Orders Over $50', code:'KHMR10', description:'Save $10 when you spend $50 or more.',
      image:'', discountType:'FixedAmount', discount:10, usageLimit:50,
      startDate:'2026-06-01T00:00:00Z', endDate:'2026-09-30T23:59:59Z' },
  ];
  for (const p of promos) {
    const r = await post('/promotions', p);
    const id = r.data?.id || '';
    await post(`/promotions/${id}/activate`);
    console.log(`  ${p.code}: ${id} (activated)`);
  }

  // Step 10: Reviews
  console.log('\n--- Step 10: Reviews ---');
  const reviews = [
    { userId:USER_ID, productId:prodIds[0], reviewText:'Absolutely stunning scarf! The colors are even more vibrant in person. You can feel the craftsmanship in every thread.', rating:5, image:'' },
    { userId:USER_ID, productId:prodIds[2], reviewText:'Beautiful silver pendant, arrived in a lovely gift box. Perfect present for my sister — she wears it every day!', rating:5, image:'' },
    { userId:USER_ID, productId:prodIds[4], reviewText:'The carving detail is incredible. Looks amazing on my wall. Shipping was fast and well-packaged.', rating:4, image:'' },
  ];
  for (const rv of reviews) {
    const r = await post('/reviews', rv);
    console.log(`  Review for ${rv.productId}: ${r.data?.id || 'FAIL'}`);
  }

  console.log('\n============================================');
  console.log('  ✅ SEEDING COMPLETE!');
  console.log('============================================');
  console.log(`  User:       ${USER_ID}`);
  console.log(`  Categories: ${Object.values(catIds).join(', ')}`);
  console.log(`  Artisans:   ${artIds.join(', ')}`);
  console.log(`  Products:   ${prodIds.join(', ')}`);
  console.log(`  Collections: ${colIds.join(', ')}`);
  console.log('\n  Restart your Flutter app to see all data!');
}

main().catch(e => { console.error('SEED FAILED:', e.message); process.exit(1); });
