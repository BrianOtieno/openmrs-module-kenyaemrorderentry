package org.openmrs.module.kenyaemrorderentry.page.controller;

import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import org.openmrs.*;
import org.openmrs.api.*;
import org.openmrs.api.context.Context;
import org.openmrs.module.appui.UiSessionContext;
import org.openmrs.module.webservices.rest.web.ConversionUtil;
import org.openmrs.module.webservices.rest.web.representation.NamedRepresentation;
import org.openmrs.module.webservices.rest.web.representation.Representation;
import org.openmrs.ui.framework.UiUtils;
import org.openmrs.ui.framework.annotation.SpringBean;
import org.openmrs.ui.framework.page.PageModel;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.*;

public class DrugOrdersPageController {
    public static final Locale LOCALE = Locale.ENGLISH;

    public void get(@RequestParam("patient") Patient patient,
                    @RequestParam(value = "careSetting", required = false) CareSetting careSetting,
                    @SpringBean("encounterService") EncounterService encounterService,
                    @SpringBean("orderService") OrderService orderService,
                    UiSessionContext sessionContext,
                    UiUtils ui,
                    PageModel model,
                    @SpringBean("orderSetService") OrderSetService orderSetService,
                    @SpringBean("patientService")PatientService patientService,
                    @SpringBean("conceptService") ConceptService conceptService,
                    @SpringBean("providerService") ProviderService providerService,
                    @SpringBean("obsService") ObsService obsService) {

        // HACK
        EncounterType drugOrderEncounterType = encounterService.getAllEncounterTypes(false).get(0);
        EncounterRole encounterRoles = encounterService.getAllEncounterRoles(false).get(0);

        List<CareSetting> careSettings = orderService.getCareSettings(false);

        List<Concept> dosingUnits = orderService.getDrugDosingUnits();
        List<Concept> dispensingUnits = orderService.getDrugDispensingUnits();
        Set<Concept> quantityUnits = new LinkedHashSet<Concept>();
        quantityUnits.addAll(dosingUnits);
        quantityUnits.addAll(dispensingUnits);

        Map<String, Object> jsonConfig = new LinkedHashMap<String, Object>();
        jsonConfig.put("patient", convertToFull(patient));
        jsonConfig.put("provider", convertToFull(sessionContext.getCurrentProvider()));
        jsonConfig.put("encounterRole", convertToFull(encounterRoles));
        jsonConfig.put("drugOrderEncounterType", convertToFull(drugOrderEncounterType));
        jsonConfig.put("careSettings", convertToFull(careSettings));
        jsonConfig.put("routes", convertToFull(orderService.getDrugRoutes()));
        jsonConfig.put("doseUnits", convertToFull(dosingUnits));
        jsonConfig.put("durationUnits", convertToFull(orderService.getDurationUnits()));
        jsonConfig.put("quantityUnits", convertToFull(dispensingUnits)); // after TRUNK-4524 is fixed, change this to quantityUnits
        jsonConfig.put("frequencies", convertTo(orderService.getOrderFrequencies(false), new NamedRepresentation("fullconcept")));
        if (careSetting != null) {
            jsonConfig.put("intialCareSetting", careSetting.getUuid());
        }

        model.put("patient", patient);
        model.put("jsonConfig", ui.toJson(jsonConfig));

        OrderType drugOrders = orderService.getOrderTypeByUuid(OrderType.DRUG_ORDER_TYPE_UUID);
        List<Order> activeDrugOrders = orderService.getActiveOrders(patient, drugOrders, null, null);
        JSONObject orderObj,component;
        JSONArray orderGroupArray=new JSONArray();
        JSONArray orderArray=new JSONArray();
        JSONArray components=new JSONArray();
        int previousOrderGroupId=0;
        for(Order order:activeDrugOrders){
            DrugOrder drugOrder=(DrugOrder)order;
            if(order.getOrderGroup()!=null){


                component=new JSONObject();
                component.put("name", drugOrder.getDrug().getConcept().getShortNameInLocale(LOCALE) != null ? drugOrder.getDrug().getConcept().getShortNameInLocale(LOCALE).getName() : drugOrder.getDrug().getConcept().getName(LOCALE).getName());
                component.put("dose", drugOrder.getDose().toString());
                component.put("units_uuid", drugOrder.getDoseUnits().getUuid());
                component.put("units_name", drugOrder.getDoseUnits().getName(LOCALE).getName());
                component.put("frequency", drugOrder.getFrequency().getUuid());
                component.put("frequency_name", drugOrder.getFrequency().getName());
                component.put("drug_id", drugOrder.getDrug().getDrugId());
                component.put("order_id",order.getOrderId());
                component.put("quantity",drugOrder.getQuantity());
                component.put("quantity_units_name",drugOrder.getQuantityUnits().getName(LOCALE).getName());
                if(order.getOrderGroup().getOrderGroupId()==previousOrderGroupId){
                    components.add(component);
                    continue;
                }
                else{
                    orderObj = new JSONObject();
                    components=new JSONArray();
                    components.add(component);
                    OrderSet orderSet=order.getOrderGroup().getOrderSet();
                    orderObj.put("name",orderSet.getName());
                    orderObj.put("date",order.getDateCreated().toString());
                    orderObj.put("orderGroupUuId",order.getOrderGroup().getUuid());
                    orderObj.put("orderSetId",orderSet.getOrderSetId());
                    orderObj.put("instructions",order.getInstructions());
                    orderObj.put("components", components);
                    orderGroupArray.add(orderObj);
                    previousOrderGroupId=order.getOrderGroup().getOrderGroupId();
                }
            }
            else {
                orderObj = new JSONObject();
                orderObj.put("uuid", order.getUuid());
                orderObj.put("orderNumber", order.getOrderNumber());
                orderObj.put("concept", convertToFull(order.getConcept()));
                orderObj.put("careSetting", convertToFull(order.getCareSetting()));
                orderObj.put("dateActivated", order.getDateCreated().toString());
                orderObj.put("encounter", convertToFull(order.getEncounter()));
                orderObj.put("orderer", convertToFull(order.getOrderer()));
                orderObj.put("drug", convertToFull(drugOrder.getDrug()));
                orderObj.put("dosingType", drugOrder.getDosingType());
                orderObj.put("dose", drugOrder.getDose());
                orderObj.put("doseUnits", convertToFull(drugOrder.getDoseUnits()));
                orderObj.put("frequency", convertToFull(drugOrder.getFrequency()));
                orderObj.put("quantity", drugOrder.getQuantity());
                orderObj.put("quantityUnits", convertToFull(drugOrder.getQuantityUnits()));
                orderObj.put("route", convertToFull(drugOrder.getRoute()));
                orderArray.add(orderObj);
            }
        }
        JSONObject activeOrdersResponse=new JSONObject();
        activeOrdersResponse.put("order_groups",orderGroupArray);
        activeOrdersResponse.put("single_drugs",orderArray);
        model.put("activeOrdersResponse",ui.toJson(activeOrdersResponse));
        getPastDrugOrders(orderService, conceptService,careSetting,ui, patient, model,obsService);

    }

