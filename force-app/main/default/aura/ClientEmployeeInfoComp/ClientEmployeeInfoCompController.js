({
	doInit : function(component, event, helper) {
		helper.handleInitlization(component, event);
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
    handleSaveEdition: function(component, event, helper) {
        var draftValues = event.getParam('draftValues');
    },
    
    handleCancel: function(component, event, helper) {
        component.find("quoteTable").set("v.selectedRows", []);
        component.set("v.draftValues", []);
        component.set("v.selectedRows", []);
        component.set("v.isDelete", false);
        helper.handleInitlization(component, event);
        component.set("v.isShowCheckboxColumn", true);
        component.set("v.isAddEmployeeInfoModal", false);
        component.set("v.mapStateOptions", []);
        component.set("v.selectedStateId", null);
        component.set("v.numberOfEmployees", null);
        component.set("v.grossWages", null);
    },
    
    handleAddClientEmployeeInfo: function(component, event, helper) {
        let selectedStateId = component.get("v.selectedStateId");
        if(selectedStateId != null && selectedStateId != undefined){
            let isValidForm = helper.validateForm(component,'numberOfEmployees,grossWages');
            if(isValidForm){
                helper.createClinetInfo(component, event);
            }else{
                helper.doShowToast(component, 'Error', 'Please fill all required information and try again.', 'error');
            }
        }else{
            helper.doShowToast(component, 'Error', 'Please select valid state and try again.', 'error');
        }
        
    },
    
    handleAddRecods: function(component, event, helper) {
        component.set("v.isAddEmployeeInfoModal", true);
    },
    
    handleDeleteRecords: function(component, event, helper) {
        component.set("v.draftValues", []);
        component.set("v.selectedRows", []);
        component.set("v.isDelete", true);
        component.set("v.isShowCheckboxColumn", false);
    },
    
    handlePerformDeleteRecords: function(component, event, helper) {
        var selectedRows = component.get("v.selectedRows");
        if(selectedRows != null && selectedRows != undefined && selectedRows.length > 0){
            helper.deleteSUTAQuotes(component, event)
        }else{
            helper.doShowToast(component, 'Error', 'Please select at least one record to delete.', 'error');
        }
    },
})