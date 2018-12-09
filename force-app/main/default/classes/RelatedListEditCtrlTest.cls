/**
 * Test class for the RelatedLiustEditCtrl
 * @author James Loghry / Demand Chain
 * @date 12/8/2018
 */
@isTest
private class RelatedListEditCtrlTest{
    
    static testmethod void testQueryRelatedRecords(){
        
        insertTestData();
        
        Test.startTest();
        Account a = [Select Id From Account];
        LightningResponse resp = RelatedListEditCtrl.queryRelatedRecords(a.Id,'Contacts','Related_List_Test');
        Test.stopTest();
        
        RelatedListEditCtrl.QueryResponse qr = (RelatedListEditCtrl.QueryResponse)JSON.deserialize(resp.jsonResponse,RelatedListEditCtrl.QueryResponse.class);
        System.assertEquals(600,qr.records.size());
        System.assertNotEquals(0,qr.fields.size());
    }
    
    static testmethod void testDeleteRecords(){
        
        insertTestData();
        
        Test.startTest();
        List<Contact> cl = [Select Id From Contact];
        String records = JSON.serialize(cl);
        LightningResponse resp = RelatedListEditCtrl.deleteRecords(records);
        Test.stopTest();
        
        System.assertEquals(0,[Select Id From Contact].size());
    }
    
    static testmethod void testCloneRecords(){
        
        insertTestData();
        
        Test.startTest();
        
        Account a = [Select Id From Account];
        
        List<Contact> contacts = new List<Contact>();
        for(Integer i=0; i < 600; i++){
            contacts.add(
                new Contact(
                    AccountId=a.Id,
                    Firstname='First'+i,
                    Lastname='Last'+i,
                    Email='email'+i+'@gmail.com'
                )
            );
        }
        
        String records = JSON.serialize(contacts);
        LightningResponse resp = RelatedListEditCtrl.cloneRecords(records);
        Test.stopTest();
        
        System.assertEquals(1200,[Select Id From Contact].size());
    }
    
    static testmethod void testUpdateRecords(){
        
        insertTestData();
        
        Test.startTest();
        List<Contact> cl = [Select Firstname From Contact];
        for(Contact c : cl){
            c.Firstname = 'Bubba';
        }
        String records = JSON.serialize(cl);
        LightningResponse resp = RelatedListEditCtrl.updateRecords(records);
        Test.stopTest();
        
        System.assertEquals(600,[Select Id From Contact Where Firstname='Bubba'].size());
    }
    
    private static void insertTestData(){
        Account a = new Account(Name='ACME');
        insert a;
        
        List<Contact> contacts = new List<Contact>();
        for(Integer i=0; i < 600; i++){
            contacts.add(
                new Contact(
                    AccountId=a.Id,
                    Firstname='First'+i,
                    Lastname='Last'+i,
                    Email='email'+i+'@gmail.com'
                )
            );
        }
        insert contacts;
    }
}