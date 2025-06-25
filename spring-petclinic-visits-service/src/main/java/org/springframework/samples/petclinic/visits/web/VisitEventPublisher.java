package org.springframework.samples.petclinic.visits.web;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.kafka.support.SendResult;
import org.springframework.samples.petclinic.visits.model.Visit;
import org.springframework.samples.petclinic.visits.model.VisitEvent;
import org.springframework.stereotype.Service;

import java.util.concurrent.CompletableFuture;

/**
 * Service for publishing visit events to Kafka.
 *
 * @author Generated
 */
@Service
public class VisitEventPublisher {

    private static final Logger log = LoggerFactory.getLogger(VisitEventPublisher.class);
    private static final String VISIT_CREATED_TOPIC = "visit.created";

    private final KafkaTemplate<String, VisitEvent> kafkaTemplate;

    public VisitEventPublisher(KafkaTemplate<String, VisitEvent> kafkaTemplate) {
        this.kafkaTemplate = kafkaTemplate;
    }

    /**
     * Publishes a visit created event to Kafka.
     *
     * @param visit the visit that was created
     */
    public void publishVisitCreatedEvent(Visit visit) {
        VisitEvent visitEvent = new VisitEvent(visit);
        
        log.info("Publishing visit created event: {}", visitEvent);
        
        CompletableFuture<SendResult<String, VisitEvent>> future = 
            kafkaTemplate.send(VISIT_CREATED_TOPIC, visit.getId().toString(), visitEvent);
            
        future.whenComplete((result, exception) -> {
            if (exception == null) {
                log.info("Successfully published visit created event for visit ID: {} to topic: {} with offset: {}",
                        visit.getId(), VISIT_CREATED_TOPIC, result.getRecordMetadata().offset());
            } else {
                log.error("Failed to publish visit created event for visit ID: {} to topic: {}",
                        visit.getId(), VISIT_CREATED_TOPIC, exception);
            }
        });
    }
} 