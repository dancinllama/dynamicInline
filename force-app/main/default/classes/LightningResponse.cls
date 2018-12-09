/**
 * LightningResponse
 * @description A wrapper class for any Apex, DML, etc that is called through Lightning Components.
 * Used for properly reporting success and error conditions (typically errors will result in ISE / Gacks, which are not helpful.)
 * @author  James Loghry 
 * @serialDate  11/22/2016
 */
public class LightningResponse {

    @AuraEnabled public String jsonResponse {get;set;}
    @AuraEnabled public List<LightningError> errors {get;set;}
    @AuraEnabled public String state {get;set;}

    public LightningResponse() {
        this.errors = new List<LightningError>();
        this.state = 'SUCCESS';
    }

    public LightningResponse(Exception e){
        this();
        this.state = 'ERROR';
        this.errors.add(new LightningError(e.getMessage()));
        System.debug('Exception:  ' + e.getMessage());
        System.debug('Exception stack trace: ' + e.getStackTraceString());           
    }

    
    public class LightningError {
    	@AuraEnabled public List<String> fields {get;set;}
    	@AuraEnabled public String message {get;set;}
    	@AuraEnabled public StatusCode statusCode {get;set;}

    	//Default constructor
    	public LightningError(){
    		this.fields = new List<String>();
    	}

    	public LightningError(Database.Error err){
    		this();
    		this.fields = err.getFields();
    		this.message = err.getMessage();
    		this.statusCode = err.getStatusCode();
    	}

    	public LightningError(String message){
    		this();
    		this.message = message;
    	}
	}
}