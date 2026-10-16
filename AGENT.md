# AGENT.md — PulseDesk Yapay Zeka & İnsan Eşli Geliştirme Günlüğü

Bu doküman, **PulseDesk** projesinin Antigravity AI Agent ile insan geliştirici arasındaki eşli programlama (pair-programming) sürecini, alınan mimari kararları, prompt iterasyonlarını ve karşılaşılan teknik engellerin nasıl aşıldığını kayıt altına alır.

---

## 1. Geliştirme Ekibi ve Araçlar

* **İnsan Geliştirici:** Proje Lideri & Mimar (Öğrenci)
* **Yapay Zeka Ajanı:** Antigravity AI Coding Assistant (Gemini 3.8 Flash High)
* **Teknoloji Yığını:**
  * Dil: Ruby 3.3.12 (x64-mingw-ucrt)
  * Framework: Ruby on Rails 8.1.4
  * Veritabanı: SQLite3 (Solid Queue, Solid Cache, Solid Cable)
  * Varlık Yolu: Propshaft & Importmaps
  * Test Altyapısı: Rails Minitest (`ActiveSupport::Testing::TimeHelpers`)
  * CI/CD: GitHub Actions (Ubuntu 24.04 Runner)
  * Canlı Barındırma: Render (Docker Container Runtime)

---

## 2. Ajanla Birlikte Alınan Stratejik Kararlar

### A. SaaS Seçimi (Zendesk $\rightarrow$ PulseDesk)
* **Karar:** DocuSign ve Greenhouse alternatifleri arasından **Zendesk** aort dilimi seçildi.
* **Gerekçe:** Hocanın ödev açıklamasında verdiği ilk örnek olması ve *"SLA hafta sonunu saymasın kural değişikliği"* gibi olası soru örneğinin doğrudan bir biletleme SLA motorunu işaret etmesi.
* **Marka Güvenliği Kuralı:** Orijinal marka adının (Zendesk) uygulamada yer alması doğrudan 0 puan getireceğinden, arayüzde tamamen özgün **PulseDesk** markası, özel renk paleti ve logoları üretildi. Orijinal marka yalnızca README'de ilham kaynağı olarak referans verildi.

### B. 100 Puanlık Kullanıcı Acısının Seçimi (Gratitude Guard)
* **Araştırma:** G2, Capterra ve Zendesk Destek Topluluğu taranarak en çok oy alan kullanıcı şikayetleri incelendi.
* **Bulgu:** Müşterilerin çözülmüş biletlere yalnızca *"Teşekkürler"* yazması nedeniyle biletin `open` durumuna dönmesi, temsilcilerin İlk Temas Çözüm (FCR) oranını ve SLA metriklerini bozmaktaydı.
* **Uygulama:** Ajanla birlikte `app/services/gratitude_guard.rb` servisi geliştirildi. Teşekkür ifadeleri (`teşekkür`, `sağol`, `thanks`) tespit edilirken, itiraz veya sorun ifadeleri (`ama`, `fakat`, `hata`, `not working`) içeren mesajlar filtrelendi.

### C. Modüler Kod Mimarisi (Sunum Kod Yeri Sorusu İçin)
* **Karar:** SLA hesaplama mantığı doğrudan model içine gömülmek yerine bağımsız `app/services/sla_calculator.rb` servisine taşındı.
* **Avantajı:** Sunumda hocanın soracağı *"SLA hafta sonunu saymasın değişikliği nerede yapılır?"* sorusuna saniyeler içinde net dosya adı ve satır numarası (`calculate_due_at` metodu) gösterilebilmesi sağlandı.

---

## 3. Karşılaşılan Zorluklar ve Ajan Çözümleri

### 1. Windows Ortamında MSYS2 ve Derleme Araçları Eksikliği
* **Problem:** Windows ortamında `gem install rails` ve C-extension bağımlılıkları (`nio4r`, `websocket-driver`) derlenirken `MSYS2 could not be found` hatası alındı.
* **Ajan Müdahalesi:** Ajan doğrudan `ridk install 1` ve `ridk install 3` komutlarını çalıştırarak MSYS2 UCRT64 toolchain'ini (gcc 15.2, make, headers) makineye otomatik kurdu ve ortam değişkenlerini yapılandırdı. Rails 8.1.4 kurulumu başarıyla tamamlandı.

### 2. Rails 7.1/8.0 Callback ActionNotFound Hatası
* **Problem:** `TicketsController` içinde tanımlanmamış olan `edit`, `update`, `destroy` aksiyonları `before_action :set_ticket, only: [...]` listesinde yer aldığı için Rails 8 controller testleri 404 ActionNotFound hatası verdi.
* **Ajan Müdahalesi:** Test hata logları incelenerek `before_action` filtresi yalnızca var olan aksiyonlarla (`show`, `transition`, `assign`, `simulate_time_travel`) sınırlandırıldı ve tüm 19 test yeşile döndü.

### 3. Canlı Sunumda SLA Süresini Gösterme Engeli
* **Problem:** SLA süresi 2 saat olan bir biletin ihlal (breach) durumunu sınıfta 5 dakikalık sunumda bekleyerek göstermek imkansızdı.
* **Ajan Müdahalesi:** Ajan, `TicketsController#simulate_time_travel` metodunu ve arayüze tek tıkla çalışan **"⚡ Zaman Makinesi"** butonunu ekledi. Bu sayede sunumda 1 saniye içinde SLA aşımı simüle edilip kırmızı alarm gösterilebilir hale geldi.

---

## 4. Görev Dağılımı Özeti

| Görev Alanı | İnsan Sorumluluğu | Ajan Sorumluluğu |
| :--- | :--- | :--- |
| **Gereksinim Analizi** | Ödev kuralları, puanlama kriterleri (0, 85, 100) | Kriterlerin teknik kontrol listesine dönüştürülmesi |
| **SaaS & Pazar Araştırması** | Kaynak ve metrik doğrulaması | F500 veri madenciliği, Zylo rapor analizi |
| **Mimari Tasarım** | Aort dilimi sınırları, Nezaket Koruması konsepti | Veritabanı şeması, State Machine matrisi, Service Object yapısı |
| **Kodlama & Test** | Kod inceleme, sunum senaryosu onayı | Rails 8 modelleri, controller'lar, `travel_to` testleri |
| **Arayüz Tasarımı** | Renk ve kullanılabilirlik geri bildirimi | Modern dark-slate CSS sistemi, KPI paneli, mikro-etkileşimler |
| **CI/CD & Dağıtım** | Render hesabı ve GitHub repo bağlantısı | Dockerfile optimizasyonu, `ci.yml` iş akışı, `render.yaml` |
