package id.ac.ui.cs.advprog.yomubacaandankuis.repository;

import id.ac.ui.cs.advprog.yomubacaandankuis.model.Quiz;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface QuizRepository extends JpaRepository<Quiz, Integer> {
	List<Quiz> findByReadingId(Integer readingId);

	long countByReadingId(Integer readingId);
}
