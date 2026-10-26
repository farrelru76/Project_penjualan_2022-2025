Analisis Penjualan 2022–2025
1. Ringkasan Proyek

Analisis 18.000 transaksi penjualan (Jan 2022 – Des 2025) di 6 negara, 4 kategori produk, dan 4 channel penjualan. Alur kerja: MySQL (cleaning dan EDA) → Power BI (dashboard).

Tools: MySQL · Power BI

Struktur repo (sesuaikan):

├── data/
│   ├── Sales_transactions_2022_2025.csv   # data mentah
│   └── datfinal.csv                       # data bersih
├── sql/
│   ├── cleaning_data.sql
│   └── eda.sql
└── dashboard/dashboard-powerbi.png
2. Pertanyaan Bisnis
Bagaimana tren penjualan dan profit dari tahun ke tahun? Kapan musim ramai?
Kategori produk, channel, dan negara mana yang paling berkontribusi?
Apakah diskon benar-benar meningkatkan keuntungan?
Seberapa besar kerugian akibat pembatalan dan retur, dan apa penyebabnya?
Apakah kode promo efektif?
Siapa pelanggan kita, dan seberapa loyal mereka?
3. Proses Data Cleaning (cleaning_data.sql)

Data mentah: 18.045 baris, 36 kolom. Hasil akhir: 18.000 baris, ditambah 6 kolom flag.

Masalah ditemukan	Jumlah	Penanganan
Baris duplikat penuh	45	ROW_NUMBER() OVER (PARTITION BY semua kolom), hapus row_num > 1
Penulisan tidak konsisten (male, FEMALE, DebitCard, LOS ANGELES, New York, NRW, completed, electronics, dll.)	ratusan	TRIM + CASE LOWER() untuk menyeragamkan gender, status, metode bayar, kategori, kota, region
Nilai kosong berupa string ''	beberapa kolom	NULLIF(kolom, '') agar menjadi NULL sungguhan
Product_Name kosong	144	Diisi dari Product_ID yang sama (self-join)
Gender dan metode bayar NULL	162 / 147	Diganti 'Unknown'
Quantity ≤ 0	8	Dihitung ulang dari Sales_Amount / (Unit_Price × (1 − diskon))
Umur tidak wajar (<16 atau >90)	4	Diubah menjadi NULL
Diskon tidak wajar (45%, 60%, 110%)	3	Dihitung ulang dari selisih harga vs Sales_Amount, dibulatkan ke kelipatan 5
Profit ≠ Sales − Cost	110	Diperbaiki: Profit = Sales − Cost
Unit_Price menyimpang >50% dari rata-rata produk	beberapa	Dikoreksi dari Sales_Amount / (Qty × (1 − diskon))
Delivery_Days = 0 untuk non-pickup	–	Diubah menjadi NULL (pickup memang 0 hari)
Customer_Rating = 0	–	Diubah menjadi NULL (0 bukan rating valid, skala 1–5)
Return_Flag = 'Yes' tapi status bukan Returned	276	Tidak dihapus, hanya ditandai dengan flag

Kolom flag untuk analisis (tabel sales_final): is_cancelled, is_returned_status, is_returned_flag, is_revenue_order, is_sales_mismatch, is_loss.

Prinsip yang dipakai: semua perubahan dilakukan di tabel salinan (sales_cleaning → sales_cleaning2), sehingga data mentah sales2 tetap utuh.

Definisi penjualan bersih: hanya transaksi berstatus Completed, Shipped, Processing. Transaksi Cancelled dan Returned dikeluarkan lewat view v_sales.

4. Insight Utama
4.1 Gambaran Umum
Metrik	Nilai
Total sales (bersih)	$7,13 juta
Total profit	$1,42 juta
Margin profit	19,95%
Jumlah order / pelanggan	12.915 / 4.696
Rata-rata nilai order (AOV)	$552
Rating pelanggan	3,99 / 5

Kebocoran pendapatan: dari penjualan kotor $8,23 juta, sekitar $1,11 juta (13,4%) hilang karena batal ($393 ribu) dan retur ($712 ribu).

