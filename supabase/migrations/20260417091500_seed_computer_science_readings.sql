-- Seed data for Computer Science readings and quizzes (idempotent)

insert into learning_mod.categories (name, created_at)
select v.name, now()
from (
    values
        ('Computer Science')
) as v(name)
where not exists (
    select 1
    from learning_mod.categories c
    where lower(c.name) = lower(v.name)
);

with cs_category as (
    select c.id
    from learning_mod.categories c
    where lower(c.name) = 'computer science'
    order by c.id
    limit 1
)
insert into learning_mod.readings (title, content, category_id, created_at)
select v.title, v.content, cs_category.id, now()
from cs_category
cross join (
    values
        (
            'What Is Computational Thinking?',
            'Computational thinking adalah cara menyelesaikan masalah secara sistematis dengan empat pilar utama: decomposition (memecah masalah menjadi bagian kecil), pattern recognition (mencari pola), abstraction (fokus pada hal penting), dan algorithm design (menyusun langkah solusi). Pola pikir ini tidak hanya dipakai saat coding, tetapi juga untuk menyusun workflow, menganalisis data, dan membuat keputusan teknis yang lebih terstruktur.'
        ),
        (
            'Algorithms and Data Structures: Why They Matter',
            'Algoritma menentukan langkah penyelesaian masalah, sedangkan struktur data menentukan bagaimana data disimpan dan diakses. Kombinasi keduanya berpengaruh besar pada performa. Misalnya, pencarian pada array tidak terurut cenderung O(n), sementara struktur seperti hash map bisa mendekati O(1) untuk lookup rata-rata. Memilih struktur data yang tepat sering kali lebih penting daripada sekadar menambah resource server.'
        ),
        (
            'Time Complexity in Practice',
            'Kompleksitas waktu membantu memprediksi pertumbuhan biaya komputasi saat input bertambah. O(1), O(log n), O(n), dan O(n^2) adalah kelas yang sering ditemui. Dalam praktik backend, perbedaan antara O(n) dan O(n^2) bisa menjadi bottleneck serius ketika jumlah pengguna meningkat. Karena itu, engineer perlu mempertimbangkan kompleksitas sejak tahap desain, bukan hanya saat aplikasi sudah lambat.'
        ),
        (
            'Database Transactions and Consistency',
            'Transaksi database memastikan sekelompok operasi diperlakukan sebagai satu unit kerja. Konsep ACID (Atomicity, Consistency, Isolation, Durability) menjaga data tetap valid walau terjadi kegagalan di tengah proses. Pada sistem kuis, transaksi penting agar status attempt, jawaban, dan skor tidak menjadi setengah tersimpan. Dengan isolation level yang tepat, kita juga mengurangi risiko race condition.'
        ),
        (
            'Client-Server Architecture for Web Apps',
            'Arsitektur client-server memisahkan antarmuka pengguna (frontend) dan logika bisnis/data (backend). Frontend mengirim request ke API, backend memvalidasi, memproses, lalu mengembalikan response. Pemisahan ini memudahkan scaling, maintenance, dan kolaborasi tim. Namun, integrasi perlu memperhatikan kontrak API, status code, penanganan error, dan keamanan seperti autentikasi serta otorisasi.'
        )
) as v(title, content)
where not exists (
    select 1
    from learning_mod.readings r
    where r.title = v.title
);

with quiz_seed as (
    select *
    from (
        values
            (
                'What Is Computational Thinking?',
                'Manakah yang termasuk pilar computational thinking?',
                'Decomposition',
                'Code formatting',
                'Dark mode',
                'Deployment rollback',
                'A'
            ),
            (
                'Algorithms and Data Structures: Why They Matter',
                'Untuk lookup cepat rata-rata, struktur data yang sering dipilih adalah ...',
                'Linked list',
                'Hash map',
                'Stack',
                'Queue',
                'B'
            ),
            (
                'Time Complexity in Practice',
                'Kompleksitas waktu yang tumbuh paling cepat berikut ini adalah ...',
                'O(1)',
                'O(log n)',
                'O(n)',
                'O(n^2)',
                'D'
            ),
            (
                'Database Transactions and Consistency',
                'Huruf D pada ACID berarti ...',
                'Dataframe',
                'Durability',
                'Distribution',
                'Dependency',
                'B'
            ),
            (
                'Client-Server Architecture for Web Apps',
                'Dalam arsitektur web, frontend biasanya berkomunikasi ke backend melalui ...',
                'BIOS',
                'Compiler flag',
                'API request',
                'Filesystem mount lokal saja',
                'C'
            )
    ) as q(reading_title, question, option_a, option_b, option_c, option_d, correct_answer)
)
insert into learning_mod.quizzes (reading_id, question, option_a, option_b, option_c, option_d, correct_answer, created_at)
select r.id, q.question, q.option_a, q.option_b, q.option_c, q.option_d, q.correct_answer, now()
from quiz_seed q
join learning_mod.readings r on r.title = q.reading_title
where not exists (
    select 1
    from learning_mod.quizzes z
    where z.reading_id = r.id
      and z.question = q.question
);
