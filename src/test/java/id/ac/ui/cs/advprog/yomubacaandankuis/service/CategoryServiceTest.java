package id.ac.ui.cs.advprog.yomubacaandankuis.service;

import id.ac.ui.cs.advprog.yomubacaandankuis.dto.CategoryRequest;
import id.ac.ui.cs.advprog.yomubacaandankuis.dto.CategoryResponse;
import id.ac.ui.cs.advprog.yomubacaandankuis.model.Category;
import id.ac.ui.cs.advprog.yomubacaandankuis.repository.CategoryRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.HttpStatus;
import org.springframework.web.server.ResponseStatusException;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class CategoryServiceTest {

    @Mock
    private CategoryRepository categoryRepository;

    private CategoryService categoryService;

    @BeforeEach
    void setUp() {
        categoryService = new CategoryService(categoryRepository);
    }

    @Test
    void findAllReturnsMappedResponses() {
        Category category = createCategory(1, "History");
        when(categoryRepository.findAll()).thenReturn(List.of(category));

        List<CategoryResponse> responses = categoryService.findAll();

        assertThat(responses)
                .singleElement()
                .extracting(CategoryResponse::getId, CategoryResponse::getName)
                .containsExactly(1, "History");
    }

    @Test
    void findByIdReturnsMappedResponse() {
        Category category = createCategory(1, "Science");
        when(categoryRepository.findById(1)).thenReturn(Optional.of(category));

        CategoryResponse response = categoryService.findById(1);

        assertThat(response.getId()).isEqualTo(1);
        assertThat(response.getName()).isEqualTo("Science");
        assertThat(response.getCreatedAt()).isEqualTo(category.getCreatedAt());
    }

    @Test
    void findByIdThrowsWhenCategoryMissing() {
        when(categoryRepository.findById(99)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> categoryService.findById(99))
                .isInstanceOf(ResponseStatusException.class)
                .satisfies(exception -> {
                    ResponseStatusException responseStatusException = (ResponseStatusException) exception;
                    assertThat(responseStatusException.getStatusCode()).isEqualTo(HttpStatus.NOT_FOUND);
                    assertThat(responseStatusException.getReason()).isEqualTo("Category with id 99 not found");
                });
    }

    @Test
    void createSavesCategoryFromRequest() {
        CategoryRequest request = new CategoryRequest();
        request.setName("Literature");
        when(categoryRepository.save(any(Category.class))).thenAnswer(invocation -> {
            Category saved = invocation.getArgument(0);
            saved.setId(10);
            saved.setCreatedAt(LocalDateTime.of(2026, 3, 6, 20, 30));
            return saved;
        });

        CategoryResponse response = categoryService.create(request);

        assertThat(response.getId()).isEqualTo(10);
        assertThat(response.getName()).isEqualTo("Literature");
    }

    @Test
    void updateModifiesExistingCategory() {
        Category category = createCategory(7, "Old Name");
        CategoryRequest request = new CategoryRequest();
        request.setName("New Name");
        when(categoryRepository.findById(7)).thenReturn(Optional.of(category));
        when(categoryRepository.save(category)).thenReturn(category);

        CategoryResponse response = categoryService.update(7, request);

        assertThat(category.getName()).isEqualTo("New Name");
        assertThat(response.getName()).isEqualTo("New Name");
    }

    @Test
    void deleteRemovesExistingCategory() {
        Category category = createCategory(5, "Math");
        when(categoryRepository.findById(5)).thenReturn(Optional.of(category));

        categoryService.delete(5);

        verify(categoryRepository).delete(category);
    }

    private Category createCategory(Integer id, String name) {
        Category category = new Category();
        category.setId(id);
        category.setName(name);
        category.setCreatedAt(LocalDateTime.of(2026, 3, 6, 20, 0));
        return category;
    }
}