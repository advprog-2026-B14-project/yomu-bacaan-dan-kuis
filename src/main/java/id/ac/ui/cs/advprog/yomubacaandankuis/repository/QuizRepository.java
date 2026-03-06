package id.ac.ui.cs.advprog.yomubacaandankuis.repository;

import id.ac.ui.cs.advprog.yomubacaandankuis.model.Quiz;
import org.springframework.data.jpa.repository.JpaRepository;

public interface QuizRepository extends JpaRepository<Quiz, Integer> {
}