package id.ac.ui.cs.advprog.yomubacaandankuis.controller;

import id.ac.ui.cs.advprog.yomubacaandankuis.dto.CategoryRequest;
import id.ac.ui.cs.advprog.yomubacaandankuis.dto.CategoryResponse;
import id.ac.ui.cs.advprog.yomubacaandankuis.service.CategoryService;
import jakarta.validation.Valid;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/admin/categories")
public class AdminCategoryController {

    private static final Logger AUDIT_LOG = LoggerFactory.getLogger("AUDIT");

    private final CategoryService categoryService;

    public AdminCategoryController(CategoryService categoryService) {
        this.categoryService = categoryService;
    }

    @GetMapping
    public List<CategoryResponse> getAllCategories() {
        return categoryService.findAll();
    }

    @GetMapping("/{id}")
    public CategoryResponse getCategoryById(@PathVariable Integer id) {
        return categoryService.findById(id);
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public CategoryResponse createCategory(Authentication authentication, @Valid @RequestBody CategoryRequest request) {
        CategoryResponse response = categoryService.create(request);
        AUDIT_LOG.info("action=ADMIN_CREATE entity=category entityId={} actor={}", response.getId(), authentication.getName());
        return response;
    }

    @PutMapping("/{id}")
    public CategoryResponse updateCategory(Authentication authentication, @PathVariable Integer id, @Valid @RequestBody CategoryRequest request) {
        CategoryResponse response = categoryService.update(id, request);
        AUDIT_LOG.info("action=ADMIN_UPDATE entity=category entityId={} actor={}", response.getId(), authentication.getName());
        return response;
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deleteCategory(Authentication authentication, @PathVariable Integer id) {
        categoryService.delete(id);
        AUDIT_LOG.info("action=ADMIN_DELETE entity=category entityId={} actor={}", id, authentication.getName());
    }
}
