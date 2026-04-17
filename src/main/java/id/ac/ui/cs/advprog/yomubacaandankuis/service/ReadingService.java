package id.ac.ui.cs.advprog.yomubacaandankuis.service;

import id.ac.ui.cs.advprog.yomubacaandankuis.dto.ReadingRequest;
import id.ac.ui.cs.advprog.yomubacaandankuis.dto.ReadingResponse;
import id.ac.ui.cs.advprog.yomubacaandankuis.model.Category;
import id.ac.ui.cs.advprog.yomubacaandankuis.model.Reading;
import id.ac.ui.cs.advprog.yomubacaandankuis.repository.CategoryRepository;
import id.ac.ui.cs.advprog.yomubacaandankuis.repository.ReadingRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;

@Service
@Transactional
public class ReadingService {

    private final ReadingRepository readingRepository;
    private final CategoryRepository categoryRepository;

    public ReadingService(ReadingRepository readingRepository, CategoryRepository categoryRepository) {
        this.readingRepository = readingRepository;
        this.categoryRepository = categoryRepository;
    }

    @Transactional(readOnly = true)
    public List<ReadingResponse> findAll() {
        return readingRepository.findAll().stream()
                .map(this::toResponse)
                .toList();
    }

    @Transactional(readOnly = true)
    public ReadingResponse findById(Integer id) {
        return toResponse(getReading(id));
    }

    public ReadingResponse create(ReadingRequest request) {
        Reading reading = new Reading();
        applyRequest(reading, request);
        return toResponse(readingRepository.save(reading));
    }

    public ReadingResponse update(Integer id, ReadingRequest request) {
        Reading reading = getReading(id);
        applyRequest(reading, request);
        return toResponse(readingRepository.save(reading));
    }

    public void delete(Integer id) {
        Reading reading = getReading(id);
        readingRepository.delete(reading);
    }

    private void applyRequest(Reading reading, ReadingRequest request) {
        Category category = categoryRepository.findById(request.getCategoryId())
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND,
                        "Category with id " + request.getCategoryId() + " not found"
                ));

        reading.setTitle(request.getTitle());
        reading.setContent(request.getContent());
        reading.setCategory(category);
    }

    private Reading getReading(Integer id) {
        return readingRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND,
                        "Reading with id " + id + " not found"
                ));
    }

    private ReadingResponse toResponse(Reading reading) {
        return new ReadingResponse(
                reading.getId(),
                reading.getTitle(),
                reading.getContent(),
                reading.getCategory().getId(),
                reading.getCreatedAt()
        );
    }
}