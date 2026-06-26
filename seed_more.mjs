// Add more products to existing artisans
import http from 'http';

const API = 'http://127.0.0.1:5248/api';
const HEADERS = {
  'X-API-KEY': 'mobile-key123',
  'Content-Type': 'application/json',
};
let AUTH = {};

function req(method, path, body = null) {
  return new Promise((resolve, reject) => {
    const url = new URL(API + path);
    const options = { method, hostname: url.hostname, port: url.port, path: url.pathname + url.search, headers: { ...HEADERS, ...AUTH } };
    const r = http.request(options, (res) => {
      let data = '';
      res.on('data', (chunk) => data += chunk);
      res.on('end', () => { try { resolve(JSON.parse(data)); } catch { resolve(data); } });
    });
    r.on('error', reject);
    if (body) r.write(JSON.stringify(body));
    r.end();
  });
}

const post = (path, body) => req('POST', path, body);
const get = (path) => req('GET', path);

async function main() {
  // Login
  const login = await post('/auth/login', { email: 'sokha@example.com', password: 'password123' });
  const token = login.data?.accessToken || '';
  AUTH['Authorization'] = `Bearer ${token}`;
  console.log('Logged in');

  // Get existing artisans and categories
  const arts = await get('/artisans');
  const cats = await get('/categories');
  const artisans = arts.data || [];
  const categories = cats.data || [];

  // Find verified artisans by craft
  const textile = artisans.find(a => a.craftType === 'Textile' && a.isVerified);
  const silver = artisans.find(a => a.craftType === 'Silver' && a.isVerified);
  const wood = artisans.find(a => a.craftType === 'Wood' && a.isVerified);
  const ceramic = artisans.find(a => a.craftType === 'Ceramics' && a.isVerified);
  const textileCat = categories.find(c => c.name === 'Textile');
  const silverCat = categories.find(c => c.name === 'Silver');
  const woodCat = categories.find(c => c.name === 'Wood');
  const ceramicCat = categories.find(c => c.name === 'Ceramics');
  const jewelryCat = categories.find(c => c.name === 'Jewelry');

  if (!textile || !silver || !wood || !ceramic) {
    console.log('Missing verified artisans!');
    return;
  }

  // Using reliable Unsplash images
  const newProducts = [
    // Textile - Silk Weaver
    { artisanId: textile.id, categoryId: textileCat.id, name: 'Phamuong Silk Shawl', description: 'Traditional Phamuong silk shawl with gold thread accents. Handwoven in Siem Reap using techniques passed down through generations.', price: 85, stockQty: 8, image: 'https://images.unsplash.com/photo-1584036561566-baf8f5f1b144?w=600', isAvailable: true },
    { artisanId: textile.id, categoryId: textileCat.id, name: 'Hol Lboeuk Pattern Scarf', description: 'Intricate Hol Lboeuk (flowing pattern) silk scarf. Natural dyes from prohut bark and indigo create deep, lasting colors.', price: 55, stockQty: 12, image: 'https://images.unsplash.com/photo-1604335398980-c6e1c7b9a3e5?w=600', isAvailable: true },
    // Silver
    { artisanId: silver.id, categoryId: silverCat.id, name: 'Angkor Wat Silver Plate', description: 'Decorative silver plate with hand-etched Angkor Wat silhouette. 99.9% pure Cambodian silver. Display piece or ceremonial use.', price: 220, stockQty: 3, image: 'https://images.unsplash.com/photo-1611652022419-a9419f74343d?w=600', isAvailable: true },
    { artisanId: silver.id, categoryId: jewelryCat.id, name: 'Khmer Lotus Silver Ring', description: 'Delicate silver ring featuring an open lotus flower design. Adjustable band. Symbol of purity in Khmer culture.', price: 38, stockQty: 20, image: 'https://images.unsplash.com/photo-1605100804763-247f67b3557e?w=600', isAvailable: true },
    // Wood
    { artisanId: wood.id, categoryId: woodCat.id, name: 'Apsara Dancer Statuette', description: 'Hand-carved wooden statuette of a celestial Apsara dancer. Intricate details capture the grace of Khmer classical dance.', price: 130, stockQty: 4, image: 'https://images.unsplash.com/photo-1508697014387-36a4c50f4b87?w=600', isAvailable: true },
    { artisanId: wood.id, categoryId: woodCat.id, name: 'Khmer Elephant Bookends', description: 'Pair of hand-carved rosewood elephant bookends. Each elephant is unique with individual trunk and tusk details.', price: 95, stockQty: 6, image: 'https://images.unsplash.com/photo-1566417713940-fe7c737a9ef2?w=600', isAvailable: true },
    // Ceramics
    { artisanId: ceramic.id, categoryId: ceramicCat.id, name: 'Celadon Ceramic Vase', description: 'Traditional celadon-glazed vase with crackle finish. Wood-fired for 3 days. Each piece has a unique glaze pattern.', price: 65, stockQty: 8, image: 'https://images.unsplash.com/photo-1578500494198-246f612d3b3d?w=600', isAvailable: true },
    { artisanId: ceramic.id, categoryId: ceramicCat.id, name: 'Rice Bowl Set (4 pcs)', description: 'Set of 4 hand-thrown rice bowls with bamboo ash glaze. Microwave and dishwasher safe. Perfect for everyday use.', price: 42, stockQty: 15, image: 'https://images.unsplash.com/photo-1514228742587-6b1558fcca3d?w=600', isAvailable: true },
  ];

  for (const p of newProducts) {
    const r = await post('/products', p);
    console.log(`  ${r.data?.name || 'FAIL'}: ${r.data?.id || ''}`);
  }

  console.log('\nDone! Added ' + newProducts.length + ' products.');
}

main().catch(e => console.error(e.message));
