<%
   // ui.decorateWith("kenyaemr", "standardPage", [patient: patient])
    ui.includeCss("kenyaemrorderentry", "labOrders.css")
   ui.includeJavascript("uicommons", "emr.js")
   ui.includeJavascript("uicommons", "angular.min.js")
   ui.includeJavascript("uicommons", "angular-app.js")
   ui.includeJavascript("uicommons", "angular-resource.min.js")
   ui.includeJavascript("uicommons", "angular-common.js")
   ui.includeJavascript("uicommons", "angular-ui/ui-bootstrap-tpls-0.11.2.js")
   ui.includeJavascript("uicommons", "ngDialog/ngDialog.js")
   ui.includeJavascript("kenyaemrorderentry", "bootstrap.min.js")
   ui.includeCss("kenyaemrorderentry", "bootstrap.min.css")


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
%>
<script type="text/javascript">

    window.OpenMRS = window.OpenMRS || {};
    window.OpenMRS.drugOrdersConfig = ${ jsonConfig };
    window.OpenMRS.enterLabOrderResults =${enterLabOrderResults}


</script>

<div id="lab-orders-results" data-ng-controller="LabOrdersCtrl" ng-init='init()'>

    <div>
        <div class="row">
            <div class="col-lg-12">
                <form class="form-horizontal">
                    <div style="padding-top: 10px">
                        <div class="card">
                            <div class="card-header">
                                <h4 class="card-title">
                                    Enter Lab Result(s)
                                </h4>
                            </div>

                            <div class="card-body">
                                <span ng-show="InspireList[0].length ===1">No Lab orders to enter results for</span>
                                <div class="row" ng-repeat="items in InspireList">
                                    <div class="col" ng-repeat="control in items" >

                                        <div ng-if="control.rendering === 'select'">
                                            <div class="form-group row">
                                                <label class="col-lg-3"><b>{{control.label}}:</b>
                                                    <p>  <span >({{control.dateActivated | date:'dd-MM-yyyy'}})</span>
                                                    </p></label>

                                                <div class="col-lg-4">
                                                    <select class="form-control"
                                                            ng-model="typeValues[control.orderId]">
                                                        <option ng-repeat=" o in control.answers"
                                                                ng-value="o.concept">{{o.label}}
                                                        </option>
                                                    </select>
                                                </div>
                                            </div>
                                        </div>

                                        <div ng-if="control.rendering === 'inputtext'">
                                            <div class="form-group row">
                                                <label class="col-lg-3"><b>{{control.label}}:</b>
                                                    <p>  <span >({{control.dateActivated | date:'dd-MM-yyyy'}})</span>
                                                    </p></label>

                                                <div class="col-lg-4">
                                                    <input class="form-control" type="text"
                                                           ng-model="typeValues[control.orderId]">
                                                </div>
                                            </div>
                                        </div>

                                        <div ng-if="control.rendering === 'inputnumeric'">
                                            <div class="form-group row">
                                                <label class="col-lg-3"><b>{{control.label}}:</b>
                                                    <p>  <span >({{control.dateActivated | date:'dd-MM-yyyy'}})</span>
                                                    </p></label>

                                                <div class="col-lg-4">
                                                    <input class="form-control" type="number"
                                                           ng-model="typeValues[control.orderId]">
                                                </div>
                                            </div>
                                        </div>

                                        <div ng-if="control.rendering === 'textarea'">
                                            <div class="form-group row">
                                                <label class="col-lg-3"><b>{{control.label}}:</b>
                                                    <p>  <span >({{control.dateActivated | date:'dd-MM-yyyy'}})</span>
                                                    </p></label>

                                                <div class="col-lg-4">
                                                    <textarea class="form-control" ng-model="typeValues[control.orderId]">
                                                    </textarea>
                                                </div>
                                            </div>
                                        </div>


                                        <div class="form-group row" ng-if="control.hvVl">
                                            <label class="col-lg-2"><b>HIV viral load:</b>
                                                <p>  <span >({{control.hvVl[0].dateActivated | date:'dd-MM-yyyy'}})</span>
                                                </p></label>

                                            <div ng-repeat="vl in control.hvVl">
                                                <div ng-if="vl.concept ==='1305AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' ||
                                                                            vl.concept ==='856AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'"></div>


                                                <div>
                                                    <div ng-if="vl.rendering ==='checkbox'" class="form-group form-check">
                                                        <input class="form-check-input "
                                                               type="checkbox" id="vl"
                                                               name="feature"
                                                               ng-checked="fag"
                                                               ng-model="hivViralValuesLDL[vl.orderId]"
                                                               ng-click="toggleSelection(vl.orderId)"
                                                               value="'1302AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'">
                                                        <label class="form-check-label">LDL</label>
                                                    </div>


                                                    <div ng-if="vl.rendering === 'inputnumeric'">
                                                        <input class="form-control" type="number" id="vload"
                                                               ng-model="hivViralValues[vl.orderId]"
                                                               ng-disabled="ischecked ==='yes'">
                                                    </div>

                                                </div>

                                            </div>


                                        </div>

                                    </div>

                                </div>

                            </div>

                            <div style="padding-left: 50%; padding-bottom: 20px" ng-show="InspireList[0].length >1"
                            >
                                <button type="button" ng-click="postLabOrderResults()" data-toggle="modal"
                                        data-target="#spinnerSave">
                                    <img src="${ ui.resourceLink("kenyaui", "images/glyphs/ok.png") }" />  Save</button>
                            </div>
                        </div>
                    </div>

                </form>
            </div>
        </div>
    </div>
    <!-- spinner modal -->
    <div class="modal fade" id="spinnerSave" tabindex="-1" role="dialog" aria-labelledby="spinModalCenterTitle" aria-hidden="true">
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


</div>
<script type="text/javascript">
    // manually bootstrap angular app, in case there are multiple angular apps on a page
    angular.bootstrap('#lab-orders-results', ['labOrders']);

</script>