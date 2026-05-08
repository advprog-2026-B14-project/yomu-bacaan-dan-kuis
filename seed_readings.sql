-- Production-like seed data for Yomu readings.
-- Idempotent and safe to rerun on PostgreSQL/Supabase.

begin;

create schema if not exists learning_mod;

alter table learning_mod.readings
    add column if not exists summary text,
    add column if not exists difficulty varchar(20) not null default 'beginner',
    add column if not exists estimated_reading_time integer not null default 5,
    add column if not exists xp_reward integer not null default 10;

insert into learning_mod.categories (name, created_at)
select 'Computer Science', now()
where not exists (
    select 1 from learning_mod.categories where lower(name) = lower('Computer Science')
);

with cs_category as (
    select id
    from learning_mod.categories
    where lower(name) = lower('Computer Science')
    order by id
    limit 1
),
reading_seed(title, summary, content, difficulty, estimated_reading_time, xp_reward) as (
    values
        ('Computational Thinking untuk Problem Solving Modern', 'Materi ini membahas decomposition, pattern recognition, abstraction, dan algorithm design sebagai fondasi berpikir seperti software engineer.', '# Computational Thinking untuk Problem Solving Modern

## Ringkasan

Materi ini membahas decomposition, pattern recognition, abstraction, dan algorithm design sebagai fondasi berpikir seperti software engineer. Materi ini dirancang seperti modul bootcamp: dimulai dari intuisi, dilanjutkan dengan model mental, lalu ditutup dengan praktik industri dan tips interview. Fokus utamanya bukan menghafal istilah, melainkan memahami cara berpikir yang bisa dipakai saat membangun aplikasi nyata, membaca kode orang lain, melakukan debugging, dan menjelaskan keputusan teknis secara profesional.

## Kenapa Topik Ini Penting

Dalam software engineering, keputusan kecil sering punya dampak besar. Memilih struktur data, menentukan status code, menaruh validasi di layer yang tepat, atau memutuskan kapan memakai cache dapat memengaruhi performa, keamanan, dan pengalaman pengguna. Topik ini penting karena muncul berulang kali di proyek kampus, magang, pekerjaan full-time, dan interview software engineer.

Analogi sederhananya: membangun software mirip mengelola dapur restoran. Menu adalah fitur, pelanggan adalah user, database adalah gudang bahan, dan pipeline deployment adalah jalur penyajian. Restoran kecil bisa berjalan dengan satu koki dan satu catatan pesanan, tetapi restoran besar butuh alur kerja, pembagian peran, quality control, dan monitoring. Software juga begitu: semakin banyak user, semakin penting desain yang rapi.

## Konsep Utama

Kata kunci yang perlu kamu kuasai: **decomposition, pattern recognition, abstraction, algorithm design**.

Beberapa prinsip yang selalu berguna:

- Pahami masalah sebelum memilih teknologi.
- Ukur bottleneck dengan data, bukan perasaan.
- Buat solusi paling sederhana yang masih memenuhi kebutuhan.
- Dokumentasikan asumsi penting agar tim lain tidak menebak-nebak.
- Pisahkan konsep inti dari detail implementasi.

| Area | Pertanyaan Penting | Dampak |
|---|---|---|
| Correctness | Apakah hasilnya benar untuk edge case? | Mengurangi bug logic |
| Performance | Bagaimana perilaku saat data membesar? | Menjaga latency |
| Maintainability | Apakah engineer lain mudah memahami kode? | Mempercepat perubahan |
| Security | Apakah data dan akses terlindungi? | Mengurangi risiko production |

## Penjelasan Detail

Bayangkan kamu menerima requirement baru dari product manager. Requirement itu biasanya terdengar sederhana, misalnya "tampilkan daftar materi yang relevan untuk user". Namun di balik kalimat singkat itu ada banyak keputusan: data apa yang dibaca, bagaimana urutannya, bagaimana jika database lambat, bagaimana jika user belum login, dan bagaimana hasilnya diuji. Engineer yang matang akan memecah requirement menjadi beberapa bagian kecil, mengidentifikasi risiko, lalu memilih pendekatan yang bisa diverifikasi.

Pada topik ini, pola berpikir yang paling penting adalah melihat hubungan antara input, proses, dan output. Input bisa berupa request HTTP, data dari database, event dari message broker, atau konfigurasi environment. Proses bisa berupa validasi, transformasi, query, perhitungan, atau komunikasi ke service lain. Output bisa berupa response JSON, record baru, log audit, atau event lanjutan. Jika salah satu bagian tidak jelas, debugging akan menjadi lebih sulit.

Dalam praktik sehari-hari, jangan hanya bertanya "apakah kode ini jalan?". Tanyakan juga:

1. Apa yang terjadi jika input kosong, duplikat, terlalu besar, atau tidak valid?
2. Apakah solusi ini masih masuk akal ketika jumlah data naik 100 kali lipat?
3. Apakah error message cukup membantu tanpa membocorkan informasi sensitif?
4. Apakah perubahan ini mudah dites secara otomatis?
5. Apakah ada asumsi yang perlu ditulis di dokumentasi?

## Contoh Implementasi

Contoh berikut bukan template final, tetapi gambaran cara menyusun ide secara eksplisit:

```text
function solve(problem) {
  const parts = decompose(problem);
  const patterns = findPatterns(parts);
  return designAlgorithm(patterns);
}
```

Perhatikan bahwa contoh tersebut menonjolkan struktur berpikir, bukan sekadar sintaks. Sintaks bisa berbeda antara Java, TypeScript, Python, atau SQL, tetapi prinsipnya tetap sama: buat data mengalir lewat tahap yang jelas, kurangi coupling, dan pastikan kegagalan dapat diamati.

## Use Case Industri

Contoh industri: tim product analytics memecah masalah churn pengguna menjadi sinyal login, aktivitas fitur, riwayat pembayaran, dan kualitas onboarding. Kasus seperti ini umum terjadi karena sistem production memiliki batasan nyata: latency, biaya cloud, reliabilitas, keamanan, dan koordinasi antar tim. Solusi yang terlihat bagus di demo lokal belum tentu cukup untuk production jika tidak mempertimbangkan volume data, konkurensi, dan failure mode.

Dalam tim profesional, keputusan teknis biasanya perlu dijelaskan dalam bentuk trade-off. Misalnya, memakai cache membuat response lebih cepat, tetapi menambah risiko stale data. Memecah service membuat deployment lebih independen, tetapi menambah kebutuhan observability dan network reliability. Menggunakan JWT membuat service stateless, tetapi perlu validasi signature dan expiry yang benar.

## Studi Kasus Terarah

Misalkan Yomu ingin menampilkan materi belajar yang relevan untuk mahasiswa yang sedang mempersiapkan interview. Requirement awalnya terdengar sederhana: user membuka halaman, melihat daftar bacaan, memilih materi, lalu mengerjakan quiz. Namun kalau fitur ini dipakai ribuan mahasiswa, ada beberapa pertanyaan desain yang harus dijawab. Apakah daftar bacaan selalu diambil dari database? Apakah setiap request perlu menghitung progress quiz dari awal? Apakah response untuk learner boleh mengandung jawaban benar? Apakah admin boleh mengubah quiz yang sudah pernah dikerjakan banyak user?

Dengan sudut pandang Computational Thinking untuk Problem Solving Modern, kamu bisa membuat keputusan yang lebih tajam. Pertama, pisahkan data yang bersifat publik, data yang personal untuk user, dan data yang hanya boleh dilihat admin. Kedua, tentukan operasi mana yang harus konsisten kuat dan mana yang boleh eventually consistent. Ketiga, siapkan test untuk memastikan perubahan schema, perubahan kontrak API, dan perubahan business rule tidak merusak pengalaman belajar.

Pendekatan yang matang biasanya menghasilkan desain seperti ini:

- Endpoint learner hanya mengembalikan informasi yang aman untuk learner.
- Endpoint admin memiliki authorization dan audit log.
- Query yang sering dipakai diberi index atau cache jika benar-benar terbukti bottleneck.
- Seed data dibuat idempotent agar environment lokal, staging, dan demo bisa diisi ulang tanpa duplikasi.
- Error response dibuat konsisten supaya frontend bisa menampilkan pesan yang jelas.

## Production Readiness Checklist

Sebelum sebuah fitur dianggap siap production, engineer perlu mengecek lebih dari sekadar "berhasil dijalankan". Gunakan checklist berikut sebagai kebiasaan:

1. **Correctness:** semua aturan bisnis utama punya test otomatis.
2. **Observability:** log cukup untuk menelusuri request bermasalah.
3. **Security:** endpoint sensitif terlindungi role, token, atau gateway policy.
4. **Performance:** query utama dan struktur data sudah dipikirkan untuk pertumbuhan data.
5. **Resilience:** error dari dependency eksternal tidak membuat seluruh aplikasi gagal tanpa pesan.
6. **Maintainability:** kode mengikuti batas layer yang jelas dan tidak mencampur terlalu banyak tanggung jawab.

Checklist ini bukan birokrasi. Ia membantu tim menghindari bug yang biasanya baru terlihat saat demo besar, traffic naik, atau ada perubahan requirement mendadak.

## Best Practices

- Mulai dari requirement dan constraint, bukan dari library favorit.
- Gunakan nama variabel, endpoint, dan tabel yang konsisten.
- Tambahkan test untuk happy path, edge case, dan failure case.
- Jangan menyimpan secret di source code.
- Catat keputusan penting di README atau ADR sederhana.
- Gunakan logging yang membantu debugging tanpa membocorkan data sensitif.
- Review performa query dan struktur data sebelum traffic membesar.

## Common Mistakes

Kesalahan yang sering dilakukan beginner adalah membuat solusi yang hanya bekerja untuk contoh kecil. Misalnya, nested loop tidak terasa lambat saat data hanya 10 baris, tetapi bisa menghancurkan latency saat data menjadi 100.000 baris. Kesalahan lain adalah mencampur validasi, business logic, dan akses database dalam satu fungsi besar sehingga sulit dites dan sulit diubah.

Kesalahan lain yang sering muncul:

- Mengabaikan edge case karena demo terlihat berhasil.
- Menggunakan status code HTTP yang tidak sesuai.
- Membiarkan endpoint admin tanpa authorization.
- Membuat query berulang dalam loop tanpa sadar.
- Menganggap semua error berasal dari frontend.
- Tidak menulis migration atau seed data yang idempotent.

## Fun Fact

Banyak konsep modern software engineering sebenarnya lahir dari masalah sederhana yang tumbuh besar. Queue muncul karena tidak semua pekerjaan harus selesai saat itu juga. Cache muncul karena membaca sumber data utama terus-menerus terlalu mahal. Load balancer muncul karena satu server tidak selamanya cukup. Dengan memahami asal masalahnya, kamu akan lebih mudah memilih teknologi yang tepat.

## Interview Tips

Saat interview, jangan langsung melompat ke jawaban final. Jelaskan asumsi, pilihan, dan trade-off. Interviewer biasanya ingin melihat cara berpikir. Untuk topik ini, jawaban yang kuat biasanya memuat:

1. Definisi singkat yang tepat.
2. Contoh real-world.
3. Edge case atau failure mode.
4. Trade-off solusi.
5. Cara menguji atau mengukur keberhasilan.

## Latihan Mandiri

Coba ambil fitur sederhana dari aplikasi Yomu, misalnya membaca materi dan mengerjakan quiz. Petakan input, proses, output, data yang disimpan, kemungkinan error, dan risiko keamanan. Setelah itu, tulis satu perbaikan kecil yang membuat fitur tersebut lebih production-ready. Latihan seperti ini akan membangun intuisi engineering yang jauh lebih kuat daripada sekadar membaca definisi.
', 'beginner', 12, 10),
        ('Algorithms and Data Structures dalam Praktik Backend', 'Pelajari hubungan algoritma, struktur data, dan dampaknya terhadap performa aplikasi backend yang melayani banyak pengguna.', '# Algorithms and Data Structures dalam Praktik Backend

## Ringkasan

Pelajari hubungan algoritma, struktur data, dan dampaknya terhadap performa aplikasi backend yang melayani banyak pengguna. Materi ini dirancang seperti modul bootcamp: dimulai dari intuisi, dilanjutkan dengan model mental, lalu ditutup dengan praktik industri dan tips interview. Fokus utamanya bukan menghafal istilah, melainkan memahami cara berpikir yang bisa dipakai saat membangun aplikasi nyata, membaca kode orang lain, melakukan debugging, dan menjelaskan keputusan teknis secara profesional.

## Kenapa Topik Ini Penting

Dalam software engineering, keputusan kecil sering punya dampak besar. Memilih struktur data, menentukan status code, menaruh validasi di layer yang tepat, atau memutuskan kapan memakai cache dapat memengaruhi performa, keamanan, dan pengalaman pengguna. Topik ini penting karena muncul berulang kali di proyek kampus, magang, pekerjaan full-time, dan interview software engineer.

Analogi sederhananya: membangun software mirip mengelola dapur restoran. Menu adalah fitur, pelanggan adalah user, database adalah gudang bahan, dan pipeline deployment adalah jalur penyajian. Restoran kecil bisa berjalan dengan satu koki dan satu catatan pesanan, tetapi restoran besar butuh alur kerja, pembagian peran, quality control, dan monitoring. Software juga begitu: semakin banyak user, semakin penting desain yang rapi.

## Konsep Utama

Kata kunci yang perlu kamu kuasai: **array, linked list, tree, hash map, graph**.

Beberapa prinsip yang selalu berguna:

- Pahami masalah sebelum memilih teknologi.
- Ukur bottleneck dengan data, bukan perasaan.
- Buat solusi paling sederhana yang masih memenuhi kebutuhan.
- Dokumentasikan asumsi penting agar tim lain tidak menebak-nebak.
- Pisahkan konsep inti dari detail implementasi.

| Area | Pertanyaan Penting | Dampak |
|---|---|---|
| Correctness | Apakah hasilnya benar untuk edge case? | Mengurangi bug logic |
| Performance | Bagaimana perilaku saat data membesar? | Menjaga latency |
| Maintainability | Apakah engineer lain mudah memahami kode? | Mempercepat perubahan |
| Security | Apakah data dan akses terlindungi? | Mengurangi risiko production |

## Penjelasan Detail

Bayangkan kamu menerima requirement baru dari product manager. Requirement itu biasanya terdengar sederhana, misalnya "tampilkan daftar materi yang relevan untuk user". Namun di balik kalimat singkat itu ada banyak keputusan: data apa yang dibaca, bagaimana urutannya, bagaimana jika database lambat, bagaimana jika user belum login, dan bagaimana hasilnya diuji. Engineer yang matang akan memecah requirement menjadi beberapa bagian kecil, mengidentifikasi risiko, lalu memilih pendekatan yang bisa diverifikasi.

Pada topik ini, pola berpikir yang paling penting adalah melihat hubungan antara input, proses, dan output. Input bisa berupa request HTTP, data dari database, event dari message broker, atau konfigurasi environment. Proses bisa berupa validasi, transformasi, query, perhitungan, atau komunikasi ke service lain. Output bisa berupa response JSON, record baru, log audit, atau event lanjutan. Jika salah satu bagian tidak jelas, debugging akan menjadi lebih sulit.

Dalam praktik sehari-hari, jangan hanya bertanya "apakah kode ini jalan?". Tanyakan juga:

1. Apa yang terjadi jika input kosong, duplikat, terlalu besar, atau tidak valid?
2. Apakah solusi ini masih masuk akal ketika jumlah data naik 100 kali lipat?
3. Apakah error message cukup membantu tanpa membocorkan informasi sensitif?
4. Apakah perubahan ini mudah dites secara otomatis?
5. Apakah ada asumsi yang perlu ditulis di dokumentasi?

## Contoh Implementasi

Contoh berikut bukan template final, tetapi gambaran cara menyusun ide secara eksplisit:

```text
Map<String, Product> cache = new HashMap<>();
Product product = cache.get(productId);
```

Perhatikan bahwa contoh tersebut menonjolkan struktur berpikir, bukan sekadar sintaks. Sintaks bisa berbeda antara Java, TypeScript, Python, atau SQL, tetapi prinsipnya tetap sama: buat data mengalir lewat tahap yang jelas, kurangi coupling, dan pastikan kegagalan dapat diamati.

## Use Case Industri

Contoh industri: platform e-commerce memilih index dan hash map cache agar pencarian produk populer tidak selalu membaca database. Kasus seperti ini umum terjadi karena sistem production memiliki batasan nyata: latency, biaya cloud, reliabilitas, keamanan, dan koordinasi antar tim. Solusi yang terlihat bagus di demo lokal belum tentu cukup untuk production jika tidak mempertimbangkan volume data, konkurensi, dan failure mode.

Dalam tim profesional, keputusan teknis biasanya perlu dijelaskan dalam bentuk trade-off. Misalnya, memakai cache membuat response lebih cepat, tetapi menambah risiko stale data. Memecah service membuat deployment lebih independen, tetapi menambah kebutuhan observability dan network reliability. Menggunakan JWT membuat service stateless, tetapi perlu validasi signature dan expiry yang benar.

## Studi Kasus Terarah

Misalkan Yomu ingin menampilkan materi belajar yang relevan untuk mahasiswa yang sedang mempersiapkan interview. Requirement awalnya terdengar sederhana: user membuka halaman, melihat daftar bacaan, memilih materi, lalu mengerjakan quiz. Namun kalau fitur ini dipakai ribuan mahasiswa, ada beberapa pertanyaan desain yang harus dijawab. Apakah daftar bacaan selalu diambil dari database? Apakah setiap request perlu menghitung progress quiz dari awal? Apakah response untuk learner boleh mengandung jawaban benar? Apakah admin boleh mengubah quiz yang sudah pernah dikerjakan banyak user?

Dengan sudut pandang Algorithms and Data Structures dalam Praktik Backend, kamu bisa membuat keputusan yang lebih tajam. Pertama, pisahkan data yang bersifat publik, data yang personal untuk user, dan data yang hanya boleh dilihat admin. Kedua, tentukan operasi mana yang harus konsisten kuat dan mana yang boleh eventually consistent. Ketiga, siapkan test untuk memastikan perubahan schema, perubahan kontrak API, dan perubahan business rule tidak merusak pengalaman belajar.

Pendekatan yang matang biasanya menghasilkan desain seperti ini:

- Endpoint learner hanya mengembalikan informasi yang aman untuk learner.
- Endpoint admin memiliki authorization dan audit log.
- Query yang sering dipakai diberi index atau cache jika benar-benar terbukti bottleneck.
- Seed data dibuat idempotent agar environment lokal, staging, dan demo bisa diisi ulang tanpa duplikasi.
- Error response dibuat konsisten supaya frontend bisa menampilkan pesan yang jelas.

## Production Readiness Checklist

Sebelum sebuah fitur dianggap siap production, engineer perlu mengecek lebih dari sekadar "berhasil dijalankan". Gunakan checklist berikut sebagai kebiasaan:

1. **Correctness:** semua aturan bisnis utama punya test otomatis.
2. **Observability:** log cukup untuk menelusuri request bermasalah.
3. **Security:** endpoint sensitif terlindungi role, token, atau gateway policy.
4. **Performance:** query utama dan struktur data sudah dipikirkan untuk pertumbuhan data.
5. **Resilience:** error dari dependency eksternal tidak membuat seluruh aplikasi gagal tanpa pesan.
6. **Maintainability:** kode mengikuti batas layer yang jelas dan tidak mencampur terlalu banyak tanggung jawab.

Checklist ini bukan birokrasi. Ia membantu tim menghindari bug yang biasanya baru terlihat saat demo besar, traffic naik, atau ada perubahan requirement mendadak.

## Best Practices

- Mulai dari requirement dan constraint, bukan dari library favorit.
- Gunakan nama variabel, endpoint, dan tabel yang konsisten.
- Tambahkan test untuk happy path, edge case, dan failure case.
- Jangan menyimpan secret di source code.
- Catat keputusan penting di README atau ADR sederhana.
- Gunakan logging yang membantu debugging tanpa membocorkan data sensitif.
- Review performa query dan struktur data sebelum traffic membesar.

## Common Mistakes

Kesalahan yang sering dilakukan beginner adalah membuat solusi yang hanya bekerja untuk contoh kecil. Misalnya, nested loop tidak terasa lambat saat data hanya 10 baris, tetapi bisa menghancurkan latency saat data menjadi 100.000 baris. Kesalahan lain adalah mencampur validasi, business logic, dan akses database dalam satu fungsi besar sehingga sulit dites dan sulit diubah.

Kesalahan lain yang sering muncul:

- Mengabaikan edge case karena demo terlihat berhasil.
- Menggunakan status code HTTP yang tidak sesuai.
- Membiarkan endpoint admin tanpa authorization.
- Membuat query berulang dalam loop tanpa sadar.
- Menganggap semua error berasal dari frontend.
- Tidak menulis migration atau seed data yang idempotent.

## Fun Fact

Banyak konsep modern software engineering sebenarnya lahir dari masalah sederhana yang tumbuh besar. Queue muncul karena tidak semua pekerjaan harus selesai saat itu juga. Cache muncul karena membaca sumber data utama terus-menerus terlalu mahal. Load balancer muncul karena satu server tidak selamanya cukup. Dengan memahami asal masalahnya, kamu akan lebih mudah memilih teknologi yang tepat.

## Interview Tips

Saat interview, jangan langsung melompat ke jawaban final. Jelaskan asumsi, pilihan, dan trade-off. Interviewer biasanya ingin melihat cara berpikir. Untuk topik ini, jawaban yang kuat biasanya memuat:

1. Definisi singkat yang tepat.
2. Contoh real-world.
3. Edge case atau failure mode.
4. Trade-off solusi.
5. Cara menguji atau mengukur keberhasilan.

## Latihan Mandiri

Coba ambil fitur sederhana dari aplikasi Yomu, misalnya membaca materi dan mengerjakan quiz. Petakan input, proses, output, data yang disimpan, kemungkinan error, dan risiko keamanan. Setelah itu, tulis satu perbaikan kecil yang membuat fitur tersebut lebih production-ready. Latihan seperti ini akan membangun intuisi engineering yang jauh lebih kuat daripada sekadar membaca definisi.
', 'beginner', 15, 10),
        ('Big O Notation dan Cara Membaca Pertumbuhan Biaya', 'Big O membantu engineer memperkirakan bagaimana waktu eksekusi berubah ketika ukuran input meningkat drastis.', '# Big O Notation dan Cara Membaca Pertumbuhan Biaya

## Ringkasan

Big O membantu engineer memperkirakan bagaimana waktu eksekusi berubah ketika ukuran input meningkat drastis. Materi ini dirancang seperti modul bootcamp: dimulai dari intuisi, dilanjutkan dengan model mental, lalu ditutup dengan praktik industri dan tips interview. Fokus utamanya bukan menghafal istilah, melainkan memahami cara berpikir yang bisa dipakai saat membangun aplikasi nyata, membaca kode orang lain, melakukan debugging, dan menjelaskan keputusan teknis secara profesional.

## Kenapa Topik Ini Penting

Dalam software engineering, keputusan kecil sering punya dampak besar. Memilih struktur data, menentukan status code, menaruh validasi di layer yang tepat, atau memutuskan kapan memakai cache dapat memengaruhi performa, keamanan, dan pengalaman pengguna. Topik ini penting karena muncul berulang kali di proyek kampus, magang, pekerjaan full-time, dan interview software engineer.

Analogi sederhananya: membangun software mirip mengelola dapur restoran. Menu adalah fitur, pelanggan adalah user, database adalah gudang bahan, dan pipeline deployment adalah jalur penyajian. Restoran kecil bisa berjalan dengan satu koki dan satu catatan pesanan, tetapi restoran besar butuh alur kerja, pembagian peran, quality control, dan monitoring. Software juga begitu: semakin banyak user, semakin penting desain yang rapi.

## Konsep Utama

Kata kunci yang perlu kamu kuasai: **O(1), O(log n), O(n), O(n log n), O(n^2)**.

Beberapa prinsip yang selalu berguna:

- Pahami masalah sebelum memilih teknologi.
- Ukur bottleneck dengan data, bukan perasaan.
- Buat solusi paling sederhana yang masih memenuhi kebutuhan.
- Dokumentasikan asumsi penting agar tim lain tidak menebak-nebak.
- Pisahkan konsep inti dari detail implementasi.

| Area | Pertanyaan Penting | Dampak |
|---|---|---|
| Correctness | Apakah hasilnya benar untuk edge case? | Mengurangi bug logic |
| Performance | Bagaimana perilaku saat data membesar? | Menjaga latency |
| Maintainability | Apakah engineer lain mudah memahami kode? | Mempercepat perubahan |
| Security | Apakah data dan akses terlindungi? | Mengurangi risiko production |

## Penjelasan Detail

Bayangkan kamu menerima requirement baru dari product manager. Requirement itu biasanya terdengar sederhana, misalnya "tampilkan daftar materi yang relevan untuk user". Namun di balik kalimat singkat itu ada banyak keputusan: data apa yang dibaca, bagaimana urutannya, bagaimana jika database lambat, bagaimana jika user belum login, dan bagaimana hasilnya diuji. Engineer yang matang akan memecah requirement menjadi beberapa bagian kecil, mengidentifikasi risiko, lalu memilih pendekatan yang bisa diverifikasi.

Pada topik ini, pola berpikir yang paling penting adalah melihat hubungan antara input, proses, dan output. Input bisa berupa request HTTP, data dari database, event dari message broker, atau konfigurasi environment. Proses bisa berupa validasi, transformasi, query, perhitungan, atau komunikasi ke service lain. Output bisa berupa response JSON, record baru, log audit, atau event lanjutan. Jika salah satu bagian tidak jelas, debugging akan menjadi lebih sulit.

Dalam praktik sehari-hari, jangan hanya bertanya "apakah kode ini jalan?". Tanyakan juga:

1. Apa yang terjadi jika input kosong, duplikat, terlalu besar, atau tidak valid?
2. Apakah solusi ini masih masuk akal ketika jumlah data naik 100 kali lipat?
3. Apakah error message cukup membantu tanpa membocorkan informasi sensitif?
4. Apakah perubahan ini mudah dites secara otomatis?
5. Apakah ada asumsi yang perlu ditulis di dokumentasi?

## Contoh Implementasi

Contoh berikut bukan template final, tetapi gambaran cara menyusun ide secara eksplisit:

```text
for (const user of users) {
  for (const item of items) {
    compare(user, item);
  }
}
```

Perhatikan bahwa contoh tersebut menonjolkan struktur berpikir, bukan sekadar sintaks. Sintaks bisa berbeda antara Java, TypeScript, Python, atau SQL, tetapi prinsipnya tetap sama: buat data mengalir lewat tahap yang jelas, kurangi coupling, dan pastikan kegagalan dapat diamati.

## Use Case Industri

Contoh industri: fitur rekomendasi yang awalnya cepat pada 1.000 item menjadi lambat pada 1.000.000 item karena nested loop. Kasus seperti ini umum terjadi karena sistem production memiliki batasan nyata: latency, biaya cloud, reliabilitas, keamanan, dan koordinasi antar tim. Solusi yang terlihat bagus di demo lokal belum tentu cukup untuk production jika tidak mempertimbangkan volume data, konkurensi, dan failure mode.

Dalam tim profesional, keputusan teknis biasanya perlu dijelaskan dalam bentuk trade-off. Misalnya, memakai cache membuat response lebih cepat, tetapi menambah risiko stale data. Memecah service membuat deployment lebih independen, tetapi menambah kebutuhan observability dan network reliability. Menggunakan JWT membuat service stateless, tetapi perlu validasi signature dan expiry yang benar.

## Studi Kasus Terarah

Misalkan Yomu ingin menampilkan materi belajar yang relevan untuk mahasiswa yang sedang mempersiapkan interview. Requirement awalnya terdengar sederhana: user membuka halaman, melihat daftar bacaan, memilih materi, lalu mengerjakan quiz. Namun kalau fitur ini dipakai ribuan mahasiswa, ada beberapa pertanyaan desain yang harus dijawab. Apakah daftar bacaan selalu diambil dari database? Apakah setiap request perlu menghitung progress quiz dari awal? Apakah response untuk learner boleh mengandung jawaban benar? Apakah admin boleh mengubah quiz yang sudah pernah dikerjakan banyak user?

Dengan sudut pandang Big O Notation dan Cara Membaca Pertumbuhan Biaya, kamu bisa membuat keputusan yang lebih tajam. Pertama, pisahkan data yang bersifat publik, data yang personal untuk user, dan data yang hanya boleh dilihat admin. Kedua, tentukan operasi mana yang harus konsisten kuat dan mana yang boleh eventually consistent. Ketiga, siapkan test untuk memastikan perubahan schema, perubahan kontrak API, dan perubahan business rule tidak merusak pengalaman belajar.

Pendekatan yang matang biasanya menghasilkan desain seperti ini:

- Endpoint learner hanya mengembalikan informasi yang aman untuk learner.
- Endpoint admin memiliki authorization dan audit log.
- Query yang sering dipakai diberi index atau cache jika benar-benar terbukti bottleneck.
- Seed data dibuat idempotent agar environment lokal, staging, dan demo bisa diisi ulang tanpa duplikasi.
- Error response dibuat konsisten supaya frontend bisa menampilkan pesan yang jelas.

## Production Readiness Checklist

Sebelum sebuah fitur dianggap siap production, engineer perlu mengecek lebih dari sekadar "berhasil dijalankan". Gunakan checklist berikut sebagai kebiasaan:

1. **Correctness:** semua aturan bisnis utama punya test otomatis.
2. **Observability:** log cukup untuk menelusuri request bermasalah.
3. **Security:** endpoint sensitif terlindungi role, token, atau gateway policy.
4. **Performance:** query utama dan struktur data sudah dipikirkan untuk pertumbuhan data.
5. **Resilience:** error dari dependency eksternal tidak membuat seluruh aplikasi gagal tanpa pesan.
6. **Maintainability:** kode mengikuti batas layer yang jelas dan tidak mencampur terlalu banyak tanggung jawab.

Checklist ini bukan birokrasi. Ia membantu tim menghindari bug yang biasanya baru terlihat saat demo besar, traffic naik, atau ada perubahan requirement mendadak.

## Best Practices

- Mulai dari requirement dan constraint, bukan dari library favorit.
- Gunakan nama variabel, endpoint, dan tabel yang konsisten.
- Tambahkan test untuk happy path, edge case, dan failure case.
- Jangan menyimpan secret di source code.
- Catat keputusan penting di README atau ADR sederhana.
- Gunakan logging yang membantu debugging tanpa membocorkan data sensitif.
- Review performa query dan struktur data sebelum traffic membesar.

## Common Mistakes

Kesalahan yang sering dilakukan beginner adalah membuat solusi yang hanya bekerja untuk contoh kecil. Misalnya, nested loop tidak terasa lambat saat data hanya 10 baris, tetapi bisa menghancurkan latency saat data menjadi 100.000 baris. Kesalahan lain adalah mencampur validasi, business logic, dan akses database dalam satu fungsi besar sehingga sulit dites dan sulit diubah.

Kesalahan lain yang sering muncul:

- Mengabaikan edge case karena demo terlihat berhasil.
- Menggunakan status code HTTP yang tidak sesuai.
- Membiarkan endpoint admin tanpa authorization.
- Membuat query berulang dalam loop tanpa sadar.
- Menganggap semua error berasal dari frontend.
- Tidak menulis migration atau seed data yang idempotent.

## Fun Fact

Banyak konsep modern software engineering sebenarnya lahir dari masalah sederhana yang tumbuh besar. Queue muncul karena tidak semua pekerjaan harus selesai saat itu juga. Cache muncul karena membaca sumber data utama terus-menerus terlalu mahal. Load balancer muncul karena satu server tidak selamanya cukup. Dengan memahami asal masalahnya, kamu akan lebih mudah memilih teknologi yang tepat.

## Interview Tips

Saat interview, jangan langsung melompat ke jawaban final. Jelaskan asumsi, pilihan, dan trade-off. Interviewer biasanya ingin melihat cara berpikir. Untuk topik ini, jawaban yang kuat biasanya memuat:

1. Definisi singkat yang tepat.
2. Contoh real-world.
3. Edge case atau failure mode.
4. Trade-off solusi.
5. Cara menguji atau mengukur keberhasilan.

## Latihan Mandiri

Coba ambil fitur sederhana dari aplikasi Yomu, misalnya membaca materi dan mengerjakan quiz. Petakan input, proses, output, data yang disimpan, kemungkinan error, dan risiko keamanan. Setelah itu, tulis satu perbaikan kecil yang membuat fitur tersebut lebih production-ready. Latihan seperti ini akan membangun intuisi engineering yang jauh lebih kuat daripada sekadar membaca definisi.
', 'beginner', 12, 10),
        ('Time Complexity Deep Dive: Dari Loop sampai Query', 'Pendalaman kompleksitas waktu melalui contoh loop, sorting, recursion, query database, dan optimasi nyata.', '# Time Complexity Deep Dive: Dari Loop sampai Query

## Ringkasan

Pendalaman kompleksitas waktu melalui contoh loop, sorting, recursion, query database, dan optimasi nyata. Materi ini dirancang seperti modul bootcamp: dimulai dari intuisi, dilanjutkan dengan model mental, lalu ditutup dengan praktik industri dan tips interview. Fokus utamanya bukan menghafal istilah, melainkan memahami cara berpikir yang bisa dipakai saat membangun aplikasi nyata, membaca kode orang lain, melakukan debugging, dan menjelaskan keputusan teknis secara profesional.

## Kenapa Topik Ini Penting

Dalam software engineering, keputusan kecil sering punya dampak besar. Memilih struktur data, menentukan status code, menaruh validasi di layer yang tepat, atau memutuskan kapan memakai cache dapat memengaruhi performa, keamanan, dan pengalaman pengguna. Topik ini penting karena muncul berulang kali di proyek kampus, magang, pekerjaan full-time, dan interview software engineer.

Analogi sederhananya: membangun software mirip mengelola dapur restoran. Menu adalah fitur, pelanggan adalah user, database adalah gudang bahan, dan pipeline deployment adalah jalur penyajian. Restoran kecil bisa berjalan dengan satu koki dan satu catatan pesanan, tetapi restoran besar butuh alur kerja, pembagian peran, quality control, dan monitoring. Software juga begitu: semakin banyak user, semakin penting desain yang rapi.

## Konsep Utama

Kata kunci yang perlu kamu kuasai: **nested loop, sorting, recursion, database query, index**.

Beberapa prinsip yang selalu berguna:

- Pahami masalah sebelum memilih teknologi.
- Ukur bottleneck dengan data, bukan perasaan.
- Buat solusi paling sederhana yang masih memenuhi kebutuhan.
- Dokumentasikan asumsi penting agar tim lain tidak menebak-nebak.
- Pisahkan konsep inti dari detail implementasi.

| Area | Pertanyaan Penting | Dampak |
|---|---|---|
| Correctness | Apakah hasilnya benar untuk edge case? | Mengurangi bug logic |
| Performance | Bagaimana perilaku saat data membesar? | Menjaga latency |
| Maintainability | Apakah engineer lain mudah memahami kode? | Mempercepat perubahan |
| Security | Apakah data dan akses terlindungi? | Mengurangi risiko production |

## Penjelasan Detail

Bayangkan kamu menerima requirement baru dari product manager. Requirement itu biasanya terdengar sederhana, misalnya "tampilkan daftar materi yang relevan untuk user". Namun di balik kalimat singkat itu ada banyak keputusan: data apa yang dibaca, bagaimana urutannya, bagaimana jika database lambat, bagaimana jika user belum login, dan bagaimana hasilnya diuji. Engineer yang matang akan memecah requirement menjadi beberapa bagian kecil, mengidentifikasi risiko, lalu memilih pendekatan yang bisa diverifikasi.

Pada topik ini, pola berpikir yang paling penting adalah melihat hubungan antara input, proses, dan output. Input bisa berupa request HTTP, data dari database, event dari message broker, atau konfigurasi environment. Proses bisa berupa validasi, transformasi, query, perhitungan, atau komunikasi ke service lain. Output bisa berupa response JSON, record baru, log audit, atau event lanjutan. Jika salah satu bagian tidak jelas, debugging akan menjadi lebih sulit.

Dalam praktik sehari-hari, jangan hanya bertanya "apakah kode ini jalan?". Tanyakan juga:

1. Apa yang terjadi jika input kosong, duplikat, terlalu besar, atau tidak valid?
2. Apakah solusi ini masih masuk akal ketika jumlah data naik 100 kali lipat?
3. Apakah error message cukup membantu tanpa membocorkan informasi sensitif?
4. Apakah perubahan ini mudah dites secara otomatis?
5. Apakah ada asumsi yang perlu ditulis di dokumentasi?

## Contoh Implementasi

Contoh berikut bukan template final, tetapi gambaran cara menyusun ide secara eksplisit:

```text
orders.forEach(order -> {
    Customer customer = customerRepository.findById(order.getCustomerId());
});
```

Perhatikan bahwa contoh tersebut menonjolkan struktur berpikir, bukan sekadar sintaks. Sintaks bisa berbeda antara Java, TypeScript, Python, atau SQL, tetapi prinsipnya tetap sama: buat data mengalir lewat tahap yang jelas, kurangi coupling, dan pastikan kegagalan dapat diamati.

## Use Case Industri

Contoh industri: dashboard operasional melambat karena setiap baris order memicu query tambahan ke tabel customer. Kasus seperti ini umum terjadi karena sistem production memiliki batasan nyata: latency, biaya cloud, reliabilitas, keamanan, dan koordinasi antar tim. Solusi yang terlihat bagus di demo lokal belum tentu cukup untuk production jika tidak mempertimbangkan volume data, konkurensi, dan failure mode.

Dalam tim profesional, keputusan teknis biasanya perlu dijelaskan dalam bentuk trade-off. Misalnya, memakai cache membuat response lebih cepat, tetapi menambah risiko stale data. Memecah service membuat deployment lebih independen, tetapi menambah kebutuhan observability dan network reliability. Menggunakan JWT membuat service stateless, tetapi perlu validasi signature dan expiry yang benar.

## Studi Kasus Terarah

Misalkan Yomu ingin menampilkan materi belajar yang relevan untuk mahasiswa yang sedang mempersiapkan interview. Requirement awalnya terdengar sederhana: user membuka halaman, melihat daftar bacaan, memilih materi, lalu mengerjakan quiz. Namun kalau fitur ini dipakai ribuan mahasiswa, ada beberapa pertanyaan desain yang harus dijawab. Apakah daftar bacaan selalu diambil dari database? Apakah setiap request perlu menghitung progress quiz dari awal? Apakah response untuk learner boleh mengandung jawaban benar? Apakah admin boleh mengubah quiz yang sudah pernah dikerjakan banyak user?

Dengan sudut pandang Time Complexity Deep Dive: Dari Loop sampai Query, kamu bisa membuat keputusan yang lebih tajam. Pertama, pisahkan data yang bersifat publik, data yang personal untuk user, dan data yang hanya boleh dilihat admin. Kedua, tentukan operasi mana yang harus konsisten kuat dan mana yang boleh eventually consistent. Ketiga, siapkan test untuk memastikan perubahan schema, perubahan kontrak API, dan perubahan business rule tidak merusak pengalaman belajar.

Pendekatan yang matang biasanya menghasilkan desain seperti ini:

- Endpoint learner hanya mengembalikan informasi yang aman untuk learner.
- Endpoint admin memiliki authorization dan audit log.
- Query yang sering dipakai diberi index atau cache jika benar-benar terbukti bottleneck.
- Seed data dibuat idempotent agar environment lokal, staging, dan demo bisa diisi ulang tanpa duplikasi.
- Error response dibuat konsisten supaya frontend bisa menampilkan pesan yang jelas.

## Production Readiness Checklist

Sebelum sebuah fitur dianggap siap production, engineer perlu mengecek lebih dari sekadar "berhasil dijalankan". Gunakan checklist berikut sebagai kebiasaan:

1. **Correctness:** semua aturan bisnis utama punya test otomatis.
2. **Observability:** log cukup untuk menelusuri request bermasalah.
3. **Security:** endpoint sensitif terlindungi role, token, atau gateway policy.
4. **Performance:** query utama dan struktur data sudah dipikirkan untuk pertumbuhan data.
5. **Resilience:** error dari dependency eksternal tidak membuat seluruh aplikasi gagal tanpa pesan.
6. **Maintainability:** kode mengikuti batas layer yang jelas dan tidak mencampur terlalu banyak tanggung jawab.

Checklist ini bukan birokrasi. Ia membantu tim menghindari bug yang biasanya baru terlihat saat demo besar, traffic naik, atau ada perubahan requirement mendadak.

## Best Practices

- Mulai dari requirement dan constraint, bukan dari library favorit.
- Gunakan nama variabel, endpoint, dan tabel yang konsisten.
- Tambahkan test untuk happy path, edge case, dan failure case.
- Jangan menyimpan secret di source code.
- Catat keputusan penting di README atau ADR sederhana.
- Gunakan logging yang membantu debugging tanpa membocorkan data sensitif.
- Review performa query dan struktur data sebelum traffic membesar.

## Common Mistakes

Kesalahan yang sering dilakukan beginner adalah membuat solusi yang hanya bekerja untuk contoh kecil. Misalnya, nested loop tidak terasa lambat saat data hanya 10 baris, tetapi bisa menghancurkan latency saat data menjadi 100.000 baris. Kesalahan lain adalah mencampur validasi, business logic, dan akses database dalam satu fungsi besar sehingga sulit dites dan sulit diubah.

Kesalahan lain yang sering muncul:

- Mengabaikan edge case karena demo terlihat berhasil.
- Menggunakan status code HTTP yang tidak sesuai.
- Membiarkan endpoint admin tanpa authorization.
- Membuat query berulang dalam loop tanpa sadar.
- Menganggap semua error berasal dari frontend.
- Tidak menulis migration atau seed data yang idempotent.

## Fun Fact

Banyak konsep modern software engineering sebenarnya lahir dari masalah sederhana yang tumbuh besar. Queue muncul karena tidak semua pekerjaan harus selesai saat itu juga. Cache muncul karena membaca sumber data utama terus-menerus terlalu mahal. Load balancer muncul karena satu server tidak selamanya cukup. Dengan memahami asal masalahnya, kamu akan lebih mudah memilih teknologi yang tepat.

## Interview Tips

Saat interview, jangan langsung melompat ke jawaban final. Jelaskan asumsi, pilihan, dan trade-off. Interviewer biasanya ingin melihat cara berpikir. Untuk topik ini, jawaban yang kuat biasanya memuat:

1. Definisi singkat yang tepat.
2. Contoh real-world.
3. Edge case atau failure mode.
4. Trade-off solusi.
5. Cara menguji atau mengukur keberhasilan.

## Latihan Mandiri

Coba ambil fitur sederhana dari aplikasi Yomu, misalnya membaca materi dan mengerjakan quiz. Petakan input, proses, output, data yang disimpan, kemungkinan error, dan risiko keamanan. Setelah itu, tulis satu perbaikan kecil yang membuat fitur tersebut lebih production-ready. Latihan seperti ini akan membangun intuisi engineering yang jauh lebih kuat daripada sekadar membaca definisi.
', 'intermediate', 15, 20),
        ('Space Complexity dan Trade-off Memori', 'Materi ini menjelaskan biaya memori, trade-off cache, struktur data tambahan, dan dampaknya pada scalability.', '# Space Complexity dan Trade-off Memori

## Ringkasan

Materi ini menjelaskan biaya memori, trade-off cache, struktur data tambahan, dan dampaknya pada scalability. Materi ini dirancang seperti modul bootcamp: dimulai dari intuisi, dilanjutkan dengan model mental, lalu ditutup dengan praktik industri dan tips interview. Fokus utamanya bukan menghafal istilah, melainkan memahami cara berpikir yang bisa dipakai saat membangun aplikasi nyata, membaca kode orang lain, melakukan debugging, dan menjelaskan keputusan teknis secara profesional.

## Kenapa Topik Ini Penting

Dalam software engineering, keputusan kecil sering punya dampak besar. Memilih struktur data, menentukan status code, menaruh validasi di layer yang tepat, atau memutuskan kapan memakai cache dapat memengaruhi performa, keamanan, dan pengalaman pengguna. Topik ini penting karena muncul berulang kali di proyek kampus, magang, pekerjaan full-time, dan interview software engineer.

Analogi sederhananya: membangun software mirip mengelola dapur restoran. Menu adalah fitur, pelanggan adalah user, database adalah gudang bahan, dan pipeline deployment adalah jalur penyajian. Restoran kecil bisa berjalan dengan satu koki dan satu catatan pesanan, tetapi restoran besar butuh alur kerja, pembagian peran, quality control, dan monitoring. Software juga begitu: semakin banyak user, semakin penting desain yang rapi.

## Konsep Utama

Kata kunci yang perlu kamu kuasai: **memory, cache, auxiliary space, streaming, trade-off**.

Beberapa prinsip yang selalu berguna:

- Pahami masalah sebelum memilih teknologi.
- Ukur bottleneck dengan data, bukan perasaan.
- Buat solusi paling sederhana yang masih memenuhi kebutuhan.
- Dokumentasikan asumsi penting agar tim lain tidak menebak-nebak.
- Pisahkan konsep inti dari detail implementasi.

| Area | Pertanyaan Penting | Dampak |
|---|---|---|
| Correctness | Apakah hasilnya benar untuk edge case? | Mengurangi bug logic |
| Performance | Bagaimana perilaku saat data membesar? | Menjaga latency |
| Maintainability | Apakah engineer lain mudah memahami kode? | Mempercepat perubahan |
| Security | Apakah data dan akses terlindungi? | Mengurangi risiko production |

## Penjelasan Detail

Bayangkan kamu menerima requirement baru dari product manager. Requirement itu biasanya terdengar sederhana, misalnya "tampilkan daftar materi yang relevan untuk user". Namun di balik kalimat singkat itu ada banyak keputusan: data apa yang dibaca, bagaimana urutannya, bagaimana jika database lambat, bagaimana jika user belum login, dan bagaimana hasilnya diuji. Engineer yang matang akan memecah requirement menjadi beberapa bagian kecil, mengidentifikasi risiko, lalu memilih pendekatan yang bisa diverifikasi.

Pada topik ini, pola berpikir yang paling penting adalah melihat hubungan antara input, proses, dan output. Input bisa berupa request HTTP, data dari database, event dari message broker, atau konfigurasi environment. Proses bisa berupa validasi, transformasi, query, perhitungan, atau komunikasi ke service lain. Output bisa berupa response JSON, record baru, log audit, atau event lanjutan. Jika salah satu bagian tidak jelas, debugging akan menjadi lebih sulit.

Dalam praktik sehari-hari, jangan hanya bertanya "apakah kode ini jalan?". Tanyakan juga:

1. Apa yang terjadi jika input kosong, duplikat, terlalu besar, atau tidak valid?
2. Apakah solusi ini masih masuk akal ketika jumlah data naik 100 kali lipat?
3. Apakah error message cukup membantu tanpa membocorkan informasi sensitif?
4. Apakah perubahan ini mudah dites secara otomatis?
5. Apakah ada asumsi yang perlu ditulis di dokumentasi?

## Contoh Implementasi

Contoh berikut bukan template final, tetapi gambaran cara menyusun ide secara eksplisit:

```text
try (Stream<String> lines = Files.lines(path)) {
  lines.forEach(this::processLine);
}
```

Perhatikan bahwa contoh tersebut menonjolkan struktur berpikir, bukan sekadar sintaks. Sintaks bisa berbeda antara Java, TypeScript, Python, atau SQL, tetapi prinsipnya tetap sama: buat data mengalir lewat tahap yang jelas, kurangi coupling, dan pastikan kegagalan dapat diamati.

## Use Case Industri

Contoh industri: service laporan memproses file besar secara streaming agar tidak menahan seluruh data di RAM. Kasus seperti ini umum terjadi karena sistem production memiliki batasan nyata: latency, biaya cloud, reliabilitas, keamanan, dan koordinasi antar tim. Solusi yang terlihat bagus di demo lokal belum tentu cukup untuk production jika tidak mempertimbangkan volume data, konkurensi, dan failure mode.

Dalam tim profesional, keputusan teknis biasanya perlu dijelaskan dalam bentuk trade-off. Misalnya, memakai cache membuat response lebih cepat, tetapi menambah risiko stale data. Memecah service membuat deployment lebih independen, tetapi menambah kebutuhan observability dan network reliability. Menggunakan JWT membuat service stateless, tetapi perlu validasi signature dan expiry yang benar.

## Studi Kasus Terarah

Misalkan Yomu ingin menampilkan materi belajar yang relevan untuk mahasiswa yang sedang mempersiapkan interview. Requirement awalnya terdengar sederhana: user membuka halaman, melihat daftar bacaan, memilih materi, lalu mengerjakan quiz. Namun kalau fitur ini dipakai ribuan mahasiswa, ada beberapa pertanyaan desain yang harus dijawab. Apakah daftar bacaan selalu diambil dari database? Apakah setiap request perlu menghitung progress quiz dari awal? Apakah response untuk learner boleh mengandung jawaban benar? Apakah admin boleh mengubah quiz yang sudah pernah dikerjakan banyak user?

Dengan sudut pandang Space Complexity dan Trade-off Memori, kamu bisa membuat keputusan yang lebih tajam. Pertama, pisahkan data yang bersifat publik, data yang personal untuk user, dan data yang hanya boleh dilihat admin. Kedua, tentukan operasi mana yang harus konsisten kuat dan mana yang boleh eventually consistent. Ketiga, siapkan test untuk memastikan perubahan schema, perubahan kontrak API, dan perubahan business rule tidak merusak pengalaman belajar.

Pendekatan yang matang biasanya menghasilkan desain seperti ini:

- Endpoint learner hanya mengembalikan informasi yang aman untuk learner.
- Endpoint admin memiliki authorization dan audit log.
- Query yang sering dipakai diberi index atau cache jika benar-benar terbukti bottleneck.
- Seed data dibuat idempotent agar environment lokal, staging, dan demo bisa diisi ulang tanpa duplikasi.
- Error response dibuat konsisten supaya frontend bisa menampilkan pesan yang jelas.

## Production Readiness Checklist

Sebelum sebuah fitur dianggap siap production, engineer perlu mengecek lebih dari sekadar "berhasil dijalankan". Gunakan checklist berikut sebagai kebiasaan:

1. **Correctness:** semua aturan bisnis utama punya test otomatis.
2. **Observability:** log cukup untuk menelusuri request bermasalah.
3. **Security:** endpoint sensitif terlindungi role, token, atau gateway policy.
4. **Performance:** query utama dan struktur data sudah dipikirkan untuk pertumbuhan data.
5. **Resilience:** error dari dependency eksternal tidak membuat seluruh aplikasi gagal tanpa pesan.
6. **Maintainability:** kode mengikuti batas layer yang jelas dan tidak mencampur terlalu banyak tanggung jawab.

Checklist ini bukan birokrasi. Ia membantu tim menghindari bug yang biasanya baru terlihat saat demo besar, traffic naik, atau ada perubahan requirement mendadak.

## Best Practices

- Mulai dari requirement dan constraint, bukan dari library favorit.
- Gunakan nama variabel, endpoint, dan tabel yang konsisten.
- Tambahkan test untuk happy path, edge case, dan failure case.
- Jangan menyimpan secret di source code.
- Catat keputusan penting di README atau ADR sederhana.
- Gunakan logging yang membantu debugging tanpa membocorkan data sensitif.
- Review performa query dan struktur data sebelum traffic membesar.

## Common Mistakes

Kesalahan yang sering dilakukan beginner adalah membuat solusi yang hanya bekerja untuk contoh kecil. Misalnya, nested loop tidak terasa lambat saat data hanya 10 baris, tetapi bisa menghancurkan latency saat data menjadi 100.000 baris. Kesalahan lain adalah mencampur validasi, business logic, dan akses database dalam satu fungsi besar sehingga sulit dites dan sulit diubah.

Kesalahan lain yang sering muncul:

- Mengabaikan edge case karena demo terlihat berhasil.
- Menggunakan status code HTTP yang tidak sesuai.
- Membiarkan endpoint admin tanpa authorization.
- Membuat query berulang dalam loop tanpa sadar.
- Menganggap semua error berasal dari frontend.
- Tidak menulis migration atau seed data yang idempotent.

## Fun Fact

Banyak konsep modern software engineering sebenarnya lahir dari masalah sederhana yang tumbuh besar. Queue muncul karena tidak semua pekerjaan harus selesai saat itu juga. Cache muncul karena membaca sumber data utama terus-menerus terlalu mahal. Load balancer muncul karena satu server tidak selamanya cukup. Dengan memahami asal masalahnya, kamu akan lebih mudah memilih teknologi yang tepat.

## Interview Tips

Saat interview, jangan langsung melompat ke jawaban final. Jelaskan asumsi, pilihan, dan trade-off. Interviewer biasanya ingin melihat cara berpikir. Untuk topik ini, jawaban yang kuat biasanya memuat:

1. Definisi singkat yang tepat.
2. Contoh real-world.
3. Edge case atau failure mode.
4. Trade-off solusi.
5. Cara menguji atau mengukur keberhasilan.

## Latihan Mandiri

Coba ambil fitur sederhana dari aplikasi Yomu, misalnya membaca materi dan mengerjakan quiz. Petakan input, proses, output, data yang disimpan, kemungkinan error, dan risiko keamanan. Setelah itu, tulis satu perbaikan kecil yang membuat fitur tersebut lebih production-ready. Latihan seperti ini akan membangun intuisi engineering yang jauh lebih kuat daripada sekadar membaca definisi.
', 'intermediate', 12, 20),
        ('Stack vs Queue: Pola LIFO dan FIFO', 'Bandingkan stack dan queue, kapan dipakai, serta contoh penerapannya pada undo, parsing, job processing, dan BFS.', '# Stack vs Queue: Pola LIFO dan FIFO

## Ringkasan

Bandingkan stack dan queue, kapan dipakai, serta contoh penerapannya pada undo, parsing, job processing, dan BFS. Materi ini dirancang seperti modul bootcamp: dimulai dari intuisi, dilanjutkan dengan model mental, lalu ditutup dengan praktik industri dan tips interview. Fokus utamanya bukan menghafal istilah, melainkan memahami cara berpikir yang bisa dipakai saat membangun aplikasi nyata, membaca kode orang lain, melakukan debugging, dan menjelaskan keputusan teknis secara profesional.

## Kenapa Topik Ini Penting

Dalam software engineering, keputusan kecil sering punya dampak besar. Memilih struktur data, menentukan status code, menaruh validasi di layer yang tepat, atau memutuskan kapan memakai cache dapat memengaruhi performa, keamanan, dan pengalaman pengguna. Topik ini penting karena muncul berulang kali di proyek kampus, magang, pekerjaan full-time, dan interview software engineer.

Analogi sederhananya: membangun software mirip mengelola dapur restoran. Menu adalah fitur, pelanggan adalah user, database adalah gudang bahan, dan pipeline deployment adalah jalur penyajian. Restoran kecil bisa berjalan dengan satu koki dan satu catatan pesanan, tetapi restoran besar butuh alur kerja, pembagian peran, quality control, dan monitoring. Software juga begitu: semakin banyak user, semakin penting desain yang rapi.

## Konsep Utama

Kata kunci yang perlu kamu kuasai: **stack, queue, LIFO, FIFO, BFS**.

Beberapa prinsip yang selalu berguna:

- Pahami masalah sebelum memilih teknologi.
- Ukur bottleneck dengan data, bukan perasaan.
- Buat solusi paling sederhana yang masih memenuhi kebutuhan.
- Dokumentasikan asumsi penting agar tim lain tidak menebak-nebak.
- Pisahkan konsep inti dari detail implementasi.

| Area | Pertanyaan Penting | Dampak |
|---|---|---|
| Correctness | Apakah hasilnya benar untuk edge case? | Mengurangi bug logic |
| Performance | Bagaimana perilaku saat data membesar? | Menjaga latency |
| Maintainability | Apakah engineer lain mudah memahami kode? | Mempercepat perubahan |
| Security | Apakah data dan akses terlindungi? | Mengurangi risiko production |

## Penjelasan Detail

Bayangkan kamu menerima requirement baru dari product manager. Requirement itu biasanya terdengar sederhana, misalnya "tampilkan daftar materi yang relevan untuk user". Namun di balik kalimat singkat itu ada banyak keputusan: data apa yang dibaca, bagaimana urutannya, bagaimana jika database lambat, bagaimana jika user belum login, dan bagaimana hasilnya diuji. Engineer yang matang akan memecah requirement menjadi beberapa bagian kecil, mengidentifikasi risiko, lalu memilih pendekatan yang bisa diverifikasi.

Pada topik ini, pola berpikir yang paling penting adalah melihat hubungan antara input, proses, dan output. Input bisa berupa request HTTP, data dari database, event dari message broker, atau konfigurasi environment. Proses bisa berupa validasi, transformasi, query, perhitungan, atau komunikasi ke service lain. Output bisa berupa response JSON, record baru, log audit, atau event lanjutan. Jika salah satu bagian tidak jelas, debugging akan menjadi lebih sulit.

Dalam praktik sehari-hari, jangan hanya bertanya "apakah kode ini jalan?". Tanyakan juga:

1. Apa yang terjadi jika input kosong, duplikat, terlalu besar, atau tidak valid?
2. Apakah solusi ini masih masuk akal ketika jumlah data naik 100 kali lipat?
3. Apakah error message cukup membantu tanpa membocorkan informasi sensitif?
4. Apakah perubahan ini mudah dites secara otomatis?
5. Apakah ada asumsi yang perlu ditulis di dokumentasi?

## Contoh Implementasi

Contoh berikut bukan template final, tetapi gambaran cara menyusun ide secara eksplisit:

```text
Deque<String> stack = new ArrayDeque<>();
Queue<String> queue = new ArrayDeque<>();
```

Perhatikan bahwa contoh tersebut menonjolkan struktur berpikir, bukan sekadar sintaks. Sintaks bisa berbeda antara Java, TypeScript, Python, atau SQL, tetapi prinsipnya tetap sama: buat data mengalir lewat tahap yang jelas, kurangi coupling, dan pastikan kegagalan dapat diamati.

## Use Case Industri

Contoh industri: sistem notifikasi memakai queue agar pesan dikirim berurutan dan tidak hilang ketika worker sibuk. Kasus seperti ini umum terjadi karena sistem production memiliki batasan nyata: latency, biaya cloud, reliabilitas, keamanan, dan koordinasi antar tim. Solusi yang terlihat bagus di demo lokal belum tentu cukup untuk production jika tidak mempertimbangkan volume data, konkurensi, dan failure mode.

Dalam tim profesional, keputusan teknis biasanya perlu dijelaskan dalam bentuk trade-off. Misalnya, memakai cache membuat response lebih cepat, tetapi menambah risiko stale data. Memecah service membuat deployment lebih independen, tetapi menambah kebutuhan observability dan network reliability. Menggunakan JWT membuat service stateless, tetapi perlu validasi signature dan expiry yang benar.

## Studi Kasus Terarah

Misalkan Yomu ingin menampilkan materi belajar yang relevan untuk mahasiswa yang sedang mempersiapkan interview. Requirement awalnya terdengar sederhana: user membuka halaman, melihat daftar bacaan, memilih materi, lalu mengerjakan quiz. Namun kalau fitur ini dipakai ribuan mahasiswa, ada beberapa pertanyaan desain yang harus dijawab. Apakah daftar bacaan selalu diambil dari database? Apakah setiap request perlu menghitung progress quiz dari awal? Apakah response untuk learner boleh mengandung jawaban benar? Apakah admin boleh mengubah quiz yang sudah pernah dikerjakan banyak user?

Dengan sudut pandang Stack vs Queue: Pola LIFO dan FIFO, kamu bisa membuat keputusan yang lebih tajam. Pertama, pisahkan data yang bersifat publik, data yang personal untuk user, dan data yang hanya boleh dilihat admin. Kedua, tentukan operasi mana yang harus konsisten kuat dan mana yang boleh eventually consistent. Ketiga, siapkan test untuk memastikan perubahan schema, perubahan kontrak API, dan perubahan business rule tidak merusak pengalaman belajar.

Pendekatan yang matang biasanya menghasilkan desain seperti ini:

- Endpoint learner hanya mengembalikan informasi yang aman untuk learner.
- Endpoint admin memiliki authorization dan audit log.
- Query yang sering dipakai diberi index atau cache jika benar-benar terbukti bottleneck.
- Seed data dibuat idempotent agar environment lokal, staging, dan demo bisa diisi ulang tanpa duplikasi.
- Error response dibuat konsisten supaya frontend bisa menampilkan pesan yang jelas.

## Production Readiness Checklist

Sebelum sebuah fitur dianggap siap production, engineer perlu mengecek lebih dari sekadar "berhasil dijalankan". Gunakan checklist berikut sebagai kebiasaan:

1. **Correctness:** semua aturan bisnis utama punya test otomatis.
2. **Observability:** log cukup untuk menelusuri request bermasalah.
3. **Security:** endpoint sensitif terlindungi role, token, atau gateway policy.
4. **Performance:** query utama dan struktur data sudah dipikirkan untuk pertumbuhan data.
5. **Resilience:** error dari dependency eksternal tidak membuat seluruh aplikasi gagal tanpa pesan.
6. **Maintainability:** kode mengikuti batas layer yang jelas dan tidak mencampur terlalu banyak tanggung jawab.

Checklist ini bukan birokrasi. Ia membantu tim menghindari bug yang biasanya baru terlihat saat demo besar, traffic naik, atau ada perubahan requirement mendadak.

## Best Practices

- Mulai dari requirement dan constraint, bukan dari library favorit.
- Gunakan nama variabel, endpoint, dan tabel yang konsisten.
- Tambahkan test untuk happy path, edge case, dan failure case.
- Jangan menyimpan secret di source code.
- Catat keputusan penting di README atau ADR sederhana.
- Gunakan logging yang membantu debugging tanpa membocorkan data sensitif.
- Review performa query dan struktur data sebelum traffic membesar.

## Common Mistakes

Kesalahan yang sering dilakukan beginner adalah membuat solusi yang hanya bekerja untuk contoh kecil. Misalnya, nested loop tidak terasa lambat saat data hanya 10 baris, tetapi bisa menghancurkan latency saat data menjadi 100.000 baris. Kesalahan lain adalah mencampur validasi, business logic, dan akses database dalam satu fungsi besar sehingga sulit dites dan sulit diubah.

Kesalahan lain yang sering muncul:

- Mengabaikan edge case karena demo terlihat berhasil.
- Menggunakan status code HTTP yang tidak sesuai.
- Membiarkan endpoint admin tanpa authorization.
- Membuat query berulang dalam loop tanpa sadar.
- Menganggap semua error berasal dari frontend.
- Tidak menulis migration atau seed data yang idempotent.

## Fun Fact

Banyak konsep modern software engineering sebenarnya lahir dari masalah sederhana yang tumbuh besar. Queue muncul karena tidak semua pekerjaan harus selesai saat itu juga. Cache muncul karena membaca sumber data utama terus-menerus terlalu mahal. Load balancer muncul karena satu server tidak selamanya cukup. Dengan memahami asal masalahnya, kamu akan lebih mudah memilih teknologi yang tepat.

## Interview Tips

Saat interview, jangan langsung melompat ke jawaban final. Jelaskan asumsi, pilihan, dan trade-off. Interviewer biasanya ingin melihat cara berpikir. Untuk topik ini, jawaban yang kuat biasanya memuat:

1. Definisi singkat yang tepat.
2. Contoh real-world.
3. Edge case atau failure mode.
4. Trade-off solusi.
5. Cara menguji atau mengukur keberhasilan.

## Latihan Mandiri

Coba ambil fitur sederhana dari aplikasi Yomu, misalnya membaca materi dan mengerjakan quiz. Petakan input, proses, output, data yang disimpan, kemungkinan error, dan risiko keamanan. Setelah itu, tulis satu perbaikan kecil yang membuat fitur tersebut lebih production-ready. Latihan seperti ini akan membangun intuisi engineering yang jauh lebih kuat daripada sekadar membaca definisi.
', 'beginner', 10, 10),
        ('Hash Map Internals: Hashing, Collision, dan Load Factor', 'Kupas cara kerja hash map, collision handling, load factor, resizing, dan risiko key yang buruk.', '# Hash Map Internals: Hashing, Collision, dan Load Factor

## Ringkasan

Kupas cara kerja hash map, collision handling, load factor, resizing, dan risiko key yang buruk. Materi ini dirancang seperti modul bootcamp: dimulai dari intuisi, dilanjutkan dengan model mental, lalu ditutup dengan praktik industri dan tips interview. Fokus utamanya bukan menghafal istilah, melainkan memahami cara berpikir yang bisa dipakai saat membangun aplikasi nyata, membaca kode orang lain, melakukan debugging, dan menjelaskan keputusan teknis secara profesional.

## Kenapa Topik Ini Penting

Dalam software engineering, keputusan kecil sering punya dampak besar. Memilih struktur data, menentukan status code, menaruh validasi di layer yang tepat, atau memutuskan kapan memakai cache dapat memengaruhi performa, keamanan, dan pengalaman pengguna. Topik ini penting karena muncul berulang kali di proyek kampus, magang, pekerjaan full-time, dan interview software engineer.

Analogi sederhananya: membangun software mirip mengelola dapur restoran. Menu adalah fitur, pelanggan adalah user, database adalah gudang bahan, dan pipeline deployment adalah jalur penyajian. Restoran kecil bisa berjalan dengan satu koki dan satu catatan pesanan, tetapi restoran besar butuh alur kerja, pembagian peran, quality control, dan monitoring. Software juga begitu: semakin banyak user, semakin penting desain yang rapi.

## Konsep Utama

Kata kunci yang perlu kamu kuasai: **hash function, collision, bucket, load factor, resizing**.

Beberapa prinsip yang selalu berguna:

- Pahami masalah sebelum memilih teknologi.
- Ukur bottleneck dengan data, bukan perasaan.
- Buat solusi paling sederhana yang masih memenuhi kebutuhan.
- Dokumentasikan asumsi penting agar tim lain tidak menebak-nebak.
- Pisahkan konsep inti dari detail implementasi.

| Area | Pertanyaan Penting | Dampak |
|---|---|---|
| Correctness | Apakah hasilnya benar untuk edge case? | Mengurangi bug logic |
| Performance | Bagaimana perilaku saat data membesar? | Menjaga latency |
| Maintainability | Apakah engineer lain mudah memahami kode? | Mempercepat perubahan |
| Security | Apakah data dan akses terlindungi? | Mengurangi risiko production |

## Penjelasan Detail

Bayangkan kamu menerima requirement baru dari product manager. Requirement itu biasanya terdengar sederhana, misalnya "tampilkan daftar materi yang relevan untuk user". Namun di balik kalimat singkat itu ada banyak keputusan: data apa yang dibaca, bagaimana urutannya, bagaimana jika database lambat, bagaimana jika user belum login, dan bagaimana hasilnya diuji. Engineer yang matang akan memecah requirement menjadi beberapa bagian kecil, mengidentifikasi risiko, lalu memilih pendekatan yang bisa diverifikasi.

Pada topik ini, pola berpikir yang paling penting adalah melihat hubungan antara input, proses, dan output. Input bisa berupa request HTTP, data dari database, event dari message broker, atau konfigurasi environment. Proses bisa berupa validasi, transformasi, query, perhitungan, atau komunikasi ke service lain. Output bisa berupa response JSON, record baru, log audit, atau event lanjutan. Jika salah satu bagian tidak jelas, debugging akan menjadi lebih sulit.

Dalam praktik sehari-hari, jangan hanya bertanya "apakah kode ini jalan?". Tanyakan juga:

1. Apa yang terjadi jika input kosong, duplikat, terlalu besar, atau tidak valid?
2. Apakah solusi ini masih masuk akal ketika jumlah data naik 100 kali lipat?
3. Apakah error message cukup membantu tanpa membocorkan informasi sensitif?
4. Apakah perubahan ini mudah dites secara otomatis?
5. Apakah ada asumsi yang perlu ditulis di dokumentasi?

## Contoh Implementasi

Contoh berikut bukan template final, tetapi gambaran cara menyusun ide secara eksplisit:

```text
int bucket = Math.abs(key.hashCode()) % capacity;
entries[bucket].add(new Entry(key, value));
```

Perhatikan bahwa contoh tersebut menonjolkan struktur berpikir, bukan sekadar sintaks. Sintaks bisa berbeda antara Java, TypeScript, Python, atau SQL, tetapi prinsipnya tetap sama: buat data mengalir lewat tahap yang jelas, kurangi coupling, dan pastikan kegagalan dapat diamati.

## Use Case Industri

Contoh industri: rate limiter menyimpan counter per user di map agar pengecekan request tetap cepat. Kasus seperti ini umum terjadi karena sistem production memiliki batasan nyata: latency, biaya cloud, reliabilitas, keamanan, dan koordinasi antar tim. Solusi yang terlihat bagus di demo lokal belum tentu cukup untuk production jika tidak mempertimbangkan volume data, konkurensi, dan failure mode.

Dalam tim profesional, keputusan teknis biasanya perlu dijelaskan dalam bentuk trade-off. Misalnya, memakai cache membuat response lebih cepat, tetapi menambah risiko stale data. Memecah service membuat deployment lebih independen, tetapi menambah kebutuhan observability dan network reliability. Menggunakan JWT membuat service stateless, tetapi perlu validasi signature dan expiry yang benar.

## Studi Kasus Terarah

Misalkan Yomu ingin menampilkan materi belajar yang relevan untuk mahasiswa yang sedang mempersiapkan interview. Requirement awalnya terdengar sederhana: user membuka halaman, melihat daftar bacaan, memilih materi, lalu mengerjakan quiz. Namun kalau fitur ini dipakai ribuan mahasiswa, ada beberapa pertanyaan desain yang harus dijawab. Apakah daftar bacaan selalu diambil dari database? Apakah setiap request perlu menghitung progress quiz dari awal? Apakah response untuk learner boleh mengandung jawaban benar? Apakah admin boleh mengubah quiz yang sudah pernah dikerjakan banyak user?

Dengan sudut pandang Hash Map Internals: Hashing, Collision, dan Load Factor, kamu bisa membuat keputusan yang lebih tajam. Pertama, pisahkan data yang bersifat publik, data yang personal untuk user, dan data yang hanya boleh dilihat admin. Kedua, tentukan operasi mana yang harus konsisten kuat dan mana yang boleh eventually consistent. Ketiga, siapkan test untuk memastikan perubahan schema, perubahan kontrak API, dan perubahan business rule tidak merusak pengalaman belajar.

Pendekatan yang matang biasanya menghasilkan desain seperti ini:

- Endpoint learner hanya mengembalikan informasi yang aman untuk learner.
- Endpoint admin memiliki authorization dan audit log.
- Query yang sering dipakai diberi index atau cache jika benar-benar terbukti bottleneck.
- Seed data dibuat idempotent agar environment lokal, staging, dan demo bisa diisi ulang tanpa duplikasi.
- Error response dibuat konsisten supaya frontend bisa menampilkan pesan yang jelas.

## Production Readiness Checklist

Sebelum sebuah fitur dianggap siap production, engineer perlu mengecek lebih dari sekadar "berhasil dijalankan". Gunakan checklist berikut sebagai kebiasaan:

1. **Correctness:** semua aturan bisnis utama punya test otomatis.
2. **Observability:** log cukup untuk menelusuri request bermasalah.
3. **Security:** endpoint sensitif terlindungi role, token, atau gateway policy.
4. **Performance:** query utama dan struktur data sudah dipikirkan untuk pertumbuhan data.
5. **Resilience:** error dari dependency eksternal tidak membuat seluruh aplikasi gagal tanpa pesan.
6. **Maintainability:** kode mengikuti batas layer yang jelas dan tidak mencampur terlalu banyak tanggung jawab.

Checklist ini bukan birokrasi. Ia membantu tim menghindari bug yang biasanya baru terlihat saat demo besar, traffic naik, atau ada perubahan requirement mendadak.

## Best Practices

- Mulai dari requirement dan constraint, bukan dari library favorit.
- Gunakan nama variabel, endpoint, dan tabel yang konsisten.
- Tambahkan test untuk happy path, edge case, dan failure case.
- Jangan menyimpan secret di source code.
- Catat keputusan penting di README atau ADR sederhana.
- Gunakan logging yang membantu debugging tanpa membocorkan data sensitif.
- Review performa query dan struktur data sebelum traffic membesar.

## Common Mistakes

Kesalahan yang sering dilakukan beginner adalah membuat solusi yang hanya bekerja untuk contoh kecil. Misalnya, nested loop tidak terasa lambat saat data hanya 10 baris, tetapi bisa menghancurkan latency saat data menjadi 100.000 baris. Kesalahan lain adalah mencampur validasi, business logic, dan akses database dalam satu fungsi besar sehingga sulit dites dan sulit diubah.

Kesalahan lain yang sering muncul:

- Mengabaikan edge case karena demo terlihat berhasil.
- Menggunakan status code HTTP yang tidak sesuai.
- Membiarkan endpoint admin tanpa authorization.
- Membuat query berulang dalam loop tanpa sadar.
- Menganggap semua error berasal dari frontend.
- Tidak menulis migration atau seed data yang idempotent.

## Fun Fact

Banyak konsep modern software engineering sebenarnya lahir dari masalah sederhana yang tumbuh besar. Queue muncul karena tidak semua pekerjaan harus selesai saat itu juga. Cache muncul karena membaca sumber data utama terus-menerus terlalu mahal. Load balancer muncul karena satu server tidak selamanya cukup. Dengan memahami asal masalahnya, kamu akan lebih mudah memilih teknologi yang tepat.

## Interview Tips

Saat interview, jangan langsung melompat ke jawaban final. Jelaskan asumsi, pilihan, dan trade-off. Interviewer biasanya ingin melihat cara berpikir. Untuk topik ini, jawaban yang kuat biasanya memuat:

1. Definisi singkat yang tepat.
2. Contoh real-world.
3. Edge case atau failure mode.
4. Trade-off solusi.
5. Cara menguji atau mengukur keberhasilan.

## Latihan Mandiri

Coba ambil fitur sederhana dari aplikasi Yomu, misalnya membaca materi dan mengerjakan quiz. Petakan input, proses, output, data yang disimpan, kemungkinan error, dan risiko keamanan. Setelah itu, tulis satu perbaikan kecil yang membuat fitur tersebut lebih production-ready. Latihan seperti ini akan membangun intuisi engineering yang jauh lebih kuat daripada sekadar membaca definisi.
', 'intermediate', 15, 20),
        ('Database Normalization untuk Desain Data yang Sehat', 'Pelajari 1NF, 2NF, 3NF, denormalisasi terkontrol, dan cara mencegah anomali data.', '# Database Normalization untuk Desain Data yang Sehat

## Ringkasan

Pelajari 1NF, 2NF, 3NF, denormalisasi terkontrol, dan cara mencegah anomali data. Materi ini dirancang seperti modul bootcamp: dimulai dari intuisi, dilanjutkan dengan model mental, lalu ditutup dengan praktik industri dan tips interview. Fokus utamanya bukan menghafal istilah, melainkan memahami cara berpikir yang bisa dipakai saat membangun aplikasi nyata, membaca kode orang lain, melakukan debugging, dan menjelaskan keputusan teknis secara profesional.

## Kenapa Topik Ini Penting

Dalam software engineering, keputusan kecil sering punya dampak besar. Memilih struktur data, menentukan status code, menaruh validasi di layer yang tepat, atau memutuskan kapan memakai cache dapat memengaruhi performa, keamanan, dan pengalaman pengguna. Topik ini penting karena muncul berulang kali di proyek kampus, magang, pekerjaan full-time, dan interview software engineer.

Analogi sederhananya: membangun software mirip mengelola dapur restoran. Menu adalah fitur, pelanggan adalah user, database adalah gudang bahan, dan pipeline deployment adalah jalur penyajian. Restoran kecil bisa berjalan dengan satu koki dan satu catatan pesanan, tetapi restoran besar butuh alur kerja, pembagian peran, quality control, dan monitoring. Software juga begitu: semakin banyak user, semakin penting desain yang rapi.

## Konsep Utama

Kata kunci yang perlu kamu kuasai: **1NF, 2NF, 3NF, foreign key, denormalization**.

Beberapa prinsip yang selalu berguna:

- Pahami masalah sebelum memilih teknologi.
- Ukur bottleneck dengan data, bukan perasaan.
- Buat solusi paling sederhana yang masih memenuhi kebutuhan.
- Dokumentasikan asumsi penting agar tim lain tidak menebak-nebak.
- Pisahkan konsep inti dari detail implementasi.

| Area | Pertanyaan Penting | Dampak |
|---|---|---|
| Correctness | Apakah hasilnya benar untuk edge case? | Mengurangi bug logic |
| Performance | Bagaimana perilaku saat data membesar? | Menjaga latency |
| Maintainability | Apakah engineer lain mudah memahami kode? | Mempercepat perubahan |
| Security | Apakah data dan akses terlindungi? | Mengurangi risiko production |

## Penjelasan Detail

Bayangkan kamu menerima requirement baru dari product manager. Requirement itu biasanya terdengar sederhana, misalnya "tampilkan daftar materi yang relevan untuk user". Namun di balik kalimat singkat itu ada banyak keputusan: data apa yang dibaca, bagaimana urutannya, bagaimana jika database lambat, bagaimana jika user belum login, dan bagaimana hasilnya diuji. Engineer yang matang akan memecah requirement menjadi beberapa bagian kecil, mengidentifikasi risiko, lalu memilih pendekatan yang bisa diverifikasi.

Pada topik ini, pola berpikir yang paling penting adalah melihat hubungan antara input, proses, dan output. Input bisa berupa request HTTP, data dari database, event dari message broker, atau konfigurasi environment. Proses bisa berupa validasi, transformasi, query, perhitungan, atau komunikasi ke service lain. Output bisa berupa response JSON, record baru, log audit, atau event lanjutan. Jika salah satu bagian tidak jelas, debugging akan menjadi lebih sulit.

Dalam praktik sehari-hari, jangan hanya bertanya "apakah kode ini jalan?". Tanyakan juga:

1. Apa yang terjadi jika input kosong, duplikat, terlalu besar, atau tidak valid?
2. Apakah solusi ini masih masuk akal ketika jumlah data naik 100 kali lipat?
3. Apakah error message cukup membantu tanpa membocorkan informasi sensitif?
4. Apakah perubahan ini mudah dites secara otomatis?
5. Apakah ada asumsi yang perlu ditulis di dokumentasi?

## Contoh Implementasi

Contoh berikut bukan template final, tetapi gambaran cara menyusun ide secara eksplisit:

```text
CREATE TABLE enrollments (
  student_id INT REFERENCES students(id),
  course_id INT REFERENCES courses(id)
);
```

Perhatikan bahwa contoh tersebut menonjolkan struktur berpikir, bukan sekadar sintaks. Sintaks bisa berbeda antara Java, TypeScript, Python, atau SQL, tetapi prinsipnya tetap sama: buat data mengalir lewat tahap yang jelas, kurangi coupling, dan pastikan kegagalan dapat diamati.

## Use Case Industri

Contoh industri: sistem akademik memisahkan student, course, enrollment, dan grade agar update data tidak tersebar di banyak baris duplikat. Kasus seperti ini umum terjadi karena sistem production memiliki batasan nyata: latency, biaya cloud, reliabilitas, keamanan, dan koordinasi antar tim. Solusi yang terlihat bagus di demo lokal belum tentu cukup untuk production jika tidak mempertimbangkan volume data, konkurensi, dan failure mode.

Dalam tim profesional, keputusan teknis biasanya perlu dijelaskan dalam bentuk trade-off. Misalnya, memakai cache membuat response lebih cepat, tetapi menambah risiko stale data. Memecah service membuat deployment lebih independen, tetapi menambah kebutuhan observability dan network reliability. Menggunakan JWT membuat service stateless, tetapi perlu validasi signature dan expiry yang benar.

## Studi Kasus Terarah

Misalkan Yomu ingin menampilkan materi belajar yang relevan untuk mahasiswa yang sedang mempersiapkan interview. Requirement awalnya terdengar sederhana: user membuka halaman, melihat daftar bacaan, memilih materi, lalu mengerjakan quiz. Namun kalau fitur ini dipakai ribuan mahasiswa, ada beberapa pertanyaan desain yang harus dijawab. Apakah daftar bacaan selalu diambil dari database? Apakah setiap request perlu menghitung progress quiz dari awal? Apakah response untuk learner boleh mengandung jawaban benar? Apakah admin boleh mengubah quiz yang sudah pernah dikerjakan banyak user?

Dengan sudut pandang Database Normalization untuk Desain Data yang Sehat, kamu bisa membuat keputusan yang lebih tajam. Pertama, pisahkan data yang bersifat publik, data yang personal untuk user, dan data yang hanya boleh dilihat admin. Kedua, tentukan operasi mana yang harus konsisten kuat dan mana yang boleh eventually consistent. Ketiga, siapkan test untuk memastikan perubahan schema, perubahan kontrak API, dan perubahan business rule tidak merusak pengalaman belajar.

Pendekatan yang matang biasanya menghasilkan desain seperti ini:

- Endpoint learner hanya mengembalikan informasi yang aman untuk learner.
- Endpoint admin memiliki authorization dan audit log.
- Query yang sering dipakai diberi index atau cache jika benar-benar terbukti bottleneck.
- Seed data dibuat idempotent agar environment lokal, staging, dan demo bisa diisi ulang tanpa duplikasi.
- Error response dibuat konsisten supaya frontend bisa menampilkan pesan yang jelas.

## Production Readiness Checklist

Sebelum sebuah fitur dianggap siap production, engineer perlu mengecek lebih dari sekadar "berhasil dijalankan". Gunakan checklist berikut sebagai kebiasaan:

1. **Correctness:** semua aturan bisnis utama punya test otomatis.
2. **Observability:** log cukup untuk menelusuri request bermasalah.
3. **Security:** endpoint sensitif terlindungi role, token, atau gateway policy.
4. **Performance:** query utama dan struktur data sudah dipikirkan untuk pertumbuhan data.
5. **Resilience:** error dari dependency eksternal tidak membuat seluruh aplikasi gagal tanpa pesan.
6. **Maintainability:** kode mengikuti batas layer yang jelas dan tidak mencampur terlalu banyak tanggung jawab.

Checklist ini bukan birokrasi. Ia membantu tim menghindari bug yang biasanya baru terlihat saat demo besar, traffic naik, atau ada perubahan requirement mendadak.

## Best Practices

- Mulai dari requirement dan constraint, bukan dari library favorit.
- Gunakan nama variabel, endpoint, dan tabel yang konsisten.
- Tambahkan test untuk happy path, edge case, dan failure case.
- Jangan menyimpan secret di source code.
- Catat keputusan penting di README atau ADR sederhana.
- Gunakan logging yang membantu debugging tanpa membocorkan data sensitif.
- Review performa query dan struktur data sebelum traffic membesar.

## Common Mistakes

Kesalahan yang sering dilakukan beginner adalah membuat solusi yang hanya bekerja untuk contoh kecil. Misalnya, nested loop tidak terasa lambat saat data hanya 10 baris, tetapi bisa menghancurkan latency saat data menjadi 100.000 baris. Kesalahan lain adalah mencampur validasi, business logic, dan akses database dalam satu fungsi besar sehingga sulit dites dan sulit diubah.

Kesalahan lain yang sering muncul:

- Mengabaikan edge case karena demo terlihat berhasil.
- Menggunakan status code HTTP yang tidak sesuai.
- Membiarkan endpoint admin tanpa authorization.
- Membuat query berulang dalam loop tanpa sadar.
- Menganggap semua error berasal dari frontend.
- Tidak menulis migration atau seed data yang idempotent.

## Fun Fact

Banyak konsep modern software engineering sebenarnya lahir dari masalah sederhana yang tumbuh besar. Queue muncul karena tidak semua pekerjaan harus selesai saat itu juga. Cache muncul karena membaca sumber data utama terus-menerus terlalu mahal. Load balancer muncul karena satu server tidak selamanya cukup. Dengan memahami asal masalahnya, kamu akan lebih mudah memilih teknologi yang tepat.

## Interview Tips

Saat interview, jangan langsung melompat ke jawaban final. Jelaskan asumsi, pilihan, dan trade-off. Interviewer biasanya ingin melihat cara berpikir. Untuk topik ini, jawaban yang kuat biasanya memuat:

1. Definisi singkat yang tepat.
2. Contoh real-world.
3. Edge case atau failure mode.
4. Trade-off solusi.
5. Cara menguji atau mengukur keberhasilan.

## Latihan Mandiri

Coba ambil fitur sederhana dari aplikasi Yomu, misalnya membaca materi dan mengerjakan quiz. Petakan input, proses, output, data yang disimpan, kemungkinan error, dan risiko keamanan. Setelah itu, tulis satu perbaikan kecil yang membuat fitur tersebut lebih production-ready. Latihan seperti ini akan membangun intuisi engineering yang jauh lebih kuat daripada sekadar membaca definisi.
', 'intermediate', 15, 20),
        ('ACID Transactions dan Konsistensi Data', 'Materi ini menjelaskan atomicity, consistency, isolation, durability, race condition, dan transaksi pada aplikasi nyata.', '# ACID Transactions dan Konsistensi Data

## Ringkasan

Materi ini menjelaskan atomicity, consistency, isolation, durability, race condition, dan transaksi pada aplikasi nyata. Materi ini dirancang seperti modul bootcamp: dimulai dari intuisi, dilanjutkan dengan model mental, lalu ditutup dengan praktik industri dan tips interview. Fokus utamanya bukan menghafal istilah, melainkan memahami cara berpikir yang bisa dipakai saat membangun aplikasi nyata, membaca kode orang lain, melakukan debugging, dan menjelaskan keputusan teknis secara profesional.

## Kenapa Topik Ini Penting

Dalam software engineering, keputusan kecil sering punya dampak besar. Memilih struktur data, menentukan status code, menaruh validasi di layer yang tepat, atau memutuskan kapan memakai cache dapat memengaruhi performa, keamanan, dan pengalaman pengguna. Topik ini penting karena muncul berulang kali di proyek kampus, magang, pekerjaan full-time, dan interview software engineer.

Analogi sederhananya: membangun software mirip mengelola dapur restoran. Menu adalah fitur, pelanggan adalah user, database adalah gudang bahan, dan pipeline deployment adalah jalur penyajian. Restoran kecil bisa berjalan dengan satu koki dan satu catatan pesanan, tetapi restoran besar butuh alur kerja, pembagian peran, quality control, dan monitoring. Software juga begitu: semakin banyak user, semakin penting desain yang rapi.

## Konsep Utama

Kata kunci yang perlu kamu kuasai: **atomicity, consistency, isolation, durability, race condition**.

Beberapa prinsip yang selalu berguna:

- Pahami masalah sebelum memilih teknologi.
- Ukur bottleneck dengan data, bukan perasaan.
- Buat solusi paling sederhana yang masih memenuhi kebutuhan.
- Dokumentasikan asumsi penting agar tim lain tidak menebak-nebak.
- Pisahkan konsep inti dari detail implementasi.

| Area | Pertanyaan Penting | Dampak |
|---|---|---|
| Correctness | Apakah hasilnya benar untuk edge case? | Mengurangi bug logic |
| Performance | Bagaimana perilaku saat data membesar? | Menjaga latency |
| Maintainability | Apakah engineer lain mudah memahami kode? | Mempercepat perubahan |
| Security | Apakah data dan akses terlindungi? | Mengurangi risiko production |

## Penjelasan Detail

Bayangkan kamu menerima requirement baru dari product manager. Requirement itu biasanya terdengar sederhana, misalnya "tampilkan daftar materi yang relevan untuk user". Namun di balik kalimat singkat itu ada banyak keputusan: data apa yang dibaca, bagaimana urutannya, bagaimana jika database lambat, bagaimana jika user belum login, dan bagaimana hasilnya diuji. Engineer yang matang akan memecah requirement menjadi beberapa bagian kecil, mengidentifikasi risiko, lalu memilih pendekatan yang bisa diverifikasi.

Pada topik ini, pola berpikir yang paling penting adalah melihat hubungan antara input, proses, dan output. Input bisa berupa request HTTP, data dari database, event dari message broker, atau konfigurasi environment. Proses bisa berupa validasi, transformasi, query, perhitungan, atau komunikasi ke service lain. Output bisa berupa response JSON, record baru, log audit, atau event lanjutan. Jika salah satu bagian tidak jelas, debugging akan menjadi lebih sulit.

Dalam praktik sehari-hari, jangan hanya bertanya "apakah kode ini jalan?". Tanyakan juga:

1. Apa yang terjadi jika input kosong, duplikat, terlalu besar, atau tidak valid?
2. Apakah solusi ini masih masuk akal ketika jumlah data naik 100 kali lipat?
3. Apakah error message cukup membantu tanpa membocorkan informasi sensitif?
4. Apakah perubahan ini mudah dites secara otomatis?
5. Apakah ada asumsi yang perlu ditulis di dokumentasi?

## Contoh Implementasi

Contoh berikut bukan template final, tetapi gambaran cara menyusun ide secara eksplisit:

```text
@Transactional
public void submitQuiz(...) {
  saveAttempt();
  calculateScore();
}
```

Perhatikan bahwa contoh tersebut menonjolkan struktur berpikir, bukan sekadar sintaks. Sintaks bisa berbeda antara Java, TypeScript, Python, atau SQL, tetapi prinsipnya tetap sama: buat data mengalir lewat tahap yang jelas, kurangi coupling, dan pastikan kegagalan dapat diamati.

## Use Case Industri

Contoh industri: checkout e-commerce harus mengurangi stok, membuat order, dan mencatat pembayaran dalam alur yang konsisten. Kasus seperti ini umum terjadi karena sistem production memiliki batasan nyata: latency, biaya cloud, reliabilitas, keamanan, dan koordinasi antar tim. Solusi yang terlihat bagus di demo lokal belum tentu cukup untuk production jika tidak mempertimbangkan volume data, konkurensi, dan failure mode.

Dalam tim profesional, keputusan teknis biasanya perlu dijelaskan dalam bentuk trade-off. Misalnya, memakai cache membuat response lebih cepat, tetapi menambah risiko stale data. Memecah service membuat deployment lebih independen, tetapi menambah kebutuhan observability dan network reliability. Menggunakan JWT membuat service stateless, tetapi perlu validasi signature dan expiry yang benar.

## Studi Kasus Terarah

Misalkan Yomu ingin menampilkan materi belajar yang relevan untuk mahasiswa yang sedang mempersiapkan interview. Requirement awalnya terdengar sederhana: user membuka halaman, melihat daftar bacaan, memilih materi, lalu mengerjakan quiz. Namun kalau fitur ini dipakai ribuan mahasiswa, ada beberapa pertanyaan desain yang harus dijawab. Apakah daftar bacaan selalu diambil dari database? Apakah setiap request perlu menghitung progress quiz dari awal? Apakah response untuk learner boleh mengandung jawaban benar? Apakah admin boleh mengubah quiz yang sudah pernah dikerjakan banyak user?

Dengan sudut pandang ACID Transactions dan Konsistensi Data, kamu bisa membuat keputusan yang lebih tajam. Pertama, pisahkan data yang bersifat publik, data yang personal untuk user, dan data yang hanya boleh dilihat admin. Kedua, tentukan operasi mana yang harus konsisten kuat dan mana yang boleh eventually consistent. Ketiga, siapkan test untuk memastikan perubahan schema, perubahan kontrak API, dan perubahan business rule tidak merusak pengalaman belajar.

Pendekatan yang matang biasanya menghasilkan desain seperti ini:

- Endpoint learner hanya mengembalikan informasi yang aman untuk learner.
- Endpoint admin memiliki authorization dan audit log.
- Query yang sering dipakai diberi index atau cache jika benar-benar terbukti bottleneck.
- Seed data dibuat idempotent agar environment lokal, staging, dan demo bisa diisi ulang tanpa duplikasi.
- Error response dibuat konsisten supaya frontend bisa menampilkan pesan yang jelas.

## Production Readiness Checklist

Sebelum sebuah fitur dianggap siap production, engineer perlu mengecek lebih dari sekadar "berhasil dijalankan". Gunakan checklist berikut sebagai kebiasaan:

1. **Correctness:** semua aturan bisnis utama punya test otomatis.
2. **Observability:** log cukup untuk menelusuri request bermasalah.
3. **Security:** endpoint sensitif terlindungi role, token, atau gateway policy.
4. **Performance:** query utama dan struktur data sudah dipikirkan untuk pertumbuhan data.
5. **Resilience:** error dari dependency eksternal tidak membuat seluruh aplikasi gagal tanpa pesan.
6. **Maintainability:** kode mengikuti batas layer yang jelas dan tidak mencampur terlalu banyak tanggung jawab.

Checklist ini bukan birokrasi. Ia membantu tim menghindari bug yang biasanya baru terlihat saat demo besar, traffic naik, atau ada perubahan requirement mendadak.

## Best Practices

- Mulai dari requirement dan constraint, bukan dari library favorit.
- Gunakan nama variabel, endpoint, dan tabel yang konsisten.
- Tambahkan test untuk happy path, edge case, dan failure case.
- Jangan menyimpan secret di source code.
- Catat keputusan penting di README atau ADR sederhana.
- Gunakan logging yang membantu debugging tanpa membocorkan data sensitif.
- Review performa query dan struktur data sebelum traffic membesar.

## Common Mistakes

Kesalahan yang sering dilakukan beginner adalah membuat solusi yang hanya bekerja untuk contoh kecil. Misalnya, nested loop tidak terasa lambat saat data hanya 10 baris, tetapi bisa menghancurkan latency saat data menjadi 100.000 baris. Kesalahan lain adalah mencampur validasi, business logic, dan akses database dalam satu fungsi besar sehingga sulit dites dan sulit diubah.

Kesalahan lain yang sering muncul:

- Mengabaikan edge case karena demo terlihat berhasil.
- Menggunakan status code HTTP yang tidak sesuai.
- Membiarkan endpoint admin tanpa authorization.
- Membuat query berulang dalam loop tanpa sadar.
- Menganggap semua error berasal dari frontend.
- Tidak menulis migration atau seed data yang idempotent.

## Fun Fact

Banyak konsep modern software engineering sebenarnya lahir dari masalah sederhana yang tumbuh besar. Queue muncul karena tidak semua pekerjaan harus selesai saat itu juga. Cache muncul karena membaca sumber data utama terus-menerus terlalu mahal. Load balancer muncul karena satu server tidak selamanya cukup. Dengan memahami asal masalahnya, kamu akan lebih mudah memilih teknologi yang tepat.

## Interview Tips

Saat interview, jangan langsung melompat ke jawaban final. Jelaskan asumsi, pilihan, dan trade-off. Interviewer biasanya ingin melihat cara berpikir. Untuk topik ini, jawaban yang kuat biasanya memuat:

1. Definisi singkat yang tepat.
2. Contoh real-world.
3. Edge case atau failure mode.
4. Trade-off solusi.
5. Cara menguji atau mengukur keberhasilan.

## Latihan Mandiri

Coba ambil fitur sederhana dari aplikasi Yomu, misalnya membaca materi dan mengerjakan quiz. Petakan input, proses, output, data yang disimpan, kemungkinan error, dan risiko keamanan. Setelah itu, tulis satu perbaikan kecil yang membuat fitur tersebut lebih production-ready. Latihan seperti ini akan membangun intuisi engineering yang jauh lebih kuat daripada sekadar membaca definisi.
', 'intermediate', 15, 20),
        ('REST API Design yang Konsisten dan Mudah Dipakai', 'Bahas resource naming, request/response contract, pagination, filtering, versioning, dan error response.', '# REST API Design yang Konsisten dan Mudah Dipakai

## Ringkasan

Bahas resource naming, request/response contract, pagination, filtering, versioning, dan error response. Materi ini dirancang seperti modul bootcamp: dimulai dari intuisi, dilanjutkan dengan model mental, lalu ditutup dengan praktik industri dan tips interview. Fokus utamanya bukan menghafal istilah, melainkan memahami cara berpikir yang bisa dipakai saat membangun aplikasi nyata, membaca kode orang lain, melakukan debugging, dan menjelaskan keputusan teknis secara profesional.

## Kenapa Topik Ini Penting

Dalam software engineering, keputusan kecil sering punya dampak besar. Memilih struktur data, menentukan status code, menaruh validasi di layer yang tepat, atau memutuskan kapan memakai cache dapat memengaruhi performa, keamanan, dan pengalaman pengguna. Topik ini penting karena muncul berulang kali di proyek kampus, magang, pekerjaan full-time, dan interview software engineer.

Analogi sederhananya: membangun software mirip mengelola dapur restoran. Menu adalah fitur, pelanggan adalah user, database adalah gudang bahan, dan pipeline deployment adalah jalur penyajian. Restoran kecil bisa berjalan dengan satu koki dan satu catatan pesanan, tetapi restoran besar butuh alur kerja, pembagian peran, quality control, dan monitoring. Software juga begitu: semakin banyak user, semakin penting desain yang rapi.

## Konsep Utama

Kata kunci yang perlu kamu kuasai: **resource, pagination, filtering, versioning, error response**.

Beberapa prinsip yang selalu berguna:

- Pahami masalah sebelum memilih teknologi.
- Ukur bottleneck dengan data, bukan perasaan.
- Buat solusi paling sederhana yang masih memenuhi kebutuhan.
- Dokumentasikan asumsi penting agar tim lain tidak menebak-nebak.
- Pisahkan konsep inti dari detail implementasi.

| Area | Pertanyaan Penting | Dampak |
|---|---|---|
| Correctness | Apakah hasilnya benar untuk edge case? | Mengurangi bug logic |
| Performance | Bagaimana perilaku saat data membesar? | Menjaga latency |
| Maintainability | Apakah engineer lain mudah memahami kode? | Mempercepat perubahan |
| Security | Apakah data dan akses terlindungi? | Mengurangi risiko production |

## Penjelasan Detail

Bayangkan kamu menerima requirement baru dari product manager. Requirement itu biasanya terdengar sederhana, misalnya "tampilkan daftar materi yang relevan untuk user". Namun di balik kalimat singkat itu ada banyak keputusan: data apa yang dibaca, bagaimana urutannya, bagaimana jika database lambat, bagaimana jika user belum login, dan bagaimana hasilnya diuji. Engineer yang matang akan memecah requirement menjadi beberapa bagian kecil, mengidentifikasi risiko, lalu memilih pendekatan yang bisa diverifikasi.

Pada topik ini, pola berpikir yang paling penting adalah melihat hubungan antara input, proses, dan output. Input bisa berupa request HTTP, data dari database, event dari message broker, atau konfigurasi environment. Proses bisa berupa validasi, transformasi, query, perhitungan, atau komunikasi ke service lain. Output bisa berupa response JSON, record baru, log audit, atau event lanjutan. Jika salah satu bagian tidak jelas, debugging akan menjadi lebih sulit.

Dalam praktik sehari-hari, jangan hanya bertanya "apakah kode ini jalan?". Tanyakan juga:

1. Apa yang terjadi jika input kosong, duplikat, terlalu besar, atau tidak valid?
2. Apakah solusi ini masih masuk akal ketika jumlah data naik 100 kali lipat?
3. Apakah error message cukup membantu tanpa membocorkan informasi sensitif?
4. Apakah perubahan ini mudah dites secara otomatis?
5. Apakah ada asumsi yang perlu ditulis di dokumentasi?

## Contoh Implementasi

Contoh berikut bukan template final, tetapi gambaran cara menyusun ide secara eksplisit:

```text
GET /api/readings?page=0&size=20
POST /api/readings
GET /api/readings/{id}
```

Perhatikan bahwa contoh tersebut menonjolkan struktur berpikir, bukan sekadar sintaks. Sintaks bisa berbeda antara Java, TypeScript, Python, atau SQL, tetapi prinsipnya tetap sama: buat data mengalir lewat tahap yang jelas, kurangi coupling, dan pastikan kegagalan dapat diamati.

## Use Case Industri

Contoh industri: mobile app dan web app memakai kontrak API yang sama agar fitur bisa dikembangkan paralel oleh tim berbeda. Kasus seperti ini umum terjadi karena sistem production memiliki batasan nyata: latency, biaya cloud, reliabilitas, keamanan, dan koordinasi antar tim. Solusi yang terlihat bagus di demo lokal belum tentu cukup untuk production jika tidak mempertimbangkan volume data, konkurensi, dan failure mode.

Dalam tim profesional, keputusan teknis biasanya perlu dijelaskan dalam bentuk trade-off. Misalnya, memakai cache membuat response lebih cepat, tetapi menambah risiko stale data. Memecah service membuat deployment lebih independen, tetapi menambah kebutuhan observability dan network reliability. Menggunakan JWT membuat service stateless, tetapi perlu validasi signature dan expiry yang benar.

## Studi Kasus Terarah

Misalkan Yomu ingin menampilkan materi belajar yang relevan untuk mahasiswa yang sedang mempersiapkan interview. Requirement awalnya terdengar sederhana: user membuka halaman, melihat daftar bacaan, memilih materi, lalu mengerjakan quiz. Namun kalau fitur ini dipakai ribuan mahasiswa, ada beberapa pertanyaan desain yang harus dijawab. Apakah daftar bacaan selalu diambil dari database? Apakah setiap request perlu menghitung progress quiz dari awal? Apakah response untuk learner boleh mengandung jawaban benar? Apakah admin boleh mengubah quiz yang sudah pernah dikerjakan banyak user?

Dengan sudut pandang REST API Design yang Konsisten dan Mudah Dipakai, kamu bisa membuat keputusan yang lebih tajam. Pertama, pisahkan data yang bersifat publik, data yang personal untuk user, dan data yang hanya boleh dilihat admin. Kedua, tentukan operasi mana yang harus konsisten kuat dan mana yang boleh eventually consistent. Ketiga, siapkan test untuk memastikan perubahan schema, perubahan kontrak API, dan perubahan business rule tidak merusak pengalaman belajar.

Pendekatan yang matang biasanya menghasilkan desain seperti ini:

- Endpoint learner hanya mengembalikan informasi yang aman untuk learner.
- Endpoint admin memiliki authorization dan audit log.
- Query yang sering dipakai diberi index atau cache jika benar-benar terbukti bottleneck.
- Seed data dibuat idempotent agar environment lokal, staging, dan demo bisa diisi ulang tanpa duplikasi.
- Error response dibuat konsisten supaya frontend bisa menampilkan pesan yang jelas.

## Production Readiness Checklist

Sebelum sebuah fitur dianggap siap production, engineer perlu mengecek lebih dari sekadar "berhasil dijalankan". Gunakan checklist berikut sebagai kebiasaan:

1. **Correctness:** semua aturan bisnis utama punya test otomatis.
2. **Observability:** log cukup untuk menelusuri request bermasalah.
3. **Security:** endpoint sensitif terlindungi role, token, atau gateway policy.
4. **Performance:** query utama dan struktur data sudah dipikirkan untuk pertumbuhan data.
5. **Resilience:** error dari dependency eksternal tidak membuat seluruh aplikasi gagal tanpa pesan.
6. **Maintainability:** kode mengikuti batas layer yang jelas dan tidak mencampur terlalu banyak tanggung jawab.

Checklist ini bukan birokrasi. Ia membantu tim menghindari bug yang biasanya baru terlihat saat demo besar, traffic naik, atau ada perubahan requirement mendadak.

## Best Practices

- Mulai dari requirement dan constraint, bukan dari library favorit.
- Gunakan nama variabel, endpoint, dan tabel yang konsisten.
- Tambahkan test untuk happy path, edge case, dan failure case.
- Jangan menyimpan secret di source code.
- Catat keputusan penting di README atau ADR sederhana.
- Gunakan logging yang membantu debugging tanpa membocorkan data sensitif.
- Review performa query dan struktur data sebelum traffic membesar.

## Common Mistakes

Kesalahan yang sering dilakukan beginner adalah membuat solusi yang hanya bekerja untuk contoh kecil. Misalnya, nested loop tidak terasa lambat saat data hanya 10 baris, tetapi bisa menghancurkan latency saat data menjadi 100.000 baris. Kesalahan lain adalah mencampur validasi, business logic, dan akses database dalam satu fungsi besar sehingga sulit dites dan sulit diubah.

Kesalahan lain yang sering muncul:

- Mengabaikan edge case karena demo terlihat berhasil.
- Menggunakan status code HTTP yang tidak sesuai.
- Membiarkan endpoint admin tanpa authorization.
- Membuat query berulang dalam loop tanpa sadar.
- Menganggap semua error berasal dari frontend.
- Tidak menulis migration atau seed data yang idempotent.

## Fun Fact

Banyak konsep modern software engineering sebenarnya lahir dari masalah sederhana yang tumbuh besar. Queue muncul karena tidak semua pekerjaan harus selesai saat itu juga. Cache muncul karena membaca sumber data utama terus-menerus terlalu mahal. Load balancer muncul karena satu server tidak selamanya cukup. Dengan memahami asal masalahnya, kamu akan lebih mudah memilih teknologi yang tepat.

## Interview Tips

Saat interview, jangan langsung melompat ke jawaban final. Jelaskan asumsi, pilihan, dan trade-off. Interviewer biasanya ingin melihat cara berpikir. Untuk topik ini, jawaban yang kuat biasanya memuat:

1. Definisi singkat yang tepat.
2. Contoh real-world.
3. Edge case atau failure mode.
4. Trade-off solusi.
5. Cara menguji atau mengukur keberhasilan.

## Latihan Mandiri

Coba ambil fitur sederhana dari aplikasi Yomu, misalnya membaca materi dan mengerjakan quiz. Petakan input, proses, output, data yang disimpan, kemungkinan error, dan risiko keamanan. Setelah itu, tulis satu perbaikan kecil yang membuat fitur tersebut lebih production-ready. Latihan seperti ini akan membangun intuisi engineering yang jauh lebih kuat daripada sekadar membaca definisi.
', 'intermediate', 15, 20),
        ('HTTP Methods and Status Codes untuk Engineer', 'Pelajari semantik GET, POST, PUT, PATCH, DELETE, idempotency, dan status code yang tepat.', '# HTTP Methods and Status Codes untuk Engineer

## Ringkasan

Pelajari semantik GET, POST, PUT, PATCH, DELETE, idempotency, dan status code yang tepat. Materi ini dirancang seperti modul bootcamp: dimulai dari intuisi, dilanjutkan dengan model mental, lalu ditutup dengan praktik industri dan tips interview. Fokus utamanya bukan menghafal istilah, melainkan memahami cara berpikir yang bisa dipakai saat membangun aplikasi nyata, membaca kode orang lain, melakukan debugging, dan menjelaskan keputusan teknis secara profesional.

## Kenapa Topik Ini Penting

Dalam software engineering, keputusan kecil sering punya dampak besar. Memilih struktur data, menentukan status code, menaruh validasi di layer yang tepat, atau memutuskan kapan memakai cache dapat memengaruhi performa, keamanan, dan pengalaman pengguna. Topik ini penting karena muncul berulang kali di proyek kampus, magang, pekerjaan full-time, dan interview software engineer.

Analogi sederhananya: membangun software mirip mengelola dapur restoran. Menu adalah fitur, pelanggan adalah user, database adalah gudang bahan, dan pipeline deployment adalah jalur penyajian. Restoran kecil bisa berjalan dengan satu koki dan satu catatan pesanan, tetapi restoran besar butuh alur kerja, pembagian peran, quality control, dan monitoring. Software juga begitu: semakin banyak user, semakin penting desain yang rapi.

## Konsep Utama

Kata kunci yang perlu kamu kuasai: **GET, POST, PUT, PATCH, DELETE, idempotent**.

Beberapa prinsip yang selalu berguna:

- Pahami masalah sebelum memilih teknologi.
- Ukur bottleneck dengan data, bukan perasaan.
- Buat solusi paling sederhana yang masih memenuhi kebutuhan.
- Dokumentasikan asumsi penting agar tim lain tidak menebak-nebak.
- Pisahkan konsep inti dari detail implementasi.

| Area | Pertanyaan Penting | Dampak |
|---|---|---|
| Correctness | Apakah hasilnya benar untuk edge case? | Mengurangi bug logic |
| Performance | Bagaimana perilaku saat data membesar? | Menjaga latency |
| Maintainability | Apakah engineer lain mudah memahami kode? | Mempercepat perubahan |
| Security | Apakah data dan akses terlindungi? | Mengurangi risiko production |

## Penjelasan Detail

Bayangkan kamu menerima requirement baru dari product manager. Requirement itu biasanya terdengar sederhana, misalnya "tampilkan daftar materi yang relevan untuk user". Namun di balik kalimat singkat itu ada banyak keputusan: data apa yang dibaca, bagaimana urutannya, bagaimana jika database lambat, bagaimana jika user belum login, dan bagaimana hasilnya diuji. Engineer yang matang akan memecah requirement menjadi beberapa bagian kecil, mengidentifikasi risiko, lalu memilih pendekatan yang bisa diverifikasi.

Pada topik ini, pola berpikir yang paling penting adalah melihat hubungan antara input, proses, dan output. Input bisa berupa request HTTP, data dari database, event dari message broker, atau konfigurasi environment. Proses bisa berupa validasi, transformasi, query, perhitungan, atau komunikasi ke service lain. Output bisa berupa response JSON, record baru, log audit, atau event lanjutan. Jika salah satu bagian tidak jelas, debugging akan menjadi lebih sulit.

Dalam praktik sehari-hari, jangan hanya bertanya "apakah kode ini jalan?". Tanyakan juga:

1. Apa yang terjadi jika input kosong, duplikat, terlalu besar, atau tidak valid?
2. Apakah solusi ini masih masuk akal ketika jumlah data naik 100 kali lipat?
3. Apakah error message cukup membantu tanpa membocorkan informasi sensitif?
4. Apakah perubahan ini mudah dites secara otomatis?
5. Apakah ada asumsi yang perlu ditulis di dokumentasi?

## Contoh Implementasi

Contoh berikut bukan template final, tetapi gambaran cara menyusun ide secara eksplisit:

```text
return ResponseEntity.status(HttpStatus.CREATED).body(response);
```

Perhatikan bahwa contoh tersebut menonjolkan struktur berpikir, bukan sekadar sintaks. Sintaks bisa berbeda antara Java, TypeScript, Python, atau SQL, tetapi prinsipnya tetap sama: buat data mengalir lewat tahap yang jelas, kurangi coupling, dan pastikan kegagalan dapat diamati.

## Use Case Industri

Contoh industri: API pembayaran harus membedakan request yang aman diulang dan request yang dapat membuat transaksi baru. Kasus seperti ini umum terjadi karena sistem production memiliki batasan nyata: latency, biaya cloud, reliabilitas, keamanan, dan koordinasi antar tim. Solusi yang terlihat bagus di demo lokal belum tentu cukup untuk production jika tidak mempertimbangkan volume data, konkurensi, dan failure mode.

Dalam tim profesional, keputusan teknis biasanya perlu dijelaskan dalam bentuk trade-off. Misalnya, memakai cache membuat response lebih cepat, tetapi menambah risiko stale data. Memecah service membuat deployment lebih independen, tetapi menambah kebutuhan observability dan network reliability. Menggunakan JWT membuat service stateless, tetapi perlu validasi signature dan expiry yang benar.

## Studi Kasus Terarah

Misalkan Yomu ingin menampilkan materi belajar yang relevan untuk mahasiswa yang sedang mempersiapkan interview. Requirement awalnya terdengar sederhana: user membuka halaman, melihat daftar bacaan, memilih materi, lalu mengerjakan quiz. Namun kalau fitur ini dipakai ribuan mahasiswa, ada beberapa pertanyaan desain yang harus dijawab. Apakah daftar bacaan selalu diambil dari database? Apakah setiap request perlu menghitung progress quiz dari awal? Apakah response untuk learner boleh mengandung jawaban benar? Apakah admin boleh mengubah quiz yang sudah pernah dikerjakan banyak user?

Dengan sudut pandang HTTP Methods and Status Codes untuk Engineer, kamu bisa membuat keputusan yang lebih tajam. Pertama, pisahkan data yang bersifat publik, data yang personal untuk user, dan data yang hanya boleh dilihat admin. Kedua, tentukan operasi mana yang harus konsisten kuat dan mana yang boleh eventually consistent. Ketiga, siapkan test untuk memastikan perubahan schema, perubahan kontrak API, dan perubahan business rule tidak merusak pengalaman belajar.

Pendekatan yang matang biasanya menghasilkan desain seperti ini:

- Endpoint learner hanya mengembalikan informasi yang aman untuk learner.
- Endpoint admin memiliki authorization dan audit log.
- Query yang sering dipakai diberi index atau cache jika benar-benar terbukti bottleneck.
- Seed data dibuat idempotent agar environment lokal, staging, dan demo bisa diisi ulang tanpa duplikasi.
- Error response dibuat konsisten supaya frontend bisa menampilkan pesan yang jelas.

## Production Readiness Checklist

Sebelum sebuah fitur dianggap siap production, engineer perlu mengecek lebih dari sekadar "berhasil dijalankan". Gunakan checklist berikut sebagai kebiasaan:

1. **Correctness:** semua aturan bisnis utama punya test otomatis.
2. **Observability:** log cukup untuk menelusuri request bermasalah.
3. **Security:** endpoint sensitif terlindungi role, token, atau gateway policy.
4. **Performance:** query utama dan struktur data sudah dipikirkan untuk pertumbuhan data.
5. **Resilience:** error dari dependency eksternal tidak membuat seluruh aplikasi gagal tanpa pesan.
6. **Maintainability:** kode mengikuti batas layer yang jelas dan tidak mencampur terlalu banyak tanggung jawab.

Checklist ini bukan birokrasi. Ia membantu tim menghindari bug yang biasanya baru terlihat saat demo besar, traffic naik, atau ada perubahan requirement mendadak.

## Best Practices

- Mulai dari requirement dan constraint, bukan dari library favorit.
- Gunakan nama variabel, endpoint, dan tabel yang konsisten.
- Tambahkan test untuk happy path, edge case, dan failure case.
- Jangan menyimpan secret di source code.
- Catat keputusan penting di README atau ADR sederhana.
- Gunakan logging yang membantu debugging tanpa membocorkan data sensitif.
- Review performa query dan struktur data sebelum traffic membesar.

## Common Mistakes

Kesalahan yang sering dilakukan beginner adalah membuat solusi yang hanya bekerja untuk contoh kecil. Misalnya, nested loop tidak terasa lambat saat data hanya 10 baris, tetapi bisa menghancurkan latency saat data menjadi 100.000 baris. Kesalahan lain adalah mencampur validasi, business logic, dan akses database dalam satu fungsi besar sehingga sulit dites dan sulit diubah.

Kesalahan lain yang sering muncul:

- Mengabaikan edge case karena demo terlihat berhasil.
- Menggunakan status code HTTP yang tidak sesuai.
- Membiarkan endpoint admin tanpa authorization.
- Membuat query berulang dalam loop tanpa sadar.
- Menganggap semua error berasal dari frontend.
- Tidak menulis migration atau seed data yang idempotent.

## Fun Fact

Banyak konsep modern software engineering sebenarnya lahir dari masalah sederhana yang tumbuh besar. Queue muncul karena tidak semua pekerjaan harus selesai saat itu juga. Cache muncul karena membaca sumber data utama terus-menerus terlalu mahal. Load balancer muncul karena satu server tidak selamanya cukup. Dengan memahami asal masalahnya, kamu akan lebih mudah memilih teknologi yang tepat.

## Interview Tips

Saat interview, jangan langsung melompat ke jawaban final. Jelaskan asumsi, pilihan, dan trade-off. Interviewer biasanya ingin melihat cara berpikir. Untuk topik ini, jawaban yang kuat biasanya memuat:

1. Definisi singkat yang tepat.
2. Contoh real-world.
3. Edge case atau failure mode.
4. Trade-off solusi.
5. Cara menguji atau mengukur keberhasilan.

## Latihan Mandiri

Coba ambil fitur sederhana dari aplikasi Yomu, misalnya membaca materi dan mengerjakan quiz. Petakan input, proses, output, data yang disimpan, kemungkinan error, dan risiko keamanan. Setelah itu, tulis satu perbaikan kecil yang membuat fitur tersebut lebih production-ready. Latihan seperti ini akan membangun intuisi engineering yang jauh lebih kuat daripada sekadar membaca definisi.
', 'beginner', 10, 10),
        ('Authentication vs Authorization di Aplikasi Web', 'Bedakan siapa pengguna, apa hak aksesnya, dan bagaimana role atau permission memengaruhi endpoint.', '# Authentication vs Authorization di Aplikasi Web

## Ringkasan

Bedakan siapa pengguna, apa hak aksesnya, dan bagaimana role atau permission memengaruhi endpoint. Materi ini dirancang seperti modul bootcamp: dimulai dari intuisi, dilanjutkan dengan model mental, lalu ditutup dengan praktik industri dan tips interview. Fokus utamanya bukan menghafal istilah, melainkan memahami cara berpikir yang bisa dipakai saat membangun aplikasi nyata, membaca kode orang lain, melakukan debugging, dan menjelaskan keputusan teknis secara profesional.

## Kenapa Topik Ini Penting

Dalam software engineering, keputusan kecil sering punya dampak besar. Memilih struktur data, menentukan status code, menaruh validasi di layer yang tepat, atau memutuskan kapan memakai cache dapat memengaruhi performa, keamanan, dan pengalaman pengguna. Topik ini penting karena muncul berulang kali di proyek kampus, magang, pekerjaan full-time, dan interview software engineer.

Analogi sederhananya: membangun software mirip mengelola dapur restoran. Menu adalah fitur, pelanggan adalah user, database adalah gudang bahan, dan pipeline deployment adalah jalur penyajian. Restoran kecil bisa berjalan dengan satu koki dan satu catatan pesanan, tetapi restoran besar butuh alur kerja, pembagian peran, quality control, dan monitoring. Software juga begitu: semakin banyak user, semakin penting desain yang rapi.

## Konsep Utama

Kata kunci yang perlu kamu kuasai: **authentication, authorization, role, permission, least privilege**.

Beberapa prinsip yang selalu berguna:

- Pahami masalah sebelum memilih teknologi.
- Ukur bottleneck dengan data, bukan perasaan.
- Buat solusi paling sederhana yang masih memenuhi kebutuhan.
- Dokumentasikan asumsi penting agar tim lain tidak menebak-nebak.
- Pisahkan konsep inti dari detail implementasi.

| Area | Pertanyaan Penting | Dampak |
|---|---|---|
| Correctness | Apakah hasilnya benar untuk edge case? | Mengurangi bug logic |
| Performance | Bagaimana perilaku saat data membesar? | Menjaga latency |
| Maintainability | Apakah engineer lain mudah memahami kode? | Mempercepat perubahan |
| Security | Apakah data dan akses terlindungi? | Mengurangi risiko production |

## Penjelasan Detail

Bayangkan kamu menerima requirement baru dari product manager. Requirement itu biasanya terdengar sederhana, misalnya "tampilkan daftar materi yang relevan untuk user". Namun di balik kalimat singkat itu ada banyak keputusan: data apa yang dibaca, bagaimana urutannya, bagaimana jika database lambat, bagaimana jika user belum login, dan bagaimana hasilnya diuji. Engineer yang matang akan memecah requirement menjadi beberapa bagian kecil, mengidentifikasi risiko, lalu memilih pendekatan yang bisa diverifikasi.

Pada topik ini, pola berpikir yang paling penting adalah melihat hubungan antara input, proses, dan output. Input bisa berupa request HTTP, data dari database, event dari message broker, atau konfigurasi environment. Proses bisa berupa validasi, transformasi, query, perhitungan, atau komunikasi ke service lain. Output bisa berupa response JSON, record baru, log audit, atau event lanjutan. Jika salah satu bagian tidak jelas, debugging akan menjadi lebih sulit.

Dalam praktik sehari-hari, jangan hanya bertanya "apakah kode ini jalan?". Tanyakan juga:

1. Apa yang terjadi jika input kosong, duplikat, terlalu besar, atau tidak valid?
2. Apakah solusi ini masih masuk akal ketika jumlah data naik 100 kali lipat?
3. Apakah error message cukup membantu tanpa membocorkan informasi sensitif?
4. Apakah perubahan ini mudah dites secara otomatis?
5. Apakah ada asumsi yang perlu ditulis di dokumentasi?

## Contoh Implementasi

Contoh berikut bukan template final, tetapi gambaran cara menyusun ide secara eksplisit:

```text
@PreAuthorize("hasRole(''ADMIN'')")
public ReadingResponse create(...) { ... }
```

Perhatikan bahwa contoh tersebut menonjolkan struktur berpikir, bukan sekadar sintaks. Sintaks bisa berbeda antara Java, TypeScript, Python, atau SQL, tetapi prinsipnya tetap sama: buat data mengalir lewat tahap yang jelas, kurangi coupling, dan pastikan kegagalan dapat diamati.

## Use Case Industri

Contoh industri: admin panel hanya boleh diakses staf tertentu walau semua user sama-sama berhasil login. Kasus seperti ini umum terjadi karena sistem production memiliki batasan nyata: latency, biaya cloud, reliabilitas, keamanan, dan koordinasi antar tim. Solusi yang terlihat bagus di demo lokal belum tentu cukup untuk production jika tidak mempertimbangkan volume data, konkurensi, dan failure mode.

Dalam tim profesional, keputusan teknis biasanya perlu dijelaskan dalam bentuk trade-off. Misalnya, memakai cache membuat response lebih cepat, tetapi menambah risiko stale data. Memecah service membuat deployment lebih independen, tetapi menambah kebutuhan observability dan network reliability. Menggunakan JWT membuat service stateless, tetapi perlu validasi signature dan expiry yang benar.

## Studi Kasus Terarah

Misalkan Yomu ingin menampilkan materi belajar yang relevan untuk mahasiswa yang sedang mempersiapkan interview. Requirement awalnya terdengar sederhana: user membuka halaman, melihat daftar bacaan, memilih materi, lalu mengerjakan quiz. Namun kalau fitur ini dipakai ribuan mahasiswa, ada beberapa pertanyaan desain yang harus dijawab. Apakah daftar bacaan selalu diambil dari database? Apakah setiap request perlu menghitung progress quiz dari awal? Apakah response untuk learner boleh mengandung jawaban benar? Apakah admin boleh mengubah quiz yang sudah pernah dikerjakan banyak user?

Dengan sudut pandang Authentication vs Authorization di Aplikasi Web, kamu bisa membuat keputusan yang lebih tajam. Pertama, pisahkan data yang bersifat publik, data yang personal untuk user, dan data yang hanya boleh dilihat admin. Kedua, tentukan operasi mana yang harus konsisten kuat dan mana yang boleh eventually consistent. Ketiga, siapkan test untuk memastikan perubahan schema, perubahan kontrak API, dan perubahan business rule tidak merusak pengalaman belajar.

Pendekatan yang matang biasanya menghasilkan desain seperti ini:

- Endpoint learner hanya mengembalikan informasi yang aman untuk learner.
- Endpoint admin memiliki authorization dan audit log.
- Query yang sering dipakai diberi index atau cache jika benar-benar terbukti bottleneck.
- Seed data dibuat idempotent agar environment lokal, staging, dan demo bisa diisi ulang tanpa duplikasi.
- Error response dibuat konsisten supaya frontend bisa menampilkan pesan yang jelas.

## Production Readiness Checklist

Sebelum sebuah fitur dianggap siap production, engineer perlu mengecek lebih dari sekadar "berhasil dijalankan". Gunakan checklist berikut sebagai kebiasaan:

1. **Correctness:** semua aturan bisnis utama punya test otomatis.
2. **Observability:** log cukup untuk menelusuri request bermasalah.
3. **Security:** endpoint sensitif terlindungi role, token, atau gateway policy.
4. **Performance:** query utama dan struktur data sudah dipikirkan untuk pertumbuhan data.
5. **Resilience:** error dari dependency eksternal tidak membuat seluruh aplikasi gagal tanpa pesan.
6. **Maintainability:** kode mengikuti batas layer yang jelas dan tidak mencampur terlalu banyak tanggung jawab.

Checklist ini bukan birokrasi. Ia membantu tim menghindari bug yang biasanya baru terlihat saat demo besar, traffic naik, atau ada perubahan requirement mendadak.

## Best Practices

- Mulai dari requirement dan constraint, bukan dari library favorit.
- Gunakan nama variabel, endpoint, dan tabel yang konsisten.
- Tambahkan test untuk happy path, edge case, dan failure case.
- Jangan menyimpan secret di source code.
- Catat keputusan penting di README atau ADR sederhana.
- Gunakan logging yang membantu debugging tanpa membocorkan data sensitif.
- Review performa query dan struktur data sebelum traffic membesar.

## Common Mistakes

Kesalahan yang sering dilakukan beginner adalah membuat solusi yang hanya bekerja untuk contoh kecil. Misalnya, nested loop tidak terasa lambat saat data hanya 10 baris, tetapi bisa menghancurkan latency saat data menjadi 100.000 baris. Kesalahan lain adalah mencampur validasi, business logic, dan akses database dalam satu fungsi besar sehingga sulit dites dan sulit diubah.

Kesalahan lain yang sering muncul:

- Mengabaikan edge case karena demo terlihat berhasil.
- Menggunakan status code HTTP yang tidak sesuai.
- Membiarkan endpoint admin tanpa authorization.
- Membuat query berulang dalam loop tanpa sadar.
- Menganggap semua error berasal dari frontend.
- Tidak menulis migration atau seed data yang idempotent.

## Fun Fact

Banyak konsep modern software engineering sebenarnya lahir dari masalah sederhana yang tumbuh besar. Queue muncul karena tidak semua pekerjaan harus selesai saat itu juga. Cache muncul karena membaca sumber data utama terus-menerus terlalu mahal. Load balancer muncul karena satu server tidak selamanya cukup. Dengan memahami asal masalahnya, kamu akan lebih mudah memilih teknologi yang tepat.

## Interview Tips

Saat interview, jangan langsung melompat ke jawaban final. Jelaskan asumsi, pilihan, dan trade-off. Interviewer biasanya ingin melihat cara berpikir. Untuk topik ini, jawaban yang kuat biasanya memuat:

1. Definisi singkat yang tepat.
2. Contoh real-world.
3. Edge case atau failure mode.
4. Trade-off solusi.
5. Cara menguji atau mengukur keberhasilan.

## Latihan Mandiri

Coba ambil fitur sederhana dari aplikasi Yomu, misalnya membaca materi dan mengerjakan quiz. Petakan input, proses, output, data yang disimpan, kemungkinan error, dan risiko keamanan. Setelah itu, tulis satu perbaikan kecil yang membuat fitur tersebut lebih production-ready. Latihan seperti ini akan membangun intuisi engineering yang jauh lebih kuat daripada sekadar membaca definisi.
', 'beginner', 12, 10),
        ('JWT Authentication: Claim, Signature, dan Risiko Umum', 'Pahami struktur JWT, claim, signature, expiry, refresh token, dan best practice validasi token.', '# JWT Authentication: Claim, Signature, dan Risiko Umum

## Ringkasan

Pahami struktur JWT, claim, signature, expiry, refresh token, dan best practice validasi token. Materi ini dirancang seperti modul bootcamp: dimulai dari intuisi, dilanjutkan dengan model mental, lalu ditutup dengan praktik industri dan tips interview. Fokus utamanya bukan menghafal istilah, melainkan memahami cara berpikir yang bisa dipakai saat membangun aplikasi nyata, membaca kode orang lain, melakukan debugging, dan menjelaskan keputusan teknis secara profesional.

## Kenapa Topik Ini Penting

Dalam software engineering, keputusan kecil sering punya dampak besar. Memilih struktur data, menentukan status code, menaruh validasi di layer yang tepat, atau memutuskan kapan memakai cache dapat memengaruhi performa, keamanan, dan pengalaman pengguna. Topik ini penting karena muncul berulang kali di proyek kampus, magang, pekerjaan full-time, dan interview software engineer.

Analogi sederhananya: membangun software mirip mengelola dapur restoran. Menu adalah fitur, pelanggan adalah user, database adalah gudang bahan, dan pipeline deployment adalah jalur penyajian. Restoran kecil bisa berjalan dengan satu koki dan satu catatan pesanan, tetapi restoran besar butuh alur kerja, pembagian peran, quality control, dan monitoring. Software juga begitu: semakin banyak user, semakin penting desain yang rapi.

## Konsep Utama

Kata kunci yang perlu kamu kuasai: **JWT, claim, signature, expiry, refresh token**.

Beberapa prinsip yang selalu berguna:

- Pahami masalah sebelum memilih teknologi.
- Ukur bottleneck dengan data, bukan perasaan.
- Buat solusi paling sederhana yang masih memenuhi kebutuhan.
- Dokumentasikan asumsi penting agar tim lain tidak menebak-nebak.
- Pisahkan konsep inti dari detail implementasi.

| Area | Pertanyaan Penting | Dampak |
|---|---|---|
| Correctness | Apakah hasilnya benar untuk edge case? | Mengurangi bug logic |
| Performance | Bagaimana perilaku saat data membesar? | Menjaga latency |
| Maintainability | Apakah engineer lain mudah memahami kode? | Mempercepat perubahan |
| Security | Apakah data dan akses terlindungi? | Mengurangi risiko production |

## Penjelasan Detail

Bayangkan kamu menerima requirement baru dari product manager. Requirement itu biasanya terdengar sederhana, misalnya "tampilkan daftar materi yang relevan untuk user". Namun di balik kalimat singkat itu ada banyak keputusan: data apa yang dibaca, bagaimana urutannya, bagaimana jika database lambat, bagaimana jika user belum login, dan bagaimana hasilnya diuji. Engineer yang matang akan memecah requirement menjadi beberapa bagian kecil, mengidentifikasi risiko, lalu memilih pendekatan yang bisa diverifikasi.

Pada topik ini, pola berpikir yang paling penting adalah melihat hubungan antara input, proses, dan output. Input bisa berupa request HTTP, data dari database, event dari message broker, atau konfigurasi environment. Proses bisa berupa validasi, transformasi, query, perhitungan, atau komunikasi ke service lain. Output bisa berupa response JSON, record baru, log audit, atau event lanjutan. Jika salah satu bagian tidak jelas, debugging akan menjadi lebih sulit.

Dalam praktik sehari-hari, jangan hanya bertanya "apakah kode ini jalan?". Tanyakan juga:

1. Apa yang terjadi jika input kosong, duplikat, terlalu besar, atau tidak valid?
2. Apakah solusi ini masih masuk akal ketika jumlah data naik 100 kali lipat?
3. Apakah error message cukup membantu tanpa membocorkan informasi sensitif?
4. Apakah perubahan ini mudah dites secara otomatis?
5. Apakah ada asumsi yang perlu ditulis di dokumentasi?

## Contoh Implementasi

Contoh berikut bukan template final, tetapi gambaran cara menyusun ide secara eksplisit:

```text
Authorization: Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9...
```

Perhatikan bahwa contoh tersebut menonjolkan struktur berpikir, bukan sekadar sintaks. Sintaks bisa berbeda antara Java, TypeScript, Python, atau SQL, tetapi prinsipnya tetap sama: buat data mengalir lewat tahap yang jelas, kurangi coupling, dan pastikan kegagalan dapat diamati.

## Use Case Industri

Contoh industri: API Gateway memvalidasi token dari identity provider sebelum request diteruskan ke service internal. Kasus seperti ini umum terjadi karena sistem production memiliki batasan nyata: latency, biaya cloud, reliabilitas, keamanan, dan koordinasi antar tim. Solusi yang terlihat bagus di demo lokal belum tentu cukup untuk production jika tidak mempertimbangkan volume data, konkurensi, dan failure mode.

Dalam tim profesional, keputusan teknis biasanya perlu dijelaskan dalam bentuk trade-off. Misalnya, memakai cache membuat response lebih cepat, tetapi menambah risiko stale data. Memecah service membuat deployment lebih independen, tetapi menambah kebutuhan observability dan network reliability. Menggunakan JWT membuat service stateless, tetapi perlu validasi signature dan expiry yang benar.

## Studi Kasus Terarah

Misalkan Yomu ingin menampilkan materi belajar yang relevan untuk mahasiswa yang sedang mempersiapkan interview. Requirement awalnya terdengar sederhana: user membuka halaman, melihat daftar bacaan, memilih materi, lalu mengerjakan quiz. Namun kalau fitur ini dipakai ribuan mahasiswa, ada beberapa pertanyaan desain yang harus dijawab. Apakah daftar bacaan selalu diambil dari database? Apakah setiap request perlu menghitung progress quiz dari awal? Apakah response untuk learner boleh mengandung jawaban benar? Apakah admin boleh mengubah quiz yang sudah pernah dikerjakan banyak user?

Dengan sudut pandang JWT Authentication: Claim, Signature, dan Risiko Umum, kamu bisa membuat keputusan yang lebih tajam. Pertama, pisahkan data yang bersifat publik, data yang personal untuk user, dan data yang hanya boleh dilihat admin. Kedua, tentukan operasi mana yang harus konsisten kuat dan mana yang boleh eventually consistent. Ketiga, siapkan test untuk memastikan perubahan schema, perubahan kontrak API, dan perubahan business rule tidak merusak pengalaman belajar.

Pendekatan yang matang biasanya menghasilkan desain seperti ini:

- Endpoint learner hanya mengembalikan informasi yang aman untuk learner.
- Endpoint admin memiliki authorization dan audit log.
- Query yang sering dipakai diberi index atau cache jika benar-benar terbukti bottleneck.
- Seed data dibuat idempotent agar environment lokal, staging, dan demo bisa diisi ulang tanpa duplikasi.
- Error response dibuat konsisten supaya frontend bisa menampilkan pesan yang jelas.

## Production Readiness Checklist

Sebelum sebuah fitur dianggap siap production, engineer perlu mengecek lebih dari sekadar "berhasil dijalankan". Gunakan checklist berikut sebagai kebiasaan:

1. **Correctness:** semua aturan bisnis utama punya test otomatis.
2. **Observability:** log cukup untuk menelusuri request bermasalah.
3. **Security:** endpoint sensitif terlindungi role, token, atau gateway policy.
4. **Performance:** query utama dan struktur data sudah dipikirkan untuk pertumbuhan data.
5. **Resilience:** error dari dependency eksternal tidak membuat seluruh aplikasi gagal tanpa pesan.
6. **Maintainability:** kode mengikuti batas layer yang jelas dan tidak mencampur terlalu banyak tanggung jawab.

Checklist ini bukan birokrasi. Ia membantu tim menghindari bug yang biasanya baru terlihat saat demo besar, traffic naik, atau ada perubahan requirement mendadak.

## Best Practices

- Mulai dari requirement dan constraint, bukan dari library favorit.
- Gunakan nama variabel, endpoint, dan tabel yang konsisten.
- Tambahkan test untuk happy path, edge case, dan failure case.
- Jangan menyimpan secret di source code.
- Catat keputusan penting di README atau ADR sederhana.
- Gunakan logging yang membantu debugging tanpa membocorkan data sensitif.
- Review performa query dan struktur data sebelum traffic membesar.

## Common Mistakes

Kesalahan yang sering dilakukan beginner adalah membuat solusi yang hanya bekerja untuk contoh kecil. Misalnya, nested loop tidak terasa lambat saat data hanya 10 baris, tetapi bisa menghancurkan latency saat data menjadi 100.000 baris. Kesalahan lain adalah mencampur validasi, business logic, dan akses database dalam satu fungsi besar sehingga sulit dites dan sulit diubah.

Kesalahan lain yang sering muncul:

- Mengabaikan edge case karena demo terlihat berhasil.
- Menggunakan status code HTTP yang tidak sesuai.
- Membiarkan endpoint admin tanpa authorization.
- Membuat query berulang dalam loop tanpa sadar.
- Menganggap semua error berasal dari frontend.
- Tidak menulis migration atau seed data yang idempotent.

## Fun Fact

Banyak konsep modern software engineering sebenarnya lahir dari masalah sederhana yang tumbuh besar. Queue muncul karena tidak semua pekerjaan harus selesai saat itu juga. Cache muncul karena membaca sumber data utama terus-menerus terlalu mahal. Load balancer muncul karena satu server tidak selamanya cukup. Dengan memahami asal masalahnya, kamu akan lebih mudah memilih teknologi yang tepat.

## Interview Tips

Saat interview, jangan langsung melompat ke jawaban final. Jelaskan asumsi, pilihan, dan trade-off. Interviewer biasanya ingin melihat cara berpikir. Untuk topik ini, jawaban yang kuat biasanya memuat:

1. Definisi singkat yang tepat.
2. Contoh real-world.
3. Edge case atau failure mode.
4. Trade-off solusi.
5. Cara menguji atau mengukur keberhasilan.

## Latihan Mandiri

Coba ambil fitur sederhana dari aplikasi Yomu, misalnya membaca materi dan mengerjakan quiz. Petakan input, proses, output, data yang disimpan, kemungkinan error, dan risiko keamanan. Setelah itu, tulis satu perbaikan kecil yang membuat fitur tersebut lebih production-ready. Latihan seperti ini akan membangun intuisi engineering yang jauh lebih kuat daripada sekadar membaca definisi.
', 'intermediate', 15, 20),
        ('Client Server Architecture dan Kontrak Integrasi', 'Bahas batas tanggung jawab frontend-backend, API contract, CORS, latency, dan error handling.', '# Client Server Architecture dan Kontrak Integrasi

## Ringkasan

Bahas batas tanggung jawab frontend-backend, API contract, CORS, latency, dan error handling. Materi ini dirancang seperti modul bootcamp: dimulai dari intuisi, dilanjutkan dengan model mental, lalu ditutup dengan praktik industri dan tips interview. Fokus utamanya bukan menghafal istilah, melainkan memahami cara berpikir yang bisa dipakai saat membangun aplikasi nyata, membaca kode orang lain, melakukan debugging, dan menjelaskan keputusan teknis secara profesional.

## Kenapa Topik Ini Penting

Dalam software engineering, keputusan kecil sering punya dampak besar. Memilih struktur data, menentukan status code, menaruh validasi di layer yang tepat, atau memutuskan kapan memakai cache dapat memengaruhi performa, keamanan, dan pengalaman pengguna. Topik ini penting karena muncul berulang kali di proyek kampus, magang, pekerjaan full-time, dan interview software engineer.

Analogi sederhananya: membangun software mirip mengelola dapur restoran. Menu adalah fitur, pelanggan adalah user, database adalah gudang bahan, dan pipeline deployment adalah jalur penyajian. Restoran kecil bisa berjalan dengan satu koki dan satu catatan pesanan, tetapi restoran besar butuh alur kerja, pembagian peran, quality control, dan monitoring. Software juga begitu: semakin banyak user, semakin penting desain yang rapi.

## Konsep Utama

Kata kunci yang perlu kamu kuasai: **client, server, API contract, CORS, latency**.

Beberapa prinsip yang selalu berguna:

- Pahami masalah sebelum memilih teknologi.
- Ukur bottleneck dengan data, bukan perasaan.
- Buat solusi paling sederhana yang masih memenuhi kebutuhan.
- Dokumentasikan asumsi penting agar tim lain tidak menebak-nebak.
- Pisahkan konsep inti dari detail implementasi.

| Area | Pertanyaan Penting | Dampak |
|---|---|---|
| Correctness | Apakah hasilnya benar untuk edge case? | Mengurangi bug logic |
| Performance | Bagaimana perilaku saat data membesar? | Menjaga latency |
| Maintainability | Apakah engineer lain mudah memahami kode? | Mempercepat perubahan |
| Security | Apakah data dan akses terlindungi? | Mengurangi risiko production |

## Penjelasan Detail

Bayangkan kamu menerima requirement baru dari product manager. Requirement itu biasanya terdengar sederhana, misalnya "tampilkan daftar materi yang relevan untuk user". Namun di balik kalimat singkat itu ada banyak keputusan: data apa yang dibaca, bagaimana urutannya, bagaimana jika database lambat, bagaimana jika user belum login, dan bagaimana hasilnya diuji. Engineer yang matang akan memecah requirement menjadi beberapa bagian kecil, mengidentifikasi risiko, lalu memilih pendekatan yang bisa diverifikasi.

Pada topik ini, pola berpikir yang paling penting adalah melihat hubungan antara input, proses, dan output. Input bisa berupa request HTTP, data dari database, event dari message broker, atau konfigurasi environment. Proses bisa berupa validasi, transformasi, query, perhitungan, atau komunikasi ke service lain. Output bisa berupa response JSON, record baru, log audit, atau event lanjutan. Jika salah satu bagian tidak jelas, debugging akan menjadi lebih sulit.

Dalam praktik sehari-hari, jangan hanya bertanya "apakah kode ini jalan?". Tanyakan juga:

1. Apa yang terjadi jika input kosong, duplikat, terlalu besar, atau tidak valid?
2. Apakah solusi ini masih masuk akal ketika jumlah data naik 100 kali lipat?
3. Apakah error message cukup membantu tanpa membocorkan informasi sensitif?
4. Apakah perubahan ini mudah dites secara otomatis?
5. Apakah ada asumsi yang perlu ditulis di dokumentasi?

## Contoh Implementasi

Contoh berikut bukan template final, tetapi gambaran cara menyusun ide secara eksplisit:

```text
const API_BASE_URL = process.env.NEXT_PUBLIC_API_BASE_URL;
```

Perhatikan bahwa contoh tersebut menonjolkan struktur berpikir, bukan sekadar sintaks. Sintaks bisa berbeda antara Java, TypeScript, Python, atau SQL, tetapi prinsipnya tetap sama: buat data mengalir lewat tahap yang jelas, kurangi coupling, dan pastikan kegagalan dapat diamati.

## Use Case Industri

Contoh industri: frontend Next.js memakai environment variable base URL agar bisa berpindah antara lokal, staging, dan production. Kasus seperti ini umum terjadi karena sistem production memiliki batasan nyata: latency, biaya cloud, reliabilitas, keamanan, dan koordinasi antar tim. Solusi yang terlihat bagus di demo lokal belum tentu cukup untuk production jika tidak mempertimbangkan volume data, konkurensi, dan failure mode.

Dalam tim profesional, keputusan teknis biasanya perlu dijelaskan dalam bentuk trade-off. Misalnya, memakai cache membuat response lebih cepat, tetapi menambah risiko stale data. Memecah service membuat deployment lebih independen, tetapi menambah kebutuhan observability dan network reliability. Menggunakan JWT membuat service stateless, tetapi perlu validasi signature dan expiry yang benar.

## Studi Kasus Terarah

Misalkan Yomu ingin menampilkan materi belajar yang relevan untuk mahasiswa yang sedang mempersiapkan interview. Requirement awalnya terdengar sederhana: user membuka halaman, melihat daftar bacaan, memilih materi, lalu mengerjakan quiz. Namun kalau fitur ini dipakai ribuan mahasiswa, ada beberapa pertanyaan desain yang harus dijawab. Apakah daftar bacaan selalu diambil dari database? Apakah setiap request perlu menghitung progress quiz dari awal? Apakah response untuk learner boleh mengandung jawaban benar? Apakah admin boleh mengubah quiz yang sudah pernah dikerjakan banyak user?

Dengan sudut pandang Client Server Architecture dan Kontrak Integrasi, kamu bisa membuat keputusan yang lebih tajam. Pertama, pisahkan data yang bersifat publik, data yang personal untuk user, dan data yang hanya boleh dilihat admin. Kedua, tentukan operasi mana yang harus konsisten kuat dan mana yang boleh eventually consistent. Ketiga, siapkan test untuk memastikan perubahan schema, perubahan kontrak API, dan perubahan business rule tidak merusak pengalaman belajar.

Pendekatan yang matang biasanya menghasilkan desain seperti ini:

- Endpoint learner hanya mengembalikan informasi yang aman untuk learner.
- Endpoint admin memiliki authorization dan audit log.
- Query yang sering dipakai diberi index atau cache jika benar-benar terbukti bottleneck.
- Seed data dibuat idempotent agar environment lokal, staging, dan demo bisa diisi ulang tanpa duplikasi.
- Error response dibuat konsisten supaya frontend bisa menampilkan pesan yang jelas.

## Production Readiness Checklist

Sebelum sebuah fitur dianggap siap production, engineer perlu mengecek lebih dari sekadar "berhasil dijalankan". Gunakan checklist berikut sebagai kebiasaan:

1. **Correctness:** semua aturan bisnis utama punya test otomatis.
2. **Observability:** log cukup untuk menelusuri request bermasalah.
3. **Security:** endpoint sensitif terlindungi role, token, atau gateway policy.
4. **Performance:** query utama dan struktur data sudah dipikirkan untuk pertumbuhan data.
5. **Resilience:** error dari dependency eksternal tidak membuat seluruh aplikasi gagal tanpa pesan.
6. **Maintainability:** kode mengikuti batas layer yang jelas dan tidak mencampur terlalu banyak tanggung jawab.

Checklist ini bukan birokrasi. Ia membantu tim menghindari bug yang biasanya baru terlihat saat demo besar, traffic naik, atau ada perubahan requirement mendadak.

## Best Practices

- Mulai dari requirement dan constraint, bukan dari library favorit.
- Gunakan nama variabel, endpoint, dan tabel yang konsisten.
- Tambahkan test untuk happy path, edge case, dan failure case.
- Jangan menyimpan secret di source code.
- Catat keputusan penting di README atau ADR sederhana.
- Gunakan logging yang membantu debugging tanpa membocorkan data sensitif.
- Review performa query dan struktur data sebelum traffic membesar.

## Common Mistakes

Kesalahan yang sering dilakukan beginner adalah membuat solusi yang hanya bekerja untuk contoh kecil. Misalnya, nested loop tidak terasa lambat saat data hanya 10 baris, tetapi bisa menghancurkan latency saat data menjadi 100.000 baris. Kesalahan lain adalah mencampur validasi, business logic, dan akses database dalam satu fungsi besar sehingga sulit dites dan sulit diubah.

Kesalahan lain yang sering muncul:

- Mengabaikan edge case karena demo terlihat berhasil.
- Menggunakan status code HTTP yang tidak sesuai.
- Membiarkan endpoint admin tanpa authorization.
- Membuat query berulang dalam loop tanpa sadar.
- Menganggap semua error berasal dari frontend.
- Tidak menulis migration atau seed data yang idempotent.

## Fun Fact

Banyak konsep modern software engineering sebenarnya lahir dari masalah sederhana yang tumbuh besar. Queue muncul karena tidak semua pekerjaan harus selesai saat itu juga. Cache muncul karena membaca sumber data utama terus-menerus terlalu mahal. Load balancer muncul karena satu server tidak selamanya cukup. Dengan memahami asal masalahnya, kamu akan lebih mudah memilih teknologi yang tepat.

## Interview Tips

Saat interview, jangan langsung melompat ke jawaban final. Jelaskan asumsi, pilihan, dan trade-off. Interviewer biasanya ingin melihat cara berpikir. Untuk topik ini, jawaban yang kuat biasanya memuat:

1. Definisi singkat yang tepat.
2. Contoh real-world.
3. Edge case atau failure mode.
4. Trade-off solusi.
5. Cara menguji atau mengukur keberhasilan.

## Latihan Mandiri

Coba ambil fitur sederhana dari aplikasi Yomu, misalnya membaca materi dan mengerjakan quiz. Petakan input, proses, output, data yang disimpan, kemungkinan error, dan risiko keamanan. Setelah itu, tulis satu perbaikan kecil yang membuat fitur tersebut lebih production-ready. Latihan seperti ini akan membangun intuisi engineering yang jauh lebih kuat daripada sekadar membaca definisi.
', 'beginner', 12, 10),
        ('Monolith vs Microservices: Kapan Dipecah dan Kapan Tidak', 'Pelajari trade-off monolith dan microservices dari sisi deployment, ownership, database, observability, dan kompleksitas.', '# Monolith vs Microservices: Kapan Dipecah dan Kapan Tidak

## Ringkasan

Pelajari trade-off monolith dan microservices dari sisi deployment, ownership, database, observability, dan kompleksitas. Materi ini dirancang seperti modul bootcamp: dimulai dari intuisi, dilanjutkan dengan model mental, lalu ditutup dengan praktik industri dan tips interview. Fokus utamanya bukan menghafal istilah, melainkan memahami cara berpikir yang bisa dipakai saat membangun aplikasi nyata, membaca kode orang lain, melakukan debugging, dan menjelaskan keputusan teknis secara profesional.

## Kenapa Topik Ini Penting

Dalam software engineering, keputusan kecil sering punya dampak besar. Memilih struktur data, menentukan status code, menaruh validasi di layer yang tepat, atau memutuskan kapan memakai cache dapat memengaruhi performa, keamanan, dan pengalaman pengguna. Topik ini penting karena muncul berulang kali di proyek kampus, magang, pekerjaan full-time, dan interview software engineer.

Analogi sederhananya: membangun software mirip mengelola dapur restoran. Menu adalah fitur, pelanggan adalah user, database adalah gudang bahan, dan pipeline deployment adalah jalur penyajian. Restoran kecil bisa berjalan dengan satu koki dan satu catatan pesanan, tetapi restoran besar butuh alur kerja, pembagian peran, quality control, dan monitoring. Software juga begitu: semakin banyak user, semakin penting desain yang rapi.

## Konsep Utama

Kata kunci yang perlu kamu kuasai: **monolith, microservices, bounded context, deployment, observability**.

Beberapa prinsip yang selalu berguna:

- Pahami masalah sebelum memilih teknologi.
- Ukur bottleneck dengan data, bukan perasaan.
- Buat solusi paling sederhana yang masih memenuhi kebutuhan.
- Dokumentasikan asumsi penting agar tim lain tidak menebak-nebak.
- Pisahkan konsep inti dari detail implementasi.

| Area | Pertanyaan Penting | Dampak |
|---|---|---|
| Correctness | Apakah hasilnya benar untuk edge case? | Mengurangi bug logic |
| Performance | Bagaimana perilaku saat data membesar? | Menjaga latency |
| Maintainability | Apakah engineer lain mudah memahami kode? | Mempercepat perubahan |
| Security | Apakah data dan akses terlindungi? | Mengurangi risiko production |

## Penjelasan Detail

Bayangkan kamu menerima requirement baru dari product manager. Requirement itu biasanya terdengar sederhana, misalnya "tampilkan daftar materi yang relevan untuk user". Namun di balik kalimat singkat itu ada banyak keputusan: data apa yang dibaca, bagaimana urutannya, bagaimana jika database lambat, bagaimana jika user belum login, dan bagaimana hasilnya diuji. Engineer yang matang akan memecah requirement menjadi beberapa bagian kecil, mengidentifikasi risiko, lalu memilih pendekatan yang bisa diverifikasi.

Pada topik ini, pola berpikir yang paling penting adalah melihat hubungan antara input, proses, dan output. Input bisa berupa request HTTP, data dari database, event dari message broker, atau konfigurasi environment. Proses bisa berupa validasi, transformasi, query, perhitungan, atau komunikasi ke service lain. Output bisa berupa response JSON, record baru, log audit, atau event lanjutan. Jika salah satu bagian tidak jelas, debugging akan menjadi lebih sulit.

Dalam praktik sehari-hari, jangan hanya bertanya "apakah kode ini jalan?". Tanyakan juga:

1. Apa yang terjadi jika input kosong, duplikat, terlalu besar, atau tidak valid?
2. Apakah solusi ini masih masuk akal ketika jumlah data naik 100 kali lipat?
3. Apakah error message cukup membantu tanpa membocorkan informasi sensitif?
4. Apakah perubahan ini mudah dites secara otomatis?
5. Apakah ada asumsi yang perlu ditulis di dokumentasi?

## Contoh Implementasi

Contoh berikut bukan template final, tetapi gambaran cara menyusun ide secara eksplisit:

```text
services:
  learning-service:
  auth-service:
  forum-service:
```

Perhatikan bahwa contoh tersebut menonjolkan struktur berpikir, bukan sekadar sintaks. Sintaks bisa berbeda antara Java, TypeScript, Python, atau SQL, tetapi prinsipnya tetap sama: buat data mengalir lewat tahap yang jelas, kurangi coupling, dan pastikan kegagalan dapat diamati.

## Use Case Industri

Contoh industri: startup sering mulai dari modular monolith lalu memecah payment atau notification ketika skala organisasi bertambah. Kasus seperti ini umum terjadi karena sistem production memiliki batasan nyata: latency, biaya cloud, reliabilitas, keamanan, dan koordinasi antar tim. Solusi yang terlihat bagus di demo lokal belum tentu cukup untuk production jika tidak mempertimbangkan volume data, konkurensi, dan failure mode.

Dalam tim profesional, keputusan teknis biasanya perlu dijelaskan dalam bentuk trade-off. Misalnya, memakai cache membuat response lebih cepat, tetapi menambah risiko stale data. Memecah service membuat deployment lebih independen, tetapi menambah kebutuhan observability dan network reliability. Menggunakan JWT membuat service stateless, tetapi perlu validasi signature dan expiry yang benar.

## Studi Kasus Terarah

Misalkan Yomu ingin menampilkan materi belajar yang relevan untuk mahasiswa yang sedang mempersiapkan interview. Requirement awalnya terdengar sederhana: user membuka halaman, melihat daftar bacaan, memilih materi, lalu mengerjakan quiz. Namun kalau fitur ini dipakai ribuan mahasiswa, ada beberapa pertanyaan desain yang harus dijawab. Apakah daftar bacaan selalu diambil dari database? Apakah setiap request perlu menghitung progress quiz dari awal? Apakah response untuk learner boleh mengandung jawaban benar? Apakah admin boleh mengubah quiz yang sudah pernah dikerjakan banyak user?

Dengan sudut pandang Monolith vs Microservices: Kapan Dipecah dan Kapan Tidak, kamu bisa membuat keputusan yang lebih tajam. Pertama, pisahkan data yang bersifat publik, data yang personal untuk user, dan data yang hanya boleh dilihat admin. Kedua, tentukan operasi mana yang harus konsisten kuat dan mana yang boleh eventually consistent. Ketiga, siapkan test untuk memastikan perubahan schema, perubahan kontrak API, dan perubahan business rule tidak merusak pengalaman belajar.

Pendekatan yang matang biasanya menghasilkan desain seperti ini:

- Endpoint learner hanya mengembalikan informasi yang aman untuk learner.
- Endpoint admin memiliki authorization dan audit log.
- Query yang sering dipakai diberi index atau cache jika benar-benar terbukti bottleneck.
- Seed data dibuat idempotent agar environment lokal, staging, dan demo bisa diisi ulang tanpa duplikasi.
- Error response dibuat konsisten supaya frontend bisa menampilkan pesan yang jelas.

## Production Readiness Checklist

Sebelum sebuah fitur dianggap siap production, engineer perlu mengecek lebih dari sekadar "berhasil dijalankan". Gunakan checklist berikut sebagai kebiasaan:

1. **Correctness:** semua aturan bisnis utama punya test otomatis.
2. **Observability:** log cukup untuk menelusuri request bermasalah.
3. **Security:** endpoint sensitif terlindungi role, token, atau gateway policy.
4. **Performance:** query utama dan struktur data sudah dipikirkan untuk pertumbuhan data.
5. **Resilience:** error dari dependency eksternal tidak membuat seluruh aplikasi gagal tanpa pesan.
6. **Maintainability:** kode mengikuti batas layer yang jelas dan tidak mencampur terlalu banyak tanggung jawab.

Checklist ini bukan birokrasi. Ia membantu tim menghindari bug yang biasanya baru terlihat saat demo besar, traffic naik, atau ada perubahan requirement mendadak.

## Best Practices

- Mulai dari requirement dan constraint, bukan dari library favorit.
- Gunakan nama variabel, endpoint, dan tabel yang konsisten.
- Tambahkan test untuk happy path, edge case, dan failure case.
- Jangan menyimpan secret di source code.
- Catat keputusan penting di README atau ADR sederhana.
- Gunakan logging yang membantu debugging tanpa membocorkan data sensitif.
- Review performa query dan struktur data sebelum traffic membesar.

## Common Mistakes

Kesalahan yang sering dilakukan beginner adalah membuat solusi yang hanya bekerja untuk contoh kecil. Misalnya, nested loop tidak terasa lambat saat data hanya 10 baris, tetapi bisa menghancurkan latency saat data menjadi 100.000 baris. Kesalahan lain adalah mencampur validasi, business logic, dan akses database dalam satu fungsi besar sehingga sulit dites dan sulit diubah.

Kesalahan lain yang sering muncul:

- Mengabaikan edge case karena demo terlihat berhasil.
- Menggunakan status code HTTP yang tidak sesuai.
- Membiarkan endpoint admin tanpa authorization.
- Membuat query berulang dalam loop tanpa sadar.
- Menganggap semua error berasal dari frontend.
- Tidak menulis migration atau seed data yang idempotent.

## Fun Fact

Banyak konsep modern software engineering sebenarnya lahir dari masalah sederhana yang tumbuh besar. Queue muncul karena tidak semua pekerjaan harus selesai saat itu juga. Cache muncul karena membaca sumber data utama terus-menerus terlalu mahal. Load balancer muncul karena satu server tidak selamanya cukup. Dengan memahami asal masalahnya, kamu akan lebih mudah memilih teknologi yang tepat.

## Interview Tips

Saat interview, jangan langsung melompat ke jawaban final. Jelaskan asumsi, pilihan, dan trade-off. Interviewer biasanya ingin melihat cara berpikir. Untuk topik ini, jawaban yang kuat biasanya memuat:

1. Definisi singkat yang tepat.
2. Contoh real-world.
3. Edge case atau failure mode.
4. Trade-off solusi.
5. Cara menguji atau mengukur keberhasilan.

## Latihan Mandiri

Coba ambil fitur sederhana dari aplikasi Yomu, misalnya membaca materi dan mengerjakan quiz. Petakan input, proses, output, data yang disimpan, kemungkinan error, dan risiko keamanan. Setelah itu, tulis satu perbaikan kecil yang membuat fitur tersebut lebih production-ready. Latihan seperti ini akan membangun intuisi engineering yang jauh lebih kuat daripada sekadar membaca definisi.
', 'advanced', 18, 35),
        ('API Gateway, Rate Limiting, dan Proteksi Edge', 'Bahas peran gateway sebagai pintu masuk, routing, auth offloading, rate limiting, observability, dan policy.', '# API Gateway, Rate Limiting, dan Proteksi Edge

## Ringkasan

Bahas peran gateway sebagai pintu masuk, routing, auth offloading, rate limiting, observability, dan policy. Materi ini dirancang seperti modul bootcamp: dimulai dari intuisi, dilanjutkan dengan model mental, lalu ditutup dengan praktik industri dan tips interview. Fokus utamanya bukan menghafal istilah, melainkan memahami cara berpikir yang bisa dipakai saat membangun aplikasi nyata, membaca kode orang lain, melakukan debugging, dan menjelaskan keputusan teknis secara profesional.

## Kenapa Topik Ini Penting

Dalam software engineering, keputusan kecil sering punya dampak besar. Memilih struktur data, menentukan status code, menaruh validasi di layer yang tepat, atau memutuskan kapan memakai cache dapat memengaruhi performa, keamanan, dan pengalaman pengguna. Topik ini penting karena muncul berulang kali di proyek kampus, magang, pekerjaan full-time, dan interview software engineer.

Analogi sederhananya: membangun software mirip mengelola dapur restoran. Menu adalah fitur, pelanggan adalah user, database adalah gudang bahan, dan pipeline deployment adalah jalur penyajian. Restoran kecil bisa berjalan dengan satu koki dan satu catatan pesanan, tetapi restoran besar butuh alur kerja, pembagian peran, quality control, dan monitoring. Software juga begitu: semakin banyak user, semakin penting desain yang rapi.

## Konsep Utama

Kata kunci yang perlu kamu kuasai: **API Gateway, routing, rate limiting, auth, policy**.

Beberapa prinsip yang selalu berguna:

- Pahami masalah sebelum memilih teknologi.
- Ukur bottleneck dengan data, bukan perasaan.
- Buat solusi paling sederhana yang masih memenuhi kebutuhan.
- Dokumentasikan asumsi penting agar tim lain tidak menebak-nebak.
- Pisahkan konsep inti dari detail implementasi.

| Area | Pertanyaan Penting | Dampak |
|---|---|---|
| Correctness | Apakah hasilnya benar untuk edge case? | Mengurangi bug logic |
| Performance | Bagaimana perilaku saat data membesar? | Menjaga latency |
| Maintainability | Apakah engineer lain mudah memahami kode? | Mempercepat perubahan |
| Security | Apakah data dan akses terlindungi? | Mengurangi risiko production |

## Penjelasan Detail

Bayangkan kamu menerima requirement baru dari product manager. Requirement itu biasanya terdengar sederhana, misalnya "tampilkan daftar materi yang relevan untuk user". Namun di balik kalimat singkat itu ada banyak keputusan: data apa yang dibaca, bagaimana urutannya, bagaimana jika database lambat, bagaimana jika user belum login, dan bagaimana hasilnya diuji. Engineer yang matang akan memecah requirement menjadi beberapa bagian kecil, mengidentifikasi risiko, lalu memilih pendekatan yang bisa diverifikasi.

Pada topik ini, pola berpikir yang paling penting adalah melihat hubungan antara input, proses, dan output. Input bisa berupa request HTTP, data dari database, event dari message broker, atau konfigurasi environment. Proses bisa berupa validasi, transformasi, query, perhitungan, atau komunikasi ke service lain. Output bisa berupa response JSON, record baru, log audit, atau event lanjutan. Jika salah satu bagian tidak jelas, debugging akan menjadi lebih sulit.

Dalam praktik sehari-hari, jangan hanya bertanya "apakah kode ini jalan?". Tanyakan juga:

1. Apa yang terjadi jika input kosong, duplikat, terlalu besar, atau tidak valid?
2. Apakah solusi ini masih masuk akal ketika jumlah data naik 100 kali lipat?
3. Apakah error message cukup membantu tanpa membocorkan informasi sensitif?
4. Apakah perubahan ini mudah dites secara otomatis?
5. Apakah ada asumsi yang perlu ditulis di dokumentasi?

## Contoh Implementasi

Contoh berikut bukan template final, tetapi gambaran cara menyusun ide secara eksplisit:

```text
limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;
```

Perhatikan bahwa contoh tersebut menonjolkan struktur berpikir, bukan sekadar sintaks. Sintaks bisa berbeda antara Java, TypeScript, Python, atau SQL, tetapi prinsipnya tetap sama: buat data mengalir lewat tahap yang jelas, kurangi coupling, dan pastikan kegagalan dapat diamati.

## Use Case Industri

Contoh industri: perusahaan SaaS membatasi request per tenant agar satu customer tidak menghabiskan kapasitas semua service. Kasus seperti ini umum terjadi karena sistem production memiliki batasan nyata: latency, biaya cloud, reliabilitas, keamanan, dan koordinasi antar tim. Solusi yang terlihat bagus di demo lokal belum tentu cukup untuk production jika tidak mempertimbangkan volume data, konkurensi, dan failure mode.

Dalam tim profesional, keputusan teknis biasanya perlu dijelaskan dalam bentuk trade-off. Misalnya, memakai cache membuat response lebih cepat, tetapi menambah risiko stale data. Memecah service membuat deployment lebih independen, tetapi menambah kebutuhan observability dan network reliability. Menggunakan JWT membuat service stateless, tetapi perlu validasi signature dan expiry yang benar.

## Studi Kasus Terarah

Misalkan Yomu ingin menampilkan materi belajar yang relevan untuk mahasiswa yang sedang mempersiapkan interview. Requirement awalnya terdengar sederhana: user membuka halaman, melihat daftar bacaan, memilih materi, lalu mengerjakan quiz. Namun kalau fitur ini dipakai ribuan mahasiswa, ada beberapa pertanyaan desain yang harus dijawab. Apakah daftar bacaan selalu diambil dari database? Apakah setiap request perlu menghitung progress quiz dari awal? Apakah response untuk learner boleh mengandung jawaban benar? Apakah admin boleh mengubah quiz yang sudah pernah dikerjakan banyak user?

Dengan sudut pandang API Gateway, Rate Limiting, dan Proteksi Edge, kamu bisa membuat keputusan yang lebih tajam. Pertama, pisahkan data yang bersifat publik, data yang personal untuk user, dan data yang hanya boleh dilihat admin. Kedua, tentukan operasi mana yang harus konsisten kuat dan mana yang boleh eventually consistent. Ketiga, siapkan test untuk memastikan perubahan schema, perubahan kontrak API, dan perubahan business rule tidak merusak pengalaman belajar.

Pendekatan yang matang biasanya menghasilkan desain seperti ini:

- Endpoint learner hanya mengembalikan informasi yang aman untuk learner.
- Endpoint admin memiliki authorization dan audit log.
- Query yang sering dipakai diberi index atau cache jika benar-benar terbukti bottleneck.
- Seed data dibuat idempotent agar environment lokal, staging, dan demo bisa diisi ulang tanpa duplikasi.
- Error response dibuat konsisten supaya frontend bisa menampilkan pesan yang jelas.

## Production Readiness Checklist

Sebelum sebuah fitur dianggap siap production, engineer perlu mengecek lebih dari sekadar "berhasil dijalankan". Gunakan checklist berikut sebagai kebiasaan:

1. **Correctness:** semua aturan bisnis utama punya test otomatis.
2. **Observability:** log cukup untuk menelusuri request bermasalah.
3. **Security:** endpoint sensitif terlindungi role, token, atau gateway policy.
4. **Performance:** query utama dan struktur data sudah dipikirkan untuk pertumbuhan data.
5. **Resilience:** error dari dependency eksternal tidak membuat seluruh aplikasi gagal tanpa pesan.
6. **Maintainability:** kode mengikuti batas layer yang jelas dan tidak mencampur terlalu banyak tanggung jawab.

Checklist ini bukan birokrasi. Ia membantu tim menghindari bug yang biasanya baru terlihat saat demo besar, traffic naik, atau ada perubahan requirement mendadak.

## Best Practices

- Mulai dari requirement dan constraint, bukan dari library favorit.
- Gunakan nama variabel, endpoint, dan tabel yang konsisten.
- Tambahkan test untuk happy path, edge case, dan failure case.
- Jangan menyimpan secret di source code.
- Catat keputusan penting di README atau ADR sederhana.
- Gunakan logging yang membantu debugging tanpa membocorkan data sensitif.
- Review performa query dan struktur data sebelum traffic membesar.

## Common Mistakes

Kesalahan yang sering dilakukan beginner adalah membuat solusi yang hanya bekerja untuk contoh kecil. Misalnya, nested loop tidak terasa lambat saat data hanya 10 baris, tetapi bisa menghancurkan latency saat data menjadi 100.000 baris. Kesalahan lain adalah mencampur validasi, business logic, dan akses database dalam satu fungsi besar sehingga sulit dites dan sulit diubah.

Kesalahan lain yang sering muncul:

- Mengabaikan edge case karena demo terlihat berhasil.
- Menggunakan status code HTTP yang tidak sesuai.
- Membiarkan endpoint admin tanpa authorization.
- Membuat query berulang dalam loop tanpa sadar.
- Menganggap semua error berasal dari frontend.
- Tidak menulis migration atau seed data yang idempotent.

## Fun Fact

Banyak konsep modern software engineering sebenarnya lahir dari masalah sederhana yang tumbuh besar. Queue muncul karena tidak semua pekerjaan harus selesai saat itu juga. Cache muncul karena membaca sumber data utama terus-menerus terlalu mahal. Load balancer muncul karena satu server tidak selamanya cukup. Dengan memahami asal masalahnya, kamu akan lebih mudah memilih teknologi yang tepat.

## Interview Tips

Saat interview, jangan langsung melompat ke jawaban final. Jelaskan asumsi, pilihan, dan trade-off. Interviewer biasanya ingin melihat cara berpikir. Untuk topik ini, jawaban yang kuat biasanya memuat:

1. Definisi singkat yang tepat.
2. Contoh real-world.
3. Edge case atau failure mode.
4. Trade-off solusi.
5. Cara menguji atau mengukur keberhasilan.

## Latihan Mandiri

Coba ambil fitur sederhana dari aplikasi Yomu, misalnya membaca materi dan mengerjakan quiz. Petakan input, proses, output, data yang disimpan, kemungkinan error, dan risiko keamanan. Setelah itu, tulis satu perbaikan kecil yang membuat fitur tersebut lebih production-ready. Latihan seperti ini akan membangun intuisi engineering yang jauh lebih kuat daripada sekadar membaca definisi.
', 'advanced', 18, 35),
        ('Clean Code Principles untuk Kode yang Mudah Dirawat', 'Materi ini membahas naming, function size, separation of concerns, error handling, dan refactoring bertahap.', '# Clean Code Principles untuk Kode yang Mudah Dirawat

## Ringkasan

Materi ini membahas naming, function size, separation of concerns, error handling, dan refactoring bertahap. Materi ini dirancang seperti modul bootcamp: dimulai dari intuisi, dilanjutkan dengan model mental, lalu ditutup dengan praktik industri dan tips interview. Fokus utamanya bukan menghafal istilah, melainkan memahami cara berpikir yang bisa dipakai saat membangun aplikasi nyata, membaca kode orang lain, melakukan debugging, dan menjelaskan keputusan teknis secara profesional.

## Kenapa Topik Ini Penting

Dalam software engineering, keputusan kecil sering punya dampak besar. Memilih struktur data, menentukan status code, menaruh validasi di layer yang tepat, atau memutuskan kapan memakai cache dapat memengaruhi performa, keamanan, dan pengalaman pengguna. Topik ini penting karena muncul berulang kali di proyek kampus, magang, pekerjaan full-time, dan interview software engineer.

Analogi sederhananya: membangun software mirip mengelola dapur restoran. Menu adalah fitur, pelanggan adalah user, database adalah gudang bahan, dan pipeline deployment adalah jalur penyajian. Restoran kecil bisa berjalan dengan satu koki dan satu catatan pesanan, tetapi restoran besar butuh alur kerja, pembagian peran, quality control, dan monitoring. Software juga begitu: semakin banyak user, semakin penting desain yang rapi.

## Konsep Utama

Kata kunci yang perlu kamu kuasai: **naming, function size, separation of concerns, refactoring, readability**.

Beberapa prinsip yang selalu berguna:

- Pahami masalah sebelum memilih teknologi.
- Ukur bottleneck dengan data, bukan perasaan.
- Buat solusi paling sederhana yang masih memenuhi kebutuhan.
- Dokumentasikan asumsi penting agar tim lain tidak menebak-nebak.
- Pisahkan konsep inti dari detail implementasi.

| Area | Pertanyaan Penting | Dampak |
|---|---|---|
| Correctness | Apakah hasilnya benar untuk edge case? | Mengurangi bug logic |
| Performance | Bagaimana perilaku saat data membesar? | Menjaga latency |
| Maintainability | Apakah engineer lain mudah memahami kode? | Mempercepat perubahan |
| Security | Apakah data dan akses terlindungi? | Mengurangi risiko production |

## Penjelasan Detail

Bayangkan kamu menerima requirement baru dari product manager. Requirement itu biasanya terdengar sederhana, misalnya "tampilkan daftar materi yang relevan untuk user". Namun di balik kalimat singkat itu ada banyak keputusan: data apa yang dibaca, bagaimana urutannya, bagaimana jika database lambat, bagaimana jika user belum login, dan bagaimana hasilnya diuji. Engineer yang matang akan memecah requirement menjadi beberapa bagian kecil, mengidentifikasi risiko, lalu memilih pendekatan yang bisa diverifikasi.

Pada topik ini, pola berpikir yang paling penting adalah melihat hubungan antara input, proses, dan output. Input bisa berupa request HTTP, data dari database, event dari message broker, atau konfigurasi environment. Proses bisa berupa validasi, transformasi, query, perhitungan, atau komunikasi ke service lain. Output bisa berupa response JSON, record baru, log audit, atau event lanjutan. Jika salah satu bagian tidak jelas, debugging akan menjadi lebih sulit.

Dalam praktik sehari-hari, jangan hanya bertanya "apakah kode ini jalan?". Tanyakan juga:

1. Apa yang terjadi jika input kosong, duplikat, terlalu besar, atau tidak valid?
2. Apakah solusi ini masih masuk akal ketika jumlah data naik 100 kali lipat?
3. Apakah error message cukup membantu tanpa membocorkan informasi sensitif?
4. Apakah perubahan ini mudah dites secara otomatis?
5. Apakah ada asumsi yang perlu ditulis di dokumentasi?

## Contoh Implementasi

Contoh berikut bukan template final, tetapi gambaran cara menyusun ide secara eksplisit:

```text
boolean isEligibleForReward(User user) {
  return user.isActive() && user.getPoints() >= 100;
}
```

Perhatikan bahwa contoh tersebut menonjolkan struktur berpikir, bukan sekadar sintaks. Sintaks bisa berbeda antara Java, TypeScript, Python, atau SQL, tetapi prinsipnya tetap sama: buat data mengalir lewat tahap yang jelas, kurangi coupling, dan pastikan kegagalan dapat diamati.

## Use Case Industri

Contoh industri: tim dengan banyak contributor menjaga velocity dengan kode yang mudah dibaca dan review yang konsisten. Kasus seperti ini umum terjadi karena sistem production memiliki batasan nyata: latency, biaya cloud, reliabilitas, keamanan, dan koordinasi antar tim. Solusi yang terlihat bagus di demo lokal belum tentu cukup untuk production jika tidak mempertimbangkan volume data, konkurensi, dan failure mode.

Dalam tim profesional, keputusan teknis biasanya perlu dijelaskan dalam bentuk trade-off. Misalnya, memakai cache membuat response lebih cepat, tetapi menambah risiko stale data. Memecah service membuat deployment lebih independen, tetapi menambah kebutuhan observability dan network reliability. Menggunakan JWT membuat service stateless, tetapi perlu validasi signature dan expiry yang benar.

## Studi Kasus Terarah

Misalkan Yomu ingin menampilkan materi belajar yang relevan untuk mahasiswa yang sedang mempersiapkan interview. Requirement awalnya terdengar sederhana: user membuka halaman, melihat daftar bacaan, memilih materi, lalu mengerjakan quiz. Namun kalau fitur ini dipakai ribuan mahasiswa, ada beberapa pertanyaan desain yang harus dijawab. Apakah daftar bacaan selalu diambil dari database? Apakah setiap request perlu menghitung progress quiz dari awal? Apakah response untuk learner boleh mengandung jawaban benar? Apakah admin boleh mengubah quiz yang sudah pernah dikerjakan banyak user?

Dengan sudut pandang Clean Code Principles untuk Kode yang Mudah Dirawat, kamu bisa membuat keputusan yang lebih tajam. Pertama, pisahkan data yang bersifat publik, data yang personal untuk user, dan data yang hanya boleh dilihat admin. Kedua, tentukan operasi mana yang harus konsisten kuat dan mana yang boleh eventually consistent. Ketiga, siapkan test untuk memastikan perubahan schema, perubahan kontrak API, dan perubahan business rule tidak merusak pengalaman belajar.

Pendekatan yang matang biasanya menghasilkan desain seperti ini:

- Endpoint learner hanya mengembalikan informasi yang aman untuk learner.
- Endpoint admin memiliki authorization dan audit log.
- Query yang sering dipakai diberi index atau cache jika benar-benar terbukti bottleneck.
- Seed data dibuat idempotent agar environment lokal, staging, dan demo bisa diisi ulang tanpa duplikasi.
- Error response dibuat konsisten supaya frontend bisa menampilkan pesan yang jelas.

## Production Readiness Checklist

Sebelum sebuah fitur dianggap siap production, engineer perlu mengecek lebih dari sekadar "berhasil dijalankan". Gunakan checklist berikut sebagai kebiasaan:

1. **Correctness:** semua aturan bisnis utama punya test otomatis.
2. **Observability:** log cukup untuk menelusuri request bermasalah.
3. **Security:** endpoint sensitif terlindungi role, token, atau gateway policy.
4. **Performance:** query utama dan struktur data sudah dipikirkan untuk pertumbuhan data.
5. **Resilience:** error dari dependency eksternal tidak membuat seluruh aplikasi gagal tanpa pesan.
6. **Maintainability:** kode mengikuti batas layer yang jelas dan tidak mencampur terlalu banyak tanggung jawab.

Checklist ini bukan birokrasi. Ia membantu tim menghindari bug yang biasanya baru terlihat saat demo besar, traffic naik, atau ada perubahan requirement mendadak.

## Best Practices

- Mulai dari requirement dan constraint, bukan dari library favorit.
- Gunakan nama variabel, endpoint, dan tabel yang konsisten.
- Tambahkan test untuk happy path, edge case, dan failure case.
- Jangan menyimpan secret di source code.
- Catat keputusan penting di README atau ADR sederhana.
- Gunakan logging yang membantu debugging tanpa membocorkan data sensitif.
- Review performa query dan struktur data sebelum traffic membesar.

## Common Mistakes

Kesalahan yang sering dilakukan beginner adalah membuat solusi yang hanya bekerja untuk contoh kecil. Misalnya, nested loop tidak terasa lambat saat data hanya 10 baris, tetapi bisa menghancurkan latency saat data menjadi 100.000 baris. Kesalahan lain adalah mencampur validasi, business logic, dan akses database dalam satu fungsi besar sehingga sulit dites dan sulit diubah.

Kesalahan lain yang sering muncul:

- Mengabaikan edge case karena demo terlihat berhasil.
- Menggunakan status code HTTP yang tidak sesuai.
- Membiarkan endpoint admin tanpa authorization.
- Membuat query berulang dalam loop tanpa sadar.
- Menganggap semua error berasal dari frontend.
- Tidak menulis migration atau seed data yang idempotent.

## Fun Fact

Banyak konsep modern software engineering sebenarnya lahir dari masalah sederhana yang tumbuh besar. Queue muncul karena tidak semua pekerjaan harus selesai saat itu juga. Cache muncul karena membaca sumber data utama terus-menerus terlalu mahal. Load balancer muncul karena satu server tidak selamanya cukup. Dengan memahami asal masalahnya, kamu akan lebih mudah memilih teknologi yang tepat.

## Interview Tips

Saat interview, jangan langsung melompat ke jawaban final. Jelaskan asumsi, pilihan, dan trade-off. Interviewer biasanya ingin melihat cara berpikir. Untuk topik ini, jawaban yang kuat biasanya memuat:

1. Definisi singkat yang tepat.
2. Contoh real-world.
3. Edge case atau failure mode.
4. Trade-off solusi.
5. Cara menguji atau mengukur keberhasilan.

## Latihan Mandiri

Coba ambil fitur sederhana dari aplikasi Yomu, misalnya membaca materi dan mengerjakan quiz. Petakan input, proses, output, data yang disimpan, kemungkinan error, dan risiko keamanan. Setelah itu, tulis satu perbaikan kecil yang membuat fitur tersebut lebih production-ready. Latihan seperti ini akan membangun intuisi engineering yang jauh lebih kuat daripada sekadar membaca definisi.
', 'beginner', 12, 10),
        ('SOLID Principles dengan Contoh Java dan Spring', 'Pelajari Single Responsibility, Open/Closed, Liskov, Interface Segregation, dan Dependency Inversion melalui contoh praktis.', '# SOLID Principles dengan Contoh Java dan Spring

## Ringkasan

Pelajari Single Responsibility, Open/Closed, Liskov, Interface Segregation, dan Dependency Inversion melalui contoh praktis. Materi ini dirancang seperti modul bootcamp: dimulai dari intuisi, dilanjutkan dengan model mental, lalu ditutup dengan praktik industri dan tips interview. Fokus utamanya bukan menghafal istilah, melainkan memahami cara berpikir yang bisa dipakai saat membangun aplikasi nyata, membaca kode orang lain, melakukan debugging, dan menjelaskan keputusan teknis secara profesional.

## Kenapa Topik Ini Penting

Dalam software engineering, keputusan kecil sering punya dampak besar. Memilih struktur data, menentukan status code, menaruh validasi di layer yang tepat, atau memutuskan kapan memakai cache dapat memengaruhi performa, keamanan, dan pengalaman pengguna. Topik ini penting karena muncul berulang kali di proyek kampus, magang, pekerjaan full-time, dan interview software engineer.

Analogi sederhananya: membangun software mirip mengelola dapur restoran. Menu adalah fitur, pelanggan adalah user, database adalah gudang bahan, dan pipeline deployment adalah jalur penyajian. Restoran kecil bisa berjalan dengan satu koki dan satu catatan pesanan, tetapi restoran besar butuh alur kerja, pembagian peran, quality control, dan monitoring. Software juga begitu: semakin banyak user, semakin penting desain yang rapi.

## Konsep Utama

Kata kunci yang perlu kamu kuasai: **SRP, OCP, LSP, ISP, DIP**.

Beberapa prinsip yang selalu berguna:

- Pahami masalah sebelum memilih teknologi.
- Ukur bottleneck dengan data, bukan perasaan.
- Buat solusi paling sederhana yang masih memenuhi kebutuhan.
- Dokumentasikan asumsi penting agar tim lain tidak menebak-nebak.
- Pisahkan konsep inti dari detail implementasi.

| Area | Pertanyaan Penting | Dampak |
|---|---|---|
| Correctness | Apakah hasilnya benar untuk edge case? | Mengurangi bug logic |
| Performance | Bagaimana perilaku saat data membesar? | Menjaga latency |
| Maintainability | Apakah engineer lain mudah memahami kode? | Mempercepat perubahan |
| Security | Apakah data dan akses terlindungi? | Mengurangi risiko production |

## Penjelasan Detail

Bayangkan kamu menerima requirement baru dari product manager. Requirement itu biasanya terdengar sederhana, misalnya "tampilkan daftar materi yang relevan untuk user". Namun di balik kalimat singkat itu ada banyak keputusan: data apa yang dibaca, bagaimana urutannya, bagaimana jika database lambat, bagaimana jika user belum login, dan bagaimana hasilnya diuji. Engineer yang matang akan memecah requirement menjadi beberapa bagian kecil, mengidentifikasi risiko, lalu memilih pendekatan yang bisa diverifikasi.

Pada topik ini, pola berpikir yang paling penting adalah melihat hubungan antara input, proses, dan output. Input bisa berupa request HTTP, data dari database, event dari message broker, atau konfigurasi environment. Proses bisa berupa validasi, transformasi, query, perhitungan, atau komunikasi ke service lain. Output bisa berupa response JSON, record baru, log audit, atau event lanjutan. Jika salah satu bagian tidak jelas, debugging akan menjadi lebih sulit.

Dalam praktik sehari-hari, jangan hanya bertanya "apakah kode ini jalan?". Tanyakan juga:

1. Apa yang terjadi jika input kosong, duplikat, terlalu besar, atau tidak valid?
2. Apakah solusi ini masih masuk akal ketika jumlah data naik 100 kali lipat?
3. Apakah error message cukup membantu tanpa membocorkan informasi sensitif?
4. Apakah perubahan ini mudah dites secara otomatis?
5. Apakah ada asumsi yang perlu ditulis di dokumentasi?

## Contoh Implementasi

Contoh berikut bukan template final, tetapi gambaran cara menyusun ide secara eksplisit:

```text
interface PaymentProcessor {
  PaymentResult pay(PaymentRequest request);
}
```

Perhatikan bahwa contoh tersebut menonjolkan struktur berpikir, bukan sekadar sintaks. Sintaks bisa berbeda antara Java, TypeScript, Python, atau SQL, tetapi prinsipnya tetap sama: buat data mengalir lewat tahap yang jelas, kurangi coupling, dan pastikan kegagalan dapat diamati.

## Use Case Industri

Contoh industri: payment service memakai interface agar metode kartu, e-wallet, dan bank transfer bisa bertambah tanpa mengubah controller. Kasus seperti ini umum terjadi karena sistem production memiliki batasan nyata: latency, biaya cloud, reliabilitas, keamanan, dan koordinasi antar tim. Solusi yang terlihat bagus di demo lokal belum tentu cukup untuk production jika tidak mempertimbangkan volume data, konkurensi, dan failure mode.

Dalam tim profesional, keputusan teknis biasanya perlu dijelaskan dalam bentuk trade-off. Misalnya, memakai cache membuat response lebih cepat, tetapi menambah risiko stale data. Memecah service membuat deployment lebih independen, tetapi menambah kebutuhan observability dan network reliability. Menggunakan JWT membuat service stateless, tetapi perlu validasi signature dan expiry yang benar.

## Studi Kasus Terarah

Misalkan Yomu ingin menampilkan materi belajar yang relevan untuk mahasiswa yang sedang mempersiapkan interview. Requirement awalnya terdengar sederhana: user membuka halaman, melihat daftar bacaan, memilih materi, lalu mengerjakan quiz. Namun kalau fitur ini dipakai ribuan mahasiswa, ada beberapa pertanyaan desain yang harus dijawab. Apakah daftar bacaan selalu diambil dari database? Apakah setiap request perlu menghitung progress quiz dari awal? Apakah response untuk learner boleh mengandung jawaban benar? Apakah admin boleh mengubah quiz yang sudah pernah dikerjakan banyak user?

Dengan sudut pandang SOLID Principles dengan Contoh Java dan Spring, kamu bisa membuat keputusan yang lebih tajam. Pertama, pisahkan data yang bersifat publik, data yang personal untuk user, dan data yang hanya boleh dilihat admin. Kedua, tentukan operasi mana yang harus konsisten kuat dan mana yang boleh eventually consistent. Ketiga, siapkan test untuk memastikan perubahan schema, perubahan kontrak API, dan perubahan business rule tidak merusak pengalaman belajar.

Pendekatan yang matang biasanya menghasilkan desain seperti ini:

- Endpoint learner hanya mengembalikan informasi yang aman untuk learner.
- Endpoint admin memiliki authorization dan audit log.
- Query yang sering dipakai diberi index atau cache jika benar-benar terbukti bottleneck.
- Seed data dibuat idempotent agar environment lokal, staging, dan demo bisa diisi ulang tanpa duplikasi.
- Error response dibuat konsisten supaya frontend bisa menampilkan pesan yang jelas.

## Production Readiness Checklist

Sebelum sebuah fitur dianggap siap production, engineer perlu mengecek lebih dari sekadar "berhasil dijalankan". Gunakan checklist berikut sebagai kebiasaan:

1. **Correctness:** semua aturan bisnis utama punya test otomatis.
2. **Observability:** log cukup untuk menelusuri request bermasalah.
3. **Security:** endpoint sensitif terlindungi role, token, atau gateway policy.
4. **Performance:** query utama dan struktur data sudah dipikirkan untuk pertumbuhan data.
5. **Resilience:** error dari dependency eksternal tidak membuat seluruh aplikasi gagal tanpa pesan.
6. **Maintainability:** kode mengikuti batas layer yang jelas dan tidak mencampur terlalu banyak tanggung jawab.

Checklist ini bukan birokrasi. Ia membantu tim menghindari bug yang biasanya baru terlihat saat demo besar, traffic naik, atau ada perubahan requirement mendadak.

## Best Practices

- Mulai dari requirement dan constraint, bukan dari library favorit.
- Gunakan nama variabel, endpoint, dan tabel yang konsisten.
- Tambahkan test untuk happy path, edge case, dan failure case.
- Jangan menyimpan secret di source code.
- Catat keputusan penting di README atau ADR sederhana.
- Gunakan logging yang membantu debugging tanpa membocorkan data sensitif.
- Review performa query dan struktur data sebelum traffic membesar.

## Common Mistakes

Kesalahan yang sering dilakukan beginner adalah membuat solusi yang hanya bekerja untuk contoh kecil. Misalnya, nested loop tidak terasa lambat saat data hanya 10 baris, tetapi bisa menghancurkan latency saat data menjadi 100.000 baris. Kesalahan lain adalah mencampur validasi, business logic, dan akses database dalam satu fungsi besar sehingga sulit dites dan sulit diubah.

Kesalahan lain yang sering muncul:

- Mengabaikan edge case karena demo terlihat berhasil.
- Menggunakan status code HTTP yang tidak sesuai.
- Membiarkan endpoint admin tanpa authorization.
- Membuat query berulang dalam loop tanpa sadar.
- Menganggap semua error berasal dari frontend.
- Tidak menulis migration atau seed data yang idempotent.

## Fun Fact

Banyak konsep modern software engineering sebenarnya lahir dari masalah sederhana yang tumbuh besar. Queue muncul karena tidak semua pekerjaan harus selesai saat itu juga. Cache muncul karena membaca sumber data utama terus-menerus terlalu mahal. Load balancer muncul karena satu server tidak selamanya cukup. Dengan memahami asal masalahnya, kamu akan lebih mudah memilih teknologi yang tepat.

## Interview Tips

Saat interview, jangan langsung melompat ke jawaban final. Jelaskan asumsi, pilihan, dan trade-off. Interviewer biasanya ingin melihat cara berpikir. Untuk topik ini, jawaban yang kuat biasanya memuat:

1. Definisi singkat yang tepat.
2. Contoh real-world.
3. Edge case atau failure mode.
4. Trade-off solusi.
5. Cara menguji atau mengukur keberhasilan.

## Latihan Mandiri

Coba ambil fitur sederhana dari aplikasi Yomu, misalnya membaca materi dan mengerjakan quiz. Petakan input, proses, output, data yang disimpan, kemungkinan error, dan risiko keamanan. Setelah itu, tulis satu perbaikan kecil yang membuat fitur tersebut lebih production-ready. Latihan seperti ini akan membangun intuisi engineering yang jauh lebih kuat daripada sekadar membaca definisi.
', 'intermediate', 15, 20),
        ('Git, Version Control, dan Collaboration Workflow', 'Bahas commit atomic, branching, pull request, conflict resolution, code review, dan kebiasaan kerja tim.', '# Git, Version Control, dan Collaboration Workflow

## Ringkasan

Bahas commit atomic, branching, pull request, conflict resolution, code review, dan kebiasaan kerja tim. Materi ini dirancang seperti modul bootcamp: dimulai dari intuisi, dilanjutkan dengan model mental, lalu ditutup dengan praktik industri dan tips interview. Fokus utamanya bukan menghafal istilah, melainkan memahami cara berpikir yang bisa dipakai saat membangun aplikasi nyata, membaca kode orang lain, melakukan debugging, dan menjelaskan keputusan teknis secara profesional.

## Kenapa Topik Ini Penting

Dalam software engineering, keputusan kecil sering punya dampak besar. Memilih struktur data, menentukan status code, menaruh validasi di layer yang tepat, atau memutuskan kapan memakai cache dapat memengaruhi performa, keamanan, dan pengalaman pengguna. Topik ini penting karena muncul berulang kali di proyek kampus, magang, pekerjaan full-time, dan interview software engineer.

Analogi sederhananya: membangun software mirip mengelola dapur restoran. Menu adalah fitur, pelanggan adalah user, database adalah gudang bahan, dan pipeline deployment adalah jalur penyajian. Restoran kecil bisa berjalan dengan satu koki dan satu catatan pesanan, tetapi restoran besar butuh alur kerja, pembagian peran, quality control, dan monitoring. Software juga begitu: semakin banyak user, semakin penting desain yang rapi.

## Konsep Utama

Kata kunci yang perlu kamu kuasai: **commit, branch, pull request, merge conflict, code review**.

Beberapa prinsip yang selalu berguna:

- Pahami masalah sebelum memilih teknologi.
- Ukur bottleneck dengan data, bukan perasaan.
- Buat solusi paling sederhana yang masih memenuhi kebutuhan.
- Dokumentasikan asumsi penting agar tim lain tidak menebak-nebak.
- Pisahkan konsep inti dari detail implementasi.

| Area | Pertanyaan Penting | Dampak |
|---|---|---|
| Correctness | Apakah hasilnya benar untuk edge case? | Mengurangi bug logic |
| Performance | Bagaimana perilaku saat data membesar? | Menjaga latency |
| Maintainability | Apakah engineer lain mudah memahami kode? | Mempercepat perubahan |
| Security | Apakah data dan akses terlindungi? | Mengurangi risiko production |

## Penjelasan Detail

Bayangkan kamu menerima requirement baru dari product manager. Requirement itu biasanya terdengar sederhana, misalnya "tampilkan daftar materi yang relevan untuk user". Namun di balik kalimat singkat itu ada banyak keputusan: data apa yang dibaca, bagaimana urutannya, bagaimana jika database lambat, bagaimana jika user belum login, dan bagaimana hasilnya diuji. Engineer yang matang akan memecah requirement menjadi beberapa bagian kecil, mengidentifikasi risiko, lalu memilih pendekatan yang bisa diverifikasi.

Pada topik ini, pola berpikir yang paling penting adalah melihat hubungan antara input, proses, dan output. Input bisa berupa request HTTP, data dari database, event dari message broker, atau konfigurasi environment. Proses bisa berupa validasi, transformasi, query, perhitungan, atau komunikasi ke service lain. Output bisa berupa response JSON, record baru, log audit, atau event lanjutan. Jika salah satu bagian tidak jelas, debugging akan menjadi lebih sulit.

Dalam praktik sehari-hari, jangan hanya bertanya "apakah kode ini jalan?". Tanyakan juga:

1. Apa yang terjadi jika input kosong, duplikat, terlalu besar, atau tidak valid?
2. Apakah solusi ini masih masuk akal ketika jumlah data naik 100 kali lipat?
3. Apakah error message cukup membantu tanpa membocorkan informasi sensitif?
4. Apakah perubahan ini mudah dites secara otomatis?
5. Apakah ada asumsi yang perlu ditulis di dokumentasi?

## Contoh Implementasi

Contoh berikut bukan template final, tetapi gambaran cara menyusun ide secara eksplisit:

```text
git checkout -b feature/learning-quiz
git add .
git commit -m "Add quiz flow"
```

Perhatikan bahwa contoh tersebut menonjolkan struktur berpikir, bukan sekadar sintaks. Sintaks bisa berbeda antara Java, TypeScript, Python, atau SQL, tetapi prinsipnya tetap sama: buat data mengalir lewat tahap yang jelas, kurangi coupling, dan pastikan kegagalan dapat diamati.

## Use Case Industri

Contoh industri: tim product menjaga release tetap stabil dengan branch protection dan review wajib sebelum merge ke main. Kasus seperti ini umum terjadi karena sistem production memiliki batasan nyata: latency, biaya cloud, reliabilitas, keamanan, dan koordinasi antar tim. Solusi yang terlihat bagus di demo lokal belum tentu cukup untuk production jika tidak mempertimbangkan volume data, konkurensi, dan failure mode.

Dalam tim profesional, keputusan teknis biasanya perlu dijelaskan dalam bentuk trade-off. Misalnya, memakai cache membuat response lebih cepat, tetapi menambah risiko stale data. Memecah service membuat deployment lebih independen, tetapi menambah kebutuhan observability dan network reliability. Menggunakan JWT membuat service stateless, tetapi perlu validasi signature dan expiry yang benar.

## Studi Kasus Terarah

Misalkan Yomu ingin menampilkan materi belajar yang relevan untuk mahasiswa yang sedang mempersiapkan interview. Requirement awalnya terdengar sederhana: user membuka halaman, melihat daftar bacaan, memilih materi, lalu mengerjakan quiz. Namun kalau fitur ini dipakai ribuan mahasiswa, ada beberapa pertanyaan desain yang harus dijawab. Apakah daftar bacaan selalu diambil dari database? Apakah setiap request perlu menghitung progress quiz dari awal? Apakah response untuk learner boleh mengandung jawaban benar? Apakah admin boleh mengubah quiz yang sudah pernah dikerjakan banyak user?

Dengan sudut pandang Git, Version Control, dan Collaboration Workflow, kamu bisa membuat keputusan yang lebih tajam. Pertama, pisahkan data yang bersifat publik, data yang personal untuk user, dan data yang hanya boleh dilihat admin. Kedua, tentukan operasi mana yang harus konsisten kuat dan mana yang boleh eventually consistent. Ketiga, siapkan test untuk memastikan perubahan schema, perubahan kontrak API, dan perubahan business rule tidak merusak pengalaman belajar.

Pendekatan yang matang biasanya menghasilkan desain seperti ini:

- Endpoint learner hanya mengembalikan informasi yang aman untuk learner.
- Endpoint admin memiliki authorization dan audit log.
- Query yang sering dipakai diberi index atau cache jika benar-benar terbukti bottleneck.
- Seed data dibuat idempotent agar environment lokal, staging, dan demo bisa diisi ulang tanpa duplikasi.
- Error response dibuat konsisten supaya frontend bisa menampilkan pesan yang jelas.

## Production Readiness Checklist

Sebelum sebuah fitur dianggap siap production, engineer perlu mengecek lebih dari sekadar "berhasil dijalankan". Gunakan checklist berikut sebagai kebiasaan:

1. **Correctness:** semua aturan bisnis utama punya test otomatis.
2. **Observability:** log cukup untuk menelusuri request bermasalah.
3. **Security:** endpoint sensitif terlindungi role, token, atau gateway policy.
4. **Performance:** query utama dan struktur data sudah dipikirkan untuk pertumbuhan data.
5. **Resilience:** error dari dependency eksternal tidak membuat seluruh aplikasi gagal tanpa pesan.
6. **Maintainability:** kode mengikuti batas layer yang jelas dan tidak mencampur terlalu banyak tanggung jawab.

Checklist ini bukan birokrasi. Ia membantu tim menghindari bug yang biasanya baru terlihat saat demo besar, traffic naik, atau ada perubahan requirement mendadak.

## Best Practices

- Mulai dari requirement dan constraint, bukan dari library favorit.
- Gunakan nama variabel, endpoint, dan tabel yang konsisten.
- Tambahkan test untuk happy path, edge case, dan failure case.
- Jangan menyimpan secret di source code.
- Catat keputusan penting di README atau ADR sederhana.
- Gunakan logging yang membantu debugging tanpa membocorkan data sensitif.
- Review performa query dan struktur data sebelum traffic membesar.

## Common Mistakes

Kesalahan yang sering dilakukan beginner adalah membuat solusi yang hanya bekerja untuk contoh kecil. Misalnya, nested loop tidak terasa lambat saat data hanya 10 baris, tetapi bisa menghancurkan latency saat data menjadi 100.000 baris. Kesalahan lain adalah mencampur validasi, business logic, dan akses database dalam satu fungsi besar sehingga sulit dites dan sulit diubah.

Kesalahan lain yang sering muncul:

- Mengabaikan edge case karena demo terlihat berhasil.
- Menggunakan status code HTTP yang tidak sesuai.
- Membiarkan endpoint admin tanpa authorization.
- Membuat query berulang dalam loop tanpa sadar.
- Menganggap semua error berasal dari frontend.
- Tidak menulis migration atau seed data yang idempotent.

## Fun Fact

Banyak konsep modern software engineering sebenarnya lahir dari masalah sederhana yang tumbuh besar. Queue muncul karena tidak semua pekerjaan harus selesai saat itu juga. Cache muncul karena membaca sumber data utama terus-menerus terlalu mahal. Load balancer muncul karena satu server tidak selamanya cukup. Dengan memahami asal masalahnya, kamu akan lebih mudah memilih teknologi yang tepat.

## Interview Tips

Saat interview, jangan langsung melompat ke jawaban final. Jelaskan asumsi, pilihan, dan trade-off. Interviewer biasanya ingin melihat cara berpikir. Untuk topik ini, jawaban yang kuat biasanya memuat:

1. Definisi singkat yang tepat.
2. Contoh real-world.
3. Edge case atau failure mode.
4. Trade-off solusi.
5. Cara menguji atau mengukur keberhasilan.

## Latihan Mandiri

Coba ambil fitur sederhana dari aplikasi Yomu, misalnya membaca materi dan mengerjakan quiz. Petakan input, proses, output, data yang disimpan, kemungkinan error, dan risiko keamanan. Setelah itu, tulis satu perbaikan kecil yang membuat fitur tersebut lebih production-ready. Latihan seperti ini akan membangun intuisi engineering yang jauh lebih kuat daripada sekadar membaca definisi.
', 'beginner', 12, 10),
        ('CI/CD Basics: Dari Test Otomatis sampai Deployment', 'Pelajari pipeline, build, test, artifact, deployment strategy, rollback, dan quality gate.', '# CI/CD Basics: Dari Test Otomatis sampai Deployment

## Ringkasan

Pelajari pipeline, build, test, artifact, deployment strategy, rollback, dan quality gate. Materi ini dirancang seperti modul bootcamp: dimulai dari intuisi, dilanjutkan dengan model mental, lalu ditutup dengan praktik industri dan tips interview. Fokus utamanya bukan menghafal istilah, melainkan memahami cara berpikir yang bisa dipakai saat membangun aplikasi nyata, membaca kode orang lain, melakukan debugging, dan menjelaskan keputusan teknis secara profesional.

## Kenapa Topik Ini Penting

Dalam software engineering, keputusan kecil sering punya dampak besar. Memilih struktur data, menentukan status code, menaruh validasi di layer yang tepat, atau memutuskan kapan memakai cache dapat memengaruhi performa, keamanan, dan pengalaman pengguna. Topik ini penting karena muncul berulang kali di proyek kampus, magang, pekerjaan full-time, dan interview software engineer.

Analogi sederhananya: membangun software mirip mengelola dapur restoran. Menu adalah fitur, pelanggan adalah user, database adalah gudang bahan, dan pipeline deployment adalah jalur penyajian. Restoran kecil bisa berjalan dengan satu koki dan satu catatan pesanan, tetapi restoran besar butuh alur kerja, pembagian peran, quality control, dan monitoring. Software juga begitu: semakin banyak user, semakin penting desain yang rapi.

## Konsep Utama

Kata kunci yang perlu kamu kuasai: **pipeline, build, test, artifact, rollback**.

Beberapa prinsip yang selalu berguna:

- Pahami masalah sebelum memilih teknologi.
- Ukur bottleneck dengan data, bukan perasaan.
- Buat solusi paling sederhana yang masih memenuhi kebutuhan.
- Dokumentasikan asumsi penting agar tim lain tidak menebak-nebak.
- Pisahkan konsep inti dari detail implementasi.

| Area | Pertanyaan Penting | Dampak |
|---|---|---|
| Correctness | Apakah hasilnya benar untuk edge case? | Mengurangi bug logic |
| Performance | Bagaimana perilaku saat data membesar? | Menjaga latency |
| Maintainability | Apakah engineer lain mudah memahami kode? | Mempercepat perubahan |
| Security | Apakah data dan akses terlindungi? | Mengurangi risiko production |

## Penjelasan Detail

Bayangkan kamu menerima requirement baru dari product manager. Requirement itu biasanya terdengar sederhana, misalnya "tampilkan daftar materi yang relevan untuk user". Namun di balik kalimat singkat itu ada banyak keputusan: data apa yang dibaca, bagaimana urutannya, bagaimana jika database lambat, bagaimana jika user belum login, dan bagaimana hasilnya diuji. Engineer yang matang akan memecah requirement menjadi beberapa bagian kecil, mengidentifikasi risiko, lalu memilih pendekatan yang bisa diverifikasi.

Pada topik ini, pola berpikir yang paling penting adalah melihat hubungan antara input, proses, dan output. Input bisa berupa request HTTP, data dari database, event dari message broker, atau konfigurasi environment. Proses bisa berupa validasi, transformasi, query, perhitungan, atau komunikasi ke service lain. Output bisa berupa response JSON, record baru, log audit, atau event lanjutan. Jika salah satu bagian tidak jelas, debugging akan menjadi lebih sulit.

Dalam praktik sehari-hari, jangan hanya bertanya "apakah kode ini jalan?". Tanyakan juga:

1. Apa yang terjadi jika input kosong, duplikat, terlalu besar, atau tidak valid?
2. Apakah solusi ini masih masuk akal ketika jumlah data naik 100 kali lipat?
3. Apakah error message cukup membantu tanpa membocorkan informasi sensitif?
4. Apakah perubahan ini mudah dites secara otomatis?
5. Apakah ada asumsi yang perlu ditulis di dokumentasi?

## Contoh Implementasi

Contoh berikut bukan template final, tetapi gambaran cara menyusun ide secara eksplisit:

```text
steps:
  - run: npm ci
  - run: npm run lint
  - run: ./gradlew test
```

Perhatikan bahwa contoh tersebut menonjolkan struktur berpikir, bukan sekadar sintaks. Sintaks bisa berbeda antara Java, TypeScript, Python, atau SQL, tetapi prinsipnya tetap sama: buat data mengalir lewat tahap yang jelas, kurangi coupling, dan pastikan kegagalan dapat diamati.

## Use Case Industri

Contoh industri: setiap pull request menjalankan lint dan test agar bug sederhana tertangkap sebelum masuk ke branch utama. Kasus seperti ini umum terjadi karena sistem production memiliki batasan nyata: latency, biaya cloud, reliabilitas, keamanan, dan koordinasi antar tim. Solusi yang terlihat bagus di demo lokal belum tentu cukup untuk production jika tidak mempertimbangkan volume data, konkurensi, dan failure mode.

Dalam tim profesional, keputusan teknis biasanya perlu dijelaskan dalam bentuk trade-off. Misalnya, memakai cache membuat response lebih cepat, tetapi menambah risiko stale data. Memecah service membuat deployment lebih independen, tetapi menambah kebutuhan observability dan network reliability. Menggunakan JWT membuat service stateless, tetapi perlu validasi signature dan expiry yang benar.

## Studi Kasus Terarah

Misalkan Yomu ingin menampilkan materi belajar yang relevan untuk mahasiswa yang sedang mempersiapkan interview. Requirement awalnya terdengar sederhana: user membuka halaman, melihat daftar bacaan, memilih materi, lalu mengerjakan quiz. Namun kalau fitur ini dipakai ribuan mahasiswa, ada beberapa pertanyaan desain yang harus dijawab. Apakah daftar bacaan selalu diambil dari database? Apakah setiap request perlu menghitung progress quiz dari awal? Apakah response untuk learner boleh mengandung jawaban benar? Apakah admin boleh mengubah quiz yang sudah pernah dikerjakan banyak user?

Dengan sudut pandang CI/CD Basics: Dari Test Otomatis sampai Deployment, kamu bisa membuat keputusan yang lebih tajam. Pertama, pisahkan data yang bersifat publik, data yang personal untuk user, dan data yang hanya boleh dilihat admin. Kedua, tentukan operasi mana yang harus konsisten kuat dan mana yang boleh eventually consistent. Ketiga, siapkan test untuk memastikan perubahan schema, perubahan kontrak API, dan perubahan business rule tidak merusak pengalaman belajar.

Pendekatan yang matang biasanya menghasilkan desain seperti ini:

- Endpoint learner hanya mengembalikan informasi yang aman untuk learner.
- Endpoint admin memiliki authorization dan audit log.
- Query yang sering dipakai diberi index atau cache jika benar-benar terbukti bottleneck.
- Seed data dibuat idempotent agar environment lokal, staging, dan demo bisa diisi ulang tanpa duplikasi.
- Error response dibuat konsisten supaya frontend bisa menampilkan pesan yang jelas.

## Production Readiness Checklist

Sebelum sebuah fitur dianggap siap production, engineer perlu mengecek lebih dari sekadar "berhasil dijalankan". Gunakan checklist berikut sebagai kebiasaan:

1. **Correctness:** semua aturan bisnis utama punya test otomatis.
2. **Observability:** log cukup untuk menelusuri request bermasalah.
3. **Security:** endpoint sensitif terlindungi role, token, atau gateway policy.
4. **Performance:** query utama dan struktur data sudah dipikirkan untuk pertumbuhan data.
5. **Resilience:** error dari dependency eksternal tidak membuat seluruh aplikasi gagal tanpa pesan.
6. **Maintainability:** kode mengikuti batas layer yang jelas dan tidak mencampur terlalu banyak tanggung jawab.

Checklist ini bukan birokrasi. Ia membantu tim menghindari bug yang biasanya baru terlihat saat demo besar, traffic naik, atau ada perubahan requirement mendadak.

## Best Practices

- Mulai dari requirement dan constraint, bukan dari library favorit.
- Gunakan nama variabel, endpoint, dan tabel yang konsisten.
- Tambahkan test untuk happy path, edge case, dan failure case.
- Jangan menyimpan secret di source code.
- Catat keputusan penting di README atau ADR sederhana.
- Gunakan logging yang membantu debugging tanpa membocorkan data sensitif.
- Review performa query dan struktur data sebelum traffic membesar.

## Common Mistakes

Kesalahan yang sering dilakukan beginner adalah membuat solusi yang hanya bekerja untuk contoh kecil. Misalnya, nested loop tidak terasa lambat saat data hanya 10 baris, tetapi bisa menghancurkan latency saat data menjadi 100.000 baris. Kesalahan lain adalah mencampur validasi, business logic, dan akses database dalam satu fungsi besar sehingga sulit dites dan sulit diubah.

Kesalahan lain yang sering muncul:

- Mengabaikan edge case karena demo terlihat berhasil.
- Menggunakan status code HTTP yang tidak sesuai.
- Membiarkan endpoint admin tanpa authorization.
- Membuat query berulang dalam loop tanpa sadar.
- Menganggap semua error berasal dari frontend.
- Tidak menulis migration atau seed data yang idempotent.

## Fun Fact

Banyak konsep modern software engineering sebenarnya lahir dari masalah sederhana yang tumbuh besar. Queue muncul karena tidak semua pekerjaan harus selesai saat itu juga. Cache muncul karena membaca sumber data utama terus-menerus terlalu mahal. Load balancer muncul karena satu server tidak selamanya cukup. Dengan memahami asal masalahnya, kamu akan lebih mudah memilih teknologi yang tepat.

## Interview Tips

Saat interview, jangan langsung melompat ke jawaban final. Jelaskan asumsi, pilihan, dan trade-off. Interviewer biasanya ingin melihat cara berpikir. Untuk topik ini, jawaban yang kuat biasanya memuat:

1. Definisi singkat yang tepat.
2. Contoh real-world.
3. Edge case atau failure mode.
4. Trade-off solusi.
5. Cara menguji atau mengukur keberhasilan.

## Latihan Mandiri

Coba ambil fitur sederhana dari aplikasi Yomu, misalnya membaca materi dan mengerjakan quiz. Petakan input, proses, output, data yang disimpan, kemungkinan error, dan risiko keamanan. Setelah itu, tulis satu perbaikan kecil yang membuat fitur tersebut lebih production-ready. Latihan seperti ini akan membangun intuisi engineering yang jauh lebih kuat daripada sekadar membaca definisi.
', 'intermediate', 15, 20),
        ('Docker Fundamentals untuk Development dan Deployment', 'Pahami image, container, Dockerfile, volume, network, environment variable, dan praktik containerisasi aplikasi.', '# Docker Fundamentals untuk Development dan Deployment

## Ringkasan

Pahami image, container, Dockerfile, volume, network, environment variable, dan praktik containerisasi aplikasi. Materi ini dirancang seperti modul bootcamp: dimulai dari intuisi, dilanjutkan dengan model mental, lalu ditutup dengan praktik industri dan tips interview. Fokus utamanya bukan menghafal istilah, melainkan memahami cara berpikir yang bisa dipakai saat membangun aplikasi nyata, membaca kode orang lain, melakukan debugging, dan menjelaskan keputusan teknis secara profesional.

## Kenapa Topik Ini Penting

Dalam software engineering, keputusan kecil sering punya dampak besar. Memilih struktur data, menentukan status code, menaruh validasi di layer yang tepat, atau memutuskan kapan memakai cache dapat memengaruhi performa, keamanan, dan pengalaman pengguna. Topik ini penting karena muncul berulang kali di proyek kampus, magang, pekerjaan full-time, dan interview software engineer.

Analogi sederhananya: membangun software mirip mengelola dapur restoran. Menu adalah fitur, pelanggan adalah user, database adalah gudang bahan, dan pipeline deployment adalah jalur penyajian. Restoran kecil bisa berjalan dengan satu koki dan satu catatan pesanan, tetapi restoran besar butuh alur kerja, pembagian peran, quality control, dan monitoring. Software juga begitu: semakin banyak user, semakin penting desain yang rapi.

## Konsep Utama

Kata kunci yang perlu kamu kuasai: **image, container, Dockerfile, volume, network**.

Beberapa prinsip yang selalu berguna:

- Pahami masalah sebelum memilih teknologi.
- Ukur bottleneck dengan data, bukan perasaan.
- Buat solusi paling sederhana yang masih memenuhi kebutuhan.
- Dokumentasikan asumsi penting agar tim lain tidak menebak-nebak.
- Pisahkan konsep inti dari detail implementasi.

| Area | Pertanyaan Penting | Dampak |
|---|---|---|
| Correctness | Apakah hasilnya benar untuk edge case? | Mengurangi bug logic |
| Performance | Bagaimana perilaku saat data membesar? | Menjaga latency |
| Maintainability | Apakah engineer lain mudah memahami kode? | Mempercepat perubahan |
| Security | Apakah data dan akses terlindungi? | Mengurangi risiko production |

## Penjelasan Detail

Bayangkan kamu menerima requirement baru dari product manager. Requirement itu biasanya terdengar sederhana, misalnya "tampilkan daftar materi yang relevan untuk user". Namun di balik kalimat singkat itu ada banyak keputusan: data apa yang dibaca, bagaimana urutannya, bagaimana jika database lambat, bagaimana jika user belum login, dan bagaimana hasilnya diuji. Engineer yang matang akan memecah requirement menjadi beberapa bagian kecil, mengidentifikasi risiko, lalu memilih pendekatan yang bisa diverifikasi.

Pada topik ini, pola berpikir yang paling penting adalah melihat hubungan antara input, proses, dan output. Input bisa berupa request HTTP, data dari database, event dari message broker, atau konfigurasi environment. Proses bisa berupa validasi, transformasi, query, perhitungan, atau komunikasi ke service lain. Output bisa berupa response JSON, record baru, log audit, atau event lanjutan. Jika salah satu bagian tidak jelas, debugging akan menjadi lebih sulit.

Dalam praktik sehari-hari, jangan hanya bertanya "apakah kode ini jalan?". Tanyakan juga:

1. Apa yang terjadi jika input kosong, duplikat, terlalu besar, atau tidak valid?
2. Apakah solusi ini masih masuk akal ketika jumlah data naik 100 kali lipat?
3. Apakah error message cukup membantu tanpa membocorkan informasi sensitif?
4. Apakah perubahan ini mudah dites secara otomatis?
5. Apakah ada asumsi yang perlu ditulis di dokumentasi?

## Contoh Implementasi

Contoh berikut bukan template final, tetapi gambaran cara menyusun ide secara eksplisit:

```text
FROM eclipse-temurin:21-jre
COPY app.jar app.jar
ENTRYPOINT ["java", "-jar", "app.jar"]
```

Perhatikan bahwa contoh tersebut menonjolkan struktur berpikir, bukan sekadar sintaks. Sintaks bisa berbeda antara Java, TypeScript, Python, atau SQL, tetapi prinsipnya tetap sama: buat data mengalir lewat tahap yang jelas, kurangi coupling, dan pastikan kegagalan dapat diamati.

## Use Case Industri

Contoh industri: tim backend menjalankan PostgreSQL, API, dan worker lokal dengan konfigurasi yang sama di semua laptop developer. Kasus seperti ini umum terjadi karena sistem production memiliki batasan nyata: latency, biaya cloud, reliabilitas, keamanan, dan koordinasi antar tim. Solusi yang terlihat bagus di demo lokal belum tentu cukup untuk production jika tidak mempertimbangkan volume data, konkurensi, dan failure mode.

Dalam tim profesional, keputusan teknis biasanya perlu dijelaskan dalam bentuk trade-off. Misalnya, memakai cache membuat response lebih cepat, tetapi menambah risiko stale data. Memecah service membuat deployment lebih independen, tetapi menambah kebutuhan observability dan network reliability. Menggunakan JWT membuat service stateless, tetapi perlu validasi signature dan expiry yang benar.

## Studi Kasus Terarah

Misalkan Yomu ingin menampilkan materi belajar yang relevan untuk mahasiswa yang sedang mempersiapkan interview. Requirement awalnya terdengar sederhana: user membuka halaman, melihat daftar bacaan, memilih materi, lalu mengerjakan quiz. Namun kalau fitur ini dipakai ribuan mahasiswa, ada beberapa pertanyaan desain yang harus dijawab. Apakah daftar bacaan selalu diambil dari database? Apakah setiap request perlu menghitung progress quiz dari awal? Apakah response untuk learner boleh mengandung jawaban benar? Apakah admin boleh mengubah quiz yang sudah pernah dikerjakan banyak user?

Dengan sudut pandang Docker Fundamentals untuk Development dan Deployment, kamu bisa membuat keputusan yang lebih tajam. Pertama, pisahkan data yang bersifat publik, data yang personal untuk user, dan data yang hanya boleh dilihat admin. Kedua, tentukan operasi mana yang harus konsisten kuat dan mana yang boleh eventually consistent. Ketiga, siapkan test untuk memastikan perubahan schema, perubahan kontrak API, dan perubahan business rule tidak merusak pengalaman belajar.

Pendekatan yang matang biasanya menghasilkan desain seperti ini:

- Endpoint learner hanya mengembalikan informasi yang aman untuk learner.
- Endpoint admin memiliki authorization dan audit log.
- Query yang sering dipakai diberi index atau cache jika benar-benar terbukti bottleneck.
- Seed data dibuat idempotent agar environment lokal, staging, dan demo bisa diisi ulang tanpa duplikasi.
- Error response dibuat konsisten supaya frontend bisa menampilkan pesan yang jelas.

## Production Readiness Checklist

Sebelum sebuah fitur dianggap siap production, engineer perlu mengecek lebih dari sekadar "berhasil dijalankan". Gunakan checklist berikut sebagai kebiasaan:

1. **Correctness:** semua aturan bisnis utama punya test otomatis.
2. **Observability:** log cukup untuk menelusuri request bermasalah.
3. **Security:** endpoint sensitif terlindungi role, token, atau gateway policy.
4. **Performance:** query utama dan struktur data sudah dipikirkan untuk pertumbuhan data.
5. **Resilience:** error dari dependency eksternal tidak membuat seluruh aplikasi gagal tanpa pesan.
6. **Maintainability:** kode mengikuti batas layer yang jelas dan tidak mencampur terlalu banyak tanggung jawab.

Checklist ini bukan birokrasi. Ia membantu tim menghindari bug yang biasanya baru terlihat saat demo besar, traffic naik, atau ada perubahan requirement mendadak.

## Best Practices

- Mulai dari requirement dan constraint, bukan dari library favorit.
- Gunakan nama variabel, endpoint, dan tabel yang konsisten.
- Tambahkan test untuk happy path, edge case, dan failure case.
- Jangan menyimpan secret di source code.
- Catat keputusan penting di README atau ADR sederhana.
- Gunakan logging yang membantu debugging tanpa membocorkan data sensitif.
- Review performa query dan struktur data sebelum traffic membesar.

## Common Mistakes

Kesalahan yang sering dilakukan beginner adalah membuat solusi yang hanya bekerja untuk contoh kecil. Misalnya, nested loop tidak terasa lambat saat data hanya 10 baris, tetapi bisa menghancurkan latency saat data menjadi 100.000 baris. Kesalahan lain adalah mencampur validasi, business logic, dan akses database dalam satu fungsi besar sehingga sulit dites dan sulit diubah.

Kesalahan lain yang sering muncul:

- Mengabaikan edge case karena demo terlihat berhasil.
- Menggunakan status code HTTP yang tidak sesuai.
- Membiarkan endpoint admin tanpa authorization.
- Membuat query berulang dalam loop tanpa sadar.
- Menganggap semua error berasal dari frontend.
- Tidak menulis migration atau seed data yang idempotent.

## Fun Fact

Banyak konsep modern software engineering sebenarnya lahir dari masalah sederhana yang tumbuh besar. Queue muncul karena tidak semua pekerjaan harus selesai saat itu juga. Cache muncul karena membaca sumber data utama terus-menerus terlalu mahal. Load balancer muncul karena satu server tidak selamanya cukup. Dengan memahami asal masalahnya, kamu akan lebih mudah memilih teknologi yang tepat.

## Interview Tips

Saat interview, jangan langsung melompat ke jawaban final. Jelaskan asumsi, pilihan, dan trade-off. Interviewer biasanya ingin melihat cara berpikir. Untuk topik ini, jawaban yang kuat biasanya memuat:

1. Definisi singkat yang tepat.
2. Contoh real-world.
3. Edge case atau failure mode.
4. Trade-off solusi.
5. Cara menguji atau mengukur keberhasilan.

## Latihan Mandiri

Coba ambil fitur sederhana dari aplikasi Yomu, misalnya membaca materi dan mengerjakan quiz. Petakan input, proses, output, data yang disimpan, kemungkinan error, dan risiko keamanan. Setelah itu, tulis satu perbaikan kecil yang membuat fitur tersebut lebih production-ready. Latihan seperti ini akan membangun intuisi engineering yang jauh lebih kuat daripada sekadar membaca definisi.
', 'intermediate', 15, 20),
        ('Caching Strategies untuk Aplikasi Cepat dan Stabil', 'Bahas cache-aside, TTL, invalidation, stale data, Redis, CDN, dan kapan cache justru berbahaya.', '# Caching Strategies untuk Aplikasi Cepat dan Stabil

## Ringkasan

Bahas cache-aside, TTL, invalidation, stale data, Redis, CDN, dan kapan cache justru berbahaya. Materi ini dirancang seperti modul bootcamp: dimulai dari intuisi, dilanjutkan dengan model mental, lalu ditutup dengan praktik industri dan tips interview. Fokus utamanya bukan menghafal istilah, melainkan memahami cara berpikir yang bisa dipakai saat membangun aplikasi nyata, membaca kode orang lain, melakukan debugging, dan menjelaskan keputusan teknis secara profesional.

## Kenapa Topik Ini Penting

Dalam software engineering, keputusan kecil sering punya dampak besar. Memilih struktur data, menentukan status code, menaruh validasi di layer yang tepat, atau memutuskan kapan memakai cache dapat memengaruhi performa, keamanan, dan pengalaman pengguna. Topik ini penting karena muncul berulang kali di proyek kampus, magang, pekerjaan full-time, dan interview software engineer.

Analogi sederhananya: membangun software mirip mengelola dapur restoran. Menu adalah fitur, pelanggan adalah user, database adalah gudang bahan, dan pipeline deployment adalah jalur penyajian. Restoran kecil bisa berjalan dengan satu koki dan satu catatan pesanan, tetapi restoran besar butuh alur kerja, pembagian peran, quality control, dan monitoring. Software juga begitu: semakin banyak user, semakin penting desain yang rapi.

## Konsep Utama

Kata kunci yang perlu kamu kuasai: **cache-aside, TTL, invalidation, Redis, CDN**.

Beberapa prinsip yang selalu berguna:

- Pahami masalah sebelum memilih teknologi.
- Ukur bottleneck dengan data, bukan perasaan.
- Buat solusi paling sederhana yang masih memenuhi kebutuhan.
- Dokumentasikan asumsi penting agar tim lain tidak menebak-nebak.
- Pisahkan konsep inti dari detail implementasi.

| Area | Pertanyaan Penting | Dampak |
|---|---|---|
| Correctness | Apakah hasilnya benar untuk edge case? | Mengurangi bug logic |
| Performance | Bagaimana perilaku saat data membesar? | Menjaga latency |
| Maintainability | Apakah engineer lain mudah memahami kode? | Mempercepat perubahan |
| Security | Apakah data dan akses terlindungi? | Mengurangi risiko production |

## Penjelasan Detail

Bayangkan kamu menerima requirement baru dari product manager. Requirement itu biasanya terdengar sederhana, misalnya "tampilkan daftar materi yang relevan untuk user". Namun di balik kalimat singkat itu ada banyak keputusan: data apa yang dibaca, bagaimana urutannya, bagaimana jika database lambat, bagaimana jika user belum login, dan bagaimana hasilnya diuji. Engineer yang matang akan memecah requirement menjadi beberapa bagian kecil, mengidentifikasi risiko, lalu memilih pendekatan yang bisa diverifikasi.

Pada topik ini, pola berpikir yang paling penting adalah melihat hubungan antara input, proses, dan output. Input bisa berupa request HTTP, data dari database, event dari message broker, atau konfigurasi environment. Proses bisa berupa validasi, transformasi, query, perhitungan, atau komunikasi ke service lain. Output bisa berupa response JSON, record baru, log audit, atau event lanjutan. Jika salah satu bagian tidak jelas, debugging akan menjadi lebih sulit.

Dalam praktik sehari-hari, jangan hanya bertanya "apakah kode ini jalan?". Tanyakan juga:

1. Apa yang terjadi jika input kosong, duplikat, terlalu besar, atau tidak valid?
2. Apakah solusi ini masih masuk akal ketika jumlah data naik 100 kali lipat?
3. Apakah error message cukup membantu tanpa membocorkan informasi sensitif?
4. Apakah perubahan ini mudah dites secara otomatis?
5. Apakah ada asumsi yang perlu ditulis di dokumentasi?

## Contoh Implementasi

Contoh berikut bukan template final, tetapi gambaran cara menyusun ide secara eksplisit:

```text
value = cache.get(key);
if (value == null) {
  value = repository.findById(id);
  cache.put(key, value, ttl);
}
```

Perhatikan bahwa contoh tersebut menonjolkan struktur berpikir, bukan sekadar sintaks. Sintaks bisa berbeda antara Java, TypeScript, Python, atau SQL, tetapi prinsipnya tetap sama: buat data mengalir lewat tahap yang jelas, kurangi coupling, dan pastikan kegagalan dapat diamati.

## Use Case Industri

Contoh industri: halaman katalog produk memakai cache untuk data populer tetapi tetap invalidasi saat stok berubah. Kasus seperti ini umum terjadi karena sistem production memiliki batasan nyata: latency, biaya cloud, reliabilitas, keamanan, dan koordinasi antar tim. Solusi yang terlihat bagus di demo lokal belum tentu cukup untuk production jika tidak mempertimbangkan volume data, konkurensi, dan failure mode.

Dalam tim profesional, keputusan teknis biasanya perlu dijelaskan dalam bentuk trade-off. Misalnya, memakai cache membuat response lebih cepat, tetapi menambah risiko stale data. Memecah service membuat deployment lebih independen, tetapi menambah kebutuhan observability dan network reliability. Menggunakan JWT membuat service stateless, tetapi perlu validasi signature dan expiry yang benar.

## Studi Kasus Terarah

Misalkan Yomu ingin menampilkan materi belajar yang relevan untuk mahasiswa yang sedang mempersiapkan interview. Requirement awalnya terdengar sederhana: user membuka halaman, melihat daftar bacaan, memilih materi, lalu mengerjakan quiz. Namun kalau fitur ini dipakai ribuan mahasiswa, ada beberapa pertanyaan desain yang harus dijawab. Apakah daftar bacaan selalu diambil dari database? Apakah setiap request perlu menghitung progress quiz dari awal? Apakah response untuk learner boleh mengandung jawaban benar? Apakah admin boleh mengubah quiz yang sudah pernah dikerjakan banyak user?

Dengan sudut pandang Caching Strategies untuk Aplikasi Cepat dan Stabil, kamu bisa membuat keputusan yang lebih tajam. Pertama, pisahkan data yang bersifat publik, data yang personal untuk user, dan data yang hanya boleh dilihat admin. Kedua, tentukan operasi mana yang harus konsisten kuat dan mana yang boleh eventually consistent. Ketiga, siapkan test untuk memastikan perubahan schema, perubahan kontrak API, dan perubahan business rule tidak merusak pengalaman belajar.

Pendekatan yang matang biasanya menghasilkan desain seperti ini:

- Endpoint learner hanya mengembalikan informasi yang aman untuk learner.
- Endpoint admin memiliki authorization dan audit log.
- Query yang sering dipakai diberi index atau cache jika benar-benar terbukti bottleneck.
- Seed data dibuat idempotent agar environment lokal, staging, dan demo bisa diisi ulang tanpa duplikasi.
- Error response dibuat konsisten supaya frontend bisa menampilkan pesan yang jelas.

## Production Readiness Checklist

Sebelum sebuah fitur dianggap siap production, engineer perlu mengecek lebih dari sekadar "berhasil dijalankan". Gunakan checklist berikut sebagai kebiasaan:

1. **Correctness:** semua aturan bisnis utama punya test otomatis.
2. **Observability:** log cukup untuk menelusuri request bermasalah.
3. **Security:** endpoint sensitif terlindungi role, token, atau gateway policy.
4. **Performance:** query utama dan struktur data sudah dipikirkan untuk pertumbuhan data.
5. **Resilience:** error dari dependency eksternal tidak membuat seluruh aplikasi gagal tanpa pesan.
6. **Maintainability:** kode mengikuti batas layer yang jelas dan tidak mencampur terlalu banyak tanggung jawab.

Checklist ini bukan birokrasi. Ia membantu tim menghindari bug yang biasanya baru terlihat saat demo besar, traffic naik, atau ada perubahan requirement mendadak.

## Best Practices

- Mulai dari requirement dan constraint, bukan dari library favorit.
- Gunakan nama variabel, endpoint, dan tabel yang konsisten.
- Tambahkan test untuk happy path, edge case, dan failure case.
- Jangan menyimpan secret di source code.
- Catat keputusan penting di README atau ADR sederhana.
- Gunakan logging yang membantu debugging tanpa membocorkan data sensitif.
- Review performa query dan struktur data sebelum traffic membesar.

## Common Mistakes

Kesalahan yang sering dilakukan beginner adalah membuat solusi yang hanya bekerja untuk contoh kecil. Misalnya, nested loop tidak terasa lambat saat data hanya 10 baris, tetapi bisa menghancurkan latency saat data menjadi 100.000 baris. Kesalahan lain adalah mencampur validasi, business logic, dan akses database dalam satu fungsi besar sehingga sulit dites dan sulit diubah.

Kesalahan lain yang sering muncul:

- Mengabaikan edge case karena demo terlihat berhasil.
- Menggunakan status code HTTP yang tidak sesuai.
- Membiarkan endpoint admin tanpa authorization.
- Membuat query berulang dalam loop tanpa sadar.
- Menganggap semua error berasal dari frontend.
- Tidak menulis migration atau seed data yang idempotent.

## Fun Fact

Banyak konsep modern software engineering sebenarnya lahir dari masalah sederhana yang tumbuh besar. Queue muncul karena tidak semua pekerjaan harus selesai saat itu juga. Cache muncul karena membaca sumber data utama terus-menerus terlalu mahal. Load balancer muncul karena satu server tidak selamanya cukup. Dengan memahami asal masalahnya, kamu akan lebih mudah memilih teknologi yang tepat.

## Interview Tips

Saat interview, jangan langsung melompat ke jawaban final. Jelaskan asumsi, pilihan, dan trade-off. Interviewer biasanya ingin melihat cara berpikir. Untuk topik ini, jawaban yang kuat biasanya memuat:

1. Definisi singkat yang tepat.
2. Contoh real-world.
3. Edge case atau failure mode.
4. Trade-off solusi.
5. Cara menguji atau mengukur keberhasilan.

## Latihan Mandiri

Coba ambil fitur sederhana dari aplikasi Yomu, misalnya membaca materi dan mengerjakan quiz. Petakan input, proses, output, data yang disimpan, kemungkinan error, dan risiko keamanan. Setelah itu, tulis satu perbaikan kecil yang membuat fitur tersebut lebih production-ready. Latihan seperti ini akan membangun intuisi engineering yang jauh lebih kuat daripada sekadar membaca definisi.
', 'advanced', 18, 35),
        ('SQL vs NoSQL dan Cara Memilih Database', 'Bandingkan relational database dan NoSQL dari sisi schema, transaksi, query pattern, scaling, dan consistency.', '# SQL vs NoSQL dan Cara Memilih Database

## Ringkasan

Bandingkan relational database dan NoSQL dari sisi schema, transaksi, query pattern, scaling, dan consistency. Materi ini dirancang seperti modul bootcamp: dimulai dari intuisi, dilanjutkan dengan model mental, lalu ditutup dengan praktik industri dan tips interview. Fokus utamanya bukan menghafal istilah, melainkan memahami cara berpikir yang bisa dipakai saat membangun aplikasi nyata, membaca kode orang lain, melakukan debugging, dan menjelaskan keputusan teknis secara profesional.

## Kenapa Topik Ini Penting

Dalam software engineering, keputusan kecil sering punya dampak besar. Memilih struktur data, menentukan status code, menaruh validasi di layer yang tepat, atau memutuskan kapan memakai cache dapat memengaruhi performa, keamanan, dan pengalaman pengguna. Topik ini penting karena muncul berulang kali di proyek kampus, magang, pekerjaan full-time, dan interview software engineer.

Analogi sederhananya: membangun software mirip mengelola dapur restoran. Menu adalah fitur, pelanggan adalah user, database adalah gudang bahan, dan pipeline deployment adalah jalur penyajian. Restoran kecil bisa berjalan dengan satu koki dan satu catatan pesanan, tetapi restoran besar butuh alur kerja, pembagian peran, quality control, dan monitoring. Software juga begitu: semakin banyak user, semakin penting desain yang rapi.

## Konsep Utama

Kata kunci yang perlu kamu kuasai: **SQL, NoSQL, schema, consistency, query pattern**.

Beberapa prinsip yang selalu berguna:

- Pahami masalah sebelum memilih teknologi.
- Ukur bottleneck dengan data, bukan perasaan.
- Buat solusi paling sederhana yang masih memenuhi kebutuhan.
- Dokumentasikan asumsi penting agar tim lain tidak menebak-nebak.
- Pisahkan konsep inti dari detail implementasi.

| Area | Pertanyaan Penting | Dampak |
|---|---|---|
| Correctness | Apakah hasilnya benar untuk edge case? | Mengurangi bug logic |
| Performance | Bagaimana perilaku saat data membesar? | Menjaga latency |
| Maintainability | Apakah engineer lain mudah memahami kode? | Mempercepat perubahan |
| Security | Apakah data dan akses terlindungi? | Mengurangi risiko production |

## Penjelasan Detail

Bayangkan kamu menerima requirement baru dari product manager. Requirement itu biasanya terdengar sederhana, misalnya "tampilkan daftar materi yang relevan untuk user". Namun di balik kalimat singkat itu ada banyak keputusan: data apa yang dibaca, bagaimana urutannya, bagaimana jika database lambat, bagaimana jika user belum login, dan bagaimana hasilnya diuji. Engineer yang matang akan memecah requirement menjadi beberapa bagian kecil, mengidentifikasi risiko, lalu memilih pendekatan yang bisa diverifikasi.

Pada topik ini, pola berpikir yang paling penting adalah melihat hubungan antara input, proses, dan output. Input bisa berupa request HTTP, data dari database, event dari message broker, atau konfigurasi environment. Proses bisa berupa validasi, transformasi, query, perhitungan, atau komunikasi ke service lain. Output bisa berupa response JSON, record baru, log audit, atau event lanjutan. Jika salah satu bagian tidak jelas, debugging akan menjadi lebih sulit.

Dalam praktik sehari-hari, jangan hanya bertanya "apakah kode ini jalan?". Tanyakan juga:

1. Apa yang terjadi jika input kosong, duplikat, terlalu besar, atau tidak valid?
2. Apakah solusi ini masih masuk akal ketika jumlah data naik 100 kali lipat?
3. Apakah error message cukup membantu tanpa membocorkan informasi sensitif?
4. Apakah perubahan ini mudah dites secara otomatis?
5. Apakah ada asumsi yang perlu ditulis di dokumentasi?

## Contoh Implementasi

Contoh berikut bukan template final, tetapi gambaran cara menyusun ide secara eksplisit:

```text
SELECT * FROM orders WHERE customer_id = 42 ORDER BY created_at DESC;
```

Perhatikan bahwa contoh tersebut menonjolkan struktur berpikir, bukan sekadar sintaks. Sintaks bisa berbeda antara Java, TypeScript, Python, atau SQL, tetapi prinsipnya tetap sama: buat data mengalir lewat tahap yang jelas, kurangi coupling, dan pastikan kegagalan dapat diamati.

## Use Case Industri

Contoh industri: sistem order memakai PostgreSQL untuk transaksi, sedangkan event clickstream disimpan di database analitik atau document store. Kasus seperti ini umum terjadi karena sistem production memiliki batasan nyata: latency, biaya cloud, reliabilitas, keamanan, dan koordinasi antar tim. Solusi yang terlihat bagus di demo lokal belum tentu cukup untuk production jika tidak mempertimbangkan volume data, konkurensi, dan failure mode.

Dalam tim profesional, keputusan teknis biasanya perlu dijelaskan dalam bentuk trade-off. Misalnya, memakai cache membuat response lebih cepat, tetapi menambah risiko stale data. Memecah service membuat deployment lebih independen, tetapi menambah kebutuhan observability dan network reliability. Menggunakan JWT membuat service stateless, tetapi perlu validasi signature dan expiry yang benar.

## Studi Kasus Terarah

Misalkan Yomu ingin menampilkan materi belajar yang relevan untuk mahasiswa yang sedang mempersiapkan interview. Requirement awalnya terdengar sederhana: user membuka halaman, melihat daftar bacaan, memilih materi, lalu mengerjakan quiz. Namun kalau fitur ini dipakai ribuan mahasiswa, ada beberapa pertanyaan desain yang harus dijawab. Apakah daftar bacaan selalu diambil dari database? Apakah setiap request perlu menghitung progress quiz dari awal? Apakah response untuk learner boleh mengandung jawaban benar? Apakah admin boleh mengubah quiz yang sudah pernah dikerjakan banyak user?

Dengan sudut pandang SQL vs NoSQL dan Cara Memilih Database, kamu bisa membuat keputusan yang lebih tajam. Pertama, pisahkan data yang bersifat publik, data yang personal untuk user, dan data yang hanya boleh dilihat admin. Kedua, tentukan operasi mana yang harus konsisten kuat dan mana yang boleh eventually consistent. Ketiga, siapkan test untuk memastikan perubahan schema, perubahan kontrak API, dan perubahan business rule tidak merusak pengalaman belajar.

Pendekatan yang matang biasanya menghasilkan desain seperti ini:

- Endpoint learner hanya mengembalikan informasi yang aman untuk learner.
- Endpoint admin memiliki authorization dan audit log.
- Query yang sering dipakai diberi index atau cache jika benar-benar terbukti bottleneck.
- Seed data dibuat idempotent agar environment lokal, staging, dan demo bisa diisi ulang tanpa duplikasi.
- Error response dibuat konsisten supaya frontend bisa menampilkan pesan yang jelas.

## Production Readiness Checklist

Sebelum sebuah fitur dianggap siap production, engineer perlu mengecek lebih dari sekadar "berhasil dijalankan". Gunakan checklist berikut sebagai kebiasaan:

1. **Correctness:** semua aturan bisnis utama punya test otomatis.
2. **Observability:** log cukup untuk menelusuri request bermasalah.
3. **Security:** endpoint sensitif terlindungi role, token, atau gateway policy.
4. **Performance:** query utama dan struktur data sudah dipikirkan untuk pertumbuhan data.
5. **Resilience:** error dari dependency eksternal tidak membuat seluruh aplikasi gagal tanpa pesan.
6. **Maintainability:** kode mengikuti batas layer yang jelas dan tidak mencampur terlalu banyak tanggung jawab.

Checklist ini bukan birokrasi. Ia membantu tim menghindari bug yang biasanya baru terlihat saat demo besar, traffic naik, atau ada perubahan requirement mendadak.

## Best Practices

- Mulai dari requirement dan constraint, bukan dari library favorit.
- Gunakan nama variabel, endpoint, dan tabel yang konsisten.
- Tambahkan test untuk happy path, edge case, dan failure case.
- Jangan menyimpan secret di source code.
- Catat keputusan penting di README atau ADR sederhana.
- Gunakan logging yang membantu debugging tanpa membocorkan data sensitif.
- Review performa query dan struktur data sebelum traffic membesar.

## Common Mistakes

Kesalahan yang sering dilakukan beginner adalah membuat solusi yang hanya bekerja untuk contoh kecil. Misalnya, nested loop tidak terasa lambat saat data hanya 10 baris, tetapi bisa menghancurkan latency saat data menjadi 100.000 baris. Kesalahan lain adalah mencampur validasi, business logic, dan akses database dalam satu fungsi besar sehingga sulit dites dan sulit diubah.

Kesalahan lain yang sering muncul:

- Mengabaikan edge case karena demo terlihat berhasil.
- Menggunakan status code HTTP yang tidak sesuai.
- Membiarkan endpoint admin tanpa authorization.
- Membuat query berulang dalam loop tanpa sadar.
- Menganggap semua error berasal dari frontend.
- Tidak menulis migration atau seed data yang idempotent.

## Fun Fact

Banyak konsep modern software engineering sebenarnya lahir dari masalah sederhana yang tumbuh besar. Queue muncul karena tidak semua pekerjaan harus selesai saat itu juga. Cache muncul karena membaca sumber data utama terus-menerus terlalu mahal. Load balancer muncul karena satu server tidak selamanya cukup. Dengan memahami asal masalahnya, kamu akan lebih mudah memilih teknologi yang tepat.

## Interview Tips

Saat interview, jangan langsung melompat ke jawaban final. Jelaskan asumsi, pilihan, dan trade-off. Interviewer biasanya ingin melihat cara berpikir. Untuk topik ini, jawaban yang kuat biasanya memuat:

1. Definisi singkat yang tepat.
2. Contoh real-world.
3. Edge case atau failure mode.
4. Trade-off solusi.
5. Cara menguji atau mengukur keberhasilan.

## Latihan Mandiri

Coba ambil fitur sederhana dari aplikasi Yomu, misalnya membaca materi dan mengerjakan quiz. Petakan input, proses, output, data yang disimpan, kemungkinan error, dan risiko keamanan. Setelah itu, tulis satu perbaikan kecil yang membuat fitur tersebut lebih production-ready. Latihan seperti ini akan membangun intuisi engineering yang jauh lebih kuat daripada sekadar membaca definisi.
', 'intermediate', 15, 20),
        ('System Design Basics: Dari Requirement ke Arsitektur', 'Materi ini melatih cara membaca requirement, memperkirakan traffic, memilih komponen, dan menggambar arsitektur awal.', '# System Design Basics: Dari Requirement ke Arsitektur

## Ringkasan

Materi ini melatih cara membaca requirement, memperkirakan traffic, memilih komponen, dan menggambar arsitektur awal. Materi ini dirancang seperti modul bootcamp: dimulai dari intuisi, dilanjutkan dengan model mental, lalu ditutup dengan praktik industri dan tips interview. Fokus utamanya bukan menghafal istilah, melainkan memahami cara berpikir yang bisa dipakai saat membangun aplikasi nyata, membaca kode orang lain, melakukan debugging, dan menjelaskan keputusan teknis secara profesional.

## Kenapa Topik Ini Penting

Dalam software engineering, keputusan kecil sering punya dampak besar. Memilih struktur data, menentukan status code, menaruh validasi di layer yang tepat, atau memutuskan kapan memakai cache dapat memengaruhi performa, keamanan, dan pengalaman pengguna. Topik ini penting karena muncul berulang kali di proyek kampus, magang, pekerjaan full-time, dan interview software engineer.

Analogi sederhananya: membangun software mirip mengelola dapur restoran. Menu adalah fitur, pelanggan adalah user, database adalah gudang bahan, dan pipeline deployment adalah jalur penyajian. Restoran kecil bisa berjalan dengan satu koki dan satu catatan pesanan, tetapi restoran besar butuh alur kerja, pembagian peran, quality control, dan monitoring. Software juga begitu: semakin banyak user, semakin penting desain yang rapi.

## Konsep Utama

Kata kunci yang perlu kamu kuasai: **requirement, capacity, component, database, trade-off**.

Beberapa prinsip yang selalu berguna:

- Pahami masalah sebelum memilih teknologi.
- Ukur bottleneck dengan data, bukan perasaan.
- Buat solusi paling sederhana yang masih memenuhi kebutuhan.
- Dokumentasikan asumsi penting agar tim lain tidak menebak-nebak.
- Pisahkan konsep inti dari detail implementasi.

| Area | Pertanyaan Penting | Dampak |
|---|---|---|
| Correctness | Apakah hasilnya benar untuk edge case? | Mengurangi bug logic |
| Performance | Bagaimana perilaku saat data membesar? | Menjaga latency |
| Maintainability | Apakah engineer lain mudah memahami kode? | Mempercepat perubahan |
| Security | Apakah data dan akses terlindungi? | Mengurangi risiko production |

## Penjelasan Detail

Bayangkan kamu menerima requirement baru dari product manager. Requirement itu biasanya terdengar sederhana, misalnya "tampilkan daftar materi yang relevan untuk user". Namun di balik kalimat singkat itu ada banyak keputusan: data apa yang dibaca, bagaimana urutannya, bagaimana jika database lambat, bagaimana jika user belum login, dan bagaimana hasilnya diuji. Engineer yang matang akan memecah requirement menjadi beberapa bagian kecil, mengidentifikasi risiko, lalu memilih pendekatan yang bisa diverifikasi.

Pada topik ini, pola berpikir yang paling penting adalah melihat hubungan antara input, proses, dan output. Input bisa berupa request HTTP, data dari database, event dari message broker, atau konfigurasi environment. Proses bisa berupa validasi, transformasi, query, perhitungan, atau komunikasi ke service lain. Output bisa berupa response JSON, record baru, log audit, atau event lanjutan. Jika salah satu bagian tidak jelas, debugging akan menjadi lebih sulit.

Dalam praktik sehari-hari, jangan hanya bertanya "apakah kode ini jalan?". Tanyakan juga:

1. Apa yang terjadi jika input kosong, duplikat, terlalu besar, atau tidak valid?
2. Apakah solusi ini masih masuk akal ketika jumlah data naik 100 kali lipat?
3. Apakah error message cukup membantu tanpa membocorkan informasi sensitif?
4. Apakah perubahan ini mudah dites secara otomatis?
5. Apakah ada asumsi yang perlu ditulis di dokumentasi?

## Contoh Implementasi

Contoh berikut bukan template final, tetapi gambaran cara menyusun ide secara eksplisit:

```text
Client -> Load Balancer -> API Service -> Database
                         -> Cache
                         -> Message Queue
```

Perhatikan bahwa contoh tersebut menonjolkan struktur berpikir, bukan sekadar sintaks. Sintaks bisa berbeda antara Java, TypeScript, Python, atau SQL, tetapi prinsipnya tetap sama: buat data mengalir lewat tahap yang jelas, kurangi coupling, dan pastikan kegagalan dapat diamati.

## Use Case Industri

Contoh industri: interview system design meminta kandidat menjelaskan trade-off antara simplicity, reliability, latency, dan cost. Kasus seperti ini umum terjadi karena sistem production memiliki batasan nyata: latency, biaya cloud, reliabilitas, keamanan, dan koordinasi antar tim. Solusi yang terlihat bagus di demo lokal belum tentu cukup untuk production jika tidak mempertimbangkan volume data, konkurensi, dan failure mode.

Dalam tim profesional, keputusan teknis biasanya perlu dijelaskan dalam bentuk trade-off. Misalnya, memakai cache membuat response lebih cepat, tetapi menambah risiko stale data. Memecah service membuat deployment lebih independen, tetapi menambah kebutuhan observability dan network reliability. Menggunakan JWT membuat service stateless, tetapi perlu validasi signature dan expiry yang benar.

## Studi Kasus Terarah

Misalkan Yomu ingin menampilkan materi belajar yang relevan untuk mahasiswa yang sedang mempersiapkan interview. Requirement awalnya terdengar sederhana: user membuka halaman, melihat daftar bacaan, memilih materi, lalu mengerjakan quiz. Namun kalau fitur ini dipakai ribuan mahasiswa, ada beberapa pertanyaan desain yang harus dijawab. Apakah daftar bacaan selalu diambil dari database? Apakah setiap request perlu menghitung progress quiz dari awal? Apakah response untuk learner boleh mengandung jawaban benar? Apakah admin boleh mengubah quiz yang sudah pernah dikerjakan banyak user?

Dengan sudut pandang System Design Basics: Dari Requirement ke Arsitektur, kamu bisa membuat keputusan yang lebih tajam. Pertama, pisahkan data yang bersifat publik, data yang personal untuk user, dan data yang hanya boleh dilihat admin. Kedua, tentukan operasi mana yang harus konsisten kuat dan mana yang boleh eventually consistent. Ketiga, siapkan test untuk memastikan perubahan schema, perubahan kontrak API, dan perubahan business rule tidak merusak pengalaman belajar.

Pendekatan yang matang biasanya menghasilkan desain seperti ini:

- Endpoint learner hanya mengembalikan informasi yang aman untuk learner.
- Endpoint admin memiliki authorization dan audit log.
- Query yang sering dipakai diberi index atau cache jika benar-benar terbukti bottleneck.
- Seed data dibuat idempotent agar environment lokal, staging, dan demo bisa diisi ulang tanpa duplikasi.
- Error response dibuat konsisten supaya frontend bisa menampilkan pesan yang jelas.

## Production Readiness Checklist

Sebelum sebuah fitur dianggap siap production, engineer perlu mengecek lebih dari sekadar "berhasil dijalankan". Gunakan checklist berikut sebagai kebiasaan:

1. **Correctness:** semua aturan bisnis utama punya test otomatis.
2. **Observability:** log cukup untuk menelusuri request bermasalah.
3. **Security:** endpoint sensitif terlindungi role, token, atau gateway policy.
4. **Performance:** query utama dan struktur data sudah dipikirkan untuk pertumbuhan data.
5. **Resilience:** error dari dependency eksternal tidak membuat seluruh aplikasi gagal tanpa pesan.
6. **Maintainability:** kode mengikuti batas layer yang jelas dan tidak mencampur terlalu banyak tanggung jawab.

Checklist ini bukan birokrasi. Ia membantu tim menghindari bug yang biasanya baru terlihat saat demo besar, traffic naik, atau ada perubahan requirement mendadak.

## Best Practices

- Mulai dari requirement dan constraint, bukan dari library favorit.
- Gunakan nama variabel, endpoint, dan tabel yang konsisten.
- Tambahkan test untuk happy path, edge case, dan failure case.
- Jangan menyimpan secret di source code.
- Catat keputusan penting di README atau ADR sederhana.
- Gunakan logging yang membantu debugging tanpa membocorkan data sensitif.
- Review performa query dan struktur data sebelum traffic membesar.

## Common Mistakes

Kesalahan yang sering dilakukan beginner adalah membuat solusi yang hanya bekerja untuk contoh kecil. Misalnya, nested loop tidak terasa lambat saat data hanya 10 baris, tetapi bisa menghancurkan latency saat data menjadi 100.000 baris. Kesalahan lain adalah mencampur validasi, business logic, dan akses database dalam satu fungsi besar sehingga sulit dites dan sulit diubah.

Kesalahan lain yang sering muncul:

- Mengabaikan edge case karena demo terlihat berhasil.
- Menggunakan status code HTTP yang tidak sesuai.
- Membiarkan endpoint admin tanpa authorization.
- Membuat query berulang dalam loop tanpa sadar.
- Menganggap semua error berasal dari frontend.
- Tidak menulis migration atau seed data yang idempotent.

## Fun Fact

Banyak konsep modern software engineering sebenarnya lahir dari masalah sederhana yang tumbuh besar. Queue muncul karena tidak semua pekerjaan harus selesai saat itu juga. Cache muncul karena membaca sumber data utama terus-menerus terlalu mahal. Load balancer muncul karena satu server tidak selamanya cukup. Dengan memahami asal masalahnya, kamu akan lebih mudah memilih teknologi yang tepat.

## Interview Tips

Saat interview, jangan langsung melompat ke jawaban final. Jelaskan asumsi, pilihan, dan trade-off. Interviewer biasanya ingin melihat cara berpikir. Untuk topik ini, jawaban yang kuat biasanya memuat:

1. Definisi singkat yang tepat.
2. Contoh real-world.
3. Edge case atau failure mode.
4. Trade-off solusi.
5. Cara menguji atau mengukur keberhasilan.

## Latihan Mandiri

Coba ambil fitur sederhana dari aplikasi Yomu, misalnya membaca materi dan mengerjakan quiz. Petakan input, proses, output, data yang disimpan, kemungkinan error, dan risiko keamanan. Setelah itu, tulis satu perbaikan kecil yang membuat fitur tersebut lebih production-ready. Latihan seperti ini akan membangun intuisi engineering yang jauh lebih kuat daripada sekadar membaca definisi.
', 'advanced', 20, 35),
        ('Load Balancing dan Horizontal Scaling', 'Bahas load balancer, health check, sticky session, stateless service, autoscaling, dan failure handling.', '# Load Balancing dan Horizontal Scaling

## Ringkasan

Bahas load balancer, health check, sticky session, stateless service, autoscaling, dan failure handling. Materi ini dirancang seperti modul bootcamp: dimulai dari intuisi, dilanjutkan dengan model mental, lalu ditutup dengan praktik industri dan tips interview. Fokus utamanya bukan menghafal istilah, melainkan memahami cara berpikir yang bisa dipakai saat membangun aplikasi nyata, membaca kode orang lain, melakukan debugging, dan menjelaskan keputusan teknis secara profesional.

## Kenapa Topik Ini Penting

Dalam software engineering, keputusan kecil sering punya dampak besar. Memilih struktur data, menentukan status code, menaruh validasi di layer yang tepat, atau memutuskan kapan memakai cache dapat memengaruhi performa, keamanan, dan pengalaman pengguna. Topik ini penting karena muncul berulang kali di proyek kampus, magang, pekerjaan full-time, dan interview software engineer.

Analogi sederhananya: membangun software mirip mengelola dapur restoran. Menu adalah fitur, pelanggan adalah user, database adalah gudang bahan, dan pipeline deployment adalah jalur penyajian. Restoran kecil bisa berjalan dengan satu koki dan satu catatan pesanan, tetapi restoran besar butuh alur kerja, pembagian peran, quality control, dan monitoring. Software juga begitu: semakin banyak user, semakin penting desain yang rapi.

## Konsep Utama

Kata kunci yang perlu kamu kuasai: **load balancer, health check, stateless, autoscaling, failover**.

Beberapa prinsip yang selalu berguna:

- Pahami masalah sebelum memilih teknologi.
- Ukur bottleneck dengan data, bukan perasaan.
- Buat solusi paling sederhana yang masih memenuhi kebutuhan.
- Dokumentasikan asumsi penting agar tim lain tidak menebak-nebak.
- Pisahkan konsep inti dari detail implementasi.

| Area | Pertanyaan Penting | Dampak |
|---|---|---|
| Correctness | Apakah hasilnya benar untuk edge case? | Mengurangi bug logic |
| Performance | Bagaimana perilaku saat data membesar? | Menjaga latency |
| Maintainability | Apakah engineer lain mudah memahami kode? | Mempercepat perubahan |
| Security | Apakah data dan akses terlindungi? | Mengurangi risiko production |

## Penjelasan Detail

Bayangkan kamu menerima requirement baru dari product manager. Requirement itu biasanya terdengar sederhana, misalnya "tampilkan daftar materi yang relevan untuk user". Namun di balik kalimat singkat itu ada banyak keputusan: data apa yang dibaca, bagaimana urutannya, bagaimana jika database lambat, bagaimana jika user belum login, dan bagaimana hasilnya diuji. Engineer yang matang akan memecah requirement menjadi beberapa bagian kecil, mengidentifikasi risiko, lalu memilih pendekatan yang bisa diverifikasi.

Pada topik ini, pola berpikir yang paling penting adalah melihat hubungan antara input, proses, dan output. Input bisa berupa request HTTP, data dari database, event dari message broker, atau konfigurasi environment. Proses bisa berupa validasi, transformasi, query, perhitungan, atau komunikasi ke service lain. Output bisa berupa response JSON, record baru, log audit, atau event lanjutan. Jika salah satu bagian tidak jelas, debugging akan menjadi lebih sulit.

Dalam praktik sehari-hari, jangan hanya bertanya "apakah kode ini jalan?". Tanyakan juga:

1. Apa yang terjadi jika input kosong, duplikat, terlalu besar, atau tidak valid?
2. Apakah solusi ini masih masuk akal ketika jumlah data naik 100 kali lipat?
3. Apakah error message cukup membantu tanpa membocorkan informasi sensitif?
4. Apakah perubahan ini mudah dites secara otomatis?
5. Apakah ada asumsi yang perlu ditulis di dokumentasi?

## Contoh Implementasi

Contoh berikut bukan template final, tetapi gambaran cara menyusun ide secara eksplisit:

```text
upstream app {
  server app-1:8080;
  server app-2:8080;
}
```

Perhatikan bahwa contoh tersebut menonjolkan struktur berpikir, bukan sekadar sintaks. Sintaks bisa berbeda antara Java, TypeScript, Python, atau SQL, tetapi prinsipnya tetap sama: buat data mengalir lewat tahap yang jelas, kurangi coupling, dan pastikan kegagalan dapat diamati.

## Use Case Industri

Contoh industri: aplikasi pendaftaran event menambah instance API saat traffic melonjak menjelang deadline. Kasus seperti ini umum terjadi karena sistem production memiliki batasan nyata: latency, biaya cloud, reliabilitas, keamanan, dan koordinasi antar tim. Solusi yang terlihat bagus di demo lokal belum tentu cukup untuk production jika tidak mempertimbangkan volume data, konkurensi, dan failure mode.

Dalam tim profesional, keputusan teknis biasanya perlu dijelaskan dalam bentuk trade-off. Misalnya, memakai cache membuat response lebih cepat, tetapi menambah risiko stale data. Memecah service membuat deployment lebih independen, tetapi menambah kebutuhan observability dan network reliability. Menggunakan JWT membuat service stateless, tetapi perlu validasi signature dan expiry yang benar.

## Studi Kasus Terarah

Misalkan Yomu ingin menampilkan materi belajar yang relevan untuk mahasiswa yang sedang mempersiapkan interview. Requirement awalnya terdengar sederhana: user membuka halaman, melihat daftar bacaan, memilih materi, lalu mengerjakan quiz. Namun kalau fitur ini dipakai ribuan mahasiswa, ada beberapa pertanyaan desain yang harus dijawab. Apakah daftar bacaan selalu diambil dari database? Apakah setiap request perlu menghitung progress quiz dari awal? Apakah response untuk learner boleh mengandung jawaban benar? Apakah admin boleh mengubah quiz yang sudah pernah dikerjakan banyak user?

Dengan sudut pandang Load Balancing dan Horizontal Scaling, kamu bisa membuat keputusan yang lebih tajam. Pertama, pisahkan data yang bersifat publik, data yang personal untuk user, dan data yang hanya boleh dilihat admin. Kedua, tentukan operasi mana yang harus konsisten kuat dan mana yang boleh eventually consistent. Ketiga, siapkan test untuk memastikan perubahan schema, perubahan kontrak API, dan perubahan business rule tidak merusak pengalaman belajar.

Pendekatan yang matang biasanya menghasilkan desain seperti ini:

- Endpoint learner hanya mengembalikan informasi yang aman untuk learner.
- Endpoint admin memiliki authorization dan audit log.
- Query yang sering dipakai diberi index atau cache jika benar-benar terbukti bottleneck.
- Seed data dibuat idempotent agar environment lokal, staging, dan demo bisa diisi ulang tanpa duplikasi.
- Error response dibuat konsisten supaya frontend bisa menampilkan pesan yang jelas.

## Production Readiness Checklist

Sebelum sebuah fitur dianggap siap production, engineer perlu mengecek lebih dari sekadar "berhasil dijalankan". Gunakan checklist berikut sebagai kebiasaan:

1. **Correctness:** semua aturan bisnis utama punya test otomatis.
2. **Observability:** log cukup untuk menelusuri request bermasalah.
3. **Security:** endpoint sensitif terlindungi role, token, atau gateway policy.
4. **Performance:** query utama dan struktur data sudah dipikirkan untuk pertumbuhan data.
5. **Resilience:** error dari dependency eksternal tidak membuat seluruh aplikasi gagal tanpa pesan.
6. **Maintainability:** kode mengikuti batas layer yang jelas dan tidak mencampur terlalu banyak tanggung jawab.

Checklist ini bukan birokrasi. Ia membantu tim menghindari bug yang biasanya baru terlihat saat demo besar, traffic naik, atau ada perubahan requirement mendadak.

## Best Practices

- Mulai dari requirement dan constraint, bukan dari library favorit.
- Gunakan nama variabel, endpoint, dan tabel yang konsisten.
- Tambahkan test untuk happy path, edge case, dan failure case.
- Jangan menyimpan secret di source code.
- Catat keputusan penting di README atau ADR sederhana.
- Gunakan logging yang membantu debugging tanpa membocorkan data sensitif.
- Review performa query dan struktur data sebelum traffic membesar.

## Common Mistakes

Kesalahan yang sering dilakukan beginner adalah membuat solusi yang hanya bekerja untuk contoh kecil. Misalnya, nested loop tidak terasa lambat saat data hanya 10 baris, tetapi bisa menghancurkan latency saat data menjadi 100.000 baris. Kesalahan lain adalah mencampur validasi, business logic, dan akses database dalam satu fungsi besar sehingga sulit dites dan sulit diubah.

Kesalahan lain yang sering muncul:

- Mengabaikan edge case karena demo terlihat berhasil.
- Menggunakan status code HTTP yang tidak sesuai.
- Membiarkan endpoint admin tanpa authorization.
- Membuat query berulang dalam loop tanpa sadar.
- Menganggap semua error berasal dari frontend.
- Tidak menulis migration atau seed data yang idempotent.

## Fun Fact

Banyak konsep modern software engineering sebenarnya lahir dari masalah sederhana yang tumbuh besar. Queue muncul karena tidak semua pekerjaan harus selesai saat itu juga. Cache muncul karena membaca sumber data utama terus-menerus terlalu mahal. Load balancer muncul karena satu server tidak selamanya cukup. Dengan memahami asal masalahnya, kamu akan lebih mudah memilih teknologi yang tepat.

## Interview Tips

Saat interview, jangan langsung melompat ke jawaban final. Jelaskan asumsi, pilihan, dan trade-off. Interviewer biasanya ingin melihat cara berpikir. Untuk topik ini, jawaban yang kuat biasanya memuat:

1. Definisi singkat yang tepat.
2. Contoh real-world.
3. Edge case atau failure mode.
4. Trade-off solusi.
5. Cara menguji atau mengukur keberhasilan.

## Latihan Mandiri

Coba ambil fitur sederhana dari aplikasi Yomu, misalnya membaca materi dan mengerjakan quiz. Petakan input, proses, output, data yang disimpan, kemungkinan error, dan risiko keamanan. Setelah itu, tulis satu perbaikan kecil yang membuat fitur tersebut lebih production-ready. Latihan seperti ini akan membangun intuisi engineering yang jauh lebih kuat daripada sekadar membaca definisi.
', 'advanced', 18, 35),
        ('Web Security Basics untuk Developer', 'Pelajari XSS, CSRF, SQL injection, secure headers, secret management, validation, dan least privilege.', '# Web Security Basics untuk Developer

## Ringkasan

Pelajari XSS, CSRF, SQL injection, secure headers, secret management, validation, dan least privilege. Materi ini dirancang seperti modul bootcamp: dimulai dari intuisi, dilanjutkan dengan model mental, lalu ditutup dengan praktik industri dan tips interview. Fokus utamanya bukan menghafal istilah, melainkan memahami cara berpikir yang bisa dipakai saat membangun aplikasi nyata, membaca kode orang lain, melakukan debugging, dan menjelaskan keputusan teknis secara profesional.

## Kenapa Topik Ini Penting

Dalam software engineering, keputusan kecil sering punya dampak besar. Memilih struktur data, menentukan status code, menaruh validasi di layer yang tepat, atau memutuskan kapan memakai cache dapat memengaruhi performa, keamanan, dan pengalaman pengguna. Topik ini penting karena muncul berulang kali di proyek kampus, magang, pekerjaan full-time, dan interview software engineer.

Analogi sederhananya: membangun software mirip mengelola dapur restoran. Menu adalah fitur, pelanggan adalah user, database adalah gudang bahan, dan pipeline deployment adalah jalur penyajian. Restoran kecil bisa berjalan dengan satu koki dan satu catatan pesanan, tetapi restoran besar butuh alur kerja, pembagian peran, quality control, dan monitoring. Software juga begitu: semakin banyak user, semakin penting desain yang rapi.

## Konsep Utama

Kata kunci yang perlu kamu kuasai: **XSS, CSRF, SQL injection, secure headers, validation**.

Beberapa prinsip yang selalu berguna:

- Pahami masalah sebelum memilih teknologi.
- Ukur bottleneck dengan data, bukan perasaan.
- Buat solusi paling sederhana yang masih memenuhi kebutuhan.
- Dokumentasikan asumsi penting agar tim lain tidak menebak-nebak.
- Pisahkan konsep inti dari detail implementasi.

| Area | Pertanyaan Penting | Dampak |
|---|---|---|
| Correctness | Apakah hasilnya benar untuk edge case? | Mengurangi bug logic |
| Performance | Bagaimana perilaku saat data membesar? | Menjaga latency |
| Maintainability | Apakah engineer lain mudah memahami kode? | Mempercepat perubahan |
| Security | Apakah data dan akses terlindungi? | Mengurangi risiko production |

## Penjelasan Detail

Bayangkan kamu menerima requirement baru dari product manager. Requirement itu biasanya terdengar sederhana, misalnya "tampilkan daftar materi yang relevan untuk user". Namun di balik kalimat singkat itu ada banyak keputusan: data apa yang dibaca, bagaimana urutannya, bagaimana jika database lambat, bagaimana jika user belum login, dan bagaimana hasilnya diuji. Engineer yang matang akan memecah requirement menjadi beberapa bagian kecil, mengidentifikasi risiko, lalu memilih pendekatan yang bisa diverifikasi.

Pada topik ini, pola berpikir yang paling penting adalah melihat hubungan antara input, proses, dan output. Input bisa berupa request HTTP, data dari database, event dari message broker, atau konfigurasi environment. Proses bisa berupa validasi, transformasi, query, perhitungan, atau komunikasi ke service lain. Output bisa berupa response JSON, record baru, log audit, atau event lanjutan. Jika salah satu bagian tidak jelas, debugging akan menjadi lebih sulit.

Dalam praktik sehari-hari, jangan hanya bertanya "apakah kode ini jalan?". Tanyakan juga:

1. Apa yang terjadi jika input kosong, duplikat, terlalu besar, atau tidak valid?
2. Apakah solusi ini masih masuk akal ketika jumlah data naik 100 kali lipat?
3. Apakah error message cukup membantu tanpa membocorkan informasi sensitif?
4. Apakah perubahan ini mudah dites secara otomatis?
5. Apakah ada asumsi yang perlu ditulis di dokumentasi?

## Contoh Implementasi

Contoh berikut bukan template final, tetapi gambaran cara menyusun ide secara eksplisit:

```text
PreparedStatement stmt = connection.prepareStatement(
  "SELECT * FROM users WHERE email = ?"
);
```

Perhatikan bahwa contoh tersebut menonjolkan struktur berpikir, bukan sekadar sintaks. Sintaks bisa berbeda antara Java, TypeScript, Python, atau SQL, tetapi prinsipnya tetap sama: buat data mengalir lewat tahap yang jelas, kurangi coupling, dan pastikan kegagalan dapat diamati.

## Use Case Industri

Contoh industri: form komentar harus melakukan escaping output agar input pengguna tidak menjadi script berbahaya di browser lain. Kasus seperti ini umum terjadi karena sistem production memiliki batasan nyata: latency, biaya cloud, reliabilitas, keamanan, dan koordinasi antar tim. Solusi yang terlihat bagus di demo lokal belum tentu cukup untuk production jika tidak mempertimbangkan volume data, konkurensi, dan failure mode.

Dalam tim profesional, keputusan teknis biasanya perlu dijelaskan dalam bentuk trade-off. Misalnya, memakai cache membuat response lebih cepat, tetapi menambah risiko stale data. Memecah service membuat deployment lebih independen, tetapi menambah kebutuhan observability dan network reliability. Menggunakan JWT membuat service stateless, tetapi perlu validasi signature dan expiry yang benar.

## Studi Kasus Terarah

Misalkan Yomu ingin menampilkan materi belajar yang relevan untuk mahasiswa yang sedang mempersiapkan interview. Requirement awalnya terdengar sederhana: user membuka halaman, melihat daftar bacaan, memilih materi, lalu mengerjakan quiz. Namun kalau fitur ini dipakai ribuan mahasiswa, ada beberapa pertanyaan desain yang harus dijawab. Apakah daftar bacaan selalu diambil dari database? Apakah setiap request perlu menghitung progress quiz dari awal? Apakah response untuk learner boleh mengandung jawaban benar? Apakah admin boleh mengubah quiz yang sudah pernah dikerjakan banyak user?

Dengan sudut pandang Web Security Basics untuk Developer, kamu bisa membuat keputusan yang lebih tajam. Pertama, pisahkan data yang bersifat publik, data yang personal untuk user, dan data yang hanya boleh dilihat admin. Kedua, tentukan operasi mana yang harus konsisten kuat dan mana yang boleh eventually consistent. Ketiga, siapkan test untuk memastikan perubahan schema, perubahan kontrak API, dan perubahan business rule tidak merusak pengalaman belajar.

Pendekatan yang matang biasanya menghasilkan desain seperti ini:

- Endpoint learner hanya mengembalikan informasi yang aman untuk learner.
- Endpoint admin memiliki authorization dan audit log.
- Query yang sering dipakai diberi index atau cache jika benar-benar terbukti bottleneck.
- Seed data dibuat idempotent agar environment lokal, staging, dan demo bisa diisi ulang tanpa duplikasi.
- Error response dibuat konsisten supaya frontend bisa menampilkan pesan yang jelas.

## Production Readiness Checklist

Sebelum sebuah fitur dianggap siap production, engineer perlu mengecek lebih dari sekadar "berhasil dijalankan". Gunakan checklist berikut sebagai kebiasaan:

1. **Correctness:** semua aturan bisnis utama punya test otomatis.
2. **Observability:** log cukup untuk menelusuri request bermasalah.
3. **Security:** endpoint sensitif terlindungi role, token, atau gateway policy.
4. **Performance:** query utama dan struktur data sudah dipikirkan untuk pertumbuhan data.
5. **Resilience:** error dari dependency eksternal tidak membuat seluruh aplikasi gagal tanpa pesan.
6. **Maintainability:** kode mengikuti batas layer yang jelas dan tidak mencampur terlalu banyak tanggung jawab.

Checklist ini bukan birokrasi. Ia membantu tim menghindari bug yang biasanya baru terlihat saat demo besar, traffic naik, atau ada perubahan requirement mendadak.

## Best Practices

- Mulai dari requirement dan constraint, bukan dari library favorit.
- Gunakan nama variabel, endpoint, dan tabel yang konsisten.
- Tambahkan test untuk happy path, edge case, dan failure case.
- Jangan menyimpan secret di source code.
- Catat keputusan penting di README atau ADR sederhana.
- Gunakan logging yang membantu debugging tanpa membocorkan data sensitif.
- Review performa query dan struktur data sebelum traffic membesar.

## Common Mistakes

Kesalahan yang sering dilakukan beginner adalah membuat solusi yang hanya bekerja untuk contoh kecil. Misalnya, nested loop tidak terasa lambat saat data hanya 10 baris, tetapi bisa menghancurkan latency saat data menjadi 100.000 baris. Kesalahan lain adalah mencampur validasi, business logic, dan akses database dalam satu fungsi besar sehingga sulit dites dan sulit diubah.

Kesalahan lain yang sering muncul:

- Mengabaikan edge case karena demo terlihat berhasil.
- Menggunakan status code HTTP yang tidak sesuai.
- Membiarkan endpoint admin tanpa authorization.
- Membuat query berulang dalam loop tanpa sadar.
- Menganggap semua error berasal dari frontend.
- Tidak menulis migration atau seed data yang idempotent.

## Fun Fact

Banyak konsep modern software engineering sebenarnya lahir dari masalah sederhana yang tumbuh besar. Queue muncul karena tidak semua pekerjaan harus selesai saat itu juga. Cache muncul karena membaca sumber data utama terus-menerus terlalu mahal. Load balancer muncul karena satu server tidak selamanya cukup. Dengan memahami asal masalahnya, kamu akan lebih mudah memilih teknologi yang tepat.

## Interview Tips

Saat interview, jangan langsung melompat ke jawaban final. Jelaskan asumsi, pilihan, dan trade-off. Interviewer biasanya ingin melihat cara berpikir. Untuk topik ini, jawaban yang kuat biasanya memuat:

1. Definisi singkat yang tepat.
2. Contoh real-world.
3. Edge case atau failure mode.
4. Trade-off solusi.
5. Cara menguji atau mengukur keberhasilan.

## Latihan Mandiri

Coba ambil fitur sederhana dari aplikasi Yomu, misalnya membaca materi dan mengerjakan quiz. Petakan input, proses, output, data yang disimpan, kemungkinan error, dan risiko keamanan. Setelah itu, tulis satu perbaikan kecil yang membuat fitur tersebut lebih production-ready. Latihan seperti ini akan membangun intuisi engineering yang jauh lebih kuat daripada sekadar membaca definisi.
', 'intermediate', 15, 20),
        ('Message Queue Basics dan Pemrosesan Asinkron', 'Bahas producer, consumer, broker, retry, dead-letter queue, idempotency, dan kapan memakai queue.', '# Message Queue Basics dan Pemrosesan Asinkron

## Ringkasan

Bahas producer, consumer, broker, retry, dead-letter queue, idempotency, dan kapan memakai queue. Materi ini dirancang seperti modul bootcamp: dimulai dari intuisi, dilanjutkan dengan model mental, lalu ditutup dengan praktik industri dan tips interview. Fokus utamanya bukan menghafal istilah, melainkan memahami cara berpikir yang bisa dipakai saat membangun aplikasi nyata, membaca kode orang lain, melakukan debugging, dan menjelaskan keputusan teknis secara profesional.

## Kenapa Topik Ini Penting

Dalam software engineering, keputusan kecil sering punya dampak besar. Memilih struktur data, menentukan status code, menaruh validasi di layer yang tepat, atau memutuskan kapan memakai cache dapat memengaruhi performa, keamanan, dan pengalaman pengguna. Topik ini penting karena muncul berulang kali di proyek kampus, magang, pekerjaan full-time, dan interview software engineer.

Analogi sederhananya: membangun software mirip mengelola dapur restoran. Menu adalah fitur, pelanggan adalah user, database adalah gudang bahan, dan pipeline deployment adalah jalur penyajian. Restoran kecil bisa berjalan dengan satu koki dan satu catatan pesanan, tetapi restoran besar butuh alur kerja, pembagian peran, quality control, dan monitoring. Software juga begitu: semakin banyak user, semakin penting desain yang rapi.

## Konsep Utama

Kata kunci yang perlu kamu kuasai: **producer, consumer, broker, retry, dead-letter queue**.

Beberapa prinsip yang selalu berguna:

- Pahami masalah sebelum memilih teknologi.
- Ukur bottleneck dengan data, bukan perasaan.
- Buat solusi paling sederhana yang masih memenuhi kebutuhan.
- Dokumentasikan asumsi penting agar tim lain tidak menebak-nebak.
- Pisahkan konsep inti dari detail implementasi.

| Area | Pertanyaan Penting | Dampak |
|---|---|---|
| Correctness | Apakah hasilnya benar untuk edge case? | Mengurangi bug logic |
| Performance | Bagaimana perilaku saat data membesar? | Menjaga latency |
| Maintainability | Apakah engineer lain mudah memahami kode? | Mempercepat perubahan |
| Security | Apakah data dan akses terlindungi? | Mengurangi risiko production |

## Penjelasan Detail

Bayangkan kamu menerima requirement baru dari product manager. Requirement itu biasanya terdengar sederhana, misalnya "tampilkan daftar materi yang relevan untuk user". Namun di balik kalimat singkat itu ada banyak keputusan: data apa yang dibaca, bagaimana urutannya, bagaimana jika database lambat, bagaimana jika user belum login, dan bagaimana hasilnya diuji. Engineer yang matang akan memecah requirement menjadi beberapa bagian kecil, mengidentifikasi risiko, lalu memilih pendekatan yang bisa diverifikasi.

Pada topik ini, pola berpikir yang paling penting adalah melihat hubungan antara input, proses, dan output. Input bisa berupa request HTTP, data dari database, event dari message broker, atau konfigurasi environment. Proses bisa berupa validasi, transformasi, query, perhitungan, atau komunikasi ke service lain. Output bisa berupa response JSON, record baru, log audit, atau event lanjutan. Jika salah satu bagian tidak jelas, debugging akan menjadi lebih sulit.

Dalam praktik sehari-hari, jangan hanya bertanya "apakah kode ini jalan?". Tanyakan juga:

1. Apa yang terjadi jika input kosong, duplikat, terlalu besar, atau tidak valid?
2. Apakah solusi ini masih masuk akal ketika jumlah data naik 100 kali lipat?
3. Apakah error message cukup membantu tanpa membocorkan informasi sensitif?
4. Apakah perubahan ini mudah dites secara otomatis?
5. Apakah ada asumsi yang perlu ditulis di dokumentasi?

## Contoh Implementasi

Contoh berikut bukan template final, tetapi gambaran cara menyusun ide secara eksplisit:

```text
producer.send("quiz.completed", event);
consumer.handle(event);
```

Perhatikan bahwa contoh tersebut menonjolkan struktur berpikir, bukan sekadar sintaks. Sintaks bisa berbeda antara Java, TypeScript, Python, atau SQL, tetapi prinsipnya tetap sama: buat data mengalir lewat tahap yang jelas, kurangi coupling, dan pastikan kegagalan dapat diamati.

## Use Case Industri

Contoh industri: setelah user menyelesaikan quiz, service bisa mengirim event untuk update achievement tanpa menahan response utama. Kasus seperti ini umum terjadi karena sistem production memiliki batasan nyata: latency, biaya cloud, reliabilitas, keamanan, dan koordinasi antar tim. Solusi yang terlihat bagus di demo lokal belum tentu cukup untuk production jika tidak mempertimbangkan volume data, konkurensi, dan failure mode.

Dalam tim profesional, keputusan teknis biasanya perlu dijelaskan dalam bentuk trade-off. Misalnya, memakai cache membuat response lebih cepat, tetapi menambah risiko stale data. Memecah service membuat deployment lebih independen, tetapi menambah kebutuhan observability dan network reliability. Menggunakan JWT membuat service stateless, tetapi perlu validasi signature dan expiry yang benar.

## Studi Kasus Terarah

Misalkan Yomu ingin menampilkan materi belajar yang relevan untuk mahasiswa yang sedang mempersiapkan interview. Requirement awalnya terdengar sederhana: user membuka halaman, melihat daftar bacaan, memilih materi, lalu mengerjakan quiz. Namun kalau fitur ini dipakai ribuan mahasiswa, ada beberapa pertanyaan desain yang harus dijawab. Apakah daftar bacaan selalu diambil dari database? Apakah setiap request perlu menghitung progress quiz dari awal? Apakah response untuk learner boleh mengandung jawaban benar? Apakah admin boleh mengubah quiz yang sudah pernah dikerjakan banyak user?

Dengan sudut pandang Message Queue Basics dan Pemrosesan Asinkron, kamu bisa membuat keputusan yang lebih tajam. Pertama, pisahkan data yang bersifat publik, data yang personal untuk user, dan data yang hanya boleh dilihat admin. Kedua, tentukan operasi mana yang harus konsisten kuat dan mana yang boleh eventually consistent. Ketiga, siapkan test untuk memastikan perubahan schema, perubahan kontrak API, dan perubahan business rule tidak merusak pengalaman belajar.

Pendekatan yang matang biasanya menghasilkan desain seperti ini:

- Endpoint learner hanya mengembalikan informasi yang aman untuk learner.
- Endpoint admin memiliki authorization dan audit log.
- Query yang sering dipakai diberi index atau cache jika benar-benar terbukti bottleneck.
- Seed data dibuat idempotent agar environment lokal, staging, dan demo bisa diisi ulang tanpa duplikasi.
- Error response dibuat konsisten supaya frontend bisa menampilkan pesan yang jelas.

## Production Readiness Checklist

Sebelum sebuah fitur dianggap siap production, engineer perlu mengecek lebih dari sekadar "berhasil dijalankan". Gunakan checklist berikut sebagai kebiasaan:

1. **Correctness:** semua aturan bisnis utama punya test otomatis.
2. **Observability:** log cukup untuk menelusuri request bermasalah.
3. **Security:** endpoint sensitif terlindungi role, token, atau gateway policy.
4. **Performance:** query utama dan struktur data sudah dipikirkan untuk pertumbuhan data.
5. **Resilience:** error dari dependency eksternal tidak membuat seluruh aplikasi gagal tanpa pesan.
6. **Maintainability:** kode mengikuti batas layer yang jelas dan tidak mencampur terlalu banyak tanggung jawab.

Checklist ini bukan birokrasi. Ia membantu tim menghindari bug yang biasanya baru terlihat saat demo besar, traffic naik, atau ada perubahan requirement mendadak.

## Best Practices

- Mulai dari requirement dan constraint, bukan dari library favorit.
- Gunakan nama variabel, endpoint, dan tabel yang konsisten.
- Tambahkan test untuk happy path, edge case, dan failure case.
- Jangan menyimpan secret di source code.
- Catat keputusan penting di README atau ADR sederhana.
- Gunakan logging yang membantu debugging tanpa membocorkan data sensitif.
- Review performa query dan struktur data sebelum traffic membesar.

## Common Mistakes

Kesalahan yang sering dilakukan beginner adalah membuat solusi yang hanya bekerja untuk contoh kecil. Misalnya, nested loop tidak terasa lambat saat data hanya 10 baris, tetapi bisa menghancurkan latency saat data menjadi 100.000 baris. Kesalahan lain adalah mencampur validasi, business logic, dan akses database dalam satu fungsi besar sehingga sulit dites dan sulit diubah.

Kesalahan lain yang sering muncul:

- Mengabaikan edge case karena demo terlihat berhasil.
- Menggunakan status code HTTP yang tidak sesuai.
- Membiarkan endpoint admin tanpa authorization.
- Membuat query berulang dalam loop tanpa sadar.
- Menganggap semua error berasal dari frontend.
- Tidak menulis migration atau seed data yang idempotent.

## Fun Fact

Banyak konsep modern software engineering sebenarnya lahir dari masalah sederhana yang tumbuh besar. Queue muncul karena tidak semua pekerjaan harus selesai saat itu juga. Cache muncul karena membaca sumber data utama terus-menerus terlalu mahal. Load balancer muncul karena satu server tidak selamanya cukup. Dengan memahami asal masalahnya, kamu akan lebih mudah memilih teknologi yang tepat.

## Interview Tips

Saat interview, jangan langsung melompat ke jawaban final. Jelaskan asumsi, pilihan, dan trade-off. Interviewer biasanya ingin melihat cara berpikir. Untuk topik ini, jawaban yang kuat biasanya memuat:

1. Definisi singkat yang tepat.
2. Contoh real-world.
3. Edge case atau failure mode.
4. Trade-off solusi.
5. Cara menguji atau mengukur keberhasilan.

## Latihan Mandiri

Coba ambil fitur sederhana dari aplikasi Yomu, misalnya membaca materi dan mengerjakan quiz. Petakan input, proses, output, data yang disimpan, kemungkinan error, dan risiko keamanan. Setelah itu, tulis satu perbaikan kecil yang membuat fitur tersebut lebih production-ready. Latihan seperti ini akan membangun intuisi engineering yang jauh lebih kuat daripada sekadar membaca definisi.
', 'intermediate', 15, 20),
        ('Event-Driven Architecture dan Scaling Applications', 'Materi advanced tentang event, eventual consistency, choreography, observability, scaling, dan failure mode.', '# Event-Driven Architecture dan Scaling Applications

## Ringkasan

Materi advanced tentang event, eventual consistency, choreography, observability, scaling, dan failure mode. Materi ini dirancang seperti modul bootcamp: dimulai dari intuisi, dilanjutkan dengan model mental, lalu ditutup dengan praktik industri dan tips interview. Fokus utamanya bukan menghafal istilah, melainkan memahami cara berpikir yang bisa dipakai saat membangun aplikasi nyata, membaca kode orang lain, melakukan debugging, dan menjelaskan keputusan teknis secara profesional.

## Kenapa Topik Ini Penting

Dalam software engineering, keputusan kecil sering punya dampak besar. Memilih struktur data, menentukan status code, menaruh validasi di layer yang tepat, atau memutuskan kapan memakai cache dapat memengaruhi performa, keamanan, dan pengalaman pengguna. Topik ini penting karena muncul berulang kali di proyek kampus, magang, pekerjaan full-time, dan interview software engineer.

Analogi sederhananya: membangun software mirip mengelola dapur restoran. Menu adalah fitur, pelanggan adalah user, database adalah gudang bahan, dan pipeline deployment adalah jalur penyajian. Restoran kecil bisa berjalan dengan satu koki dan satu catatan pesanan, tetapi restoran besar butuh alur kerja, pembagian peran, quality control, dan monitoring. Software juga begitu: semakin banyak user, semakin penting desain yang rapi.

## Konsep Utama

Kata kunci yang perlu kamu kuasai: **event, eventual consistency, choreography, observability, scaling**.

Beberapa prinsip yang selalu berguna:

- Pahami masalah sebelum memilih teknologi.
- Ukur bottleneck dengan data, bukan perasaan.
- Buat solusi paling sederhana yang masih memenuhi kebutuhan.
- Dokumentasikan asumsi penting agar tim lain tidak menebak-nebak.
- Pisahkan konsep inti dari detail implementasi.

| Area | Pertanyaan Penting | Dampak |
|---|---|---|
| Correctness | Apakah hasilnya benar untuk edge case? | Mengurangi bug logic |
| Performance | Bagaimana perilaku saat data membesar? | Menjaga latency |
| Maintainability | Apakah engineer lain mudah memahami kode? | Mempercepat perubahan |
| Security | Apakah data dan akses terlindungi? | Mengurangi risiko production |

## Penjelasan Detail

Bayangkan kamu menerima requirement baru dari product manager. Requirement itu biasanya terdengar sederhana, misalnya "tampilkan daftar materi yang relevan untuk user". Namun di balik kalimat singkat itu ada banyak keputusan: data apa yang dibaca, bagaimana urutannya, bagaimana jika database lambat, bagaimana jika user belum login, dan bagaimana hasilnya diuji. Engineer yang matang akan memecah requirement menjadi beberapa bagian kecil, mengidentifikasi risiko, lalu memilih pendekatan yang bisa diverifikasi.

Pada topik ini, pola berpikir yang paling penting adalah melihat hubungan antara input, proses, dan output. Input bisa berupa request HTTP, data dari database, event dari message broker, atau konfigurasi environment. Proses bisa berupa validasi, transformasi, query, perhitungan, atau komunikasi ke service lain. Output bisa berupa response JSON, record baru, log audit, atau event lanjutan. Jika salah satu bagian tidak jelas, debugging akan menjadi lebih sulit.

Dalam praktik sehari-hari, jangan hanya bertanya "apakah kode ini jalan?". Tanyakan juga:

1. Apa yang terjadi jika input kosong, duplikat, terlalu besar, atau tidak valid?
2. Apakah solusi ini masih masuk akal ketika jumlah data naik 100 kali lipat?
3. Apakah error message cukup membantu tanpa membocorkan informasi sensitif?
4. Apakah perubahan ini mudah dites secara otomatis?
5. Apakah ada asumsi yang perlu ditulis di dokumentasi?

## Contoh Implementasi

Contoh berikut bukan template final, tetapi gambaran cara menyusun ide secara eksplisit:

```text
{
  "eventType": "QuizCompleted",
  "studentId": "u-123",
  "score": 90
}
```

Perhatikan bahwa contoh tersebut menonjolkan struktur berpikir, bukan sekadar sintaks. Sintaks bisa berbeda antara Java, TypeScript, Python, atau SQL, tetapi prinsipnya tetap sama: buat data mengalir lewat tahap yang jelas, kurangi coupling, dan pastikan kegagalan dapat diamati.

## Use Case Industri

Contoh industri: marketplace memakai event order.created untuk memicu inventory, payment, notification, dan analytics secara terpisah. Kasus seperti ini umum terjadi karena sistem production memiliki batasan nyata: latency, biaya cloud, reliabilitas, keamanan, dan koordinasi antar tim. Solusi yang terlihat bagus di demo lokal belum tentu cukup untuk production jika tidak mempertimbangkan volume data, konkurensi, dan failure mode.

Dalam tim profesional, keputusan teknis biasanya perlu dijelaskan dalam bentuk trade-off. Misalnya, memakai cache membuat response lebih cepat, tetapi menambah risiko stale data. Memecah service membuat deployment lebih independen, tetapi menambah kebutuhan observability dan network reliability. Menggunakan JWT membuat service stateless, tetapi perlu validasi signature dan expiry yang benar.

## Studi Kasus Terarah

Misalkan Yomu ingin menampilkan materi belajar yang relevan untuk mahasiswa yang sedang mempersiapkan interview. Requirement awalnya terdengar sederhana: user membuka halaman, melihat daftar bacaan, memilih materi, lalu mengerjakan quiz. Namun kalau fitur ini dipakai ribuan mahasiswa, ada beberapa pertanyaan desain yang harus dijawab. Apakah daftar bacaan selalu diambil dari database? Apakah setiap request perlu menghitung progress quiz dari awal? Apakah response untuk learner boleh mengandung jawaban benar? Apakah admin boleh mengubah quiz yang sudah pernah dikerjakan banyak user?

Dengan sudut pandang Event-Driven Architecture dan Scaling Applications, kamu bisa membuat keputusan yang lebih tajam. Pertama, pisahkan data yang bersifat publik, data yang personal untuk user, dan data yang hanya boleh dilihat admin. Kedua, tentukan operasi mana yang harus konsisten kuat dan mana yang boleh eventually consistent. Ketiga, siapkan test untuk memastikan perubahan schema, perubahan kontrak API, dan perubahan business rule tidak merusak pengalaman belajar.

Pendekatan yang matang biasanya menghasilkan desain seperti ini:

- Endpoint learner hanya mengembalikan informasi yang aman untuk learner.
- Endpoint admin memiliki authorization dan audit log.
- Query yang sering dipakai diberi index atau cache jika benar-benar terbukti bottleneck.
- Seed data dibuat idempotent agar environment lokal, staging, dan demo bisa diisi ulang tanpa duplikasi.
- Error response dibuat konsisten supaya frontend bisa menampilkan pesan yang jelas.

## Production Readiness Checklist

Sebelum sebuah fitur dianggap siap production, engineer perlu mengecek lebih dari sekadar "berhasil dijalankan". Gunakan checklist berikut sebagai kebiasaan:

1. **Correctness:** semua aturan bisnis utama punya test otomatis.
2. **Observability:** log cukup untuk menelusuri request bermasalah.
3. **Security:** endpoint sensitif terlindungi role, token, atau gateway policy.
4. **Performance:** query utama dan struktur data sudah dipikirkan untuk pertumbuhan data.
5. **Resilience:** error dari dependency eksternal tidak membuat seluruh aplikasi gagal tanpa pesan.
6. **Maintainability:** kode mengikuti batas layer yang jelas dan tidak mencampur terlalu banyak tanggung jawab.

Checklist ini bukan birokrasi. Ia membantu tim menghindari bug yang biasanya baru terlihat saat demo besar, traffic naik, atau ada perubahan requirement mendadak.

## Best Practices

- Mulai dari requirement dan constraint, bukan dari library favorit.
- Gunakan nama variabel, endpoint, dan tabel yang konsisten.
- Tambahkan test untuk happy path, edge case, dan failure case.
- Jangan menyimpan secret di source code.
- Catat keputusan penting di README atau ADR sederhana.
- Gunakan logging yang membantu debugging tanpa membocorkan data sensitif.
- Review performa query dan struktur data sebelum traffic membesar.

## Common Mistakes

Kesalahan yang sering dilakukan beginner adalah membuat solusi yang hanya bekerja untuk contoh kecil. Misalnya, nested loop tidak terasa lambat saat data hanya 10 baris, tetapi bisa menghancurkan latency saat data menjadi 100.000 baris. Kesalahan lain adalah mencampur validasi, business logic, dan akses database dalam satu fungsi besar sehingga sulit dites dan sulit diubah.

Kesalahan lain yang sering muncul:

- Mengabaikan edge case karena demo terlihat berhasil.
- Menggunakan status code HTTP yang tidak sesuai.
- Membiarkan endpoint admin tanpa authorization.
- Membuat query berulang dalam loop tanpa sadar.
- Menganggap semua error berasal dari frontend.
- Tidak menulis migration atau seed data yang idempotent.

## Fun Fact

Banyak konsep modern software engineering sebenarnya lahir dari masalah sederhana yang tumbuh besar. Queue muncul karena tidak semua pekerjaan harus selesai saat itu juga. Cache muncul karena membaca sumber data utama terus-menerus terlalu mahal. Load balancer muncul karena satu server tidak selamanya cukup. Dengan memahami asal masalahnya, kamu akan lebih mudah memilih teknologi yang tepat.

## Interview Tips

Saat interview, jangan langsung melompat ke jawaban final. Jelaskan asumsi, pilihan, dan trade-off. Interviewer biasanya ingin melihat cara berpikir. Untuk topik ini, jawaban yang kuat biasanya memuat:

1. Definisi singkat yang tepat.
2. Contoh real-world.
3. Edge case atau failure mode.
4. Trade-off solusi.
5. Cara menguji atau mengukur keberhasilan.

## Latihan Mandiri

Coba ambil fitur sederhana dari aplikasi Yomu, misalnya membaca materi dan mengerjakan quiz. Petakan input, proses, output, data yang disimpan, kemungkinan error, dan risiko keamanan. Setelah itu, tulis satu perbaikan kecil yang membuat fitur tersebut lebih production-ready. Latihan seperti ini akan membangun intuisi engineering yang jauh lebih kuat daripada sekadar membaca definisi.
', 'advanced', 20, 35)
)
insert into learning_mod.readings (
    title,
    summary,
    content,
    difficulty,
    estimated_reading_time,
    xp_reward,
    category_id,
    created_at
)
select
    rs.title,
    rs.summary,
    rs.content,
    rs.difficulty,
    rs.estimated_reading_time,
    rs.xp_reward,
    cs_category.id,
    now()
from reading_seed rs
cross join cs_category
where not exists (
    select 1
    from learning_mod.readings r
    where lower(r.title) = lower(rs.title)
);

commit;
