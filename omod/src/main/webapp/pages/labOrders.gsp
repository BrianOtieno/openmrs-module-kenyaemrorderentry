<%
    ui.decorateWith("kenyaemr", "standardPage", [patient: patient])
    def menuItems = [
            [label: "Back to home", iconProvider: "kenyaui", icon: "buttons/back.png", label: "Back to Client home", href: ui.pageLink("kenyaemr", "clinician/clinicianViewPatient", [patient: patient, patientId: patient])]
    ]

    ui.includeJavascript("uicommons", "emr.js")
    ui.includeJavascript("uicommons", "angular.min.js")
    ui.includeJavascript("uicommons", "angular-app.js")
    ui.includeJavascript("uicommons", "angular-resource.min.js")
    ui.includeJavascript("uicommons", "angular-common.js")
    ui.includeJavascript("uicommons", "angular-ui/ui-bootstrap-tpls-0.11.2.js")
    ui.includeJavascript("uicommons", "ngDialog/ngDialog.js")
    ui.includeJavascript("kenyaemrorderentry", "bootstrap.min.js")


    ui.includeJavascript("uicommons", "filters/display.js")
    ui.includeJavascript("uicommons", "filters/serverDate.js")
    ui.includeJavascript("uicommons", "services/conceptService.js")
    ui.includeJavascript("uicommons", "services/drugService.js")
    ui.includeJavascript("uicommons", "services/encounterService.js")
    ui.includeJavascript("uicommons", "services/orderService.js")
    ui.includeJavascript("uicommons", "services/session.js")

    ui.includeJavascript("uicommons", "directives/select-concept-from-list.js")
    ui.includeJavascript("uicommons", "directives/select-order-frequency.js")
    ui.includeJavascript("uicommons", "directives/select-drug.js")
    ui.includeJavascript("kenyaemrorderentry", "order-model.js")
    ui.includeJavascript("kenyaemrorderentry", "order-entry.js")
    ui.includeJavascript("kenyaemrorderentry", "labOrders.js")

    ui.includeCss("uicommons", "ngDialog/ngDialog.min.css")
    ui.includeCss("kenyaemrorderentry", "drugOrders.css")
    ui.includeCss("uicommons", "styleguide/jquery-ui-1.9.2.custom.min.css")
    ui.includeCss("kenyaemrorderentry", "index.css")


    ui.includeCss("kenyaemrorderentry", "bootstrap.min.css")
    ui.includeCss("kenyaemrorderentry", "labOrders.css")
    ui.includeCss("kenyaemrorderentry", "font-awesome.css")
    ui.includeCss("kenyaemrorderentry", "font-awesome.min.css")
    ui.includeCss("kenyaemrorderentry", "font-awesome.css.map")
    ui.includeCss("kenyaemrorderentry", "fontawesome-webfont.svg")
%>
<style type="text/css">
#new-order input {
    margin: 5px;
}

th, td {
    text-align: left;
}
</style>
<script type="text/javascript">


    window.OpenMRS = window.OpenMRS || {};
    window.OpenMRS.drugOrdersConfig = ${ jsonConfig };
    window.OpenMRS.labTestJsonPayload = ${labTestJsonPayload}
    patientId = ${ patient.patientId };

    jq(document).ready(function() {
        jq("#btnBack").click(function(){
            ui.navigate('${ ui.pageLink("kenyaemr", "clinician/clinicianViewPatient", [patient: patient, patientId: patient]) }');
           //window.location="http://localhost:8080/openmrs/kenyaemr/clinician/clinicianViewPatient.page?patientId=" +patientId +'&'
        });
    });


</script>

${ui.includeFragment("appui", "messages", [codes: [
        "kenyaemrorderentry.pastAction.REVISE",
        "kenyaemrorderentry.pastAction.DISCONTINUE"
]])}

