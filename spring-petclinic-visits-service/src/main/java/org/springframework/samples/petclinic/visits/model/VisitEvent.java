package org.springframework.samples.petclinic.visits.model;

import com.fasterxml.jackson.annotation.JsonFormat;

import java.time.Instant;
import java.util.Date;

/**
 * Domain event representing a visit creation.
 *
 * @author Generated
 */
public class VisitEvent {

    private Integer visitId;
    private int petId;
    private String description;
    
    @JsonFormat(pattern = "yyyy-MM-dd")
    private Date visitDate;
    
    private Instant eventTimestamp;
    private String eventType;

    public VisitEvent() {
        this.eventTimestamp = Instant.now();
        this.eventType = "VISIT_CREATED";
    }

    public VisitEvent(Visit visit) {
        this();
        this.visitId = visit.getId();
        this.petId = visit.getPetId();
        this.description = visit.getDescription();
        this.visitDate = visit.getDate();
    }

    // Getters and setters
    public Integer getVisitId() {
        return visitId;
    }

    public void setVisitId(Integer visitId) {
        this.visitId = visitId;
    }

    public int getPetId() {
        return petId;
    }

    public void setPetId(int petId) {
        this.petId = petId;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public Date getVisitDate() {
        return visitDate;
    }

    public void setVisitDate(Date visitDate) {
        this.visitDate = visitDate;
    }

    public Instant getEventTimestamp() {
        return eventTimestamp;
    }

    public void setEventTimestamp(Instant eventTimestamp) {
        this.eventTimestamp = eventTimestamp;
    }

    public String getEventType() {
        return eventType;
    }

    public void setEventType(String eventType) {
        this.eventType = eventType;
    }

    @Override
    public String toString() {
        return "VisitEvent{" +
                "visitId=" + visitId +
                ", petId=" + petId +
                ", description='" + description + '\'' +
                ", visitDate=" + visitDate +
                ", eventTimestamp=" + eventTimestamp +
                ", eventType='" + eventType + '\'' +
                '}';
    }
} 