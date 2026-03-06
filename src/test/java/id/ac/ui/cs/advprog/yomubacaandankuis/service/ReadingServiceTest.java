package id.ac.ui.cs.advprog.yomubacaandankuis.service;

import id.ac.ui.cs.advprog.yomubacaandankuis.dto.ReadingRequest;
import id.ac.ui.cs.advprog.yomubacaandankuis.dto.ReadingResponse;
import id.ac.ui.cs.advprog.yomubacaandankuis.model.Category;
import id.ac.ui.cs.advprog.yomubacaandankuis.model.Reading;
import id.ac.ui.cs.advprog.yomubacaandankuis.repository.CategoryRepository;
import id.ac.ui.cs.advprog.yomubacaandankuis.repository.ReadingRepository;
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
class ReadingServiceTest {

    @Mock
    private ReadingRepository readingRepository;

    @Mock
    private CategoryRepository categoryRepository;

    private ReadingService readingService;

    @BeforeEach
    void setUp() {
        readingService = new ReadingService(readingRepository, categoryRepository);
    }

    @Test
    void findAllReturnsMappedResponses() {
        Reading reading = createReading(3, createCategory(2, "Science"));
        when(readingRepository.findAll()).thenReturn(List.of(reading));

        List<ReadingResponse> responses = readingService.findAll();

        assertThat(responses)
                .singleElement()
                .extracting(ReadingResponse::getId, ReadingResponse::getTitle, ReadingResponse::getCategoryId)
                .containsExactly(3, "Gravity", 2);
    }

    @Test
    void findByIdReturnsMappedResponse() {
        Reading reading = createReading(1, createCategory(4, "History"));
        when(readingRepository.findById(1)).thenReturn(Optional.of(reading));

        ReadingResponse response = readingService.findById(1);

        assertThat(response.getId()).isEqualTo(1);
        assertThat(response.getTitle()).isEqualTo("Gravity");
        assertThat(response.getContent()).isEqualTo("About planets");
        assertThat(response.getCategoryId()).isEqualTo(4);
    }

    @Test
    void findByIdThrowsWhenReadingMissing() {
        when(readingRepository.findById(100)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> readingService.findById(100))
                .isInstanceOf(ResponseStatusException.class)
                .satisfies(exception -> {
                    ResponseStatusException responseStatusException = (ResponseStatusException) exception;
                    assertThat(responseStatusException.getStatusCode()).isEqualTo(HttpStatus.NOT_FOUND);
                    assertThat(responseStatusException.getReason()).isEqualTo("Reading with id 100 not found");
                });
    }

    @Test
    void createSavesReadingWithResolvedCategory() {
        Category category = createCategory(8, "Science");
        ReadingRequest request = createReadingRequest(8);
        when(categoryRepository.findById(8)).thenReturn(Optional.of(category));
        when(readingRepository.save(any(Reading.class))).thenAnswer(invocation -> {
            Reading saved = invocation.getArgument(0);
            saved.setId(20);
            saved.setCreatedAt(LocalDateTime.of(2026, 3, 6, 21, 0));
            return saved;
        });

        ReadingResponse response = readingService.create(request);

        assertThat(response.getId()).isEqualTo(20);
        assertThat(response.getTitle()).isEqualTo("Gravity");
        assertThat(response.getCategoryId()).isEqualTo(8);
    }

    @Test
    void updateModifiesExistingReading() {
        Category category = createCategory(9, "Updated Category");
        Reading existing = createReading(11, createCategory(1, "Old Category"));
        ReadingRequest request = createReadingRequest(9);
        request.setTitle("New Title");
        request.setContent("Updated content");
        when(readingRepository.findById(11)).thenReturn(Optional.of(existing));
        when(categoryRepository.findById(9)).thenReturn(Optional.of(category));
        when(readingRepository.save(existing)).thenReturn(existing);

        ReadingResponse response = readingService.update(11, request);

        assertThat(existing.getTitle()).isEqualTo("New Title");
        assertThat(existing.getContent()).isEqualTo("Updated content");
        assertThat(existing.getCategory()).isEqualTo(category);
        assertThat(response.getCategoryId()).isEqualTo(9);
    }

    @Test
    void deleteRemovesExistingReading() {
        Reading reading = createReading(15, createCategory(6, "Math"));
        when(readingRepository.findById(15)).thenReturn(Optional.of(reading));

        readingService.delete(15);

        verify(readingRepository).delete(reading);
    }

    @Test
    void createThrowsWhenCategoryMissing() {
        ReadingRequest request = createReadingRequest(404);
        when(categoryRepository.findById(404)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> readingService.create(request))
                .isInstanceOf(ResponseStatusException.class)
                .satisfies(exception -> {
                    ResponseStatusException responseStatusException = (ResponseStatusException) exception;
                    assertThat(responseStatusException.getStatusCode()).isEqualTo(HttpStatus.NOT_FOUND);
                    assertThat(responseStatusException.getReason()).isEqualTo("Category with id 404 not found");
                });
    }

    private ReadingRequest createReadingRequest(Integer categoryId) {
        ReadingRequest request = new ReadingRequest();
        request.setTitle("Gravity");
        request.setContent("About planets");
        request.setCategoryId(categoryId);
        return request;
    }

    private Category createCategory(Integer id, String name) {
        Category category = new Category();
        category.setId(id);
        category.setName(name);
        return category;
    }

    private Reading createReading(Integer id, Category category) {
        Reading reading = new Reading();
        reading.setId(id);
        reading.setTitle("Gravity");
        reading.setContent("About planets");
        reading.setCategory(category);
        reading.setCreatedAt(LocalDateTime.of(2026, 3, 6, 21, 15));
        return reading;
    }
}