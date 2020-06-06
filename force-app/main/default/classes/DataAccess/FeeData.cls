public class FeeData extends Entity{
    private Boolean isAccessible;
    public FeeData(){
        isAccessible = true;
    }
    public List<Fee> getById(String sId){
        List<Fee> lsFee = new List<Fee>();
        if (isAccessible){
            Course cr = new Course();
            for(Course_Fee__c crFee: [SELECT Id, Name, Fee__c, Fee__r.Name, Fee__r.Amount__c, Fee__r.Unit_Price__c, Fee__r.Schedule__c, Fee__r.Units__c, Fee__r.Type__c, Fee__r.Frequency__c, Fee__r.Required__c, Fee__r.Override__c
                                      FROM Course_Fee__c WHERE Course__c =: sId AND Fee__r.Amount__c != null AND Fee__r.Type__c != null])
            {
                Fee fe = new Fee();
                fe.Id  = crFee.Fee__c;
                fe.Name = crFee.Fee__r.Name;
                fe.Type  = crFee.Fee__r.Type__c;
                fe.Frequency = crFee.Fee__r.Frequency__c;  
                fe.Amount = crFee.Fee__r.Amount__c;
                fe.Schedule  = crFee.Fee__r.Schedule__c;  
                fe.Units  = crFee.Fee__r.Units__c != null ? Integer.valueOf(crFee.Fee__r.Units__c):0;   
                lsFee.add(fe);
            }
            return lsFee;
        }
        else{
            return null;
        }        
    }

}