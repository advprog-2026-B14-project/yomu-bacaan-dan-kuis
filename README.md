# yomu-bacaan-dan-kuis

Backend Spring Boot untuk modul **Bacaan dan Kuis** pada platform Yomu. Service ini menangani CRUD kategori, bacaan, pertanyaan kuis, flow learner membaca dan submit kuis, serta statistik internal untuk modul liga.

Dokumentasi arsitektur VPIC lengkap ada di root frontend: `../docs/VPIC_ARCHITECTURE.md`.

## Tech Stack

- Java 21
- Spring Boot 3.4.2
- Spring Web
- Spring Security OAuth2 Resource Server
- Spring Boot Actuator + Micrometer Prometheus
- Spring Data JPA
- Bean Validation
- PostgreSQL/Supabase untuk runtime
- H2 in-memory untuk test
- JaCoCo untuk coverage
- SonarCloud plugin

## Struktur Backend

```text
src/main/java/id/ac/ui/cs/advprog/yomubacaandankuis/
├─ controller/      # REST controller dan exception handler
├─ service/         # business logic
├─ repository/      # Spring Data JPA repository
├─ model/           # JPA entity
├─ dto/             # request/response DTO
└─ config/          # CORS config
```

## Environment Variables

Aplikasi membaca env dari environment atau file `.env` di root backend.

```properties
DB_URL=jdbc:postgresql://localhost:5432/postgres
DB_USERNAME=postgres
DB_PASSWORD=postgres
DB_SCHEMA=learning_mod
PORT=8080
JPA_SHOW_SQL=false
JPA_FORMAT_SQL=false
CORS_ALLOWED_ORIGINS=http://localhost:3000,http://127.0.0.1:3000
JWT_ISSUER_URI=
JWT_JWK_SET_URI=
JWT_STUDENT_CLAIM=student_id
JWT_ROLES_CLAIM=roles
INTERNAL_SERVICE_TOKEN=<secret-token>
INTERNAL_SERVICE_TOKEN_HEADER=X-Internal-Service-Token
SECURITY_DEV_AUTH_ENABLED=false
ACTUATOR_HEALTH_SHOW_DETAILS=when_authorized
```

Keterangan:

- `DB_URL`, `DB_USERNAME`, `DB_PASSWORD`: wajib untuk runtime.
- `DB_SCHEMA`: opsional, default `learning_mod`.
- `PORT`: opsional, default `8080`.
- `CORS_ALLOWED_ORIGINS`: origin frontend yang boleh mengakses `/api/**`.
- `JWT_ISSUER_URI`: issuer JWT dari auth service. Isi salah satu dari `JWT_ISSUER_URI` atau `JWT_JWK_SET_URI` untuk production.
- `JWT_JWK_SET_URI`: JWK Set URI untuk verifikasi signature JWT.
- `JWT_STUDENT_CLAIM`: claim JWT yang berisi student ID, default `student_id`; fallback ke `sub` jika claim ini tidak ada.
- `JWT_ROLES_CLAIM`: claim JWT yang berisi role, default `roles`. Role dikonversi menjadi authority `ROLE_*`.
- `INTERNAL_SERVICE_TOKEN`: token rahasia untuk endpoint `/api/internal/**`.
- `INTERNAL_SERVICE_TOKEN_HEADER`: header token internal, default `X-Internal-Service-Token`.
- `SECURITY_DEV_AUTH_ENABLED`: mode development lokal. Default `false`; jangan aktifkan di production.
- `ACTUATOR_HEALTH_SHOW_DETAILS`: detail health actuator, default `when_authorized`.

## Menjalankan Aplikasi

Linux/macOS:

```bash
./gradlew bootRun
```

Windows PowerShell:

```powershell
.\gradlew.bat bootRun
```

Untuk development lokal tanpa auth service/JWT asli, aktifkan dev header auth:

```powershell
$env:SECURITY_DEV_AUTH_ENABLED="true"
$env:INTERNAL_SERVICE_TOKEN="local-internal-token"
.\gradlew.bat bootRun
```

Dalam mode ini:

- request `/api/admin/**` diberi role dev `ADMIN`.
- request `/api/learner/**` diberi role dev `LEARNER`.
- learner identity tetap dibaca dari `X-Student-Id` untuk kompatibilitas frontend lokal.
- mode ini hanya untuk development dan harus dimatikan di production.

Service berjalan di:

```text
http://localhost:8080
```

## Deployment Fly.io

Service ini sudah disiapkan untuk deploy ke Fly.io melalui:

- `Dockerfile`
- `.dockerignore`
- `fly.toml`
- `.github/workflows/fly-deploy.yml`

Deploy manual pertama:

```powershell
fly auth login
fly apps create yomu-bacaan-dan-kuis
fly secrets set DB_URL="<supabase-postgres-jdbc-url>"
fly secrets set DB_USERNAME="<supabase-username>"
fly secrets set DB_PASSWORD="<supabase-password>"
fly secrets set DB_SCHEMA="learning_mod"
fly secrets set CORS_ALLOWED_ORIGINS="https://<frontend-vercel-url>"
fly secrets set INTERNAL_SERVICE_TOKEN="<random-secret>"
fly deploy
```

Jika frontend testing belum punya JWT/auth service, mode development bisa dinyalakan sementara:

```powershell
fly secrets set SECURITY_DEV_AUTH_ENABLED="true"
```

Untuk production final, matikan kembali dan gunakan JWT:

```powershell
fly secrets set SECURITY_DEV_AUTH_ENABLED="false"
fly secrets set JWT_ISSUER_URI="<issuer-url>"
# atau
fly secrets set JWT_JWK_SET_URI="<jwk-set-url>"
```

URL backend setelah deploy:

```text
https://yomu-bacaan-dan-kuis.fly.dev
```

Setelah URL Fly.io aktif, set frontend Vercel:

```text
BACKEND_API_URL=https://yomu-bacaan-dan-kuis.fly.dev
NEXT_PUBLIC_API_BASE_URL=/api/backend
```

Untuk GitHub Actions deployment, tambahkan repository secret:

```text
FLY_API_TOKEN=<token dari fly auth token>
```

Catatan rollback:

```powershell
fly releases
fly deploy --image <previous-image>
```

Atau gunakan rollback dari dashboard/CLI Fly.io sesuai release yang ingin dikembalikan.

## Menjalankan Test dan Coverage

```powershell
.\gradlew.bat test
```

Untuk coverage report dan verification:

```powershell
.\gradlew.bat test jacocoTestReport jacocoTestCoverageVerification
```

Test memakai konfigurasi H2 in-memory di `src/test/resources/application.properties`, sehingga tidak membutuhkan koneksi Supabase.

Report:

- Test report: `build/reports/tests/test/index.html`
- JaCoCo HTML: `build/reports/jacoco/test/html/index.html`
- JaCoCo XML: `build/reports/jacoco/test/jacocoTestReport.xml`

## Endpoint Utama

### Admin

Semua endpoint admin membutuhkan Bearer JWT dengan role `ADMIN`.

- `GET /api/admin/categories`
- `GET /api/admin/categories/{id}`
- `POST /api/admin/categories`
- `PUT /api/admin/categories/{id}`
- `DELETE /api/admin/categories/{id}`
- `GET /api/admin/readings`
- `GET /api/admin/readings/{id}`
- `POST /api/admin/readings`
- `PUT /api/admin/readings/{id}`
- `DELETE /api/admin/readings/{id}`
- `GET /api/admin/quizzes`
- `GET /api/admin/quizzes/{id}`
- `POST /api/admin/quizzes`
- `PUT /api/admin/quizzes/{id}`
- `DELETE /api/admin/quizzes/{id}`

### Learner