4.2 Tren dan Musiman
Tahun	Sales	Profit	YoY
2022	$1,76 jt	$356 rb	–
2023	$1,73 jt	$343 rb	−1,8%
2024	$1,64 jt	$330 rb	−4,8%
2025	$2,00 jt	$393 rb	+21,4%
Penjualan sempat turun dua tahun berturut-turut, lalu rebound kuat di 2025. Margin stabil di kisaran 19,7–20,2%.
Kuartal 4 adalah puncak: November ($806 rb) dan Desember ($798 rb) tertinggi, sedangkan Januari terendah ($439 rb), selisih sekitar 1,8×.
Hari kerja jauh lebih ramai (±2.400 transaksi/hari) dibanding akhir pekan (±1.690). Jam tersibuk 13.00–17.00.
4.3 Produk
Kategori	Share sales	Margin
Electronics	59,5%	19,3%
Furniture	24,3%	21,1%
Office Supplies	9,2%	19,4%
Appliances	7,1%	22,0%
Dua laptop (ProBook 16 dan AeroBook 14) menghasilkan lebih dari $2,3 juta sales dan menjadi penyumbang profit terbesar.
Margin terendah: Copy Paper Box (12,2%), Printer Plus (13,9%), EdgeTab 11 Tablet (14,8%), Meeting Table (15,5%).
Margin tertinggi ada di produk kecil: NoiseCancel Headset (26,1%) dan Filing Cabinet (25,0%).
4.4 Channel dan Geografi
Channel: Online 37,5% → Retail Store 29,5% → B2B Portal 26,2% → Phone Order 6,7%. Margin hampir sama di semua channel (~20%).
Negara: AS 42,5%, Inggris 16,0%, Kanada 14,5%, Jerman 11,7%, Prancis 9,0%, Australia 6,3%. Margin merata di ~20%, sehingga perbedaan ada di volume, bukan efisiensi.
4.5 Diskon: Temuan Terpenting
Diskon	Transaksi	Margin	% transaksi rugi	Rata-rata qty
0%	6.578	25,1%	0%	2,13
5%	3.077	20,9%	0%	2,10
10%	2.767	16,8%	0,04%	2,17
15%	1.869	11,8%	0,6%	2,18
20%	933	6,2%	10,5%	2,16
25%	279	0,6%	28,7%	2,11
30%	7	−7,0%	85,7%	3,86
Margin turun sekitar 4–5 poin untuk setiap kenaikan diskon 5%.
Diskon tidak mendorong pembelian lebih banyak. Rata-rata qty per transaksi hampir sama (~2,1) di semua level diskon. Artinya diskon hanya mengurangi margin tanpa menambah volume.
Dari 196 transaksi rugi, sekitar 91% (178 transaksi) terjadi pada diskon ≥20%.
4.6 Promo

Semua kode promo punya rata-rata diskon dan margin yang hampir sama dengan transaksi tanpa promo (19,2–20,9% vs 20,0%). Tidak ada kode promo yang terbukti meningkatkan nilai transaksi, karena rata-rata sales per transaksi promo ($413–$491) setara dengan non-promo ($460). Hasil terbaik: HALLOWEEN15 (margin 20,9%). Terendah: VALENTINE20 (19,2%). Catatan: tidak ada data pembanding sebelum/sesudah promo, jadi efek promo terhadap jumlah transaksi belum bisa disimpulkan.

4.7 Retur dan Pengiriman
Retur ada di sekitar 8,6–9,6% transaksi di semua kategori (tertinggi: Appliances 9,6%).
Penyebab retur tersebar merata (Late Delivery 286, Wrong Item 271, Damaged 269, Other 265, Defective 258, Changed Mind 248). Tidak ada satu penyebab dominan.
Sekitar 3 dari 6 penyebab (Late Delivery, Wrong Item, Damaged) berkaitan dengan operasional logistik/fulfillment, jadi bisa dicegah.
Metode pengiriman hampir tidak memengaruhi rating (3,97–4,03) maupun return rate (8,5–9,5%).
4.8 Pelanggan
71,6% pelanggan membeli lebih dari sekali, jadi basis pelanggan cukup loyal.
Top 10% pelanggan menyumbang 41% penjualan.
Segmen: Consumer 44,3% sales; Corporate margin terendah (18,4%) dibanding segmen lain (20–21%); Premium margin tertinggi (21,0%) tapi share kecil (4,5%).
Kelompok umur 35–44 tahun terbesar ($2,55 jt), diikuti 25–34 ($1,79 jt).
5. Rekomendasi
Batasi diskon maksimum di 15%. Diskon ≥20% hampir menghapus margin dan tidak menambah volume. Terapkan persetujuan khusus untuk diskon di atas 15%.
Evaluasi ulang program promo. Tidak ada kode promo yang terbukti lebih baik dari harga normal. Uji A/B sebelum menjalankan promo besar berikutnya.
Siapkan stok dan kapasitas untuk Q4, terutama Electronics, dan lakukan kampanye di Jan–Feb yang lemah.
Perbaiki margin produk berkontribusi besar tapi margin rendah (AeroBook 14, EdgeTab 11, Meeting Table): negosiasi harga supplier atau naikkan harga jual.
Kurangi retur dari sisi operasional. Fokus pada Late Delivery, Wrong Item, dan Damaged (±826 retur): perbaiki quality control gudang dan kemasan.
Kurangi ketergantungan pada satu pasar. AS = 42,5% penjualan. Peluang pertumbuhan di UK dan Kanada.
Jaga pelanggan bernilai tinggi. Buat program loyalitas untuk top 10% pelanggan, dan tinjau harga kontrak segmen Corporate.
Dorong produk margin tinggi (Appliances, headset, filing cabinet) lewat cross-sell bersama laptop.
6. Catatan dan Keterbatasan
Data bersifat transaksi tunggal tanpa biaya operasional, sehingga “profit” adalah laba kotor (Sales − Cost).
276 transaksi punya Return_Flag = Yes namun status bukan Returned. Ini dibiarkan dan perlu klarifikasi dengan pemilik data.
65 baris (0,34% sales) masih tidak cocok dengan rumus Qty × Harga × (1 − diskon), ditandai dengan is_sales_mismatch.
Asumsi: transaksi Cancelled/Returned tidak dihitung sebagai pendapatan.
