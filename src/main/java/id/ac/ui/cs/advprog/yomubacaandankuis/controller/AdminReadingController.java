package id.ac.ui.cs.advprog.yomubacaandankuis.controller;

import id.ac.ui.cs.advprog.yomubacaandankuis.dto.ReadingRequest;
import id.ac.ui.cs.advprog.yomubacaandankuis.dto.ReadingResponse;
import id.ac.ui.cs.advprog.yomubacaandankuis.service.ReadingService;
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
@RequestMapping("/api/admin/readings")
public class AdminReadingController {

    private static final Logger AUDIT_LOG = LoggerFactory.getLogger("AUDIT");

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
    public ReadingResponse createReading(Authentication authentication, @Valid @RequestBody ReadingRequest request) {
        ReadingResponse response = readingService.create(request);
        AUDIT_LOG.info("action=ADMIN_CREATE entity=reading entityId={} actor={}", response.getId(), authentication.getName());
        return response;
    }

    @PutMapping("/{id}")
    public ReadingResponse updateReading(Authentication authentication, @PathVariable Integer id, @Valid @RequestBody ReadingRequest request) {
        ReadingResponse response = readingService.update(id, request);
        AUDIT_LOG.info("action=ADMIN_UPDATE entity=reading entityId={} actor={}", response.getId(), authentication.getName());
        return response;
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deleteReading(Authentication authentication, @PathVariable Integer id) {
        readingService.delete(id);
        AUDIT_LOG.info("action=ADMIN_DELETE entity=reading entityId={} actor={}", id, authentication.getName());
    }
}
