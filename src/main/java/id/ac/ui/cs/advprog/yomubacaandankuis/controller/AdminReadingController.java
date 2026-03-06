package id.ac.ui.cs.advprog.yomubacaandankuis.controller;

import id.ac.ui.cs.advprog.yomubacaandankuis.dto.ReadingRequest;
import id.ac.ui.cs.advprog.yomubacaandankuis.dto.ReadingResponse;
import id.ac.ui.cs.advprog.yomubacaandankuis.service.ReadingService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
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
@RequestMapping("/api/admin/readings")
public class AdminReadingController {

    private final ReadingService readingService;

    public AdminReadingController(ReadingService readingService) {
        this.readingService = readingService;
    }

    @GetMapping
    public List<ReadingResponse> getAllReadings() {
        return readingService.findAll();
    }

    @GetMapping("/{id}")
    public ReadingResponse getReadingById(@PathVariable Integer id) {
        return readingService.findById(id);
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public ReadingResponse createReading(@Valid @RequestBody ReadingRequest request) {
        return readingService.create(request);
    }

    @PutMapping("/{id}")
    public ReadingResponse updateReading(@PathVariable Integer id, @Valid @RequestBody ReadingRequest request) {
        return readingService.update(id, request);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deleteReading(@PathVariable Integer id) {
        readingService.delete(id);
    }
}