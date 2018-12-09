({
	handleSubmit : function(component, event) {
        event.preventDefault();
        var parentField = component.get("v.field");
        var newParentId = event.getParam("fields")[parentField];
        var evt = $A.get('e.c:RelatedListEditLookupEvent');
        evt.setParams({
            recordId : component.get("v.recordId")
            ,applyAll : component.get("v.applyAll")
            ,relationshipName : parentField
            ,newParentId : newParentId
        });
        evt.fire();
        component.set("v.isOpen", false); 
        component.find("popuplib").notifyClose();
    }
})