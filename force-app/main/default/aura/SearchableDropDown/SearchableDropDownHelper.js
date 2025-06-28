({
	hlpToggleMenu : function(component){
        this.showDropDown(component,true);
    },
    showDropDown : function(component,toggle){
        try{
            var dropDown = component.find("dropDown");
            if(toggle){
                $A.util.toggleClass(dropDown, "slds-is-open");
            }
            else{
                $A.util.addClass(dropDown, "slds-is-open");
            }
            this.toggleIcons(component,true);
            // $A.util.addClass(component.find('diplayedul').get('v.body')[0].elements[0],'hlight');
        }
        catch(e){
            this.showError(component, e.message);
        }
    },
    showError : function(component, message){
        try{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type": "Error",
                "mode": "sticky",
                "message": message
            });
            toastEvent.fire(); 
        }
        catch(e){
            this.showError(component, e.message);
        }   
    },
    toggleIcons : function(component,show){
        if(show){
            $A.util.removeClass(component.find('dropdownicon'),'hide');
            $A.util.removeClass(component.find('search_icon'),'hide');
        }
        else{
            $A.util.addClass(component.find('dropdownicon'),'hide');
            $A.util.addClass(component.find('search_icon'),'hide');
        }
    },

    hlpCheckValidity : function(component) {
        try{
            var myinput = document.getElementById(component.getGlobalId() + "_myinput").value;
            var required = component.get("v.required");
            var dropDown = component.find("dropDown");
            if(required && (!myinput || myinput == '')){
                $A.util.addClass(dropDown, 'slds-has-error');
                component.set("v.valid", false);
            }
            else{
                $A.util.removeClass(dropDown, 'slds-has-error');
                component.set("v.valid", true);
            }
        }
        catch(e){
            this.showError(component, e.message);
        }
    },

    hlpPerformLookup : function(component) {
        try{
            // we need to reset selected value and and name because the user is typing again, but since
            // selectedName is tied to the value of the input, we should save what the user has typed and restore
            // it after we change selectedName
            var searchString = document.getElementById(component.getGlobalId() + "_myinput").value;
            console.log("***searchString***"+searchString);
            var resultListDisplay = component.get("v.resultListDisplay");
            var matchListDisplay = [];
            if(resultListDisplay != null && resultListDisplay != undefined){
                for(let i=0; i<resultListDisplay.length;i++){
                    if(searchString != null && searchString != '' && searchString != undefined){
                        if(resultListDisplay[i].value.toLowerCase().indexOf(searchString.toLowerCase()) > -1){
                            matchListDisplay.push({key:resultListDisplay[i].key , value: resultListDisplay[i].value});
                        }
                    }else{
                        matchListDisplay.push({key:resultListDisplay[i].key , value: resultListDisplay[i].value});
                    }
                }
            }
            component.set("v.matchedListDisplay", matchListDisplay);
        }
        catch(e){
            this.showError(component, e.message);
        }
    },
    toggleIcons : function(component,show){
        if(show){
            $A.util.removeClass(component.find('dropdownicon'),'hide');
        }
        else{
            $A.util.addClass(component.find('dropdownicon'),'hide');
        }
    },
    clearField : function(component, fireEvent){
        try{
            component.set('v.selectedName',null);
            component.set('v.selectedValue',null);
            component.find('pillsdiv').set('v.body',null);
            $A.util.removeClass(component.find("inputField"),'hide');
            $A.util.addClass(component.find('removebtn'),'hide');
            document.getElementById(component.getGlobalId() + "_myinput").value = '';
            var resultListDisplay = component.get("v.resultListDisplay");
            component.set("v.matchedListDisplay", resultListDisplay);
        }
        catch(e){
            this.showError(component, e.message);
        }
    },
    hideDropDown : function(component){
        try{
            var dropDown = component.find("dropDown");
            $A.util.removeClass(dropDown, "slds-is-open");
        }
        catch(e){
            this.showError(component, e.message);
        }
    },
    
    populateField : function(component,name,val){
            try{
                this.showSpinner(component);
                var f = component.find('inputField')
                if(!component.get('v.pills')){
                    setTimeout(
                        $A.getCallback(function() {
                            document.getElementById(component.getGlobalId() + "_myinput").value = name;
                            $A.util.removeClass(component.find('removebtn'),'hide');
                            var spinner = component.find("spinner");
                            $A.util.addClass(spinner, "slds-hide");
                        }), 1000); 
                }
                else{
                    $A.util.addClass(f,'hide');
                    this.toggleIcons(component,false);
                    var l = name;
                    var a = component.getReference('c.clearField');
                    var i = component.get('v.svg')
                    $A.createComponent('c:CmpPills',
                                       {
                                           'label' : l ,
                                           'onremove' : a,
                                           'iconName': i
                                       },
                                       function(nc){
                                           component.find('pillsdiv').set('v.body',nc);
                                       }
                                      );
                    var spinner = component.find("spinner");
                    $A.util.addClass(spinner, "slds-hide");
                }
                this.hideDropDown(component);
            }
            catch(e){
                this.showError(component, e.message);
            }
        },

        showSpinner : function(component) {
            var spinner = component.find("spinner");
            $A.util.removeClass(spinner, "slds-hide");
        },
        
        hideSpinner : function(component) {
            var spinner = component.find("spinner");
            $A.util.addClass(spinner, "slds-hide");
        },
})