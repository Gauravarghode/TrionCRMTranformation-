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
    
    handleIncludeSurcharge : function(component, event, helper) {
        component.set("v.isShowCheckboxColumn", false);
        component.set("v.isIncluded", true);
    },
    
    handleExcludeSurcharge : function(component, event, helper) {
        component.set("v.isShowCheckboxColumn", false);
        component.set("v.isExcluded", true);
    },
    
    handleCancelIncludeSurcharge : function(component, event, helper) {
        component.find("sutaTable").set("v.selectedRows", []);
        component.set("v.isShowCheckboxColumn", true);
        component.set("v.selectedRows", []);
        component.set("v.isIncluded", false);
        component.set("v.isExcluded", false);
    },
    
    handleCancelExcludeSurcharge : function(component, event, helper) {
        component.find("sutaTable").set("v.selectedRows", []);
        component.set("v.isShowCheckboxColumn", true);
        component.set("v.selectedRows", []);
        component.set("v.isExcluded", false);
        component.set("v.isIncluded", false);
    },
    
    handleUpdateIncludeSurcharge : function(component, event, helper) {
        let selectedRows = component.get("v.selectedRows");
        if(selectedRows != null && selectedRows != undefined && selectedRows.length > 0){
            helper.updateSUTARecordSurcharges(component, event, true);
        }else{
            helper.doShowToast(component, 'Error', 'Please select atleast one record to continue', 'error');
        }
    },
    
    handleUpdateExcludeSurcharge : function(component, event, helper) {
        let selectedRows = component.get("v.selectedRows");
        if(selectedRows != null && selectedRows != undefined && selectedRows.length > 0){
            helper.updateSUTARecordSurcharges(component, event, false);
        }else{
            helper.doShowToast(component, 'Error', 'Please select atleast one record to continue', 'error');
        }
    },
    
})