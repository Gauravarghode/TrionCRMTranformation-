({
    doInit : function(component, event, helper) {
        helper.fetchFederaTaxData(component, event);
        helper.createDataTableHeaders(component, false);
        let btnvisibilitysoqlFilter = component.get("v.buttonvisibilitysoqlFilter");
        if(btnvisibilitysoqlFilter != null && btnvisibilitysoqlFilter != '' && btnvisibilitysoqlFilter != undefined){
            helper.checkButtonVisibility(component, event);
        }
    },
    
	handleTaxYear : function(component, event, helper) {
		component.set("v.isShowSelectYear", true);
        var oProposal = component.get("v.oProposal");
        if(oProposal.Year__c != null && oProposal.Year__c != undefined){
            component.set("v.selectedYearId", oProposal.Year__c);
        }
        helper.fetchYears(component, event);
	},
    
    handleSelectTaxYear : function(component, event, helper) {
        let selectedYearId = component.get("v.selectedYearId")
        if(selectedYearId != null && selectedYearId != undefined && selectedYearId != ''){
            helper.selectTaxYear(component, event);
        }else{
            helper.doShowToast(component, 'Error','Please select a valid Year', 'error');
        }
	},
    
    handleCancelTaxYear : function(component, event, helper) {
		component.set("v.isShowSelectYear", false);
	},
    
    handleColumnSorting : function(component, event, helper) {
        let fieldName = event.getParam("fieldName");
        component.set("v.sortedBy", fieldName);
    	component.set("v.sortedDirection", event.getParam("sortDirection")); 
        helper.sortData(component, fieldName, event.getParam("sortDirection"));
    },
    
    handleSaveEdition: function(component, event, helper) {
        var draftValues = event.getParam('draftValues');
		helper.saveSUTAQuoteRecords(component, event, draftValues);
    },
    
    handleRowSelection : function(component, event, helper) {
        var selectedRows = event.getParam('selectedRows'); 
        component.set("v.selectedRows", selectedRows);
    },
    
    handleCancelDeleteRecords : function(component, event, helper) {
        component.set("v.isShowDeleteModal", false);
        component.set("v.selectedRecordId", null);
    },

    handleDeleteRecords : function(component, event, helper) {
        helper.deleteSelectedRecords(component, event);
    },

    handleRowAction: function (component, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        switch (action.name) {
            case 'edit':
                component.set("v.selectedRecordId", row.Id);
                component.set("v.selectedRecordName", row.Name);
                component.set("v.isShowEditModal", true);
                component.set("v.selectedSUTA", row.SUTA__c);
                helper.fetchSUTARecords(component, event, row.SUTA__c, row.State__c, row.Year__c);
                //alert('Showing Details: ' + JSON.stringify(row));
                break;
           case 'delete':
                component.set("v.isShowDeleteModal", true);
                component.set("v.selectedRecordId", row.Id);
                break;
                
        }
    },

    handleRecordEditCancel : function (component, event, helper) {
        component.set("v.isShowEditModal", false);
        component.set("v.selectedRecordId", null);
        component.set("v.selectedRecordName", null);
        component.set("v.selectedSUTA", null);
    },

    handleEditQuoteRecord: function (component, event, helper) {
        helper.showSpinner(component);
        //component.find("editForm").submit();
        var objQuote = {'sobjectType':'SUTA_Quote__c'};
        objQuote['SUTA__c'] = component.get("v.selectedSUTA");
        let SUTA_Bill_Rate = component.find("SUTA_Bill_Rate").get("v.value");
        let SUTA_Cost_Rate = component.find("SUTA_Cost_Rate").get("v.value");
        
        if(SUTA_Cost_Rate != null && SUTA_Cost_Rate != '' && SUTA_Cost_Rate != undefined && SUTA_Bill_Rate>=SUTA_Cost_Rate){
            objQuote['SUTA_Bill_Rate__c'] = component.find("SUTA_Bill_Rate").get("v.value");
            component.find("editForm").submit(objQuote);
        }else{
            helper.doShowToast(component, 'Error', 'SUTA Bill Rate should be equal or greater than SUTA Cost Rate', 'error');
            helper.hideSpinner(component); 
        }
    },

 
    handleErrorQuoteRecord : function (component, event, helper) {
        helper.hideSpinner(component);
        var message = event.getParam('message');
        if(message != null && message != '' && message != undefined){
            helper.doShowToast(component, 'Error', message, 'error');
        }
    },

    handleSuccessQuoteRecord : function (component, event, helper) {
        component.set("v.isShowEditModal", false);
        component.set("v.selectedRecordId", null);
        component.set("v.selectedRecordName", null);
        component.set("v.selectedSUTA", null)
        helper.fetchProposalSUTAQuoteRecords(component, event);
    },
    
})