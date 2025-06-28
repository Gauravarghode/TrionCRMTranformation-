({
    getStatusPicklistValues : function(component, event) {
        this.showSpinner(component);
        var action = component.get("c.getPicklistValues");
        action.setParams({
            objectName:"Policy__c",
            fieldName:"Status__c"
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                 var statusMap = [];
                if(result != null && result != undefined){
                    for(var key in result){
                        statusMap.push({key:key , value: result[key]});
                    }
                }
                component.set("v.mapStatusPicklistValues",statusMap);
                this.getCarrierOptions(component, event);
            } else if(component.isValid() && state === 'ERROR') {
                var errors = response.getError();
                this.handleErrors(component, errors);
            }
            this.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },
    
    getCarrierOptions : function(component, event) {
        this.showSpinner(component);
        var action = component.get("c.getCarrierPicklistValues");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                 var carrierMap = [];
                if(result != null && result != undefined){
                    for(var key in result){
                        carrierMap.push({key:key , value: result[key]});
                    }
                }
                component.set("v.mapCarrierPicklistValues",carrierMap);
                this.getStateOptions(component, event);
            } else if(component.isValid() && state === 'ERROR') {
                var errors = response.getError();
                this.handleErrors(component, errors);
            }
            this.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },
    
    getStateOptions : function(component, event) {
        this.showSpinner(component);
        var action = component.get("c.getStatePicklistValues");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                 var stateMap = [];
                if(result != null && result != undefined){
                    for(var key in result){
                        stateMap.push({key:key , value: result[key]});
                    }
                }
                component.set("v.mapStatePicklistValues",stateMap);
            } else if(component.isValid() && state === 'ERROR') {
                var errors = response.getError();
                this.handleErrors(component, errors);
            }
            this.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },
    
    fetchCarrierWCRates : function(component, event, isDelete) {
        this.showSpinner(component);
        var lstFilters = component.get("v.lstFilters");
        
        var action = component.get("c.getCarrierWCRates");
        action.setParams({
            filterJSON:JSON.stringify(lstFilters)
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                if(result != null && result != undefined){
                    result.forEach(function(record){
                        if(record.WC_Code__c != null && record.WC_Code__c != undefined){
                            record.CompCodeName = record.WC_Code__r.Name;
                        }
                        if(record.Carrier__c != null && record.Carrier__c != undefined){
                            record.CarrierName = record.Carrier__r.Name;
                        }
                        if(record.State__c != null && record.State__c != undefined){
                            record.StateName = record.State__r.Name;
                        }
                    });
                }
                
                component.set("v.filteredData",result);
                if(!isDelete){
                    component.set("v.isShowSearchFilter", false);
                	component.set("v.isShowModal", false);
                }
                component.set("v.sortedBy", "CompCodeName");
                component.set("v.sortedDirection", "asc"); 
                this.sortData(component, "CompCodeName", "asc");
            } else if(component.isValid() && state === 'ERROR') {
                var errors = response.getError();
                this.handleErrors(component, errors);
            }
            this.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },
    
    saveCarrierWCRates : function(component, event, draftValues) {
        this.showSpinner(component);
        var action = component.get("c.updateCarrierWCRates");
        action.setParams({
            lstCarrierWCRates:draftValues
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                this.fetchCarrierWCRates(component, event, false);
                component.set("v.draftValues", []);
            } else if(component.isValid() && state === 'ERROR') {
                var errors = response.getError();
                this.handleErrors(component, errors);
            }
            this.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },
    
    createDataTableHeaders : function(component, isEditable){
        var columns = [];
        columns.push({label: 'Comp Code', fieldName: 'CompCodeName', type: 'text', sortable:true, editable: false });
        columns.push({label: 'Status', fieldName: 'Status__c', type: 'text', sortable:true, editable: false });
        columns.push({label: 'Description', fieldName: 'Description__c', type: 'text', sortable:true, editable: false });
        columns.push({label: 'Carrier', fieldName: 'CarrierName', type: 'text', sortable:true, editable: false });
        columns.push({label: 'Rate', fieldName: 'Rate__c', type: 'number', sortable:true, editable: false, cellAttributes: { alignment: 'left' }});
        columns.push({label: 'Modifier', fieldName: 'Modifier__c', type: 'number', sortable:true, editable: isEditable, cellAttributes: { alignment: 'left' }});
        columns.push({label: 'State Assessment Fee', fieldName: 'State_Assessment_Fee__c', type: 'number', sortable:true, editable: false, cellAttributes: { alignment: 'left' }});
        columns.push({label: 'Trion Bill Rate', fieldName: 'Trion_Bill_Rate__c', type: 'number', sortable:true, editable: false, cellAttributes: { alignment: 'left' }});
        columns.push({label: 'Trion Bill Rate Exc. Assessment Fees', fieldName: 'Trion_Bill_Rate_Exc_Assessment_Fees__c', type: 'number', sortable:true, editable: false, cellAttributes: { alignment: 'left' }});
        columns.push({label: 'State', fieldName: 'StateName', type: 'text', sortable:true, editable: false });
        columns.push({label: 'Effective Date', fieldName: 'Effective_Date__c', type: 'date', sortable:true, editable: false, typeAttributes:{year:"numeric",month:"numeric",day:"numeric",timeZone:"UTC"} });
        component.set('v.columns', columns);
    },
    
    showSpinner : function(component) {
        let isShowModal = component.get("v.isShowModal");
        if(isShowModal){
            var spinner = component.find("modalspinner");
            $A.util.removeClass(spinner, "slds-hide");
        }else{
            var spinner = component.find("spinner");
            $A.util.removeClass(spinner, "slds-hide");
        }
    },
    
    hideSpinner : function(component) {
        let isShowModal = component.get("v.isShowModal");
        if(isShowModal){
            var spinner = component.find("modalspinner");
            $A.util.addClass(spinner, "slds-hide");
        }else{
            var spinner = component.find("spinner");
            $A.util.addClass(spinner, "slds-hide");
        }
    },
    
    doShowToast: function(component, title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        if(toastEvent != undefined){
            toastEvent.setParams({
                title: title,
                message: message,
                type: type
            });
            toastEvent.fire();
        }
    },
    
    handleErrors: function(component, errors) {
        var eCount;
        for(eCount in errors){
            var error = errors[eCount];
            if (error.pageErrors != undefined) {
                var i;
                for (i in error.pageErrors) {
                    this.doShowToast(component, error.pageErrors[i].statusCode, error.pageErrors[i].message, 'warning');
                }
            } else {
                var i;
                var msgArray = (error.message).split('|');
                for (i in msgArray) {
                    this.doShowToast(component, 'Error', msgArray[i], 'error');
                }   
            }
            
            if (error.fieldErrors != undefined) {
                var fieldErrors = error.fieldErrors;
                var fld;
                for (fld in fieldErrors) {
                    if (fieldErrors.hasOwnProperty(fld)) { 
                        var fldErrors = fieldErrors[fld];
                        var i;
                        for (i in fldErrors) {
                            this.doShowToast(component, fldErrors[i].statusCode, fldErrors[i].message+' ['+fld+']', 'error');
                        }
                    }
                }
            } else {
                var i;
                var msgArray = (error.message).split('|');
                for (i in msgArray) {
                    this.doShowToast(component, 'Error', msgArray[i], 'error');
                }   
            }
        }
    },
    
    sortData: function (component, fieldName, sortDirection) {
        var filteredData = component.get("v.filteredData");
        var reverse = sortDirection !== 'asc';
        //sorts the rows based on the column header that's clicked
        filteredData.sort(this.sortBy(fieldName, reverse))
        component.set("v.filteredData", filteredData);
    },
    
    sortBy: function (field, reverse, primer) {
        var key = primer ?
            function(x) {return primer(x[field])} :
            function(x) {return x[field]};
        //checks if the two rows should switch places
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
    },
})