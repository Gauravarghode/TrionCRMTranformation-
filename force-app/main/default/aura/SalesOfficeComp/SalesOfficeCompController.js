({
	doInit : function(component, event, helper) {
		helper.handleInitilize(component, event);
	},
    
    handleColumnSorting : function(component, event, helper) {
        let fieldName = event.getParam("fieldName");
        component.set("v.sortedBy", fieldName);
    	component.set("v.sortedDirection", event.getParam("sortDirection")); 
        helper.sortData(component, fieldName, event.getParam("sortDirection"));
    },
    
    handleRowSelection : function(component, event, helper) {
        var selectedRows = event.getParam('selectedRows'); 
        component.set("v.selectedRows", selectedRows);
    },
    
    handleRowAction: function (component, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        switch (action.name) {
            case 'edit':
                var whereClause = null;
                if(row.SUTA_Quote__r.State__r.Id != null && row.SUTA_Quote__r.State__r.Id != undefined){
                    whereClause = ' State__c = \''+row.SUTA_Quote__r.State__r.Id+'\'';
                }
                component.set("v.wcRateWhereClause", whereClause);
                component.set("v.selectedStateCompCode", row.State_Comp_Code__c);
                component.set("v.selectedRecordId", row.Id);
                component.set("v.selectedRecordName", row.Description__c);
                component.set("v.isShowEditModal", true);
                break;
                
           case 'delete':
                helper.deleteWCRateRecords(component, event, row.Id);
                break;
        }
    },
    
    
    handleCancelEditModal : function (component, event, helper) {
        component.set("v.selectedRecordId", null);
        component.set("v.selectedRecordName", null);
        component.set("v.isShowEditModal", false);
    },
    
    handleSuccessWCRateRecord : function (component, event, helper) {
        component.set("v.isShowEditModal", false);
        component.set("v.selectedRecordId", null);
        component.set("v.selectedRecordName", null);
        helper.handleInitilize(component, event);
    },
    
    handleSubmitWCRateRecord : function (component, event, helper) {
        var wcRate = {'sobjecttype':'WC_Rate__c'};
        wcRate['State_Comp_Code__c'] = component.get("v.selectedStateCompCode");
        wcRate['Manual_Comp_Description__c'] = component.find("Manual_Comp_Description").get("v.value");
        wcRate['Part_Time_Employees__c'] = component.find("Part_Time_Employees").get("v.value");
        wcRate['of_Employees__c'] = component.find("of_Employees").get("v.value");
        wcRate['Gross_Wages__c'] = component.find("Gross_Wages").get("v.value");
        wcRate['Carrier_Rate__c'] = component.find("Carrier_Rate").get("v.value");
        
        helper.showSpinner(component);
        component.find("editForm").submit(wcRate);
    },
    
    handleErrorWCRateRecord : function (component, event, helper) {
        helper.hideSpinner(component);
        var message = event.getParam('message');
        if(message != null && message != '' && message != undefined){
            helper.doShowToast(component, 'Error', message, 'error');
        }
    },
    
    handleShowCalculateRate : function (component, event, helper) {
        component.set("v.isShowCheckboxColumn", false);
        component.set("v.isCalculateRate", true);
        component.find("wcRate").set("v.selectedRows", []);
        component.set("v.draftValues", []);
        component.set("v.selectedRows", []);
        component.set("v.selectedCalculateWCRateby", null);
        component.set("v.modifier", null);
        helper.fetchPicklistValues(component, event, 'WC_Rate__c', 'Calculate_WC_Rate_by__c');
    },
    
    handleCancelCalculateRate : function (component, event, helper) {
        component.set("v.isShowCheckboxColumn", true);
        component.set("v.isCalculateRate", false);
        component.find("wcRate").set("v.selectedRows", []);
        component.set("v.draftValues", []);
        component.set("v.selectedRows", []);
        component.set("v.selectedCalculateWCRateby", null);
        component.set("v.modifier", null);
    },
    
    handleCalculateRates : function (component, event, helper) {
        let isValidate = helper.validateForm(component, 'calculateBillRateby,modifier');
        if(isValidate){
            let selectedRows = component.get("v.selectedRows");
            if(selectedRows != null && selectedRows != undefined && selectedRows.length > 0){
                helper.updateCalculateRates(component, event);
            }else{
                helper.doShowToast(component, 'Error', 'Please select atleast one record to calculate rate.', 'error');
            }
        }else{
            helper.doShowToast(component, 'Error', 'Please fill required information and try again', 'error');
        }
    },
    
    handleShowCarrier : function (component, event, helper) {
        component.set("v.isSelectCarrier", true);
        component.set("v.selectedCarrier", null);
        component.set("v.mapCarrier", []);
        //helper.fetchActiveCarrier(component, event);
        component.set("v.isShowPolicy", true);
        helper.fetchPolicyWrapper(component,event);
        helper.createMasterPolicyDataTableHeaders(component);
    },
    
    handleCancelCarrier : function (component, event, helper) {
        component.set("v.isSelectCarrier", false);
        component.set("v.selectedCarrier", null);
        component.set("v.mapCarrier", []);
        component.set("v.lstWCCode", []);
        component.set("v.WCCodeColumns", []);
        component.set("v.sortedByWCCode", null);
        component.set("v.sortedDirectionWCCode", null);
        component.set("v.isShowWCCode", false);
        component.set("v.isShowState", false);
        component.set("v.isShowAddCompCodeModal" , false);
        component.set("v.isShowPolicy" , false);
        component.set("v.masterQuoteColumns", []);
        component.set("v.lstMasterQuotes", []);
        component.set("v.selectedMasterQuotes", []);
        component.set("v.policyColumns", []);
        component.set("v.lstPolicy", []);
        component.set("v.selectedPolicy", []);
        helper.handleInitilize(component, event);
    },
    
    handleViewPolicies : function (component, event, helper) {
        let isValidate = helper.validateForm(component, 'carrier');
        if(isValidate){
            component.set("v.isShowPolicy", true);
            helper.fetchPolicyWrapper(component,event);
            helper.createMasterPolicyDataTableHeaders(component);
        }else{
            helper.doShowToast(component, 'Error', 'Please fill required information and try again', 'error');
        }
    },
    
    updateSelectedMasterQuotes: function (component, event, helper) {
        var selectedRows = event.getParam('selectedRows');
        component.set('v.selectedMasterQuotes', selectedRows);
    },
    
    
    updateSelectedPolicy: function (component, event, helper) {
        var selectedRows = event.getParam('selectedRows');
        component.set('v.selectedPolicy', selectedRows);
    },
    
    handleAddPolicyRates: function (component, event, helper) {
        var lstMasterQuotes = component.get("v.lstMasterQuotes");
        var lstPolicy = component.get("v.lstPolicy");
        var lstMCPStateWrapper = component.get("v.lstMCPStateWrapper");
        
        if(lstMasterQuotes != null && lstMasterQuotes != undefined && lstMasterQuotes.length > 0
          	&& lstPolicy != null && lstPolicy != undefined && lstPolicy.length > 0){
             let selectedPolicy = component.get("v.selectedPolicy");
            if(selectedPolicy != null && selectedPolicy != undefined && selectedPolicy.length > 0){
                component.set("v.oPolicy", selectedPolicy[0]);
                let selectedMasterQuotes = component.get("v.selectedMasterQuotes");
                if(selectedMasterQuotes != null && selectedMasterQuotes != undefined && selectedMasterQuotes.length > 0){
                    helper.updateMasterSUTAQuoteHelper(component, event);
                }else{
                    helper.doShowToast(component, 'Error', 'Please select atleast one SUTA Quote record to continue', 'error');
                }
            }else{
                helper.doShowToast(component, 'Error', 'Please select atleast one Master Policy record to continue', 'error');
            }
        }else if(lstMCPStateWrapper != null && lstMCPStateWrapper != undefined && lstMCPStateWrapper.length > 0){
            helper.updateMasterSUTAQuoteHelper(component, event);
        }else{
            component.set("v.isSelectCarrier", false);
            component.set("v.selectedCarrier", null);
            component.set("v.mapCarrier", []);
            component.set("v.isShowWCCode", false);
            component.set("v.isShowState", false);
            component.set("v.isShowAddCompCodeModal" , false);
            component.set("v.isShowPolicy" , false);
            component.set("v.masterQuoteColumns", []);
            component.set("v.lstMasterQuotes", []);
            component.set("v.selectedMasterQuotes", []);
            component.set("v.policyColumns", []);
            component.set("v.lstPolicy", []);
            component.set("v.selectedPolicy", []);
            helper.handleInitilize(component, event);
        }
    },
    
    handleShowAddCompCodeListModal : function(component, event, helper){
        component.set("v.isShowAddCompCodeListModal" , true);
    },
    
    handleHideAddCompCodeListModal : function(component, event, helper){
        component.set("v.isShowAddCompCodeModal" , false);
        component.set("v.isShowAddCompCodeListModal" , false);
        component.set("v.mapStates", []);
        component.set("v.isShowState", false);
        component.set("v.selectedState", null);
    },
    
    handleShowAddCompCodeModal : function(component, event, helper){
        component.set("v.mapStates", []);
        component.set("v.isShowAddCompCodeListModal" , false);
        component.set("v.isShowAddCompCodeModal" , true);
        component.set("v.isShowState", true);
        component.set("v.selectedState", null);
        component.set("v.numberEmployee", null);
        component.set("v.grossWage", null);
        helper.fetchState(component, event);
    },
    
    handleHideAddCompCodeModal : function(component, event, helper){
        component.set("v.isShowAddCompCodeModal" , false);
        component.set("v.isShowAddCompCodeListModal" , false);
        component.set("v.mapStates", []);
        component.set("v.isShowState", false);
        component.set("v.selectedState", null);
        helper.navigateToRecord(component,event,component.get("v.recordId"));
    },
    
    handleAddCompstoState : function(component, event, helper){
        let isValidate = helper.validateForm(component, 'state');
        if(isValidate){
            component.set("v.isShowWCCode", true);
            component.set("v.isShowState", false);
            helper.createRateDataTableHeaders(component, event);
            helper.fetchWCRateWithState(component, event);
        }else{
            helper.doShowToast(component, 'Error', 'Please fill required information and try again', 'error');
        }
    },
    
    handleWCCodeColumnSorting : function(component, event, helper){
        let fieldName = event.getParam("fieldName");
        component.set("v.sortedByWCCode", fieldName);
    	component.set("v.sortedDirectionWCCode", event.getParam("sortDirection")); 
        helper.sortWCData(component, fieldName, event.getParam("sortDirection"));
    },
    
    hndleSaveAddMoreWcRate : function(component, event, helper){
        let selectedStateCompCode = component.get("v.selectedStateCompCode");
        let numberOfEmployees = component.get("v.numberEmployee");
        let grossWages = component.get("v.grossWage");
       
        if(selectedStateCompCode != null && selectedStateCompCode != undefined
          	&& numberOfEmployees != null && numberOfEmployees != undefined
          	&& grossWages != null && grossWages != undefined){
            helper.createUpdateWCRateHelper(component, event, true, false, false);
        }else{
            helper.doShowToast(component, 'Error', 'Please fill required information and try again', 'error');
        }
    },
    
    
    hndleSaveAddNewStateWcRate : function(component, event, helper){
        let selectedStateCompCode = component.get("v.selectedStateCompCode");
        let numberOfEmployees = component.get("v.numberEmployee");
        let grossWages = component.get("v.grossWage");
        
        if(selectedStateCompCode != null && selectedStateCompCode != undefined
          	&& numberOfEmployees != null && numberOfEmployees != undefined
          	&& grossWages != null && grossWages != undefined){
            helper.createUpdateWCRateHelper(component, event, false, true, false);
        }else{
            helper.doShowToast(component, 'Error', 'Please fill required information and try again', 'error');
        }
    },
    
    hndleSaveFinishWcRate : function(component, event, helper){
        let selectedStateCompCode = component.get("v.selectedStateCompCode");
        let numberOfEmployees = component.get("v.numberEmployee");
        let grossWages = component.get("v.grossWage");
        
        if(selectedStateCompCode != null && selectedStateCompCode != undefined
          	&& numberOfEmployees != null && numberOfEmployees != undefined
          	&& grossWages != null && grossWages != undefined){
            helper.createUpdateWCRateHelper(component, event, false, false, true);
        }else{
            helper.doShowToast(component, 'Error', 'Please fill required information and try again', 'error');
        }
    },
    
    
})