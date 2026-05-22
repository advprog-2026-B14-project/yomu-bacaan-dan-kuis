package id.ac.ui.cs.advprog.yomubacaandankuis.service;

import id.ac.ui.cs.advprog.yomubacaandankuis.dto.QuizCompletedEvent;

public interface QuizCompletedEventPublisher {
    void publish(QuizCompletedEvent event);
}
