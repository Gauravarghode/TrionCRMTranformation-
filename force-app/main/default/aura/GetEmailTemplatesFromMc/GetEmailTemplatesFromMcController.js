({

  // This is the onInit function of the component.
  // It is called when the component is first loaded.
  onInit: function(component, event, helper) {

    // Get the action called "createEmailTemplatesAndCtas".
    let action = component.get("c.createEmailTemplatesAndCtas");

    // Set a callback function for the action.
    // The callback function will be called when the action is completed.
    action.setCallback(this, function(response) {

      // Get the state of the response.
      let state = response.getState();

      // If the state is "SUCCESS", close the quick action and refresh the view.
      if (state === "SUCCESS") {
        $A.get("e.force:closeQuickAction").fire();
        $A.get('e.force:refreshView').fire();
      } else {

        // Otherwise, show a toast with an error message.
        let showToast = $A.get("e.force:showToast");
        showToast.setParams({
          title: 'Error!',
          message: 'Sync Failed due to an error!!',
          type: 'error',
          mode: 'sticky',
          message: 'Some error occured'
        });
        showToast.fire();
      }
    });

    // Enqueue the action.
    $A.enqueueAction(action);
  }
})