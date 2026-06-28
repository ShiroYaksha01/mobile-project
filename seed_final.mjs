// Update product images + add quiz questions
import http from 'http';

const API = 'http://127.0.0.1:5248/api';
let TOKEN = '';

function r(method, path, body = null) {
  return new Promise((resolve, reject) => {
    const u = new URL(API + path);
    const opts = { method, hostname: u.hostname, port: u.port, path: u.pathname + u.search,
      headers: { 'X-API-KEY': 'mobile-key123', 'Content-Type': 'application/json', 'Authorization': 'Bearer ' + TOKEN } };
    const req = http.request(opts, (res) => { let d = ''; res.on('data', c => d += c); res.on('end', () => { try { resolve(JSON.parse(d)); } catch { resolve(d); } }); });
    req.on('error', reject);
    if (body) req.write(JSON.stringify(body));
    req.end();
  });
}

// Khmer-colored placeholder images for each product
const images = {
  'Handwoven Ikat Silk Scarf': 'https://placehold.co/400x360.png/8B3A2B/FFF5E6?text=Ikat+Silk+Scarf&font=playfair-display',
  'Cotton Krama Scarf': 'https://placehold.co/400x360.png/B75D4E/FFFFFF?text=Krama+Scarf&font=playfair-display',
  'Phamuong Silk Shawl': 'https://placehold.co/400x360.png/5A2117/FFF5E6?text=Silk+Shawl&font=playfair-display',
  'Hol Lboeuk Pattern Scarf': 'https://placehold.co/400x360.png/8B3A2B/FFE088?text=Hol+Lboeuk&font=playfair-display',
  'Silver Elephant Pendant': 'https://placehold.co/400x360.png/D4AF37/2C241E?text=Elephant+Pendant&font=playfair-display',
  'Apsara Silver Bracelet': 'https://placehold.co/400x360.png/D4AF37/2C241E?text=Apsara+Bracelet&font=playfair-display',
  'Angkor Wat Silver Plate': 'https://placehold.co/400x360.png/D4AF37/2C241E?text=Silver+Plate&font=playfair-display',
  'Khmer Lotus Silver Ring': 'https://placehold.co/400x360.png/D4AF37/2C241E?text=Lotus+Ring&font=playfair-display',
  'Angkor Wat Wood Panel': 'https://placehold.co/400x360.png/5A2117/FFF5E6?text=Angkor+Panel&font=playfair-display',
  'Buddha Face Wall Hanging': 'https://placehold.co/400x360.png/5A2117/FFF5E6?text=Buddha+Face&font=playfair-display',
  'Apsara Dancer Statuette': 'https://placehold.co/400x360.png/5A2117/FFF5E6?text=Apsara+Dancer&font=playfair-display',
  'Khmer Elephant Bookends': 'https://placehold.co/400x360.png/5A2117/FFF5E6?text=Elephant+Bookends&font=playfair-display',
  'Khmer Lotus Tea Set': 'https://placehold.co/400x360.png/997A00/FFFFFF?text=Lotus+Tea+Set&font=playfair-display',
  'Celadon Ceramic Vase': 'https://placehold.co/400x360.png/997A00/FFFFFF?text=Celadon+Vase&font=playfair-display',
  'Rice Bowl Set (4 pcs)': 'https://placehold.co/400x360.png/997A00/FFFFFF?text=Rice+Bowl+Set&font=playfair-display',
};

async function main() {
  const login = await r('POST', '/auth/login', { email: 'sokha@example.com', password: 'password123' });
  TOKEN = login.data?.accessToken || '';
  console.log('Logged in');

  // Update product images
  const prods = await r('GET', '/products');
  for (const p of (prods.data || [])) {
    const img = images[p.name] || '';
    if (img) {
      await r('PUT', `/products/${p.id}`, {
        artisanId: p.artisanId, categoryId: p.categoryId,
        name: p.name, description: p.description || '',
        price: p.price, stockQty: p.stockQty || 10,
        image: img, isAvailable: true,
      });
      console.log('  Image: ' + p.name);
    }
  }

  // Add quiz questions 5 & 6
  console.log('\nAdding quiz questions 5 & 6...');
  const q5 = await r('POST', '/quiz', { questionText: 'What occasion is the gift for?', displayOrder: 5 });
  const q5id = q5.data?.id || '';
  console.log('  Q5: ' + q5id);
  await r('POST', '/quiz/answer', { questionId: q5id, answerText: 'Wedding / ceremony', tags: 'silver,bracelet,pendant,premium' });
  await r('POST', '/quiz/answer', { questionId: q5id, answerText: 'Housewarming', tags: 'wood,panel,decor,ceramic,vase' });
  await r('POST', '/quiz/answer', { questionId: q5id, answerText: 'Everyday wear / casual', tags: 'scarf,krama,ring,textile' });

  const q6 = await r('POST', '/quiz', { questionText: 'Any special material preference?', displayOrder: 6 });
  const q6id = q6.data?.id || '';
  console.log('  Q6: ' + q6id);
  await r('POST', '/quiz/answer', { questionId: q6id, answerText: 'Natural fibers & silk', tags: 'silk,textile,scarf,ikat' });
  await r('POST', '/quiz/answer', { questionId: q6id, answerText: 'Precious metals', tags: 'silver,pendant,bracelet,ring' });
  await r('POST', '/quiz/answer', { questionId: q6id, answerText: 'Hand-carved wood', tags: 'wood,panel,statuette,bookends' });
  await r('POST', '/quiz/answer', { questionId: q6id, answerText: 'Handmade ceramics', tags: 'ceramic,tea,vase,bowl' });

  console.log('\nDone!');
}

main().catch(e => console.error(e.message));
