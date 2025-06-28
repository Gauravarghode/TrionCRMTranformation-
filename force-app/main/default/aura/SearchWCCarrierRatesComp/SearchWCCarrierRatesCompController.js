({
    doInit : function(component, event, helper) {
        var filter = [];
        filter.push({selectedCompCode:'', selectedState:'', selectedCarrier:'', selectedStatus: '', isDisabledSelectedCompCode : false,isDisabledSelectedState : false,isDisabledSelectedCarrier : false,isDisabledSelectedStatus :false});
        component.set("v.lstFilters", filter);
        helper.getStatusPicklistValues(component, event);
        //helper.getCarrierOptions(component, event);
        //helper.getStateOptions(component, event);
    },
    
    handleMoreFilter: function(component, event, helper) {
        var filter = component.get("v.lstFilters");
        filter.push({selectedCompCode:'', selectedState:'', selectedCarrier:'', selectedStatus: '', isDisabledSelectedCompCode : false,isDisabledSelectedState : false,isDisabledSelectedCarrier : false,isDisabledSelectedStatus :false});
        component.set("v.lstFilters", filter);
    },
    
    handleResetFilter: function(component, event, helper) {
        var filter = [];
        filter.push({selectedCompCode:'', selectedState:'', selectedCarrier:'', selectedStatus: '', isDisabledSelectedCompCode : false,isDisabledSelectedState : false,isDisabledSelectedCarrier : false,isDisabledSelectedStatus :false});
        component.set("v.lstFilters", filter);
    },
    
    handleApplyFilter : function(component, event, helper) {
        let isRequiredFilter = true;
        let lstFilters = component.get("v.lstFilters");
        
        for(let i=0;i<lstFilters.length;i++){
            if(lstFilters[i].selectedCompCode == null || lstFilters[i].selectedCompCode == '' || lstFilters[i].selectedCompCode == undefined){
                isRequiredFilter = false;
            }
        }
        
        if(isRequiredFilter){
            for(let i=0;i<lstFilters.length;i++){
                lstFilters[i].isDisabledSelectedCompCode = true;
                lstFilters[i].isDisabledSelectedState = true;
                lstFilters[i].isDisabledSelectedCarrier = true;
                lstFilters[i].isDisabledSelectedStatus = true;
            }
            component.set("v.lstFilters", lstFilters);
            helper.createDataTableHeaders(component, true);
        	helper.fetchCarrierWCRates(component, event, false);
        }else{
            helper.doShowToast(component, 'Error', $A.get("$Label.c.SelectValidCompCodeErrorMessage"), 'error');
        }
    },
    
    handleSaveEdition: function(component, event, helper) {
        var draftValues = event.getParam('draftValues');
        helper.saveCarrierWCRates(component, event, draftValues);
    },
    
    handleCancel: function(component, event, helper) {
        component.set("v.draftValues", []);
    },
    
    handleAdd: function(component, event, helper) {
        var filter = component.get("v.lstFilters");
        filter.push({selectedCompCode:'', selectedState:'', selectedCarrier:'', selectedStatus: '',isDisabledSelectedCompCode : false,isDisabledSelectedState : false,isDisabledSelectedCarrier : false,isDisabledSelectedStatus :false});
        component.set("v.lstFilters", filter);
        component.set("v.isShowModal", true);
    },
    
    handleCloseModal : function(component, event, helper) {
        var lstFilters = component.get("v.lstFilters");
        for(let i=0;i<lstFilters.length;i++){
            if(lstFilters[i].selectedCompCode == null || lstFilters[i].selectedCompCode == '' || lstFilters[i].selectedCompCode == undefined){
               lstFilters.splice(i, 1);
            } 
        }
        component.set("v.lstFilters", lstFilters);
        component.set("v.isShowModal", false);
    },
    
    handleSearchCancel : function(component, event, helper) {
         var filter = [];
        filter.push({selectedCompCode:'', selectedState:'', selectedCarrier:'', selectedStatus: '',isDisabledSelectedCompCode : false,isDisabledSelectedState : false,isDisabledSelectedCarrier : false,isDisabledSelectedStatus :false});
        component.set("v.lstFilters", filter);
        component.set("v.isShowSearchFilter", true);
        component.set("v.filteredData",[]);
    },
    
    handleColumnSorting : function(component, event, helper) {
        // assign the latest attribute with the sorted column fieldName and sorted direction
        let fieldName = event.getParam("fieldName");
        component.set("v.sortedBy", fieldName);  
    	component.set("v.sortedDirection", event.getParam("sortDirection")); 
        helper.sortData(component, fieldName, event.getParam("sortDirection"));
    },
    
    handleDeleteFilter : function(component, event, helper) {
        var indexvar = event.getSource().get("v.name");
        var lstFilters = component.get("v.lstFilters");
        lstFilters.splice(indexvar, 1);
        if(lstFilters.length == 0){
            lstFilters.push({selectedCompCode:'', selectedState:'', selectedCarrier:'', selectedStatus: '',isDisabledSelectedCompCode : false,isDisabledSelectedState : false,isDisabledSelectedCarrier : false,isDisabledSelectedStatus :false});
        }
        component.set("v.lstFilters", lstFilters);
        var isShowSearchFilter = component.get("v.isShowSearchFilter");
        if(isShowSearchFilter == false){
            helper.fetchCarrierWCRates(component, event, true);
        }
    },
    
    handleEditFilter : function(component, event, helper) {
        var indexvar = event.getSource().get("v.name");
        var lstFilters = component.get("v.lstFilters");
        lstFilters[indexvar].isDisabledSelectedCompCode = false;
        lstFilters[indexvar].isDisabledSelectedState = false;
        lstFilters[indexvar].isDisabledSelectedCarrier = false;
        lstFilters[indexvar].isDisabledSelectedStatus = false;
        component.set("v.lstFilters", lstFilters);
    },
})