public class RelatedListEditCtrl {
    
    public static final Map<Schema.DisplayType,String> FIELD_SET_TO_DATA_TABLE_MAP = new Map<Schema.DisplayType,String>{
        Schema.DisplayType.Date => 'date',
        Schema.DisplayType.DateTime => 'date',
        Schema.DisplayType.Double => 'number',
        Schema.DisplayType.Integer => 'number',
        Schema.DisplayType.Email => 'email',
        Schema.DisplayType.Long => 'number',
       	Schema.DisplayType.Percent => 'percent',
        Schema.DisplayType.Phone => 'phone',
        Schema.DisplayType.Time => 'date',
        Schema.DisplayType.URL => 'url'
    };

    @AuraEnabled
    public static LightningResponse queryRelatedRecords(Id recordId, String relationshipApiName, String fieldSetName){
        LightningResponse resp = new LightningResponse();
        
        try{
            Schema.sObjectType sObjectType = recordId.getSobjectType();
            Schema.sObjectType childsObjectType = null;
            String parentField = null;
            String relatedApiName = null;
            
            Schema.ChildRelationship rel = getChildRelationship(sObjectType,relationshipApiName);
            parentField = rel.getField().getDescribe().getName();
            childsObjectType = rel.getChildsObject();
            Schema.DescribeSObjectResult dsr = childsObjectType.getDescribe();
            relatedApiName = dsr.getName();
            
            Map<String, Schema.SObjectField> fieldMap = dsr.fields.getMap();
            Schema.fieldSet fieldSet = dsr.fieldSets.getMap().get(fieldSetName);
            List<Schema.FieldSetMember> fsmList = fieldSet.getFields();
            
            QueryResponse qr = new QueryResponse();
            qr.childSObjectName = relatedApiName;
            qr.childSObjectLabel = dsr.getLabel();
            qr.fields = new List<Field>();
            
            Set<String> fieldsForQuerying = new Set<String>();
            for(Schema.FieldSetMember fsm : fsmList){
                Field f = new Field(fsm,fieldMap);
                qr.fields.add(f);
                fieldsForQuerying.add(f.fieldName);
                if(!String.isEmpty(f.relationshipIdField)){
                    fieldsForQuerying.add(f.relationshipIdField);
                }
            }
            String fieldString = ',' + String.join(new List<String>(fieldsForQuerying),',');
            
            String query = 'Select Id' + fieldString + ' From ' + relatedApiName + ' Where ' + parentField + ' = :recordId';
            System.debug('Query: ' + query);
            qr.records = Database.query(query);
            resp.jsonResponse = JSON.serialize(qr);
        }catch(Exception e){
            resp = new LightningResponse(e);
        }
        return resp;
    }
    
    @AuraEnabled
    public static LightningResponse updateRecords(String recordString){
        LightningResponse resp = new LightningResponse();
        
        try{
            List<sObject> records = (List<sObject>)JSON.deserialize(recordString,List<sObject>.class);
            update records;
        }catch(Exception e){
            resp = new LightningResponse(e);
        }
        return resp;
    }
    
    @AuraEnabled
    public static LightningResponse deleteRecords(String recordString){
        LightningResponse resp = new LightningResponse();
        
        try{
            List<sObject> recordsToDelete = (List<sObject>)JSON.deserialize(recordString,List<sObject>.class);
            delete recordsToDelete;
        }catch(Exception e){
            resp = new LightningResponse(e);
        }
        return resp;
    }
    
    @AuraEnabled
    public static LightningResponse cloneRecords(String recordString){
        LightningResponse resp = new LightningResponse();
        
        try{
            List<sObject> recordsToClone = (List<sObject>)JSON.deserialize(recordString,List<sObject>.class);
            System.debug('JWL: recordsToClone: ' + recordsToClone);
            insert recordsToClone;
        }catch(Exception e){
            resp = new LightningResponse(e);
        }
        return resp;
    }
    
    private static Schema.ChildRelationship getChildRelationship(Schema.sObjectType sot, String apiName){
        for(Schema.ChildRelationship rel: sot.getDescribe().getChildRelationships()){
            if(rel.getRelationshipName() == apiName){
                return rel;
            }
        }
        return null;
    }
        
        
    
    public class QueryResponse{
        @AuraEnabled public List<Field> fields {get; set;}
        @AuraEnabled public List<sObject> records {get; set;}
        @AuraEnabled public String childSObjectName {get; set;}
        @AuraEnabled public String childSObjectLabel {get; set;}
    }
    
    public class Field{
        public String label {get; set;}
        public String fieldName {get; set;} 
        public String type {get; set;}
        public boolean editable {get; set;}
        public String relationshipIdField {get; set;}
        public String relationship {get; set;}
        public TypeAttribute typeAttributes {get; set;}
        
        public Field(Schema.FieldSetMember fsm, Map<String, Schema.SObjectField> fieldMap){
            this.label = fsm.getLabel();
            this.fieldName = fsm.getFieldPath();
            Schema.DescribeFieldResult dfr = fieldMap.get(this.fieldName.toLowerCase()).getDescribe();
            this.editable = dfr.isCreateable();
            if(dfr.isNillable()){
                typeAttributes = new TypeAttribute();
                typeAttributes.required = true;
            }
            
            this.type = FIELD_SET_TO_DATA_TABLE_MAP.get(fsm.getType());
            if(String.isEmpty(this.Type)){
                this.type ='text';
            }
            
            if(!String.isEmpty(dfr.getRelationshipName())){
                this.relationshipIdField = this.fieldName;
                this.relationship = dfr.getRelationshipName();
                this.fieldName = this.relationship + '.Name';

                if(this.editable){
                    this.type = 'button';
                    if(this.typeAttributes == null){
                        this.typeAttributes = new TypeAttribute();
                    }
                    this.typeAttributes.label = new TypeLabel();
                    this.typeAttributes.label.fieldName = this.relationship + '.Name';
                    this.typeAttributes.name = 'edit_lookup_' + this.relationshipIdField;
                    this.typeAttributes.iconName = 'utility:edit';
                }
            }
        }
    }
    
    public class TypeAttribute{
        public boolean required {get; set;}
        public TypeLabel label {get; set;}
        public String name {get; set;}
        public String iconName {get; set;}
    }
        
    public class TypeLabel{
        public String fieldName {get; set;}
    }
}