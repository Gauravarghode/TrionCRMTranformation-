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
        helper.saveClinetContactRecords(component, event,draftValues);
    },
    
    handleCancel: function(component, event, helper) {
        component.find("clientTable").set("v.selectedRows", []);
        component.set("v.draftValues", []);
        component.set("v.selectedRows", []);
    },
    
    handleEnableDelete: function(component, event, helper) {
        component.set("v.isDelete", true);
        component.set("v.isHideCheckboxColumn", false);
    },
    
    handleCancelDelete: function(component, event, helper) {
        component.set("v.isDelete", false);
        component.find("clientTable").set("v.selectedRows", []);
        component.set("v.draftValues", []);
        component.set("v.selectedRows", []);
        component.set("v.isHideCheckboxColumn", true);
    },
    
    handleDoDelete: function(component, event, helper) {
        let selectedRows = component.get("v.selectedRows");
        if(selectedRows != null && selectedRows != undefined && selectedRows.length > 0){
            helper.deleteClinetContactRecords(component, event);
        }else{
            helper.doShowToast(component, 'Error', 'Please select at least one record to delete', 'error');
        }
    },
    
    handleEnableEdit: function(component, event, helper) {
        component.set("v.isEdit", true);
        component.set("v.isHideCheckboxColumn", false);
        helper.createDataTableHeaders(component, true);
    },
    
    handleCancelEdit: function(component, event, helper) {
        component.set("v.isEdit", false);
        component.set("v.isHideCheckboxColumn", true);
        helper.handleInitlization(component, event);
    },
    
    handleShowMdal : function(component, event, helper) {
        var clinetContactWrapper = {'firstName':'','lastName':'','titleRelationship':'','email':'','phone':'','ownership':null,'selectedState':null,'payroll':null,'selectedClientLocation':null,'selectedStampCode':null,'primaryContactLastName':'','primaryContactFirstName':'','primaryContactPhone':'','primaryContactTitle':'','primaryContactEmail':'','isPrimary':false,'isIncluded':false, 'clientLocation':'', 'birthdate':null, 'duties':'','clientContactType':null,'mobilePhone':null};
        component.set("v.isPrimary", false);
        
        var isContactInformation = component.get("v.isContactInformation");
        
        /*if(component.get("v.isSubmissionDocument") == true && isContactInformation == false){
            clinetContactWrapper['isPrimary'] = true;
            component.set("v.isPrimary", true);
        }*/
        component.set("v.oClinetContactWrapper",clinetContactWrapper);
        component.set("v.isShowAddModal", true);
        component.set("v.mapClientLocationPicklistValues", []);
        component.set("v.wcRateWhereClause", '');
        component.set("v.isIncluded", false);
        helper.fetchClientContactType(component, event);
    },
    
    handleCloseMdal : function(component, event, helper) {
        var clinetContactWrapper = {'firstName':'','lastName':'','titleRelationship':'','email':'','phone':'','ownership':null,'selectedState':null,'payroll':null,'selectedClientLocation':null,'selectedStampCode':null,'primaryContactLastName':'','primaryContactFirstName':'','primaryContactPhone':'','primaryContactTitle':'','primaryContactEmail':'','isPrimary':false,'isIncluded':false, 'clientLocation':'', 'birthdate':null, 'duties':'','clientContactType':null,'mobilePhone':null};
        component.set("v.isPrimary", false);
        /*if(component.get("v.isSubmissionDocument") == true){
            clinetContactWrapper['isPrimary'] = true;
            component.set("v.isPrimary", true);
        }*/
        component.set("v.oClinetContactWrapper",clinetContactWrapper);
        component.set("v.isShowAddModal", false);
        component.set("v.mapClientLocationPicklistValues", []);
        component.set("v.wcRateWhereClause", '');
        component.set("v.isIncluded", false);
        component.set("v.mapType", []);
    },
    
    handleSubmitAddClinetContact : function(component, event, helper) {
		let isPrimary = component.get("v.isPrimary");
        let isIncluded = component.get("v.isIncluded");
        
        var requiredFieldAuraId = 'clientContactType,firstname,lastname,title';
        
        if(isIncluded){
            requiredFieldAuraId += ',ownership,state,payroll,location';
        }
        
        let isValidForm = helper.validateForm(component, requiredFieldAuraId);
        
        if(isValidForm){
            var oClinetContactWrapper = component.get("v.oClinetContactWrapper");
            if(isIncluded && (oClinetContactWrapper.selectedStampCode == null || oClinetContactWrapper.selectedStampCode == undefined)){
                isValidForm = false;
            }
            if(isValidForm){
                helper.submitClientLocationRecords(component, event); 
            }else{
                helper.doShowToast(component, 'Error', 'Please select valid WC Code and try again', 'error');
            }
        }else{
            helper.doShowToast(component, 'Error', 'Please fill all required fields and try again', 'error');
        }
        
    },
    
    handleStateChange: function(component, event, helper) {
		let stateId = component.find("state").get("v.value");
        var whereClause = ' State__c = \''+stateId+'\'';
        component.set("v.wcRateWhereClause", whereClause);
        component.set("v.mapClientLocationPicklistValues", []);
        if(stateId != null && stateId != '' && stateId != undefined){
            helper.fetchClientLocationRecords(component,event,stateId);
        }
    },
    
    handleLocationChange : function(component, event, helper) {
        let locationId = component.find("location").get("v.value");
        let oClinetContactWrapper = component.get("v.oClinetContactWrapper");
        if(locationId != null && locationId != undefined){
            helper.fetchClientLocationValue(component, event, locationId);
        }else{
            oClinetContactWrapper.clientLocation = null;
            component.set("v.oClinetContactWrapper", oClinetContactWrapper);
        }
    },
    
    handleNewLocation: function(component, event, helper) {
        component.set('v.isTerritorialRating', false);
        
        let statename = '';
        let stateId = component.find("state").get("v.value");
        let stateMap = component.get('v.mapStatePicklistValues');
        for(var i = 0; i < stateMap.length; i++){
            if(stateMap[i].key == stateId){
                statename = stateMap[i].value;
            }
        }
        if(statename === 'California - CA'){
            component.set('v.isTerritorialRating', true);
        }
        component.set("v.isNewClientLocation", false);
        component.set("v.isEdit", false);
        component.set("v.oClientLocation", null);
        var clinetContactWrapper = component.get("v.oClinetContactWrapper");
        clinetContactWrapper.selectedClientLocation = null;
        component.set("v.oClinetContactWrapper", clinetContactWrapper);
        if(stateId != null && stateId != '' && stateId != undefined){
            component.set("v.isShowAddModal", false);
            helper.fetchNewClientLocation(component, event, stateId);
        }else{
            helper.doShowToast(component, 'Error', 'Please select state to create new Location', 'error');
        }
    },
    
    handleCloseNewLocationModal: function(component, event, helper) {
        component.set("v.isNewClientLocation", false);
        component.set("v.oClientLocation", null);
        component.set('v.isTerritorialRating', false);
        var isRecordEdit = component.get("v.isRecordEdit");
        if(isRecordEdit){
            component.set("v.isEdit", true);
        }else{
            component.set("v.isShowAddModal", true);
        }
    },
    
    handleSubmitNewLocationModal: function(component, event, helper) {
        let isValidatedForm = helper.validateForm(component, 'street,city,Zip_Code');
        
        var message = 'Please fill all required fields and try again';
        
        let isTerritorialRating = component.get("v.isTerritorialRating");
        
        if(isValidatedForm && isTerritorialRating){
            var postalCode = component.get("v.oClientLocation.Postal_Code__c");
            if(postalCode == null || postalCode == undefined){
                isValidatedForm = false;
                message = 'Please select valid Postal Code and try again';
            }
        }
        
        if(isValidatedForm){
        	helper.createLocationHelperHelper(component, event);      
        }else{
            helper.doShowToast(component, 'Error', message, 'error');
        }
    },
    
    handlePrimaryIncludeChange : function(component, event, helper) {
        var clinetContactWrapper = component.get("v.oClinetContactWrapper");
        //clinetContactWrapper.ownership = null;
        //clinetContactWrapper.selectedState = null;
        //clinetContactWrapper.payroll = null;
        //clinetContactWrapper.selectedClientLocation = null;
        clinetContactWrapper.selectedStampCode = null;
        clinetContactWrapper.primaryContactLastName = '';
        clinetContactWrapper.primaryContactFirstName = '';
        clinetContactWrapper.primaryContactPhone = '';
        clinetContactWrapper.primaryContactTitle = '';
        clinetContactWrapper.primaryContactEmail = '';
        clinetContactWrapper.clientLocation = null;
        component.set("v.oClinetContactWrapper", clinetContactWrapper);
    },
    
     handleRowAction: function (component, event, helper) {
        component.set("v.isRecordEdit", false);
        var action = event.getParam('action');
        var row = event.getParam('row');
        switch (action.name) {
            case 'edit':
                component.set("v.selectedRecordName", row.Name);
                component.set("v.selectedRecordId", row.Id);
                component.set("v.isEdit", true);
                component.set("v.isRecordEdit", true);
                helper.fatchClientContactEditRecord(component, event, helper);
                helper.fetchClientContactType(component, event);
              	let stateId = row.State__c;
                if(stateId != null && stateId != '' && stateId != undefined){
                    var whereClause = ' State__c = \''+stateId+'\'';
                    component.set("v.wcRateWhereClause", whereClause);
                    helper.fetchClientLocationRecords(component,event,stateId);
                }
                //component.set("v.oClientContact", row);
                break;
                
           case 'view':
                component.set("v.selectedRecordId", row.Id);
                component.set("v.selectedRecordName", row.Name);
                component.set("v.isView", true);
                component.set("v.oClientContact", row);
                break;
                
            case 'delete':
                helper.deleteClinetContactRecords(component, event, row.Id);
                break;
                
        }
    },
    
    handleCancelEditModal : function (component, event, helper) {
        component.set("v.isEdit", false);
        component.set("v.selectedRecordId", null);
        component.set("v.selectedRecordName", null);
        component.set("v.oClientContact", null);
        component.set("v.isRecordEdit", false);
    },
    
    handleCancelViewModal : function (component, event, helper) {
        component.set("v.isView", false);
        component.set("v.selectedRecordId", null);
        component.set("v.selectedRecordName", null);
        component.set("v.oClientContact", null);
    },
    
    handleSaveEditModal: function (component, event, helper) {
        helper.showSpinner(component);
        component.find("editForm").submit();
    },
    
    handleSuccessSaveEditModal: function (component, event, helper) {
        helper.doShowToast(component, 'Success', 'Record updated successfully', 'success');
        helper.handleInitlization(component, event);
        component.set("v.isEdit", false);
        component.set("v.selectedRecordId", null);
        component.set("v.selectedRecordName", null);
        component.set("v.oClientContact", null);
        component.set("v.isRecordEdit", false);
        helper.hideSpinner(component);
    },
    
    handleErrorSaveEditModal: function (component, event, helper) {
		var errorMessage = event.getParam("message");
        helper.doShowToast(component, 'Error', errorMessage, 'error');
        helper.hideSpinner(component);
    },
    
    handleClientContactTypeChange : function (component, event, helper) {
        let clientContactType = component.find("clientContactType").get("v.value");
        component.set("v.isShowMobilePhone", false);
        if(clientContactType != null && clientContactType != undefined 
           	&& clientContactType != '' && (clientContactType == 'Inspection' || clientContactType == 'Accting Record' || clientContactType == 'Claims Info')){
            component.find("title").set("v.value", clientContactType);
            component.set("v.isShowMobilePhone", true);
        }else{
            component.find("title").set("v.value", null);
        }
    },
    
    
})