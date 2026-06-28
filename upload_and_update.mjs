// Script: download images → upload to backend → update product records
import { writeFileSync } from 'fs';
import { execSync } from 'child_process';

const PRODUCTS = [
  // Ceramics
  { id: '8582ffe2-15de-432e-94f2-da39016a0662', name: 'Rice Bowl Set (4 pcs)', category: 'Ceramics', unsplash: 'pottery-bowls-workshop' },
  { id: '1eca292d-a2be-4902-8cdb-e5bcb647e4f8', name: 'Celadon Ceramic Vase', category: 'Ceramics', unsplash: 'celadon-glaze-vase' },
  { id: 'fa8be795-9472-4c98-a5e6-e4462269a80d', name: 'Khmer Lotus Tea Set', category: 'Ceramics', unsplash: 'tea-set-lotus' },
  // Wood
  { id: '5fc9d25d-3514-430b-a7c4-f328c728f62e', name: 'Khmer Elephant Bookends', category: 'Wood', unsplash: 'elephant-wood-bookends' },
  { id: 'cec5bf54-013c-411f-a406-13c0c1edb3f6', name: 'Apsara Dancer Statuette', category: 'Wood', unsplash: 'apsara-dance-statuette' },
  { id: '490d1139-0ce3-4633-9a1e-acd6711df29a', name: 'Buddha Face Wall Hanging', category: 'Wood', unsplash: 'buddha-face-wall-hanging' },
  { id: '60d5cf49-fb14-4c61-bf0f-bf7e47ad0394', name: 'Angkor Wat Wood Panel', category: 'Wood', unsplash: 'angkor-wat-wood-panel' },
  // Jewelry
  { id: 'f16cec83-2f2c-4304-89d7-a0c0ffbe84b3', name: 'Khmer Lotus Silver Ring', category: 'Jewelry', unsplash: 'lotus-silver-ring' },
  { id: '9578788b-a7f6-4beb-8bda-a21f5a1c8bea', name: 'Apsara Silver Bracelet', category: 'Jewelry', unsplash: 'apsara-silver-bracelet' },
  // Silver
  { id: '8174ad9a-ab37-40e6-83b8-ddf9dd6ff0b9', name: 'Angkor Wat Silver Plate', category: 'Silver', unsplash: 'angkor-silver-plate' },
  { id: 'c1df4ca9-2115-4109-872c-41f051edb106', name: 'Silver Elephant Pendant', category: 'Silver', unsplash: 'elephant-silver-pendant' },
  // Textile
  { id: '1c097e67-2ac0-414a-9307-d2d23506d67a', name: 'Hol Lboeuk Pattern Scarf', category: 'Textile', unsplash: 'hol-pattern-scarf' },
  { id: 'e3151b0a-26d3-49eb-8687-c8113243bc7d', name: 'Phamuong Silk Shawl', category: 'Textile', unsplash: 'silk-shawl-phamuong' },
  { id: 'd8119919-971a-425d-b7e7-f290a9c8375a', name: 'Cotton Krama Scarf', category: 'Textile', unsplash: 'cotton-krama-scarf' },
  { id: 'fc2416d8-4cbf-4d1e-ad89-40927eba59f1', name: 'Handwoven Ikat Silk Scarf', category: 'Textile', unsplash: 'ikat-silk-handwoven' },
  // Duplicates (wrong category)
  { id: '1de3603f-51b4-48a2-8b4e-ce453da0f60e', name: 'Cotton Krama Scarf', category: 'Textile', unsplash: 'cotton-krama-scarf-dup' },
  { id: '58913c1a-d0c0-4663-8c50-bb4778fbbe6b', name: 'Handwoven Ikat Silk Scarf', category: 'Ceramics', unsplash: 'ikat-silk-handwoven-dup' },
];

// Upload each image
for (const product of PRODUCTS) {
  const imageUrl = product.unsplash || `https://images.unsplash.com/photo-${product.id}?w=800`;
  console.log(`Downloading: ${imageUrl}`);

  // Download image → save to temp file
  const tempFile = `/tmp/${product.name.replace(/\s+/g, '-')}.jpg`;
  execSync(`curl -s -o "${tempFile}" "${imageUrl}"`);

  // Upload to backend media endpoint
  const uploadResult = execSync(
    `curl -s -X POST http://127.0.0.1:5248/api/media/upload -H "X-API-KEY: mobile-key123" -F "file=@${tempFile}"`,
    { encoding: 'utf-8' }
  );
  const { url } = JSON.parse(uploadResult);
  console.log(`Uploaded: ${url}`);

  // Update product record with new image URL
  execSync(
    `curl -s -X PUT http://127.0.0.1:5248/api/products/${product.id} -H "X-API-KEY: mobile-key123" -H "Content-Type: application/json" -d '{"image":"${url}"}'`
  );
  console.log(`Updated product ${product.name}`);
}

console.log('Done! All 17 products updated.');
