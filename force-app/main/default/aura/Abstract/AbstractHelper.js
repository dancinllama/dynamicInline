({
	handleAction : function(component, actionParams, actionName, callback, errorCallback){
		var action = component.get(actionName);
		action.setParams(actionParams);
		var self = this;
		action.setCallback(this,function(a){
			try{
				if(a.getState() !== 'SUCCESS'){
					throw {'message' : 'An undetermined error occurred with the Apex call.'};
				}

				var result = a.getReturnValue();

				//Some error likely inside of the Apex code occurred.
				if(result.state !== 'SUCCESS'){
					//Try to get the error message from the lightningdmlerror object
					var errorEncountered = result.errors[0].message;
					throw {
						'message' : 'An error occurred in the apex call',
						'errors' : result.errors
					};
				}

				var returnValue = undefined;
				if(!$A.util.isEmpty(result.jsonResponse)){
					//Will throw a JSON exception if the result cannot be parsed.
					returnValue = JSON.parse(result.jsonResponse);
				}

				//var returnValue = JSON.parse(result.jsonResponse);

				//SUCCESS!!! USe the parameterized callback for additional / specific logic.
				var concreteComponent = component.getConcreteComponent();
				callback(concreteComponent,returnValue, self);
				/*var concreteCallback = concreteComponent.getDef().getHelper().handleActionCallback(
					concreteComponent,
					returnValue
				);*/
			}catch(ex){
				//Call the implementing method's error callback if provided.
				if(!$A.util.isEmpty(errorCallback)){
					var concreteComponent = component.getConcreteComponent();
					errorCallback(concreteComponent,ex,self);
					return;
				}

				//Handle any exceptions encountered in the callback
				var errorTitle = 'An error occurred with the action';

				if(!$A.util.isEmpty(ex.errors)){
					for(var i=0; i < ex.errors.length; i++){
						self.handleError(component, errorTitle, ex.errors[i].message);
					}
				}else{
					//Handle any exceptions encountered in the callback
					var errorMessage = ex.message;

					//Add a detailed description of the error if one is found.
					if(!$A.util.isEmpty(ex.extendedMessage)){
						errorMessage = errorMessage + ' ' + ex.extendedMessage;
					}

					self.handleError(component, errorTitle, errorMessage);
				}
			}
		});

		$A.enqueueAction(action);
	},
	handleError : function(component, errorTitle, errorMessage){
		this.showToast('error', errorTitle, errorMessage);
	},
	showToast : function(type, title, message){
		var toastEvent = $A.get("e.force:showToast");
		toastEvent.setParams({
			"title" : title,
			"type" : type,
			"message" : message,
			"duration" : 10000
		});
		toastEvent.fire();
	}
})