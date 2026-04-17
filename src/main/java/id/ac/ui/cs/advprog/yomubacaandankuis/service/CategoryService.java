package id.ac.ui.cs.advprog.yomubacaandankuis.service;

import id.ac.ui.cs.advprog.yomubacaandankuis.dto.CategoryRequest;
import id.ac.ui.cs.advprog.yomubacaandankuis.dto.CategoryResponse;
import id.ac.ui.cs.advprog.yomubacaandankuis.model.Category;
import id.ac.ui.cs.advprog.yomubacaandankuis.repository.CategoryRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;

@Service
@Transactional
public class CategoryService {

    private final CategoryRepository categoryRepository;

    public CategoryService(CategoryRepository categoryRepository) {
        this.categoryRepository = categoryRepository;
    }

    @Transactional(readOnly = true)
    public List<CategoryResponse> findAll() {
        return categoryRepository.findAll().stream()
                .map(this::toResponse)
                .toList();
    }

    @Transactional(readOnly = true)
    public CategoryResponse findById(Integer id) {
        return toResponse(getCategory(id));
    }

    public CategoryResponse create(CategoryRequest request) {
        Category category = new Category();
        category.setName(request.getName());
        return toResponse(categoryRepository.save(category));
    }

    public CategoryResponse update(Integer id, CategoryRequest request) {
        Category category = getCategory(id);
        category.setName(request.getName());
        return toResponse(categoryRepository.save(category));
    }

    public void delete(Integer id) {
        Category category = getCategory(id);
        categoryRepository.delete(category);
    }

    private Category getCategory(Integer id) {
        return categoryRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND,
                        "Category with id " + id + " not found"
                ));
    }

    private CategoryResponse toResponse(Category category) {
        return new CategoryResponse(category.getId(), category.getName(), category.getCreatedAt());
    }
}