/*
	Name			:	PaymentTriggerHelper;
	Date			:	04/20/2020
	Author			:	Arpit vijayvergiya
	Description		:

*/
public class PaymentTriggerHelper {
    public static void amountRollUpOnInvoice(Set<String> invIds){
        Map<String,Decimal> mapOfInvAmount = new Map<String,Decimal>();
        List<Invoice__c> invoiceList = new List<Invoice__c>();
        for(AggregateResult result : [SELECT SUM(AMOUNT__C) totalAmount,Type__c,Invoice__c FROM Payment__c WHERE Invoice__c IN: invIds 
                                      AND Type__c != NULL AND Status__c IN ('paid','Success')  GROUP BY Invoice__c, Type__c]){
            String invId = (String)result.get('educato__Invoice__c');
        	String type = (String)result.get('educato__Type__c');
                                          System.debug('type '+type);
            Decimal amount = (Decimal)result.get('totalAmount');
        	string key =  type== 'Refund' ? invId+'-Refund' : invId+'-Paid';
                                          System.debug('key '+key);
            Decimal finalAmount =  mapOfInvAmount.containsKey(key) ? mapOfInvAmount.get(key)+amount : amount; 
          	mapOfInvAmount.put(key,finalAmount);                                
        }
        
        for(String invId : invIds){
            Invoice__c objInv = new Invoice__c(Id= invId);
            Decimal  refundAmount = mapOfInvAmount.containsKey(invId+'-Refund') ? mapOfInvAmount.get(invId+'-Refund'): 0;
            Decimal paidAmount = mapOfInvAmount.containsKey(invId+'-Paid') ? mapOfInvAmount.get(invId+'-Paid'): 0;
            objInv.put('Total_Paid_Amount__c',paidAmount);
            objInv.put('Total_Refund_Amount__c',refundAmount);
            System.debug('objInv '+objInv);
            invoiceList.add(objInv); 
        }
        
        if(invoiceList.size() > 0){
            update invoiceList;
        }
        
    }
}