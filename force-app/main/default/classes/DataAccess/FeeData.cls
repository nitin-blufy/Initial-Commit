public class FeeData extends Entity{
    private Boolean isAccessible;
    public FeeData(){
        isAccessible = true;
    }
    public Fee getById(String sId){
        if (isAccessible){
            Fee fe = new Fee();
            for(Fee__c fee: [SELECT Id, Name, Type__c, Frequency__c, Amount__c, Schedule__c, Units__c   
                            FROM Fee__c WHERE ID =: sId])
            {
                fe.Id  = fee.ID;
                fe.Name = fee.Name;
                fe.Type  = fee.Type__c;
                fe.Frequency = fee.Frequency__c;  
                fe.Amount = fee.Amount__c;
                fe.Schedule  = fee.Schedule__c;  
                fe.Units  = fee.Units__c;   
            }
            return fe;
        }
        else{
            return null;
        }        
    }

}