    public void getPastDrugOrders(@SpringBean("orderService") OrderService orderService, @SpringBean("conceptService")
            ConceptService conceptService,
                             @SpringBean("careSetting")
                                     CareSetting careSetting,
                                  UiUtils ui,
                             Patient patient, PageModel model,@SpringBean("obsService") ObsService obsService) {
        OrderType drugType = orderService.getOrderTypeByUuid(OrderType.DRUG_ORDER_TYPE_UUID);
        CareSetting careset = orderService.getCareSetting(1);
        List<Order> pastOrders = orderService.getOrders(patient, careset, drugType, false);

        JSONObject orderObj,component;
        JSONArray orderGroupArray = new JSONArray();
        JSONArray orderArray = new JSONArray();
        JSONArray components =  new JSONArray();
        int previousOrderGroupId=0;
        for(Order order:pastOrders){
            DrugOrder drugOrder=(DrugOrder)order;
            if(order.getOrderGroup()!= null) {
                if(order.getDateStopped() != null) {


                component = new JSONObject();
                component.put("name", drugOrder.getDrug().getConcept().getShortNameInLocale(LOCALE) != null ? drugOrder.getDrug().getConcept().getShortNameInLocale(LOCALE).getName() : drugOrder.getDrug().getConcept().getName(LOCALE).getName());
                component.put("dose", drugOrder.getDose().toString());
                component.put("units_uuid", drugOrder.getDoseUnits().getUuid());
                component.put("units_name", drugOrder.getDoseUnits().getName(LOCALE).getName());
                component.put("frequency", drugOrder.getFrequency().getUuid());
                component.put("frequency_name", drugOrder.getFrequency().getName());
                component.put("drug_id", drugOrder.getDrug().getDrugId());
                component.put("dateActivated", order.getDateCreated().toString());
                component.put("dateStopped", order.getDateStopped().toString());
                component.put("order_group_id", order.getOrderGroup().getOrderGroupId());
                component.put("quantity", drugOrder.getQuantity());
                component.put("quantity_units_name", drugOrder.getQuantityUnits().getName(LOCALE).getName());



                    if (order.getOrderGroup().getOrderGroupId() == previousOrderGroupId) {
                    components.add(component);
                    continue;
                } else {
                    orderObj = new JSONObject();
                    components = new JSONArray();
                    components.add(component);
                    OrderSet orderSet = order.getOrderGroup().getOrderSet();
                    orderObj.put("name", orderSet.getName());
                    orderObj.put("date", order.getDateCreated().toString());
                    orderObj.put("dateStopped", order.getDateStopped().toString());
                    orderObj.put("orderSetId", orderSet.getOrderSetId());
                    orderObj.put("instructions", order.getInstructions());
                    orderObj.put("components", components);
                    orderGroupArray.add(orderObj);
                     previousOrderGroupId=order.getOrderGroup().getOrderGroupId();
                }
            }
            }
            else {
                if(order.getDateStopped() != null) {
                    orderObj = new JSONObject();
                    orderObj.put("uuid", order.getUuid());
                    orderObj.put("concept", order.getConcept());
                    orderObj.put("dateActivated", order.getDateCreated().toString());
                    orderObj.put("dateStopped", order.getDateStopped().toString());
                    orderObj.put("drug", drugOrder.getDrug().getFullName(LOCALE) != null ? drugOrder.getDrug().getFullName(LOCALE) : drugOrder.getDrug().getConcept().getName(LOCALE).getName());
                    orderObj.put("dose", drugOrder.getDose());
                    orderObj.put("doseUnits", drugOrder.getDoseUnits().getName(LOCALE).getName());
                    orderObj.put("frequency", drugOrder.getFrequency().toString());
                    orderObj.put("quantity", drugOrder.getQuantity());
                    orderObj.put("quantityUnits", drugOrder.getQuantityUnits().getName(LOCALE).getName());
                    orderObj.put("route", drugOrder.getRoute().getName(LOCALE).getName());
                    orderArray.add(orderObj);
                }

            }
        }
        JSONObject pastDrugOrders=new JSONObject();
        pastDrugOrders.put("pastOrder_groups",orderGroupArray);
        pastDrugOrders.put("pastSingle_drugs",orderArray);
        model.put("pastDrugOrdersPayload", pastDrugOrders.toString());
    }


    private Object convertTo(Object object, Representation rep) {
        return object == null ? null : ConversionUtil.convertToRepresentation(object, rep);
    }

    private Object convertToFull(Object object) {
        return object == null ? null : ConversionUtil.convertToRepresentation(object, Representation.FULL);
    }
}