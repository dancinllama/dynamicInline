({
	doInit : function(component){
		this.handleAction(
			component,
			{
				recordId : component.get("v.recordId")
                ,relationshipApiName : component.get("v.relationshipApiName")
                ,fieldSetName : component.get("v.fieldSetName")
			},
			"c.queryRelatedRecords",
			this.handleCallback
		);
	},
    handleCallback : function(component, returnValue, ctx){
        var records = returnValue.records;
        var cols = returnValue.fields;
        
        //Do some JavaScript transformations to handle lookup / master detail relationships
        //That come back from the describe call(s) and query.
        if(!$A.util.isEmpty(records)){
            if(!$A.util.isEmpty(cols)){
        		for(var i=0; i < cols.length; i++){
                    var relationship = cols[i].relationship;
                    if(!$A.util.isEmpty(relationship)){
                        for(var j = 0; j < records.length; j++){
                            var record = records[j];
                            var parent = record[relationship];
                            if(!$A.util.isEmpty(parent)){
                                var fieldName = relationship + '.Name';
                                record[fieldName] = parent.Name;
                            }
                        }
                    }
                }
            }    
        }
        
        component.set("v.childSObjectName", returnValue.childSObjectName);
        component.set("v.childSObjectLabel", returnValue.childSObjectLabel);
        component.set("v.columns", cols);
        component.set("v.records", records);
    },
    handleRowAction : function(component, event){
        debugger;
        var action = event.getParam('action');
        var row = event.getParam('row');
        if(action.name.startsWith('edit_lookup')){
            var relationshipName = action.name.replace('edit_lookup_','');
            this.handleLookupModal(component, row.Id, relationshipName);   
        }
        
        if(action.name == 'addrecord'){
            component.set("v.displayAddRecord",true);
        }
    },
    handleLookupModal : function(component, recordId, relationshipName) {
        debugger;
        
        // open modal 
        var modalBody;
        
        $A.createComponent(
            "c:RelatedListEditLookup",
            {
                "recordId": recordId,
                "sObjectName" : component.get('v.childSObjectName'),
                "field" : relationshipName,
                "showApplyAll": true
            },
            function(content, status) {
                if (status === "SUCCESS") {
                    modalBody = content;
                    component.find('popuplib').showCustomModal({
                        body: modalBody, 
                        showCloseButton: true
                     })
                 } 
            }
        );
    },
    handleEditLookup : function(component, event){
        var parms = event.getParams();
        
        var records = component.get("v.records");
        
        var lookupUpdateMap = {};
        
        if(!$A.util.isEmpty(records)){
            for(var i = 0; i < records.length; i++){
                if(records[i].Id == parms.recordId){
                    lookupUpdateMap[parms.recordId] = {};
                    lookupUpdateMap[parms.recordId].recordId =parms.recordId;
                    lookupUpdateMap[parms.recordId][parms.relationshipName]=parms.newParentId;
                }
            }
        }
        
        if(parms.applyAll){
            var selectedRows = component.get("v.selectedRows");
            debugger;
        }
    },
    handleDeleteRecords : function(component){
    	var recordString = this.getSelectedRecords(component, true);
        this.handleAction(
			component,
			{
				records : recordString
			},
			"c.deleteRecords",
			this.handleDeleteCallback
		);
    },
    handleCloneRecords : function(component){
    	var recordString = this.getSelectedRecords(component, false);
        this.handleAction(
			component,
			{
				recordString : recordString
			},
			"c.cloneRecords",
			this.handleCloneCallback
		);
    },
    getRecords : function(component, keepId, rows){
        var result = [];
        
        var fieldsToUpdate = [];
        
        var fields = component.get("v.columns");
        if(!$A.util.isEmpty(fields)){
            for(var i=0; i < fields.length; i++){
            	var field = fields[i];
                if($A.util.isEmpty(field.relationship)){
                    fieldsToUpdate.push(field.fieldName);
                }else{
                    fieldsToUpdate.push(field.relationshipIdField);
                }
            }
        }
        
        if(keepId){
            fieldsToUpdate.push('Id');
        }
      
        
        var records = [];
        if(!$A.util.isEmpty(rows)){
            for(var i=0; i < rows.length; i++){
                var record = {attributes:{type:component.get("v.childSObjectName")}};
                var selectedRow = rows[i];
                for(var j=0; j < fieldsToUpdate.length; j++){
                    var field = fieldsToUpdate[j];
                    record[field] = selectedRow[field];
                }
                records.push(record);
            }
        }
        return JSON.stringify(records);
    },
    getSelectedRecords : function(component, keepId){
        return getRecords(component, keepId, component.get("v.selectedRows"));
    },
    handleCloneCallback : function(component, returnValue, ctx){
       helper.hideCloneConfirm(component);
       helper.doInit(component);
    },
    handleDeleteCallback : function(component, returnValue, ctx){
       helper.hideDeleteConfirm(component);
       helper.doInit(component);
    },
    hideDeleteConfirm : function(component){
        component.set("v.displayDeleteConfirm",false);
    },
    hideCloneConfirm : function(component){
        component.set("v.displayCloneConfirm",false);
    },
    handleSave : function(component, event){
        var recordString = this.getRecords(component, true, event.getParam("draftValues"));
        this.handleAction(
			component,
			{
				recordString : recordString
			},
			"c.updateRecords",
			this.handleUpdateCallback
		);
    },
    handleUpdateCallback : function(component, returnValue, ctx){
       ctx.doInit(component);
    }
})