<div class="ke-page-content">
    <div >
        <div class="ui-tabs">

            <div class="ui-tabs-panel ui-widget-content">

                <div>
                    <button type="button" class="fa fa-arrow-left " style="float: left" id="btnBack">
                        Back to client home
                    </button>
                    <label id="orderHeader"> <h3>Lab Orders</h3></label>
                </div>
                

                <div id="program-tabs" class="ke-tabs" style="padding-top: 10px">
                    <div class="ke-tabmenu">
                        <div class="ke-tabmenu-item" data-tabid="active_orders">Active Order(s)</div>

                        <div class="ke-tabmenu-item" data-tabid="new_orders">Create New Order(s)</div>

                        <div class="ke-tabmenu-item" data-tabid="lab_results">Enter Lab Result(s)</div>
                        <div class="ke-tabmenu-item" data-tabid="past_orders">Previous Lab Order(s)</div>

                    </div>

                    <div class="ke-tab" data-tabid="new_orders" style="padding-top:10px" >
                        <div id="lab-orders-app" data-ng-controller="LabOrdersCtrl" ng-init='init()'>
                        <div class="card">
                            <div class="card-header">
                                <h4 class="card-title">
                                    Create New Order(s)
                                </h4>
                            </div>

                            <div class="card-body">
                                <form>
                                    <table class="table col-lg-12">


                                        <tr>
                                            <td class="col-lg-3" style="width: 25%">
                                                <div class="card border-dark" >
                                                    <div class="list-group list-group-decorator" >
                                                        <div class="list-group-item" ng-repeat="lab in labOrders" style="cursor: pointer"
                                                             ng-click="loadLabPanels(lab)">
                                                            <div class="link-item">
                                                                <a class="formLink">
                                                                    {{lab.name}}
                                                                </a>
                                                            </div>

                                                        </div>
                                                    </div>
                                                </div>

                                                <div style="padding-top:10px">
                                                    <div class="card border-dark" >
                                                        <div class="card-header">
                                                            <h5 class="card-title">
                                                                Selected Order(s)
                                                            </h5>
                                                        </div>

                                                        <div class="card-body " >
                                                            <div ng-show="selectedOrders.length === 0">{{noOrderSelected}}</div>

                                                            <div class="list-group ">
                                                                <div class="list-group-item"
                                                                     ng-repeat="order in filteredOrders">
                                                                    <div class="link-item">
                                                                        <div class="btn-group button-size " role="group" aria-label="Basic example">
                                                                            <button type="button" class="text-left" style="width: 76%">{{order.name}}</button>
                                                                            <button type="button" class="fa fa-calendar fa-1x" style="width: 8%"
                                                                                    data-toggle="modal" data-target="#dateOrder"
                                                                                    ng-click="orderSelectedToAddDateActivated(order)"></button>
                                                                            <button type="button" class="fa fa-warning fa-1x" style="width: 8%"
                                                                                    data-placement="top" title="Urgency | Reason"
                                                                                    data-toggle="modal" data-target="#orderUrgency"
                                                                                    ng-click="orderSelectedToAddDateActivated(order)"
                                                                            ></button>
                                                                            <button type="button" class="fa fa-remove fa-1x"
                                                                                    ng-click="deselectedOrder(order)" style="color:#9D0101;cursor: pointer; width: 8%"></button>
                                                                        </div>

                                                                    </div>

                                                                </div>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>
                                            </td>
                                            <td class="col-lg-9" style="width: 75%">
                                                <div class="col-lg-12">
                                                    <fieldset class="col-lg-12 scheduler-border">
                                                        <legend class="col-lg-12 scheduler-border">Panels | <span style="background-color: pink">{{sampleTypeName}}</span></legend>

                                                        <div class="row">
                                                            <div class="col-lg-12">
                                                                <ul>
                                                                    <li ng-repeat="panel in labPanels"
                                                                        ng-click="loadLabPanelTests(panel)">
                                                                        <button type="button" class="column">
                                                                            {{panel.name}}</button>
                                                                    </li>
                                                                </ul>
                                                            </div>

                                                        </div>

                                                    </fieldset>
                                                </div>

                                                <div class="col-lg-12">
                                                    <fieldset class="col-lg-12 scheduler-border">
                                                        <legend class="col-lg-12 scheduler-border">Tests | <span style="background-color: pink">{{panelTypeName}}</span></legend>

                                                        <div class="row">
                                                            <div class="col-lg-12">
                                                                <div ng-repeat="test in panelTests"
                                                                     ng-click="getSelectedTests(test)">
                                                                    <div class="column">
                                                                        <div class="form-group form-check">
                                                                            <input class="form-check-input"
                                                                                   type="checkbox" id="scales"
                                                                                   name="feature"
                                                                                   ng-model='test.selected'
                                                                                   value="test.concept_id">
                                                                            <label class="form-check-label">{{test.name}}</label>
                                                                        </div>
                                                                    </div>

                                                                </div>
                                                            </div>
                                                        </div>
                                                    </fieldset>
                                                </div>

                                            </td>

                                        </tr>
                                    </table>

                                    <div style="padding-left: 50%">
                                        <button type="button"
                                                data-toggle="modal" data-target="#confirmation-dailog"
                                            ng-click="generateLabOrdersSummaryView()"
                                                ng-disabled="selectedOrders.length === 0"><img src="${ ui.resourceLink("kenyaui", "resources.images/glyphs/ok.png") }" />
                                            Confirm</button>
                                    </div>

                                </form>
                            </div>



                        </div>
                            <!-- confirmation dialog -->
                            <div class="modal fade" id="confirmation-dailog" tabindex="-1" role="dialog" aria-labelledby="confirmationMessageModalCenterTitle" aria-hidden="true">
                                <div class="modal-dialog modal-lg" role="document">
                                    <div class="modal-content">
                                        <div class="modal-header modal-header-primary">
                                            <h5 class="modal-title" id="confirmationModalCenterTitle">Confirm Orders</h5>
                                            <button type="button" class="close" data-dismiss="modal" ng-click="closeConfirmationDialogModal()">&times;

                                            </button>
                                        </div>

                                        <div class="modal-body">
                                            <div class="table-responsive">
                                                <table class="table table-striped">
                                                    <tr>
                                                        <th>Order Date</th>
                                                        <th>Test Name</th>
                                                        <th>Order Reason</th>
                                                        <th>Order Urgency</th>
                                                        <th>Actions</th>
                                                    </tr>
                                                    <tr ng-repeat="testSummary in viewSummaryLabs">
                                                        <td>
                                                            {{testSummary.dateActivated}}
                                                        </td>
                                                        <td>
                                                            {{testSummary.name}}
                                                        </td>
                                                        <td>
                                                            {{testSummary.orderReasonCodedName}}

                                                        </td>
                                                        <td>
                                                            {{testSummary.urgency}}

                                                        </td>
                                                        <td>
                                                            <div  role="group" aria-label="Basic example">
                                                                <button type="button" class="fa fa-calendar fa-1x"
                                                                        data-toggle="modal" data-target="#dateOrder"
                                                                        ng-click="orderSelectedToAddDateActivated(testSummary)"></button>
                                                                <button type="button" class="fa fa-warning fa-1x"
                                                                        data-placement="top" title="Urgency | Reason"
                                                                        data-toggle="modal" data-target="#orderUrgency"
                                                                        ng-click="orderSelectedToAddDateActivated(testSummary)"
                                                                ></button>
                                                                <button type="button" class="fa fa-remove fa-1x"
                                                                        ng-click="deselectedOrder(testSummary)" style="color:#9D0101;cursor: pointer"></button>
                                                            </div>
                                                        </td>

                                                    </tr>
                                                </table>
                                            </div>
                                        </div>
                                        <div class="modal-footer">
                                            <button type="button" class="mr-auto"   data-dismiss="modal" ng-click="closeConfirmationDialogModal()"
                                            >Cancel</button>

                                            <div>
                                                <button type="button" ng-click="postLabOrdersEncounters()"
                                                        ng-disabled="selectedOrders.length === 0">Save</button>
                                            </div>


                                        </div>
                                    </div>
                                </div>
                            </div>

                        <!-- Modal date for lab orders -->
                        <div class="modal fade" id="dateOrder" tabindex="-1" role="dialog" aria-labelledby="dateModalCenterTitle" aria-hidden="true">
                            <div class="modal-dialog modal-dialog-centered" role="document">
                                <div class="modal-content">
                                    <div class="modal-header modal-header-primary">
                                        <h5 class="modal-title" id="dateModalCenterTitle"></h5>
                                        <button type="button" class="close" data-dismiss="modal2" ng-click="closeDateOrderModal()">&times;

                                        </button>
                                    </div>
                                    <div class="modal-body">
                                        <label >Enter Date Order was made</label>
                                        <div>
                                            Date: ${ ui.includeFragment("kenyaui", "field/java.util.Date", [ id: "orderDate", formFieldName: "orderDate"]) }
                                        </div>
                                    </div>
                                    <div class="modal-footer">
                                        <button type="button" data-dismiss="modal2"   ng-click="closeDateOrderModal()">Close</button>
                                        <button type="button" ng-click="setOrderDate()">
                                            <img src="${ ui.resourceLink("kenyaui", "resources.images/glyphs/ok.png") }" /> Save</button>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <!-- Modal urgency  and reason for lab orders -->
                        <div class="modal fade" id="orderUrgency" tabindex="-1" role="dialog" aria-labelledby="urgencyModalCenterTitle" aria-hidden="true">
                            <div class="modal-dialog modal-dialog-centered" role="document">
                                <div class="modal-content">
                                    <div class="modal-header modal-header-primary">
                                        <h5 class="modal-title" id="urgencyModalCenterTitle"> Order Urgency | Reason(s)</h5>
                                        <button type="button" class="close" data-dismiss="modal2" ng-click="closeModal()">&times;
                                        </button>
                                    </div>
                                    <div class="modal-body" >
                                        <label ><b>Order Urgency</b></label>
                                        <div>
                                            <select id="ddlOrderUrgency" class="form-control">
                                                <option value="ROUTINE" selected="selected">ROUTINE</option>
                                                <option value="STAT" >IMMEDIATELY</option>
                                            </select>

                                        </div>
                                        <div style="padding-top: 5px">
                                        <label ><b>Order Reason </b></label>
                                        <div>
                                            Reason:
                                            <select id="ddlOrderReason" class="form-control" ng-model="orderReasonCoded" >
                                            <option value="{{r.uuid}}" ng-repeat=" r in OrderReason">{{r.name}}</option>

                                            </select>
                                            Reason(other):
                                            <input class="form-control" type="text" ng-model="orderReasonNonCoded">
                                        </div>
                                        </div>
                                    </div>
                                    <div class="modal-footer">
                                        <button type="button" data-dismiss="modal2"   ng-click="closeModal()">Close</button>
                                        <button type="button" ng-click="setOrderUrgency()">
                                            <img src="${ ui.resourceLink("kenyaui", "resources.images/glyphs/ok.png") }" /> Save</button>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- spinner modal -->
                        <div class="modal fade" id="spinner" tabindex="-1" role="dialog" aria-labelledby="spinnerModalCenterTitle" aria-hidden="true">
                            <div class="modal-dialog modal-dialog-centered" role="document">
                                <div class="modal-content">

                                    <div class="modal-body modal-header-primary">
                                        <div>
                                            <i class="fa fa-spinner fa-spin" style="font-size:30px"></i> Saving...
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                            <!--Error Modal -->
                            <div class="modal fade" id="orderError" tabindex="-1" role="dialog" style="font-size:16px;">
                                <div class="modal-dialog modal-dialog-centered" role="document">
                                    <div class="modal-content">
                                        <div class="modal-header modal-header-primary">
                                            <h5 class="modal-title" id="exampleModalLabel">Server Error</h5>
                                            <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                                                <span aria-hidden="true">&times;</span>
                                            </button>
                                        </div>

                                        <div class="modal-body" style="color:red;" id="modal-text">
                                            {{showErrorToast}}
                                        </div>
                                        <div class="modal-footer">
                                            <button type="button"  data-dismiss="modal2" ng-click="closeModal()">Close</button>
                                        </div>
                                    </div>
                                </div>
                            </div>


                        <!-- general message modal -->

                        <!-- general message modal -->
                        <div class="modal fade" id="generalMessage" tabindex="-1" role="dialog" aria-labelledby="generalMessageModalCenterTitle" aria-hidden="true">
                            <div class="modal-dialog modal-dialog-centered" role="document">
                                <div class="modal-content">
                                    <div class="modal-header modal-header-warning">
                                        <button type="button" class="close" data-dismiss="modal2" ng-click="closeModal()">&times;

                                        </button>
                                    </div>

                                    <div class="modal-body">
                                        <div>
                                            Active <b>{{testName}}</b>  Order Already exits. Please check the Active Orders Tab to cancel the order and proceed.
                                        </div>
                                    </div>
                                    <div class="modal-footer">
                                        <button type="button"  data-dismiss="modal2" ng-click="closeModal()">Close</button>
                                    </div>
                                </div>
                            </div>
                        </div>


                        </div>
                    </div>

                    <div class="ke-tab" data-tabid="lab_results">

                        ${ui.includeFragment("kenyaemrorderentry", "patientdashboard/labOrdersResults", ["patient": patient])}

                    </div>


                    <div class="ke-tab" data-tabid="active_orders" style="padding-top: 10px">
                        ${ui.includeFragment("kenyaemrorderentry", "patientdashboard/activeTestOrders", ["patient": patient])}
                    </div>
                    <div class="ke-tab" data-tabid="past_orders" style="padding-top: 10px">
                        ${ui.includeFragment("kenyaemrorderentry", "patientdashboard/pastLabOrders", ["patient": patient])}

                    </div>

                </div>

            </div>

        </div>


    </div>


</div>

</div>
<script type="text/javascript">
    // manually bootstrap angular app, in case there are multiple angular apps on a page
    angular.bootstrap('#lab-orders-app', ['labOrders']);

</script>