Semua endpoint learner membutuhkan Bearer JWT dengan role `LEARNER`. Student ID diambil dari claim JWT `student_id` atau claim yang dikonfigurasi lewat `JWT_STUDENT_CLAIM`; jika claim tidak ada, service memakai `sub`.

Contoh claim:

```json
{
  "sub": "student-1",
  "student_id": "student-1",
  "roles": ["LEARNER"]
}
```

- `GET /api/learner/readings/{readingId}`
- `POST /api/learner/readings/{readingId}/quiz/start`
- `GET /api/learner/readings/{readingId}/quiz`
- `POST /api/learner/readings/{readingId}/quiz/submit`

### Internal

Endpoint internal membutuhkan header service token:

```text
X-Internal-Service-Token: <INTERNAL_SERVICE_TOKEN>
```

- `GET /api/internal/league/statistics/students/{studentId}`

Endpoint internal ini dipakai modul lain untuk membaca statistik penyelesaian kuis learner.

### Observability

Endpoint observability:

- `GET /actuator/health`: public untuk health check.
- `GET /actuator/prometheus`: public agar Prometheus dapat scrape metrics.
- `GET /actuator/**` selain health/info/prometheus: membutuhkan `X-Internal-Service-Token`.

Prometheus/Grafana untuk final tersedia di root project:

```powershell
cd C:\adpro\IdeaProjects\group
docker compose -f monitoring/docker-compose.yml up
```

Buka Grafana di `http://localhost:3001` dengan user/pass `admin/admin`, lalu pilih dashboard `Yomu Bacaan dan Kuis Observability`.

## Design Pattern

- Layered Architecture / MVC: controller, service, repository, model, DTO.
- Repository Pattern: Spring Data JPA repository.
- DTO Pattern: request/response tidak langsung memakai entity.
- Dependency Injection: constructor injection.
- Centralized Exception Handling: `RestExceptionHandler`.

## Status Integrasi gRPC/RabbitMQ

Service ini belum memakai gRPC atau RabbitMQ. Integrasi saat ini memakai REST API. Jika event-driven diwajibkan, kandidat implementasi paling realistis adalah publish event `quiz.completed` setelah `LearnerQuizService.submitQuiz()` berhasil menyimpan attempt sebagai `COMPLETED`.

## Security

Status security saat ini sudah memakai Spring Security Resource Server JWT dan internal service token.

Yang sudah diimplementasikan:

- credential database memakai environment variable dan `.env` di-ignore.
- CORS dibatasi melalui `CORS_ALLOWED_ORIGINS`.
- `/api/admin/**` hanya untuk role `ADMIN`.
- `/api/learner/**` hanya untuk role `LEARNER`.
- learner identity diambil dari JWT claim, bukan header bebas pada mode production.
- `/api/internal/**` dilindungi `INTERNAL_SERVICE_TOKEN`.
- endpoint lain ditutup dengan `denyAll`.
- audit log sederhana untuk operasi create/update/delete admin dan submit quiz.

Yang masih di luar scope service ini:

- rate limiting, WAF, dan mTLS/gateway policy sebaiknya ditempatkan di API Gateway.
- audit log saat ini masih berupa structured application log, belum dikirim ke SIEM/centralized log storage.

Contoh audit log:

```text
action=ADMIN_CREATE entity=reading entityId=10 actor=admin-user
action=QUIZ_SUBMIT entity=quiz_attempt actor=student-1 readingId=10 score=2
```

## Profiling

Profiling runtime dapat dilakukan dengan Java Flight Recorder tanpa menambah dependency:

```powershell
$env:JAVA_TOOL_OPTIONS="-XX:StartFlightRecording=filename=build/profile/yomu-bacaan-kuis.jfr,duration=120s,settings=profile"
.\gradlew.bat bootRun
```

Lakukan flow baca dan submit kuis, lalu buka file `.jfr` menggunakan Java Mission Control.

## Kontrak API

Kontrak lengkap lintas service ada di:

```text
../API_CONTRACT.md
```
