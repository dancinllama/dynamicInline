({
	handleSubmit : function(component, event, helper) {
        helper.handleSubmit(component, event);
    },
   	handleCancel : function(component) {
       component.set("v.isOpen", false);
       component.find("popuplib").notifyClose();
    }
})