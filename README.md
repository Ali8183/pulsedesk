# PulseDesk ⚡

![CI Status](https://github.com/Ali8183/pulsedesk/actions/workflows/ci.yml/badge.svg)
![Ruby Version](https://img.shields.io/badge/Ruby-3.3.12-red.svg)
![Rails Version](https://img.shields.io/badge/Rails-8.1.4-CC0000.svg)
![License](https://img.shields.io/badge/License-MIT-blue.svg)

> **GitHub Repo:** [https://github.com/Ali8183/pulsedesk](https://github.com/Ali8183/pulsedesk)  
> **Canlı Uygulama URL:** [https://pulsedesk-8tji.onrender.com](https://pulsedesk-8tji.onrender.com)  
> **İlham Kaynağı Orijinal SaaS:** Zendesk (Müşteri Destek & Kurumsal Biletleme Platformu)  
> **Geliştirici:** Bireysel Öğrenci Projesi (Ruby on Rails 8+)

---

## 1. Faz 1: Fortune 500 & SaaS Pazarı Araştırması

Fortune 500 şirketlerinin kurumsal SaaS tüketimi ve genel finansal/operasyonel profili aşağıda akademik ve sektörel kaynaklarıyla özetlenmiştir:

| Metrik | Değer Aralığı / Rakam | Kaynak & Referans |
| :--- | :--- | :--- |
| **a. Değerleme (Piyasa Değeri) Aralığı** | • **En Küçük:** ~$2.1 Milyar - $10 Milyar *(Sıralamanın 450-500. bandındaki düşük marjlı enerji ve toptancı şirketler)*<br>• **En Büyük:** ~$3.2 Trilyon *(Apple, Microsoft, NVIDIA, Alphabet)* | [Fortune 500 Resmi Listesi](https://fortune.com/ranking/fortune500/) & [CompaniesMarketCap](https://companiesmarketcap.com/) |
| **b. Çalışan Sayısı Aralığı** | • **En Küçük:** ~4.200 - 8.000 çalışan *(Sermaye/enerji yoğun veya yüksek otomasyonlu kuruluşlar)*<br>• **En Büyük:** ~2.100.000 çalışan *(Walmart)* ve ~1.520.000 çalışan *(Amazon)* | [Fortune 500 Workforce Data](https://fortune.com/) & [Statista Global Enterprise Employment](https://www.statista.com/) |
| **c. Bir Firmanın Kullandığı SaaS Sayısı** | **447 ile 664 adet** kurumsal SaaS ürünü.<br>*(10.000+ çalışanlı büyük kurumsal şirketler ayda ortalama 21 yeni SaaS aracı entegre etmekte veya değiştirmektedir).* | [Zylo 2024 SaaS Management Index Raporu](https://zylo.com/reports/saas-management-index/) |
| **d. SaaS Aboneliklerine Yıllık Ödenen Para** | Büyük kurumsal şirketlerde yıllık ortalama **$123.5 Milyon ile $375 Milyon** *(Grup ortalaması: ~$284 Milyon)*. | [Zylo Enterprise Cloud & SaaS Spend Insights](https://zylo.com/) & [Carly SaaS Benchmarks](https://usecarly.com/) |

### Seçilen SaaS ve Fortune 500 Kanıtı
* **Seçilen SaaS:** **Zendesk** (Kurumsal Müşteri Destek, Biletleme ve SLA Yönetim Platformu).
* **Ölçek:** ~350.000 - 450.000 satır kod büyüklüğünde, monolitik Rails mimarisiyle başlayıp mikroservislerle büyütülmüş küresel bir platform.
* **Fortune 500 Kullanım Kanıtı:**
  1. **Stanley Black & Decker** (Fortune 500 #216): Küresel operasyonlarında omnichannel destek altyapısını ve çağrı merkezlerini Zendesk üzerinde birleştirmiştir.  
     🔗 [Zendesk - Stanley Black & Decker Resmi Vaka Analizi](https://www.zendesk.com/customer/stanley-black-decker/) | [FeaturedCustomers İncelemesi](https://www.featuredcustomers.com/customer-stories/stanley-black-decker-zendesk)
  2. **Uber Technologies** (Fortune 500 #141): Sürücü ve yolcu operasyonlarındaki milyonlarca haftalık destek talebini Zendesk altyapısıyla yönetmektedir.  
     🔗 [Zendesk - Uber Resmi Müşteri Hikayesi](https://www.zendesk.com/customer/uber/)

---

## 2. Faz 2: Maliyet ve Kod Satırı (LOC) Tahmini

* **Seçilen SaaS'ın Yaklaşık Satır Sayısı:** ~350.000 satır kod (LOC).
  * **Tahmin Yöntemi:** Zendesk 2007 yılında Ruby on Rails monoliti olarak kuruldu. Şirketin halka arz (IPO S-1) formundaki mühendislik kadrosu verileri, açık kaynak kurumsal Rails destek sistemleri (GitLab ~500k LOC, Discourse ~250k LOC) ve COCOMO II fonksiyon noktası analizi (biletleme, omnichannel yönlendirme, analitik, SLA motoru ve API entegrasyonları) karşılaştırılarak bu tahmine ulaşılmıştır.
* **Coding Agent ile Çekirdeğin (Aort Dilimi) Üretim Maliyeti:**
  * **Tahmin Edilen:** ~$15 - $25 token/abonelik harcaması, 2-3 tam geliştirme günü (15-20 aktif pair programming saati).
  * **Gerçekleşen:** ~$6 - $10 token harcaması, 1.5 geliştirme günü.

---

## 3. Aort Dilimi: Çekirdek İş Akışı (PulseDesk)

Müşterinin bu ürüne para ödemesinin asıl nedeni olan uçtan uca destek biletleme ve SLA akışı:

```
[Müşteri Talebi (New)] 
          │
          ▼ (Temsilci Atanır)
   [İşlemde (Open)] ────► [SLA Geri Sayım Motoru Aktif] (Urgent: 2s, High: 4s, Med: 8s, Low: 24s)
          │                         │
          ├─────────────────────────┼──► [SLA Süresi Dolarsa: sla_breached: true & Alarm]
          ▼                         ▼
 [Yanıt Bekleniyor (Pending)]   [Çözüldü (Solved)] ──► [SLA Sayacı Başarıyla Durur]
                                    │
                                    ├── (Müşteri Teşekkür Ederse: Gratitude Guard Devreye Girer -> Solved Kalır)
                                    ├── (Müşteri Yeni Hata Bildirirse -> Yeniden Open Olur)
                                    ▼
                              [Kapatıldı (Closed / Arşiv)]
```

### Zaman Kuralı (Time Rule)
* **SLA Motoru (`SlaCalculator`):** Biletin önceliğine göre otomatik çözüm süresi tanımlanır:
  * **Acil (Urgent):** 2 Saat
  * **Yüksek (High):** 4 Saat
  * **Normal (Medium):** 8 Saat
  * **Düşük (Low):** 24 Saat
* **Süre Aşımı (Breach):** Süre aşıldığında bilet `sla_breached: true` durumuna geçer ve arayüzde kırmızı alarm yanıp söner.
* **Test Doğrulaması:** `ActiveSupport::Testing::TimeHelpers` içindeki `travel_to` kullanılarak zaman 3 saat ileri sarılmış ve SLA aşımının otomatik tetiklendiği doğrulanmıştır.

### Durum Akışı (State Transitions)
`Ticket::ALLOWED_TRANSITIONS` matrisi ile kontrol edilen katı geçiş kuralları:
`status_new` $\rightarrow$ `status_open` $\rightarrow$ `status_pending` $\rightarrow$ `status_solved` $\rightarrow$ `status_closed`. Geçersiz durum atlamaları (ör. `new` durumundan doğrudan `closed` yapma) model seviyesinde engellenmiştir.

---

## 4. 100 Puanlık Özellik: "Kullanılabilir Pas" (Kullanıcı Acısı Çözümü)

### Sunumdaki Tek Cümle:
> *"G2 ve Capterra'da binlerce destek temsilcisinin şikayet ettiği, 'müşterinin çözülmüş bilete sadece teşekkür etmesiyle biletin yeniden açılıp SLA ve başarı metriklerini çöp etmesi' acısını; PulseDesk'te kural tabanlı Akıllı Nezaket Koruması (Gratitude Guard) ile çözdük."*

* **Kimin Acısı:** Müşteri destek temsilcileri, takım liderleri ve müşteri deneyimi (CX) operasyon yöneticileri.
* **Hangi Yorum / İnceleme:** G2, Capterra ve [Zendesk Community #4409217316634](https://support.zendesk.com/hc/en-us/community/posts/4409217316634-Prevent-Solved-tickets-from-reopening-when-customer-says-Thank-You) şikayetleri:
  > *"Zendesk automatically re-opens solved tickets when a customer replies with just 'Thanks!', which ruins our First Contact Resolution and agent SLA reporting. We waste hours manually closing thank-you tickets."*
* **Bizim Çözümümüz (`GratitudeGuard`):**
  Müşteri `status_solved` durumundaki bir bilete yanıt yazdığında, doğal dil filtreleme motoru devreye girer. Yanıt yalnızca teşekkür/memnuniyet ifadeleri içeriyorsa biletin durumu `status_solved` kalmaya devam eder, arayüzde altın rozetle "Teşekkür Korundu" bilgisi gösterilir ve sayaç artırılır. Müşteri teşekkürün yanına yeni bir sorun/hata eklerse bilet derhal yeniden `status_open` yapılarak temsilcinin kuyruğuna alınır.

---

## 5. Yapamadıklarım (Dürüst Eksikler Listesi)

Ödev kuralları gereği, kopyalanmayan ve bilinçli olarak kapsam dışı bırakılan kurumsal modüller:
1. **SAML / Okta SSO Entegrasyonu:** Kurumsal şirketlerde zorunlu olan Active Directory / Okta SSO girişi yerine demo ortamı için rol tabanlı hızlı temsilci/müşteri simülasyonu tercih edildi.
2. **Çok Kanallı VoIP / Telefon Santrali:** Zendesk Talk benzeri tarayıcı içi çağrı alma modülü yapılmadı; yalnızca yazılı destek akışına odaklanıldı.
3. **Dinamik Tetikleyici / Makro Tasarımcısı (Trigger Builder):** Zendesk'in karmaşık if/then kural motoru yerine standart SLA politikaları kodlandı.
4. **Çoklu Dil Otomatik Çeviri:** Farklı dillerdeki talepler için gerçek zamanlı makine çevirisi eklenmedi.

---

## 6. Testler & CI (GitHub Actions)

Uygulamanın tüm zaman kuralları, durum geçişleri ve Nezaket Koruması test kapsamındadır:

```bash
# Testleri çalıştırmak için:
bin/rails db:test:prepare
bin/rails test
```

* **Test Sonucu:** `38 runs, 143 assertions, 0 failures, 0 errors, 0 skips` (38/38 %100 Yeşil).
* **Zaman Testleri:** `test/models/ticket_test.rb` içerisinde `travel_to` ile test edilmiştir.
* **Müşteri Portalı:** `test/controllers/musteri_controller_test.rb` ile `/musteri` müşteri oturumu ve bilet izolasyonu uçtan uca test edilmiştir.
* **Yetkili Temsilci Masası:** `test/controllers/sessions_controller_test.rb` ve `test/controllers/tickets_controller_test.rb` ile `/temsilci` bilet yönetimi doğrulanmıştır.

---

## 7. 5 Dakikalık Sunum Rehberi & Hızlı İpuçları

Sistem yalnızca **2 temel kapıdan / URL'den** oluşur:
1. **Müşteri Kapısı (`/musteri`):**
   - Giriş yapılmamışsa: Yalnızca e-posta/isim ile müşteri giriş ekranı.
   - Giriş yapılmışsa: Sadece o müşteriye ait biletler listelenir (tam müşteri veri izolasyonu) ve yeni bilet formu bulunur.
2. **Temsilci Masası (`/temsilci`):**
   - Giriş yapılmamışsa: Yetkili personel giriş ekranı (şifre: `admin` veya 1-tıkla Ahmet Kaya).
   - Giriş yapılmışsa: Gelen TÜM talepler tablosu, SLA geri sayım sayaçları, atama ve yanıtlama araçları.

### Hocaya Gösterilecek Canlı Akış Senaryosu:
1. **Giriş (30 sn):** "PulseDesk, Zendesk'in kurumsal biletleme aort diliminin Rails 8 klonudur. Stanley Black & Decker ve Uber gibi F500 firmalarının para ödediği temel iş akışını çözer."
2. **Canlı Akış (2 dk - Çift Taraflı Deneyim):**
   - **Müşteri Kapısı (`/musteri`):** Telefondan veya gizli sekmeden `/musteri` adresine girip acil bir talep oluşturulur.
   - **Temsilci Masası (`/temsilci`):** `/temsilci` ekranına talep sayfa yenilenmeden **canlı olarak düşer**!
   - Temsilci Ahmet Kaya olarak bilete tıklanır, yanıt yazılır ve durum 'Çözüldü' yapılır.
3. **Zaman Kuralı & Kod Yeri (1 dk):**
   - **Hocanın Olası Kod Yeri Sorusu:** *"SLA hafta sonunu saymasın kuralını nereye eklersiniz?"*
   - **Cevap:** `app/services/sla_calculator.rb` dosyası içindeki `calculate_due_at` metodu (Satır 24-40). Burada `target += 2.days if target.saturday?` iş günü kontrolü eklenir.
   - **Canlı SLA Aşımı:** Bilet sayfasındaki **"⚡ Zaman Makinesi"** butonuna basılarak SLA aşımı canlıda gösterilir.
4. **100 Puanlık Nezaket Koruması (Gratitude Guard) (1 dk):**
   - Müşteri portalından `/musteri` bilete **"✨ Hızlı Teşekkür"** gönderilir. Biletin durumu `solved` kalır!
   - Ardından **"⚠️ Hızlı İtiraz"** gönderilir. Bilet derhal yeniden `open` olur!


