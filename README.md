# Yomu Bacaan dan Kuis

Backend ini menangani modul Bacaan dan Kuis di Yomu. Scope utamanya adalah data kategori, bacaan, soal kuis, pengerjaan kuis oleh learner, review hasil kuis, dan statistik yang dibutuhkan modul Liga.

## Stack

- Java 21
- Spring Boot 3.4.2
- Spring Web dan Spring Security
- Spring Data JPA
- PostgreSQL/Supabase
- Actuator dan Prometheus metrics
- JaCoCo dan SonarCloud
- Fly.io untuk deployment


## Struktur Kode

```text
src/main/java/id/ac/ui/cs/advprog/yomubacaandankuis/
├─ config/          konfigurasi security, CORS, dan auth helper
├─ controller/      boundary REST API
├─ dto/             request dan response object
├─ model/           entity JPA
├─ repository/      akses database
└─ service/         business logic
```

## Diagram

### Component Diagram

```mermaid
flowchart TB
    User[Pelajar / Admin]

    subgraph Frontend["Frontend - Yomu Frontend"]
        BacaanKuisModule["BacaanKuisModule<br/>Next.js Component<br/><br/>Menampilkan daftar bacaan, mode kuis,<br/>form admin, dan hasil pengerjaan"]
        BackendProxy["Next.js API Proxy<br/>/api/backend/[...path]"]
        LeagueProxy["Next.js League Proxy<br/>/api/league/statistics/students/{studentId}"]
    end

    subgraph Backend["Backend - Yomu Bacaan dan Kuis Service"]
        AdminCategoryController["AdminCategoryController<br/>Mengelola kategori bacaan"]
        AdminReadingController["AdminReadingController<br/>Mengelola konten bacaan"]
        AdminQuizController["AdminQuizController<br/>Mengelola soal kuis"]
        LearnerReadingController["LearnerReadingController<br/>Flow pelajar membaca dan mengerjakan kuis"]
        InternalStatisticsController["InternalLearningStatisticsController<br/>Menyediakan statistik belajar untuk service lain"]

        CategoryService["CategoryService"]
        ReadingService["ReadingService"]
        QuizService["QuizService"]
        LearnerQuizService["LearnerQuizService"]
        LearningStatisticsService["LearningStatisticsService"]

        CategoryRepository["CategoryRepository"]
        ReadingRepository["ReadingRepository"]
        QuizRepository["QuizRepository"]
        QuizAttemptRepository["QuizAttemptRepository"]
    end

    subgraph Data["Data Layer"]
        Database[("PostgreSQL / Supabase<br/>Schema: learning_mod")]
    end

    ExternalService["Service lain<br/>Contoh: Liga / Achievements"]

    User -->|"Mengakses halaman /bacaan-kuis"| BacaanKuisModule

    BacaanKuisModule -->|"Frontend request"| BackendProxy
    BacaanKuisModule -->|"Statistik Liga"| LeagueProxy

    BackendProxy -->|"REST /api/admin/categories"| AdminCategoryController
    BackendProxy -->|"REST /api/admin/readings"| AdminReadingController
    BackendProxy -->|"REST /api/admin/quizzes"| AdminQuizController
    BackendProxy -->|"REST /api/learner/readings/{readingId}"| LearnerReadingController
    LeagueProxy -->|"REST internal statistics + token"| InternalStatisticsController

    ExternalService -->|"REST internal statistics + token"| InternalStatisticsController

    AdminCategoryController --> CategoryService
    AdminReadingController --> ReadingService
    AdminQuizController --> QuizService
    LearnerReadingController --> LearnerQuizService
    InternalStatisticsController --> LearningStatisticsService

    CategoryService --> CategoryRepository
    ReadingService --> ReadingRepository
    ReadingService --> CategoryRepository
    QuizService --> QuizRepository
    QuizService --> ReadingRepository
    LearnerQuizService --> QuizAttemptRepository
    LearnerQuizService --> QuizRepository
    LearnerQuizService --> ReadingRepository
    LearningStatisticsService --> QuizAttemptRepository
    LearningStatisticsService --> QuizRepository

    CategoryRepository --> Database
    ReadingRepository --> Database
    QuizRepository --> Database
    QuizAttemptRepository --> Database

    classDef frontend fill:#2563eb,stroke:#93c5fd,color:#ffffff,stroke-width:2px;
    classDef controller fill:#7c3aed,stroke:#c4b5fd,color:#ffffff,stroke-width:2px;
    classDef service fill:#047857,stroke:#6ee7b7,color:#ffffff,stroke-width:2px;
    classDef repository fill:#b45309,stroke:#fbbf24,color:#ffffff,stroke-width:2px;
    classDef database fill:#374151,stroke:#d1d5db,color:#ffffff,stroke-width:2px;
    classDef actor fill:#1f2937,stroke:#94a3b8,color:#ffffff,stroke-width:1px;

    class BacaanKuisModule,BackendProxy,LeagueProxy frontend;
    class AdminCategoryController,AdminReadingController,AdminQuizController,LearnerReadingController,InternalStatisticsController controller;
    class CategoryService,ReadingService,QuizService,LearnerQuizService,LearningStatisticsService service;
    class CategoryRepository,ReadingRepository,QuizRepository,QuizAttemptRepository repository;
    class Database database;
    class User,ExternalService actor;
```

