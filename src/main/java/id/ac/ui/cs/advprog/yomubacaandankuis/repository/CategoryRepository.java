package id.ac.ui.cs.advprog.yomubacaandankuis.repository;

import id.ac.ui.cs.advprog.yomubacaandankuis.model.Category;
import org.springframework.data.jpa.repository.JpaRepository;

public interface CategoryRepository extends JpaRepository<Category, Integer> {
}