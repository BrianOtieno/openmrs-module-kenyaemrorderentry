package org.openmrs.module.kenyaemrorderentry.api;


import org.openmrs.BaseOpenmrsData;
import org.openmrs.Patient;

import java.util.Date;
import java.util.UUID;

public class DrugRegimenHistory extends BaseOpenmrsData {

    private Integer id;
    private String regimenName;
    private String status;
    private Integer orderGroupId;
    private Patient patient;
    private String program;
    private Integer orderSetId;


    public DrugRegimenHistory() {
        prePersist();
    }

    public DrugRegimenHistory(String regimenName, String status, String program, Integer orderSetId,
                              Integer orderGroupId, Date dateCreated,
                              Integer changedBy, Date dateChanged, boolean voided, Integer voidedBy, Date dateVoided, String voidedReason) {


        this.regimenName = regimenName;
        this.status = status;
        this.orderGroupId = orderGroupId;
        this.program = program;
        this.orderSetId = orderSetId;

    }


    public void prePersist() {

        if (null == getUuid())
            setUuid(UUID.randomUUID().toString());
    }

    public String getRegimenName() {
        return regimenName;
    }

    public void setRegimenName(String regimenName) {
        this.regimenName = regimenName;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Integer getOrderGroupId() {
        return orderGroupId;
    }
    public void setOrderGroupId(Integer orderGroupId) {
        this.orderGroupId = orderGroupId;
    }


    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public Patient getPatient() {
        return patient;
    }

    public void setPatient(Patient patient) {
        this.patient = patient;
    }

    public String getProgram() {return program;}
    public void setProgram(String program) {
        this.program = program;
    }
    public Integer getOrderSetId() {
        return orderSetId;
    }

    public void setOrderSetId(Integer orderSetId) {
        this.orderSetId = orderSetId;
    }
}