### Learner Quiz Flow

```mermaid
sequenceDiagram
    actor Learner as Pelajar
    participant FE as BacaanKuisModule
    participant Controller as LearnerReadingController
    participant Service as LearnerQuizService
    participant AttemptRepo as QuizAttemptRepository
    participant QuizRepo as QuizRepository
    participant ReadingRepo as ReadingRepository
    participant DB as PostgreSQL/Supabase

    Learner->>FE: Membuka bacaan dan kuis
    FE->>Controller: GET /api/learner/readings/{readingId} via Next.js proxy
    Controller->>Service: getReadingForLearner(studentId, readingId)
    Service->>ReadingRepo: findById(readingId)
    ReadingRepo->>DB: Query reading
    DB-->>ReadingRepo: Reading data
    ReadingRepo-->>Service: Reading
    Service-->>Controller: LearnerReadingResponse
    Controller-->>FE: Reading response

    FE->>Controller: POST /api/learner/readings/{readingId}/quiz/start via Next.js proxy
    Controller->>Service: startQuiz(studentId, readingId)
    Service->>AttemptRepo: existsByStudentIdAndReadingIdAndStatus(...)
    AttemptRepo->>DB: Check completed attempt
    DB-->>AttemptRepo: Attempt status
    Service->>AttemptRepo: save(new QuizAttempt)
    AttemptRepo->>DB: Insert quiz attempt

    FE->>Controller: GET /api/learner/readings/{readingId}/quiz via Next.js proxy
    Controller->>Service: getQuizQuestionsForLearner(studentId, readingId)
    Service->>QuizRepo: findByReadingId(readingId)
    QuizRepo->>DB: Query quiz questions
    DB-->>QuizRepo: Quiz data
    Service-->>Controller: LearnerQuizQuestionResponse[]
    Controller-->>FE: Questions without correctAnswer

    FE->>Controller: POST /api/learner/readings/{readingId}/quiz/submit via Next.js proxy
    Controller->>Service: submitQuizWithReview(studentId, readingId, answers)
    Service->>AttemptRepo: findByStudentIdAndReadingId(studentId, readingId)
    AttemptRepo->>DB: Query attempt
    Service->>Service: Reject if attempt already COMPLETED
    Service->>QuizRepo: findByReadingId(readingId)
    QuizRepo->>DB: Query correct answers
    Service->>Service: Calculate score and correctAnswers
    Service->>AttemptRepo: save(completed attempt)
    AttemptRepo->>DB: Update attempt score and status
    Controller-->>FE: LearnerSubmitQuizResponse(score, totalQuestions, correctAnswers)
    FE->>FE: Show review-only mode
```

### Admin Content Management Flow

```mermaid
sequenceDiagram
    actor Admin
    participant FE as BacaanKuisModule
    participant CategoryController as AdminCategoryController
    participant ReadingController as AdminReadingController
    participant QuizController as AdminQuizController
    participant CategoryService as CategoryService
    participant ReadingService as ReadingService
    participant QuizService as QuizService
    participant CategoryRepo as CategoryRepository
    participant ReadingRepo as ReadingRepository
    participant QuizRepo as QuizRepository
    participant DB as PostgreSQL/Supabase

    Admin->>FE: Mengisi form kategori, bacaan, atau kuis

    FE->>CategoryController: POST /api/admin/categories
    CategoryController->>CategoryService: create(CategoryRequest)
    CategoryService->>CategoryRepo: save(Category)
    CategoryRepo->>DB: Insert category
    DB-->>CategoryRepo: Saved category
    CategoryService-->>CategoryController: CategoryResponse
    CategoryController-->>FE: Category created

    FE->>ReadingController: POST /api/admin/readings
    ReadingController->>ReadingService: create(ReadingRequest)
    ReadingService->>CategoryRepo: findById(categoryId)
    CategoryRepo->>DB: Query category
    ReadingService->>ReadingRepo: save(Reading)
    ReadingRepo->>DB: Insert reading
    ReadingService-->>ReadingController: ReadingResponse
    ReadingController-->>FE: Reading created

    FE->>QuizController: POST /api/admin/quizzes
    QuizController->>QuizService: create(QuizRequest)
    QuizService->>ReadingRepo: findById(readingId)
    ReadingRepo->>DB: Query reading
    QuizService->>QuizRepo: save(Quiz)
    QuizRepo->>DB: Insert quiz
    QuizService-->>QuizController: QuizResponse
    QuizController-->>FE: Quiz created
```

### Internal Statistics Flow

