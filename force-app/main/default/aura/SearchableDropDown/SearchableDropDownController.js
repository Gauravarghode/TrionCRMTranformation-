({
    doInit : function(component, event, helper) {
        var resultListDisplay = component.get("v.resultListDisplay");
        var selectedValue = component.get("v.selectedValue");
        if(resultListDisplay != null && resultListDisplay != undefined && selectedValue != null && selectedValue != '' && selectedValue != undefined){
            for(let i=0; i<resultListDisplay.length;i++){
                if(resultListDisplay[i].key == selectedValue){
                    console.log("***selectedValue***match***key***"+resultListDisplay[i].key+'***value***'+resultListDisplay[i].value);
                    helper.populateField(component,resultListDisplay[i].value,resultListDisplay[i].key);
                }
            }
        }    
        component.set("v.matchedListDisplay", resultListDisplay);
    },
    selectItem : function(component, event, helper) {
        var index = event.currentTarget.dataset.index;
        var matchedListDisplay = component.get("v.matchedListDisplay");
        if(matchedListDisplay != null && matchedListDisplay != undefined){
            component.set("v.selectedValue", matchedListDisplay[index].key);
            helper.populateField(component,matchedListDisplay[index].value,matchedListDisplay[index].key);
        }
	},
    toggleMenu : function(component, event, helper) {
		helper.hlpToggleMenu(component);
	},
    checkValidity : function(component, event, helper) {
		helper.hlpCheckValidity(component);
	},
    performLookup : function(component, event, helper) {
		helper.hlpPerformLookup(component);
    },
    clearField : function(component, event, helper){
        helper.clearField(component,true);
        helper.toggleIcons(component,true);
    },
})