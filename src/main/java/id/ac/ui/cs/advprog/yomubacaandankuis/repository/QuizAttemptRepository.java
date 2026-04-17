package id.ac.ui.cs.advprog.yomubacaandankuis.repository;

import id.ac.ui.cs.advprog.yomubacaandankuis.model.QuizAttempt;
import id.ac.ui.cs.advprog.yomubacaandankuis.model.QuizAttemptStatus;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface QuizAttemptRepository extends JpaRepository<QuizAttempt, Integer> {
    Optional<QuizAttempt> findByStudentIdAndReadingId(String studentId, Integer readingId);

    boolean existsByStudentIdAndReadingIdAndStatus(String studentId, Integer readingId, QuizAttemptStatus status);
}