```mermaid
sequenceDiagram
    participant External as Service Lain<br/>Liga / Achievements
    participant Controller as InternalLearningStatisticsController
    participant Service as LearningStatisticsService
    participant AttemptRepo as QuizAttemptRepository
    participant QuizRepo as QuizRepository
    participant DB as PostgreSQL/Supabase

    External->>Controller: GET /api/internal/league/statistics/students/{studentId}<br/>X-Internal-Service-Token
    Controller->>Service: getStudentStatistics(studentId)
    Service->>AttemptRepo: findByStudentIdAndStatus(studentId, COMPLETED)
    AttemptRepo->>DB: Query completed attempts
    DB-->>AttemptRepo: Completed attempts
    AttemptRepo-->>Service: List<QuizAttempt>

    loop For each completed attempt
        Service->>QuizRepo: countByReadingId(readingId)
        QuizRepo->>DB: Count quiz questions
        DB-->>QuizRepo: Total questions
    end

    Service->>Service: Calculate completedQuizCount, accuracyRate, accuracyPercentage
    Service-->>Controller: LearningStatisticsResponse
    Controller-->>External: Learning statistics
```

## Modul Bacaan dan Kuis

Fitur utama backend:

- CRUD kategori, bacaan, dan soal kuis untuk admin.
- Flow learner untuk membuka bacaan, mulai kuis, mengambil soal, dan submit jawaban.
- Pencegahan pengerjaan ulang untuk quiz attempt yang sudah selesai.
- Response review setelah submit agar frontend dapat menampilkan jawaban benar tanpa membocorkan kunci jawaban sebelum submit.
- Statistik internal untuk akurasi, jumlah quiz selesai, total jawaban benar, dan total soal.

## Design Pattern

Kode memakai layered architecture: controller, service, repository, DTO, dan entity dipisahkan jelas. Controller hanya menangani request/response HTTP, service memegang aturan bisnis, dan repository berurusan dengan persistence.

Beberapa prinsip desain yang diterapkan:

- **Single Responsibility**: validasi request, business logic, dan akses database tidak dicampur di satu kelas.
- **Dependency Inversion**: controller dan service menerima dependency lewat constructor injection.
- **Interface-based persistence**: akses database dilakukan lewat Spring Data repository.
- **DTO boundary**: entity JPA tidak langsung menjadi kontrak API.
- **Centralized error handling**: response error ditangani melalui exception handler.

## REST API

Audit kode menggunakan REST API untuk integrasi frontend dan kebutuhan service lain. REST dipakai karena alurnya sinkron dan langsung: frontend meminta bacaan, mengambil soal, submit kuis, lalu membaca hasil/statistik.

Endpoint utama:

```text
GET    /api/admin/categories
POST   /api/admin/categories
GET    /api/admin/readings
POST   /api/admin/readings
GET    /api/admin/quizzes
POST   /api/admin/quizzes

GET    /api/learner/readings/{readingId}
POST   /api/learner/readings/{readingId}/quiz/start
GET    /api/learner/readings/{readingId}/quiz
POST   /api/learner/readings/{readingId}/quiz/submit

GET    /api/internal/league/statistics/students/{studentId}
```

Endpoint learner tidak mengirim `correctAnswer` saat soal diambil. Kunci jawaban hanya dikirim sebagai bagian dari response submit untuk kebutuhan review.

## Security

Backend menggunakan Spring Security Resource Server.

- `/api/admin/**` membutuhkan role `ADMIN`.
- `/api/learner/**` membutuhkan role `LEARNER`.
- Student ID dibaca dari claim JWT.
- `/api/internal/**` membutuhkan token internal service-to-service.
- CORS dikontrol lewat environment.
- Credential database, token internal, dan token deploy tidak disimpan di repository.

Ada mode dev auth untuk testing lokal, tetapi mode ini bukan untuk production.

## Observability dan Performance

Backend mengekspos:

```text
/actuator/health
/actuator/prometheus
```

Health endpoint dipakai untuk deployment smoke test. Prometheus metrics dipakai untuk monitoring latency, throughput, JVM, dan koneksi database.

Performance evidence yang relevan untuk modul ini:

- APDEX untuk flow learner.
- Java Flight Recorder untuk profiling backend.
- Prometheus/Grafana untuk observability.
- Lighthouse dan Clarity untuk sisi frontend.

## Deployment

Backend berjalan di Fly.io:

```text
https://yomu-bacaan-dan-kuis-b14-hanif.fly.dev
```

File deployment:

- `Dockerfile`
- `.dockerignore`
- `fly.toml`
- `.github/workflows/cd.yml`
- `.github/workflows/fly-deploy.yml`

Workflow CD melakukan deploy ke Fly.io, mengecek health endpoint setelah deploy, dan menyediakan rollback manual dari GitHub Actions.

## Konfigurasi Penting

Runtime memakai environment variable untuk koneksi database, CORS, JWT, dan token internal.

```text
DB_URL
DB_USERNAME
DB_PASSWORD
DB_SCHEMA
CORS_ALLOWED_ORIGINS
JWT_ISSUER_URI atau JWT_JWK_SET_URI
INTERNAL_SERVICE_TOKEN
SECURITY_DEV_AUTH_ENABLED
```

Frontend mengakses backend melalui proxy Next.js dengan:

```text
BACKEND_API_URL=https://yomu-bacaan-dan-kuis-b14-hanif.fly.dev
NEXT_PUBLIC_API_BASE_URL=/api/backend
```
