### yomu-bacaan-dan-kuis

## Individual Diagram - Bacaan dan Kuis Module

### Component Diagram

```mermaid
flowchart TB
    User[Pelajar / Admin]

    subgraph Frontend["Frontend - Yomu Frontend"]
        BacaanKuisModule["BacaanKuisModule<br/>Next.js Component<br/><br/>Menampilkan daftar bacaan, mode kuis,<br/>form admin, dan hasil pengerjaan"]
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

    BacaanKuisModule -->|"REST /api/admin/categories"| AdminCategoryController
    BacaanKuisModule -->|"REST /api/admin/readings"| AdminReadingController
    BacaanKuisModule -->|"REST /api/admin/quizzes"| AdminQuizController
    BacaanKuisModule -->|"REST /api/learner/readings/{readingId}"| LearnerReadingController

    ExternalService -->|"REST internal statistics"| InternalStatisticsController

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

    class BacaanKuisModule frontend;
    class AdminCategoryController,AdminReadingController,AdminQuizController,LearnerReadingController,InternalStatisticsController controller;
    class CategoryService,ReadingService,QuizService,LearnerQuizService,LearningStatisticsService service;
    class CategoryRepository,ReadingRepository,QuizRepository,QuizAttemptRepository repository;
    class Database database;
    class User,ExternalService actor;
```

### Code Diagram - Learner Quiz Flow

Diagram ini menunjukkan alur kode ketika pelajar membaca materi, memulai kuis, mengambil soal, dan mengirim jawaban.

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
    FE->>Controller: GET /api/learner/readings/{readingId}
    Controller->>Service: getReadingForLearner(studentId, readingId)
    Service->>ReadingRepo: findById(readingId)
    ReadingRepo->>DB: Query reading
    DB-->>ReadingRepo: Reading data
    ReadingRepo-->>Service: Reading
    Service-->>Controller: LearnerReadingResponse
    Controller-->>FE: Reading response

    FE->>Controller: POST /api/learner/readings/{readingId}/quiz/start
    Controller->>Service: startQuiz(studentId, readingId)
    Service->>AttemptRepo: existsByStudentIdAndReadingIdAndStatus(...)
    AttemptRepo->>DB: Check completed attempt
    DB-->>AttemptRepo: Attempt status
    Service->>AttemptRepo: save(new QuizAttempt)
    AttemptRepo->>DB: Insert quiz attempt

    FE->>Controller: GET /api/learner/readings/{readingId}/quiz
    Controller->>Service: getQuizQuestionsForLearner(studentId, readingId)
    Service->>QuizRepo: findByReadingId(readingId)
    QuizRepo->>DB: Query quiz questions
    DB-->>QuizRepo: Quiz data
    Service-->>Controller: LearnerQuizQuestionResponse[]
    Controller-->>FE: Questions without correctAnswer

    FE->>Controller: POST /api/learner/readings/{readingId}/quiz/submit
    Controller->>Service: submitQuiz(studentId, readingId, answers)
    Service->>AttemptRepo: findByStudentIdAndReadingId(studentId, readingId)
    AttemptRepo->>DB: Query attempt
    Service->>QuizRepo: findByReadingId(readingId)
    QuizRepo->>DB: Query correct answers
    Service->>Service: Calculate score
    Service->>AttemptRepo: save(completed attempt)
    AttemptRepo->>DB: Update attempt score and status
    Controller-->>FE: LearnerSubmitQuizResponse
```

### Code Diagram - Admin Content Management Flow

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

### Code Diagram - Internal Statistics Flow

```mermaid
sequenceDiagram
    participant External as Service Lain<br/>Liga / Achievements
    participant Controller as InternalLearningStatisticsController
    participant Service as LearningStatisticsService
    participant AttemptRepo as QuizAttemptRepository
    participant QuizRepo as QuizRepository
    participant DB as PostgreSQL/Supabase

    External->>Controller: GET /api/internal/league/statistics/students/{studentId}
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
