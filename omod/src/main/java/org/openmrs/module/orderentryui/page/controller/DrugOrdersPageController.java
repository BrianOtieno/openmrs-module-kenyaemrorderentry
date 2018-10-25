package org.openmrs.module.orderentryui.page.controller;

import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
import org.json.simple.parser.ParseException;
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
                    @SpringBean("providerService") ProviderService providerService) {

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
                component.put("name", drugOrder.getDrug().getName());
                component.put("dose", drugOrder.getDose().toString());
                component.put("units_uuid", drugOrder.getDoseUnits().getUuid());
                component.put("frequency", drugOrder.getFrequency().getUuid());
                component.put("drug_id", drugOrder.getDrug().getDrugId());
                component.put("order_id",order.getOrderId());
                component.put("quantity",drugOrder.getQuantity());
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
                    orderObj.put("date",order.getDateActivated().toString());
                    orderObj.put("orderGroupUuId",order.getOrderGroup().getUuid());
                    orderObj.put("orderSetId",orderSet.getOrderSetId());
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
                orderObj.put("dateActivated", order.getDateActivated().toString());
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
        model.put("currentRegimens",computeCurrentRegimen());
    }

    private Object convertTo(Object object, Representation rep) {
        return object == null ? null : ConversionUtil.convertToRepresentation(object, rep);
    }

    private Object convertToFull(Object object) {
        return object == null ? null : ConversionUtil.convertToRepresentation(object, Representation.FULL);
    }
    private String computeCurrentRegimen(){
        String currentRegimen="{\n" +
                "  \"patientregimens\": [\n" +
                "    {\n" +
                "      \"program\": \"HIV\",\n" +
                "      \"name\": \"TDF + 3TC + NVP (300mg OD/150mg BD/200mg BD)\",\n" +
                "      \"components\": [\n" +
                "        {\n" +
                "          \"dose\": \"300.0\",\n" +
                "          \"drug_id\": 15,\n" +
                "          \"quantity\": 60,\n" +
                "          \"name\": \"TDF\",\n" +
                "          \"order_id\": 154,\n" +
                "          \"units_uuid\": \"161553AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\",\n" +
                "          \"frequency\": \"067ac6ea-a396-37dc-b324-2c3943e2d1ce\"\n" +
                "        },\n" +
                "        {\n" +
                "          \"dose\": \"150.0\",\n" +
                "          \"drug_id\": 14,\n" +
                "          \"quantity\": 120,\n" +
                "          \"name\": \"3TC\",\n" +
                "          \"order_id\": 155,\n" +
                "          \"units_uuid\": \"161553AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\",\n" +
                "          \"frequency\": \"9159cc28-3443-3265-9e79-503caecb69bd\"\n" +
                "        },\n" +
                "        {\n" +
                "          \"dose\": \"200.0\",\n" +
                "          \"drug_id\": 16,\n" +
                "          \"quantity\": 120,\n" +
                "          \"name\": \"NVP\",\n" +
                "          \"order_id\": 156,\n" +
                "          \"units_uuid\": \"161553AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\",\n" +
                "          \"frequency\": \"9159cc28-3443-3265-9e79-503caecb69bd\"\n" +
                "        }\n" +
                "      ]\n" +
                "    },\n" +
                "    {\n" +
                "      \"program\": \"TB\",\n" +
                "      \"name\": \"RHZE (150mg/75mg/400mg/275mg x 1 tabs)\",\n" +
                "      \"components\": [\n" +
                "        {\n" +
                "          \"name\": \"R150\",\n" +
                "          \"dose\": \"1\",\n" +
                "          \"units\": \"tab\",\n" +
                "          \"units_uuid\": \"1513AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\",\n" +
                "          \"frequency\": \"067ac6ea-a396-37dc-b324-2c3943e2d1ce\",\n" +
                "          \"drug_id\": \"3\"\n" +
                "        },\n" +
                "        {\n" +
                "          \"name\": \"H75\",\n" +
                "          \"dose\": \"1\",\n" +
                "          \"units\": \"tab\",\n" +
                "          \"units_uuid\": \"1513AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\",\n" +
                "          \"frequency\": \"067ac6ea-a396-37dc-b324-2c3943e2d1ce\",\n" +
                "          \"drug_id\": \"1\"\n" +
                "        },\n" +
                "        {\n" +
                "          \"name\": \"Z400\",\n" +
                "          \"dose\": \"1\",\n" +
                "          \"units\": \"tab\",\n" +
                "          \"units_uuid\": \"1513AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\",\n" +
                "          \"frequency\": \"067ac6ea-a396-37dc-b324-2c3943e2d1ce\",\n" +
                "          \"drug_id\": \"4\"\n" +
                "        },\n" +
                "        {\n" +
                "          \"name\": \"E275\",\n" +
                "          \"dose\": \"1\",\n" +
                "          \"units\": \"tab\",\n" +
                "          \"units_uuid\": \"1513AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\",\n" +
                "          \"frequency\": \"067ac6ea-a396-37dc-b324-2c3943e2d1ce\",\n" +
                "          \"drug_id\": \"8\"\n" +
                "        }\n" +
                "      ]\n" +
                "    }\n" +
                "  ]\n" +
                "}";
        return currentRegimen;
    }
}