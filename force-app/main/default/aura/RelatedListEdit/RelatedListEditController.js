({
	doInit : function(component, event, helper) {
        component.set("v.errors",[]);
        component.set("v.draftValues",[]);
        component.set("v.selectedRows",[]);
        helper.doInit(component);
    },
    handleSave : function(component, event, helper){
        helper.handleSave(component, event);
    },
    handleRowAction : function(component, event, helper){
        helper.handleRowAction(component,event);
    },
    handleCellChange : function(component, event, helper){
        debugger;
    },
    handleHeaderAction : function(component, event, helper){
        debugger;
    },
    handleCancel : function(component, event, helper){
        debugger;
    },
    handleSort : function(component, event, helper){
        debugger;
    },
    handleEditLookup : function(component, event, helper){
        helper.handleEditLookup(component, event);
    },
    handleAddRecordSubmit : function(component, event, helper){
        component.set("v.displayAddRecord",false);
        helper.doInit(component);
    },
    showAddRecord : function(component){
        component.set("v.displayAddRecord",true);
    },
    hideAddRecord : function(component){
        component.set("v.displayAddRecord",false);
    },
    showDeleteRecord : function(component){
        component.set("v.displayDeleteConfirm",true);
    },
    hideDeleteConfirm : function(component, event, helper){
        helper.hideDeleteConfirm(component);
    },
    showCloneRecord : function(component){
        component.set("v.displayCloneConfirm",true);
    },
    hideCloneConfirm : function(component, event, helper){
        helper.hideCloneConfirm(component);
    },
    handleCloneRecords : function(component, event, helper){
        helper.handleCloneRecords(component);
    },
    handleDeleteRecords : function(component, event, helper){      
        helper.handleDeleteRecords(component);
    },
    handleRowSelection : function(component, event){
        component.set("v.selectedRows",event.getParam("selectedRows"));
    }
})