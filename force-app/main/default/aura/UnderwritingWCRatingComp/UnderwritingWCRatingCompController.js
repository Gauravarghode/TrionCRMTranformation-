({
	doInit : function(component, event, helper) {
		helper.handleInitialize(component, event);
	},
    
    handleColumnSorting : function(component, event, helper) {
        let fieldName = event.getParam("fieldName");
        component.set("v.sortedBy", fieldName);
    	component.set("v.sortedDirection", event.getParam("sortDirection")); 
        helper.sortData(component, fieldName, event.getParam("sortDirection"));
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
                component.set("v.selectedRecordId", row.Id);
                component.set("v.selectedRecordName", row.Description__c);
                component.set("v.selectedStateCompCode", row.State_Comp_Code__c);
                component.set("v.isShowEditModal", true);
                break;
           case 'delete':
                helper.deleteWCRateRecord(component, event, row.Id);
                break;
        }
    },
    
    handleRecordEditCancel: function (component, event, helper) {
        component.set("v.selectedRecordId", null);
        component.set("v.selectedRecordName", null);
        component.set("v.isShowEditModal", false);
    },
    
    handleSuccessWCRateRecord: function (component, event, helper) {
        component.set("v.isShowEditModal", false);
        component.set("v.selectedRecordId", null);
        component.set("v.selectedRecordName", null);
        helper.doShowToast(component, 'Success', 'Record updated successfully!', 'success');
        helper.handleInitialize(component, event);
        helper.hideSpinner(component);
    },
    
    handleErrorWCRateRecord: function (component, event, helper) {
        helper.hideSpinner(component);
        var message = event.getParam('message');
        if(message != null && message != '' && message != undefined){
            helper.doShowToast(component, 'Error', message, 'error');
        }
    },
    
    handleEditWCRateRecord: function (component, event, helper) {
        helper.showSpinner(component);
        var fields = {'sobjecttype': 'WC_Rate__c'};
        fields['State_Comp_Code__c'] = component.get("v.selectedStateCompCode");
        fields['of_Employees__c'] = component.find("of_Employees").get("v.value");
        fields['Gross_Wages__c'] = component.find("Gross_Wages").get("v.value");
        fields['Current_Rate__c'] = component.find("Current_Rate").get("v.value");
        fields['Part_Time_Employees__c'] = component.find("Part_Time_Employees").get("v.value");
        fields['Debit_Discount__c'] = component.find("Debit_Discount").get("v.value");
        fields['Carrier_Rate__c'] = component.find("Carrier_Rate").get("v.value");
        component.find("editForm").submit(fields);
    },
    
    handleShowAddCompCodeListModal: function (component, event, helper) {
		component.set("v.isShowAddCompCodeListModal" , true);
    },
    
    handleHideAddCompCodeModal: function (component, event, helper) {
		component.set("v.isShowAddCompCodeListModal" , false);
    },
    
    handleShowchangeCompCode: function (component, event, helper) {
		component.set("v.isShowChangeCompCode", true);
        helper.createDataTableHeaders(component, true);
    },
    
    handleHidechangeCompCode: function (component, event, helper) {
		component.set("v.isShowChangeCompCode", false);
        component.set("v.selectedRows", []);
        component.set("v.isShowStampCompCode", false);
        helper.createDataTableHeaders(component, false);
    },
    
    handleShowStampCompCode: function (component, event, helper) {
        let selectedRows = component.get("v.selectedRows");
        if(selectedRows != null && selectedRows != undefined && selectedRows.length >0){
            component.set("v.isShowStampCompCode", true);
        }else{
            helper.doShowToast(component, 'Error', 'Please select atleast one record to continue.', 'error');
        }
    },
    
    handleUpdateStampCompCode: function (component, event, helper) {
        let selectedStateCompCode = component.get("v.selectedStateCompCode");
        if(selectedStateCompCode != null && selectedStateCompCode != undefined){
            helper.updateStateCompCodeWCRate(component, event, component.get("v.selectedRows")[0].Id);
        }else{
            helper.doShowToast(component, 'Error', 'Please select valid State Comp Code and try again', 'error');
        }
    },
    
    handleRowSelection : function(component, event, helper) {
        var selectedRows = event.getParam('selectedRows'); 
        component.set("v.selectedRows", selectedRows);
    },
    
    handleShowCarrier: function (component, event, helper) {
		component.set("v.isShowSelectCarrierModal", true);
        /*component.set("v.isShowSelectCarrier", false);
        component.set("v.selectedRows", []);
        component.set("v.selectedCarrier", null);
        helper.createDataTableHeaders(component, true);*/

        component.set("v.selectedCarrier", null);
        helper.fetchPolicyWrapper(component,event);
        helper.fetchPolicyYears(component,event);
        helper.createMasterPolicyDataTableHeaders(component);
    },
    
    updateSelectedPolicy: function (component, event, helper) {
        var selectedRows = event.getParam('selectedRows');
        component.set('v.selectedPolicy', selectedRows);
    },
    
    updateSelectedMasterQuotes: function (component, event, helper) {
        var selectedRows = event.getParam('selectedRows');
        component.set('v.selectedMasterQuotes', selectedRows);
    },
    
    handleAddPolicyRates: function (component, event, helper) {
        var lstMasterQuotes = component.get("v.lstMasterQuotes");
        var lstPolicy = component.get("v.lstPolicy");
        var lstMCPStateWrapper = component.get("v.lstMCPStateWrapper");
        let selectedPolicyYear = component.get("v.selectedPolicyYear");
        
        if(lstMasterQuotes != null && lstMasterQuotes != undefined && lstMasterQuotes.length > 0
          	&& lstPolicy != null && lstPolicy != undefined && lstPolicy.length > 0){
             let selectedPolicy = component.get("v.selectedPolicy");
            if(selectedPolicyYear != null && selectedPolicyYear != undefined && selectedPolicyYear != ''){
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
            }else{
                helper.doShowToast(component, 'Error', 'Policy Year: You must select a value.', 'error');
            }
        }else if(lstMCPStateWrapper != null && lstMCPStateWrapper != undefined && lstMCPStateWrapper.length > 0){
            if(selectedPolicyYear != null && selectedPolicyYear != undefined && selectedPolicyYear != ''){
                helper.updateMasterSUTAQuoteHelper(component, event);
            }else{
                helper.doShowToast(component, 'Error', 'Policy Year: You must select a value.', 'error');
            }
        }else{

            component.set("v.selectedCarrier", null);
            component.set("v.masterQuoteColumns", []);
            component.set("v.lstMasterQuotes", []);
            component.set("v.selectedMasterQuotes", []);
            component.set("v.policyColumns", []);
            component.set("v.lstPolicy", []);
            component.set("v.selectedPolicy", []);
            helper.handleInitilize(component, event);
        }
    },
    
    handleHideCarrier: function (component, event, helper) {
		component.set("v.isShowSelectCarrierModal", false);
        component.set("v.isShowSelectCarrier", false);
        component.set("v.selectedRows", []);
        component.set("v.selectedCarrier", null);
        component.set("v.selectedPolicyYear", null);
        //helper.createDataTableHeaders(component, false);
    },
    
    handleShowSelectedCarrier : function (component, event, helper) {
        let selectedRows = component.get("v.selectedRows");
        if(selectedRows != null && selectedRows != undefined && selectedRows.length >0){
            component.set("v.isShowSelectCarrier", true);
            helper.fetchWCCarrier(component, event);
        }else{
            helper.doShowToast(component, 'Error', 'Please select atleast one record to continue.', 'error');
        }
    },
    
    handleUpdateCarrier : function (component, event, helper) {
        let selectedCarrier = component.get("v.selectedCarrier");
        if(selectedCarrier != null && selectedCarrier != undefined){
			helper.updateWCCarrierRates(component, event);
        }else{
            helper.doShowToast(component, 'Error', 'Please select valid Carrier and try again', 'error');
        }
    },
    
    handleShowUWMod : function (component, event, helper) {
        component.set("v.isShowSetUWMod", true);
        component.set("v.isShowUWModSelected", false);
        component.set("v.selectedWCRateRows", []);
    },
    
    handleSaveUWMod : function (component, event, helper) {
        var selectedWCRateRows = component.get("v.selectedWCRateRows");
        var modValue = component.get("v.modValue");
        
        if(modValue != null && modValue != undefined){
            if(selectedWCRateRows != null && selectedWCRateRows != undefined && selectedWCRateRows.length > 0){
                helper.updateDebitDiscountHandler(component, event);  
            }else{
                helper.doShowToast(component, 'Error', 'Please select at least one record to continue.', 'error');
            }
        }else{
            helper.doShowToast(component, 'Error', 'Mod : You must enter a value.', 'error');
        }
    },

    handleWCRateSelection : function (component, event, helper) {
        var selectedRows = event.getParam('selectedRows'); 
        component.set("v.selectedWCRateRows", selectedRows);
    },
    
    handleCancelUWMod : function (component, event, helper) {
        component.set("v.isShowSetUWMod", false);
        component.set("v.isShowUWModSelected", true);
        component.set("v.selectedWCRateRows", []);
    },
})